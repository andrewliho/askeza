import SwiftUI

struct AskezaTheme {
    // MARK: - Colors
    static let backgroundColor = Color("BackgroundColor")
    static let textColor = Color.white
    static let secondaryTextColor = Color(white: 0.7)
    static let accentColor = Color("AccentColor")
    static let intentColor = Color("IntentColor") // Бронзовый для интенций и "Своя аскеза"
    static let buttonBackground = Color("ButtonBackground")
    static let successColor = Color(red: 0.4, green: 0.8, blue: 0.6) // Пастельный зеленый
    static let errorColor = Color(red: 0.9, green: 0.6, blue: 0.6) // Пастельный красный
    static let warningColor = Color(red: 0.95, green: 0.8, blue: 0.5) // Пастельный оранжевый
    
    // MARK: - Fonts
    static let titleFont = Font.system(size: 24, weight: .bold)
    static let subtitleFont = Font.system(size: 20, weight: .semibold)
    static let bodyFont = Font.system(size: 16, weight: .regular)
    static let captionFont = Font.system(size: 14, weight: .regular)
    
    // MARK: - Dimensions
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    
    // MARK: - Animation
    static let defaultAnimation = Animation.easeInOut(duration: 0.3)
}

// MARK: - Category Colors
extension AskezaCategory {
}

public struct ShadowModifier: ViewModifier {
    public init() {}
    
    public func body(content: Content) -> some View {
        content
        // Временно отключаем тени для устранения проблем со сборкой
        // .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

public extension View {
    func askezaShadow() -> some View {
        modifier(ShadowModifier())
    }
}

public struct AskezaButton: View {
    let title: String
    let action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(AskezaTheme.bodyFont)
                .foregroundColor(AskezaTheme.accentColor)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AskezaTheme.buttonBackground)
                .cornerRadius(12)
                .askezaShadow()
        }
    }
}

public struct AskezaTextField: View {
    let placeholder: String
    @Binding var text: String
    
    public init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    public var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(PlainTextFieldStyle())
            .font(AskezaTheme.bodyFont)
            .foregroundColor(AskezaTheme.textColor)
            .padding()
            .background(AskezaTheme.buttonBackground)
            .cornerRadius(12)
            .askezaShadow()
    }
}

public struct AskezaProgressBar: View {
    let progress: Double
    
    public init(progress: Double) {
        self.progress = progress
    }
    
    public var body: some View {
        // Временно упрощаем для отладки
        Rectangle()
            .fill(AskezaTheme.accentColor)
            .frame(height: 12)
            .cornerRadius(6)
    }
}

public struct AskezaToast: ViewModifier {
    let message: String
    @Binding var isPresented: Bool
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                VStack {
                    Spacer()
                    
                    Text(message)
                        .font(AskezaTheme.bodyFont)
                        .foregroundColor(AskezaTheme.textColor)
                        .padding()
                        .background(AskezaTheme.buttonBackground)
                        .cornerRadius(12)
                        .askezaShadow()
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}

public extension View {
    func askezaToast(message: String, isPresented: Binding<Bool>) -> some View {
        modifier(AskezaToast(message: message, isPresented: isPresented))
    }
} 