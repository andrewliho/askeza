import Foundation
import SwiftUI
import AuthenticationServices

class AuthenticationViewModel: NSObject, ObservableObject {
    @Published var user: User?
    @Published var isAuthenticating = false
    @Published var error: Error?
    
    private let userDefaultsKey = "authenticatedUser"
    private var currentNonce: String?
    
    override init() {
        super.init()
        loadSavedUser()
    }
    
    func loadSavedUser() {
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let savedUser = try? JSONDecoder().decode(User.self, from: userData) {
            self.user = savedUser
            print("Загружен пользователь: \(savedUser.id)")
        }
    }
    
    func saveUser(_ user: User) {
        self.user = user
        if let encodedData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
            print("Сохранен пользователь: \(user.id)")
        }
    }
    
    func signOut() {
        user = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        print("Пользователь вышел из системы")
    }
    
    func signInWithApple() {
        isAuthenticating = true
        error = nil
        
        let nonce = String.randomNonceString()
        currentNonce = nonce
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonce.sha256
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AuthenticationViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            isAuthenticating = false
            error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ошибка аутентификации: неверные учетные данные"])
            return
        }
        
        guard let nonceString = currentNonce, !nonceString.isEmpty else {
            isAuthenticating = false
            error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ошибка аутентификации: недействительное состояние"])
            return
        }
        
        guard let identityToken = appleIDCredential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8),
              !tokenString.isEmpty else {
            isAuthenticating = false
            error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ошибка аутентификации: невозможно декодировать токен"])
            return
        }
        
        // Можно использовать nonceString и tokenString для проверки в бэкенде, если нужно
        print("Авторизация через Apple: получен токен длиной \(tokenString.count) символов")
        
        let userId = appleIDCredential.user
        let email = appleIDCredential.email
        let firstName = appleIDCredential.fullName?.givenName
        let lastName = appleIDCredential.fullName?.familyName
        
        let user = User(id: userId, email: email, firstName: firstName, lastName: lastName)
        
        // Сохраняем пользователя в UserDefaults
        saveUser(user)
        
        isAuthenticating = false
        print("Успешная авторизация: \(user.id)")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        isAuthenticating = false
        self.error = error
        print("Ошибка авторизации: \(error.localizedDescription)")
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AuthenticationViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if #available(iOS 15.0, *) {
            // Используем новый подход для iOS 15+
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else {
                // Если не можем найти окно через UIWindowScene, создаем новое окно
                return UIWindow()
            }
            return window
        } else {
            // Старый подход для iOS до 15
            // Создаем функцию, которая будет использоваться только для совместимости
            // Компилятор не будет выдавать предупреждение, так как мы явно указываем,
            // что код выполняется только на старых версиях iOS
            func legacyKeyWindow() -> UIWindow? {
                return UIApplication.shared.windows.first { $0.isKeyWindow }
            }
            return legacyKeyWindow() ?? UIWindow()
        }
    }
} 