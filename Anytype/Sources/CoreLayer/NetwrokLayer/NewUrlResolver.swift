//
//  NewUrlResolver.swift
//  Anytype
//
//  Created by Konstantin Mordan on 21.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

final class NewUrlResolver {
    
    static let shared = NewUrlResolver()
    
    private let configurationService = MiddlewareConfigurationService.shared
    
}

extension NewUrlResolver {
    
    func resolvedUrl(_ urlType: UrlType) -> URL? {
        guard let gatewayUrl = configurationService.configuration?.gatewayURL else {
            assertionFailure("Configuration must be loaded")
            return nil
        }
        
        guard let components = URLComponents(string: gatewayUrl) else {
            return nil
        }
        
        switch urlType {
        case let .file(id):
            return makeFileUrl(initialComponents: components, fileId: id)
        case let .image(id, width):
            return makeImageUrl(initialComponents: components, imageId: id, width: width)
        }
    }
    
    
    func makeFileUrl(initialComponents: URLComponents, fileId: String) -> URL? {
        guard !fileId.isEmpty else { return nil }
        
        var components = initialComponents
        components.path = "\(Constants.fileSubPath)/\(fileId)"
        
        return components.url
    }
    
    func makeImageUrl(initialComponents: URLComponents, imageId: String, width: ImageWidth) -> URL? {
        guard !imageId.isEmpty else { return nil }
        
        var components = initialComponents
        components.path = "\(Constants.imageSubPath)/\(imageId)"
        components.queryItems = [
            URLQueryItem(name: "width", value: width.rawValue)
        ]
        
        return components.url
    }
    
}

extension NewUrlResolver {
    
    enum UrlType {
        case file(id: String)
        case image(id: String, width: ImageWidth)
    }
    
    enum ImageWidth: String {
        case `default` = "1080"
        case thumbnail = "100"
    }
    
}

private extension NewUrlResolver {
    
    enum Constants {
        static let imageSubPath = "/image"
        static let fileSubPath = "/file"
    }
    
}
