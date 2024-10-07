import Services
import Combine
import AnytypeCore
import Foundation
import PhotosUI
import SwiftUI

enum FileUploadingSource {
    case path(String)
    case itemProvider(NSItemProvider)
}

struct FileData {
    let path: String
    let type: UTType
    let isTemporary: Bool
}

protocol FileActionsServiceProtocol {
    
    func createFileData(source: FileUploadingSource) async throws -> FileData
    func createFileData(photoItem: PhotosPickerItem) async throws -> FileData
    
    func uploadDataAt(data: FileData, contextID: String, blockID: String) async throws
    func uploadFileObject(spaceId: String, data: FileData, origin: ObjectOrigin) async throws -> FileDetails
    
    func uploadDataAt(source: FileUploadingSource, contextID: String, blockID: String) async throws
    func uploadImage(spaceId: String, source: FileUploadingSource, origin: ObjectOrigin) async throws -> FileDetails
    
    func nodeUsage() async throws -> NodeUsageInfo
    
    func clearCache() async throws
}
