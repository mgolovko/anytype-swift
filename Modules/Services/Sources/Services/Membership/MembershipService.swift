import ProtobufMessages
import Foundation
import AnytypeCore
import StoreKit


public typealias MiddlewareMemberhsipStatus = Anytype_Model_Membership

enum MembershipServiceError: Error {
    case tierNotFound
}


public protocol MembershipServiceProtocol {
    func getMembership() async throws -> MembershipStatus
    func makeMembershipFromMiddlewareModel(membership: MiddlewareMemberhsipStatus) async throws -> MembershipStatus
    
    func getTiers(noCache: Bool) async throws -> [MembershipTier]
    func dropTiersCache() async throws
    
    
    func getVerificationEmail(data: EmailVerificationData) async throws
    func verifyEmailCode(code: String) async throws
    
    typealias ValidateNameError = Anytype_Rpc.Membership.IsNameValid.Response.Error
    func validateName(name: String, tierType: MembershipTierType) async throws
}

public extension MembershipServiceProtocol {
    func getTiers() async throws -> [MembershipTier] {
        try await getTiers(noCache: false)
    }
}

final class MembershipService: MembershipServiceProtocol {
    
    public func getMembership() async throws -> MembershipStatus {
        let status = try await ClientCommands.membershipGetStatus().invoke().data
        return try await makeMembershipFromMiddlewareModel(membership: status)
    }
    
    public func makeMembershipFromMiddlewareModel(membership: MiddlewareMemberhsipStatus) async throws -> MembershipStatus {
        let tier = try await getTiers().first { $0.type.id == membership.tier }
        
        if tier == nil, membership.tier != 0 {
            anytypeAssertionFailure("Not found tier info for \(membership)")
            throw MembershipServiceError.tierNotFound
        }
        
        return convertMiddlewareMembership(membership: membership, tier: tier)
    }
    
    public func getTiers(noCache: Bool) async throws -> [MembershipTier] {
        return try await ClientCommands.membershipGetTiers(.with {
            $0.locale = Locale.current.languageCode ?? "en"
            $0.noCache = noCache
        })
        .invoke().tiers
        .filter { FeatureFlags.membershipTestTiers || !$0.isTest }
        .asyncMap { await buildMemberhsipTier(tier: $0) }.compactMap { $0 }
    }
    
    func dropTiersCache() async throws {
        _ = try await getTiers(noCache: true)
    }
    
    public func getVerificationEmail(data: EmailVerificationData) async throws {
        try await ClientCommands.membershipGetVerificationEmail(.with {
            $0.email = data.email
            $0.subscribeToNewsletter = data.subscribeToNewsletter
        }).invoke()
    }
    
    public func verifyEmailCode(code: String) async throws {
        try await ClientCommands.membershipVerifyEmailCode(.with {
            $0.code = code
        }).invoke(ignoreLogErrors: .wrong)
    }
    
    public func validateName(name: String, tierType: MembershipTierType) async throws {
        try await ClientCommands.membershipIsNameValid(.with {
            $0.nsName = name
            $0.nsNameType = .anyName
            $0.requestedTier = tierType.id
        }).invoke(ignoreLogErrors: .hasInvalidChars, .tooLong, .tooShort)
    }
    
    // MARK: - Private
    private func convertMiddlewareMembership(membership: MiddlewareMemberhsipStatus, tier: MembershipTier?) -> MembershipStatus {
        if let tier {
            anytypeAssert(tier.type.id == membership.tier, "\(tier) and \(membership) does not match an id")
        }
        
        return MembershipStatus(
            tier: tier,
            status: membership.status,
            dateEnds: Date(timeIntervalSince1970: TimeInterval(membership.dateEnds)),
            paymentMethod: membership.paymentMethod,
            anyName: AnyName(handle: membership.nsName, extension: membership.nsNameType)
        )
    }

    private func buildMemberhsipTier(tier: Anytype_Model_MembershipTierData) async -> MembershipTier? {
        guard let type = MembershipTierType(intId: tier.id) else { return nil } // ignore 0 tier
        guard let paymentType = await buildMembershipPaymentType(type: type, tier: tier) else { return nil }
        
        let anyName: MembershipAnyName = tier.anyNamesCountIncluded > 0 ? .some(minLenght: tier.anyNameMinLength) : .none
        
        return MembershipTier(
            type: type,
            name: tier.name,
            anyName: anyName,
            features: tier.features,
            paymentType: paymentType,
            color: MembershipColor(string: tier.colorStr)
        )
    }
    
    private func buildMembershipPaymentType(
        type: MembershipTierType,
        tier: Anytype_Model_MembershipTierData
    ) async -> MembershipTierPaymentType? {
        guard type != .explorer else { return .email }
        
        if tier.iosProductID.isNotEmpty {
            do {
                let product = try await Product.products(for: [tier.iosProductID])
                guard let product = product.first else {
                    anytypeAssertionFailure("Not found product for id \(tier.iosProductID)")
                    return nil
                }
                
                return .appStore(product: product)
            } catch {
                anytypeAssertionFailure("Get products error", info: ["error": error.localizedDescription])
                return nil
            }
        } else {
            let info = StripePaymentInfo(
                periodType: tier.periodType,
                periodValue: tier.periodValue,
                priceInCents: tier.priceStripeUsdCents,
                paymentUrl: URL(string: tier.iosManageURL) ?? URL(string: "https://anytype.io/pricing")!
            )
            return .external(info: info)
        }
    }
}
