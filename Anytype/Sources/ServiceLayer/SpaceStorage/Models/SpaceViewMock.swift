import Services

extension SpaceView {
    static func mock(id: Int) -> SpaceView {
        mock(id: "\(id)")
    }
    
    static func mock(id: String) -> SpaceView {
        SpaceView(
            id: id,
            name: "Name \(id)",
            objectIconImage: .object(.space(.mock)),
            targetSpaceId: "Target\(id)",
            createdDate: .yesterday,
            accountStatus: .ok,
            localStatus: .ok,
            spaceAccessType: .private,
            readersLimit: nil,
            writersLimit: nil,
            sharedSpacesLimit: nil,
            chatId: nil
        )
    }
}

public extension ObjectIcon.Space {
    static var mock: ObjectIcon.Space {
        .name(name: Loc.Object.Title.placeholder, iconOption: 1)
    }
}
