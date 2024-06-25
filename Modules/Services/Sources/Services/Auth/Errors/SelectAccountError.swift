import Foundation
import ProtobufMessages

public enum SelectAccountError: Error {
    case accountIsDeleted
    case failedToFetchRemoteNodeHasIncompatibleProtoVersion
    case accountLoadIsCanceled
}

extension Anytype_Rpc.Account.Select.Response.Error {
    var asError: SelectAccountError? {
        switch code {
        case .accountIsDeleted:
            return .accountIsDeleted
        case .failedToFetchRemoteNodeHasIncompatibleProtoVersion:
            return .failedToFetchRemoteNodeHasIncompatibleProtoVersion
        case .accountLoadIsCanceled:
            return .accountLoadIsCanceled
        default:
            return nil
        }
    }
}
