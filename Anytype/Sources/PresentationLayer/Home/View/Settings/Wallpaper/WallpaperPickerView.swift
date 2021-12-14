import SwiftUI
import AnytypeCore

struct WallpaperPickerView: View {
    @EnvironmentObject var model: SettingsViewModel
    
    var body: some View {
        Group {
            DragIndicator()
            AnytypeText(
                "Change wallpaper".localized,
                style: .uxTitle1Semibold,
                color: .textPrimary
            )
                .multilineTextAlignment(.center)
            WallpaperColorsGridView() { background in
                model.wallpaper = background
                model.wallpaperPicker = false
            }
        }
        .background(Color.backgroundSecondary)
    }
}

struct WallpaperPickerView_Previews: PreviewProvider {
    static var previews: some View {
        WallpaperPickerView()
    }
}
