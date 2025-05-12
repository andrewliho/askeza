import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authModel: AuthenticationViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(AskezaTheme.accentColor)
                .padding(.top, 40)
            
            if let user = authModel.user {
                if let fullName = user.fullName {
                    Text(fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                if let email = user.email {
                    Text(email)
                        .font(.subheadline)
                }
            }
            
            Spacer()
            
            Button(action: {
                authModel.signOut()
            }) {
                Text("Выйти")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AskezaTheme.errorColor)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AskezaTheme.backgroundColor)
        .foregroundColor(AskezaTheme.textColor)
        .navigationTitle("Профиль")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject({
                let viewModel = AuthenticationViewModel()
                viewModel.user = User(id: "123", email: "test@example.com", firstName: "Иван", lastName: "Иванов")
                return viewModel
            }())
    }
} 