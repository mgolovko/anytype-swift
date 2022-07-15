struct SetFilterRowConfiguration: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String?
    let iconName: String
    let relation: Relation
    let hasValues: Bool
    @EquatableNoop var onTap: () -> Void
}