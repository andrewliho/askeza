import SwiftUI

struct CompletionView: View {
    @ObservedObject var viewModel: AskezaViewModel
    let askeza: Askeza
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var showingWishStatusDialog = false
    let onShare: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                AskezaTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Congratulations Section
                        VStack(spacing: 16) {
                            Text("Поздравляем!")
                                .font(AskezaTheme.titleFont)
                                .foregroundColor(AskezaTheme.textColor)
                                .padding(.bottom, 8)
                            
                            Text("Вы успешно завершили аскезу")
                                .font(AskezaTheme.bodyFont)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 24)
                        }
                        
                        // Victory Symbol
                        VStack(spacing: 16) {
                            Image(systemName: "star.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(AskezaTheme.accentColor)
                                .askezaShadow()
                            
                            Text("Поздравляем с завершением!")
                                .font(AskezaTheme.bodyFont)
                                .foregroundColor(AskezaTheme.textColor)
                        }
                        
                        // Askeza Summary
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Итоги пути:")
                                .font(AskezaTheme.subtitleFont)
                                .foregroundColor(AskezaTheme.textColor)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Название: \(askeza.title)")
                                Text("Намерение: \(askeza.intention ?? "Не указано")")
                                if case .days(let days) = askeza.duration {
                                    Text("Дней пройдено: \(days)")
                                }
                                if let wish = askeza.wish {
                                    Text("Желание: \(wish)")
                                }
                            }
                            .font(AskezaTheme.bodyFont)
                            .foregroundColor(AskezaTheme.secondaryTextColor)
                        }
                        .padding()
                        .background(AskezaTheme.buttonBackground)
                        .cornerRadius(12)
                        
                        if askeza.wish != nil {
                            AskezaButton(title: "Статус желания") {
                                showingWishStatusDialog = true
                            }
                        }
                        
                        AskezaButton(title: "Поделиться достижением") {
                            onShare()
                        }
                            
                        AskezaButton(title: "Закрыть") {
                            isPresented = false
                            onDismiss()
                        }
                    }
                    .padding()
                }
            }
            .confirmationDialog("Статус желания", isPresented: $showingWishStatusDialog, titleVisibility: .visible) {
                Button("Исполнилось") {
                    viewModel.updateWishStatus(askeza, status: .fulfilled)
                    dismiss()
                }
                Button("Ожидает исполнения") {
                    viewModel.updateWishStatus(askeza, status: .waiting)
                    dismiss()
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Выберите статус вашего желания")
            }
        }
    }
}

#Preview {
    CompletionView(
        viewModel: AskezaViewModel(),
        askeza: Askeza(
            title: "Медитация каждое утро",
            intention: "Обрести внутренний покой",
            duration: .days(30),
            wish: "Обрести внутреннюю гармонию"
        ),
        isPresented: .constant(true),
        onShare: {},
        onDismiss: {}
    )
} 