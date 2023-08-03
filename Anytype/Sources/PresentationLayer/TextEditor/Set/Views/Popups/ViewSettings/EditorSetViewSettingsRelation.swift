struct EditorSetViewSettingsRelation: Identifiable {
    let id: String
    let image: ImageAsset
    let title: String
    let isOn: Bool
    let canBeRemovedFromObject: Bool
    @EquatableNoop var onChange: (Bool) -> Void
}
