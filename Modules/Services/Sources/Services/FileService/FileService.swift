import Foundation
import ProtobufMessages
import AnytypeCore

public protocol FileServiceProtocol: AnyObject {
    func uploadFileBlock(path: String, contextID: BlockId, blockID: BlockId) async throws
    func uploadFileObject(path: String, spaceId: String) async throws -> String
    func clearCache() async throws
    func nodeUsage() async throws -> NodeUsageInfo
}

public final class FileService: FileServiceProtocol {
    
    public init() {}
    
    // MARK: - FileServiceProtocol
    
    public func uploadFileBlock(path: String, contextID: BlockId, blockID: BlockId) async throws {
        try await ClientCommands.blockUpload(.with {
            $0.contextID = contextID
            $0.blockID = blockID
            $0.filePath = path
        }).invoke()
    }
    
    public func uploadFileObject(path: String, spaceId: String) async throws -> String {
        let result = try await ClientCommands.fileUpload(.with {
            $0.localPath = path
            $0.disableEncryption = false
            $0.style = .auto
            $0.spaceID = spaceId
            // TODO: Add origin
        }).invoke()
        return result.objectID
    }
    
    public func clearCache() async throws {
        try await ClientCommands.fileListOffload(.with {
            $0.includeNotPinned = false
        }).invoke()
    }
    
    public func nodeUsage() async throws -> NodeUsageInfo {
        let result = try await ClientCommands.fileNodeUsage().invoke()
        return NodeUsageInfo(from: result)
    }
}
