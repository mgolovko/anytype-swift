import Foundation
import Combine
import Services
import ProtobufMessages
import AnytypeCore
import UniformTypeIdentifiers
import PhotosUI
import SwiftUI

final class FileActionsService: FileActionsServiceProtocol {
    
    private enum FileServiceError: Error {
        case undefiled
    }
    
    private enum Constants {
        static let filesDirectory = "fileServiceCache"
        static let supportedUploadedTypes: [UTType] = [
            // We are don't support heic and other platform specific types
            // Picture
            UTType.image,
            UTType.ico,
            UTType.icns,
            UTType.png,
            UTType.jpeg,
            UTType.webP,
            UTType.tiff,
            UTType.bmp,
            UTType.svg,
            UTType.rawImage,
            // Video
            UTType.movie,
            UTType.video,
            UTType.quickTimeMovie,
            UTType.mpeg,
            UTType.mpeg2Video,
            UTType.mpeg2TransportStream,
            UTType.mpeg4Movie,
            UTType.appleProtectedMPEG4Video,
            UTType.avi,
            // Audio
            UTType.audio,
            // Other Files
            UTType.item
        ]
    }
    
    // Clear file cache once for app launch
    private static var cacheCleared: Bool = false
    @Injected(\.fileService)
    private var fileService: any FileServiceProtocol
    
    init() {
        if !FileActionsService.cacheCleared {
            clearFileCache()
            FileActionsService.cacheCleared = true
        }
    }
    
    func createFileData(source: FileUploadingSource) async throws -> FileData {
        switch source {
        case .path(let path):
            return FileData(path: path, type: .data, isTemporary: false)
        case .itemProvider(let itemProvider):
            let typeIdentifier = itemProvider.registeredTypeIdentifiers.compactMap { typeId in
                Constants.supportedUploadedTypes.first { $0.identifier == typeId }
            }.first
            guard let typeIdentifier else {
                throw FileServiceError.undefiled
            }
            let url = try await itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier.identifier, directory: tempDirectoryPath())
            return FileData(path: url.relativePath, type: typeIdentifier, isTemporary: true)
        }
    }
 
    func createFileData(photoItem: PhotosPickerItem) async throws -> FileData {
        do {
            let typeIdentifier = photoItem.supportedContentTypes.first {
                Constants.supportedUploadedTypes.contains($0)
            }
            guard let typeIdentifier else {
                throw FileServiceError.undefiled
            }
            guard let data = try await photoItem.loadTransferable(type: MediaFileUrl.self) else {
                throw FileServiceError.undefiled
            }
            let newPath = tempDirectoryPath().appendingPathComponent(UUID().uuidString, isDirectory: true)
            try FileManager.default.createDirectory(at: newPath, withIntermediateDirectories: false)
            
            let newFilePath = newPath.appendingPathComponent(data.url.lastPathComponent, isDirectory: false)
            try FileManager.default.moveItem(at: data.url, to: newFilePath)
            
            return FileData(path: newFilePath.relativePath, type: typeIdentifier, isTemporary: true)
        } catch {
            anytypeAssertionFailure(error.localizedDescription)
            throw error
        }
    }
    
    func createFileData(fileUrl: URL) throws -> FileData {
        do {
            let newPath = tempDirectoryPath().appendingPathComponent(UUID().uuidString, isDirectory: true)
            try FileManager.default.createDirectory(at: newPath, withIntermediateDirectories: false)
            
            let newFilePath = newPath.appendingPathComponent(fileUrl.lastPathComponent, isDirectory: false)
            try FileManager.default.copyItem(at: fileUrl, to: newFilePath)
            
            return FileData(path: newFilePath.relativePath, type: getUTType(for: newFilePath) ?? .data, isTemporary: true)
        } catch {
            anytypeAssertionFailure(error.localizedDescription)
            throw error
        }
    }
    
    func uploadDataAt(data: FileData, contextID: String, blockID: String) async throws {
        defer {
            if data.isTemporary {
                try? FileManager.default.removeItem(atPath: data.path)
            }
        }
        try await fileService.uploadFileBlock(path: data.path, contextID: contextID, blockID: blockID)
    }
    
    func uploadFileObject(spaceId: String, data: FileData, origin: ObjectOrigin) async throws -> FileDetails {
        defer {
            if data.isTemporary {
                try? FileManager.default.removeItem(atPath: data.path)
            }
        }
        
        return try await fileService.uploadFileObject(path: data.path, spaceId: spaceId, origin: origin)
    }
    
    func uploadDataAt(source: FileUploadingSource, contextID: String, blockID: String) async throws {
        let data = try await createFileData(source: source)
        try await uploadDataAt(data: data, contextID: contextID, blockID: blockID)
    }
    
    func uploadImage(spaceId: String, source: FileUploadingSource, origin: ObjectOrigin) async throws -> FileDetails {
        let data = try await createFileData(source: source)
        return try await uploadFileObject(spaceId: spaceId, data: data, origin: origin)
    }
    
    func clearCache() async throws {
        try await fileService.clearCache()
    }
    
    func nodeUsage() async throws -> NodeUsageInfo {
        return try await fileService.nodeUsage()
    }
    
    // MARK: - Private
    
    private func tempDirectoryPath() -> URL {
        return FileManager.default.temporaryDirectory.appendingPathComponent(Constants.filesDirectory, isDirectory: true)
    }
    
    private func clearFileCache() {
        
        let fileManager = FileManager.default
        
        guard let paths = try? fileManager.contentsOfDirectory(at: tempDirectoryPath(), includingPropertiesForKeys: nil) else { return }
        
        for path in paths {
            try? fileManager.removeItem(at: path)
        }
    }
    
    private func getUTType(for fileURL: URL) -> UTType? {
        do {
            let resourceValues = try fileURL.resourceValues(forKeys: [.typeIdentifierKey])
            if let typeIdentifier = resourceValues.typeIdentifier {
                return UTType(typeIdentifier)
            }
        } catch {}
        
        return nil
    }

}
