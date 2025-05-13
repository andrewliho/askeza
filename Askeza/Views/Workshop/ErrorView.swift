import SwiftUI

struct ErrorView: View {
    let message: String
    let icon: String
    let action: (() -> Void)?
    
    init(
        message: String,
        icon: String = "exclamationmark.triangle",
        action: (() -> Void)? = nil
    ) {
        self.message = message
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(AskezaTheme.secondaryTextColor)
            
            Text(message)
                .font(.headline)
                .foregroundColor(AskezaTheme.textColor)
                .multilineTextAlignment(.center)
            
            if let action = action {
                Button("Повторить") {
                    action()
                }
                .foregroundColor(AskezaTheme.accentColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(AskezaTheme.buttonBackground)
                .cornerRadius(10)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(AskezaTheme.backgroundColor)
    }
}

#Preview {
    ErrorView(
        message: "Не удалось загрузить шаблоны практик",
        action: {}
    )
} 