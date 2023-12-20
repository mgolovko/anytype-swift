import Services

struct EmbedBlockContent: Hashable {
    let url: String
}

struct EmbedBlockConfiguration: BlockConfiguration {
    typealias View = EmbedBlockView

    let content: EmbedBlockContent
}
