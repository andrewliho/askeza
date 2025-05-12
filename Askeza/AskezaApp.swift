//
//  AskezaApp.swift
//  Askeza
//
//  Created by LIHØ on 02.05.2023.
//

import SwiftUI
import OSLog

@main
struct AskezaApp: App {
    @StateObject private var viewModel = AskezaViewModel()
    // Временно отключено до оформления Apple Developer Program
    // @StateObject private var authModel = AuthenticationViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @State private var progressCheckTimer: Timer?
    @State private var midnightCheckTimer: Timer?
    @State private var currentDay = Calendar.current.component(.day, from: Date())
    @State private var isFirstLaunch = true
    
    // Создаем логгер для отладки
    private let logger = Logger(subsystem: "com.liho.askeza", category: "AppLifecycle")
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(viewModel)
                // Временно отключено до оформления Apple Developer Program
                // .environmentObject(authModel)
                .preferredColorScheme(.dark)
                .onAppear {
                    if isFirstLaunch {
                        logger.debug("🚀 App did launch")
                        isFirstLaunch = false
                        
                        // Инициализируем шаблоны аскез при первом запуске
                        let templateStore = PracticeTemplateStore.shared
                        AdditionalTemplates.addTemplates(to: templateStore)
                        logger.debug("📋 Templates added to store")
                    }
                    
                    // Мы можем настроить таймеры для проверки и обновления состояния аскез
                    progressCheckTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                        Task { @MainActor in
                            self.viewModel.updateAskezaStates()
                        }
                    }
                    
                    // Проверка смены дня
                    midnightCheckTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                        Task { @MainActor in
                            self.checkDayChange()
                        }
                    }
                    
                    // Чтобы обеспечить согласованность, давайте проверим состояние при запуске приложения
                    Task { @MainActor in
                        viewModel.updateAskezaStates()
                    }
                }
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    if newPhase == .active {
                        logger.debug("🏃‍♂️ App became active")
                        Task { @MainActor in
                            viewModel.updateAskezaStates()
                        }
                    } else if newPhase == .inactive {
                        logger.debug("⏸ App became inactive")
                    } else if newPhase == .background {
                        logger.debug("🔙 App entered background")
                    }
                }
        }
    }
    
    @MainActor
    private func checkDayChange() {
        let today = Calendar.current.component(.day, from: Date())
        if today != currentDay {
            currentDay = today
            logger.debug("📅 Day changed to \(today), updating askeza states")
            viewModel.updateAskezaStates()
        }
    }
}

// MARK: - App Configuration
extension Bundle {
    static func configureApp() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            UserDefaults.standard.set("Аскеза", forKey: "\(bundleIdentifier).displayName")
        }
    }
}

