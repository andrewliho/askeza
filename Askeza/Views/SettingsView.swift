import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: AskezaViewModel
    @State private var showingResetAlert = false
    @State private var showingDebugSection = false
    @State private var showingForceUpdateAlert = false
    @State private var tapCount = 0
    @State private var refreshTimer: Timer?
    @State private var lastCheckInfo = ""
    @State private var statsInfo = ""
    
    var body: some View {
        ZStack {
            AskezaTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                List {
                    Section {
                        Button(action: {
                            showingResetAlert = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundColor(.red)
                                Text("Сбросить все данные")
                                    .foregroundColor(.red)
                            }
                        }
                    } footer: {
                        Text("Это действие удалит все аскезы и достижения. Приложение вернется к начальному состоянию.")
                            .font(AskezaTheme.captionFont)
                            .foregroundColor(AskezaTheme.secondaryTextColor)
                    }
                    
                    if showingDebugSection {
                        Section {
                            Button(action: {
                                showingForceUpdateAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "hammer")
                                        .foregroundColor(.blue)
                                    Text("Увеличить все счетчики на 1 день")
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Button(action: {
                                updateDebugInfo()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                        .foregroundColor(.blue)
                                    Text("Обновить информацию")
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Text(lastCheckInfo)
                                .font(.footnote)
                                .foregroundColor(.gray)
                            
                            Text(statsInfo)
                                .font(.footnote)
                                .foregroundColor(.gray)
                            
                            Text("Текущее время: \(formattedCurrentTime())")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        } header: {
                            Text("Отладка")
                        } footer: {
                            Text("Используйте эти функции только для отладки. Чтобы принудительно увеличить счетчики, нажмите 'Увеличить все счетчики на 1 день'.")
                                .font(AskezaTheme.captionFont)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .alert("Сбросить все данные?", isPresented: $showingResetAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Сбросить", role: .destructive) {
                    viewModel.resetAllData()
                }
            } message: {
                Text("Это действие нельзя отменить. Все аскезы и достижения будут удалены.")
            }
            .alert("Увеличить счетчики?", isPresented: $showingForceUpdateAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Увеличить", role: .destructive) {
                    // Выполняем принудительное обновление счетчиков
                    Task { @MainActor in
                        viewModel.forceUpdateAllAskezas()
                        updateDebugInfo()
                    }
                }
            } message: {
                Text("Это прибавит 1 день к прогрессу всех активных аскез.")
            }
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            tapCount += 1
            if tapCount >= 10 {
                withAnimation {
                    showingDebugSection = true
                    updateDebugInfo()
                    startDebugTimer()
                }
            }
        }
        .onAppear {
            updateDebugInfo()
            if showingDebugSection {
                startDebugTimer()
            }
        }
        .onDisappear {
            stopDebugTimer()
        }
    }
    
    private func updateDebugInfo() {
        lastCheckInfo = viewModel.getLastCheckInfo()
        statsInfo = viewModel.getActiveAskezasStats()
    }
    
    private func formattedCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: Date())
    }
    
    private func startDebugTimer() {
        stopDebugTimer()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            // Обновляем информацию каждые 10 секунд
            Task { @MainActor in
                self.updateDebugInfo()
            }
        }
        if let timer = refreshTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func stopDebugTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}

#Preview {
    NavigationView {
        SettingsView(viewModel: AskezaViewModel())
    }
} 