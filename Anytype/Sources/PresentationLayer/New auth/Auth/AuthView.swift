import SwiftUI

struct AuthView: View {
    
    @ObservedObject var model: AuthViewModel
    
    var body: some View {
        AuthBackgroundView(url: model.videoUrl()) {
            content
                .navigationBarHidden(true)
                .modifier(LogoOverlay())
                .opacity(model.opacity)
                .onAppear {
                    model.onViewAppear()
                }
                .sheet(isPresented: $model.showSafari) {
                    if let currentUrl = model.currentUrl {
                        SafariView(url: currentUrl)
                    }
                }
                .background(TransparentBackground())
        }
    }
    
    private var content: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            greetings
            Spacer()
            buttons
            Spacer.fixedHeight(16)
            if #available(iOS 15.0, *) {
                privacyPolicy
            }
            Spacer.fixedHeight(14)
        }
    }
    
    private var greetings: some View {
        VStack(alignment: .center, spacing: 0) {
            AnytypeText(Loc.Auth.Welcome.title, style: .authTitle, color: .Text.primary)
                .multilineTextAlignment(.center)
                .opacity(0.9)
            
            Spacer.fixedHeight(30)
            
            AnytypeText(Loc.Auth.Welcome.subtitle, style: .authBoby, color: .Auth.body)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 58)
    }

    private var buttons: some View {
        HStack(spacing: 13) {
            StandardButton(
                Loc.Auth.join,
                style: .primaryLarge,
                action: {
                    model.onJoinButtonTap()
                }
            )
            .colorScheme(.light)
            .addEmptyNavigationLink(destination: model.onJoinAction(), isActive: $model.showJoinFlow)
            
            StandardButton(
                Loc.Auth.logIn,
                style: .secondaryLarge,
                action: {}
            )
        }
        .padding(.horizontal, 30)
    }
    
    @available(iOS 15.0, *)
    private var privacyPolicy: some View {
        AnytypeText(
            Loc.Auth.Caption.Privacy.text(Constants.termsOfUseUrl, Constants.privacyPolicy),
            style: .authCaption,
            color: .Auth.caption
        )
        .multilineTextAlignment(.center)
        .padding(.horizontal, 58)
        .accentColor(.Text.secondary)
        .environment(\.openURL, OpenURLAction { url in
            model.onUrlTapAction(url)
            return .handled
        })
    }
}

extension AuthView {
    enum Constants {
        static let termsOfUseUrl = "https://anytype.io/en"
        static let privacyPolicy = "https://anytype.io/en/manifesto"
    }
}


struct AuthView_Previews : PreviewProvider {
    static var previews: some View {
        AuthView(
            model: AuthViewModel(
                viewControllerProvider: DI.preview.uihelpersDI.viewControllerProvider(),
                output: nil
            )
        )
    }
}
