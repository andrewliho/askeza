import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authModel: AuthenticationViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Аскеза")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(AskezaTheme.accentColor)
            
            Text("Войдите в приложение, чтобы сохранять ваш прогресс")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(AskezaTheme.textColor)
            
            Spacer()
            
            if authModel.isAuthenticating {
                ProgressView()
                    .padding()
            } else {
                SignInWithAppleButton(action: {
                    authModel.signInWithApple()
                })
            }
            
            if let error = authModel.error {
                Text(error.localizedDescription)
                    .foregroundColor(AskezaTheme.errorColor)
                    .padding()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AskezaTheme.backgroundColor)
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthenticationViewModel())
    }
} 