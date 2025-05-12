import SwiftUI
import AuthenticationServices

struct SignInWithAppleButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "apple.logo")
                    .font(.title2)
                Text("Войти с Apple")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color.black)
            .cornerRadius(10)
        }
    }
}

struct SignInWithAppleButton_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithAppleButton(action: {})
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
    }
} 