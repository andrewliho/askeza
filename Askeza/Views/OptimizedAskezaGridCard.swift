import SwiftUI

/// Оптимизированная версия карточки аскезы для сетки в стиле шаблонов
struct OptimizedAskezaGridCard: View {
    let askeza: Askeza
    let onDelete: () -> Void
    let onComplete: (() -> Void)?
    let onExtend: (() -> Void)?
    let onProgressUpdate: ((Int) -> Void)?
    
    @State private var showingContextMenu = false
    @State private var showingDeleteAlert = false
    @State private var showCopiedToast = false
    
    private var isLifetime: Bool {
        if case .lifetime = askeza.duration {
            return true
        }
        return false
    }
    
    private var isCompleted: Bool {
        askeza.isCompleted || (askeza.daysLeft == 0)
    }
    
    private var progressPercentage: Double {
        askeza.progressPercentage
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Верхняя часть с фоном категории
            ZStack {
                // Градиент фон
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(
                                colors: [
                                    askeza.category.mainColor.opacity(0.7),
                                    askeza.category.mainColor.opacity(0.3)
                                ]
                            ),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Большая иконка категории с круговым прогресс-баром
                ZStack {
                    // Серый фоновый круг для прогресс-бара и прогресс-бар
                    if !isCompleted && !isLifetime {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 6)
                            .frame(width: 120, height: 120)
                            .padding(10)
                        
                        // Сам прогресс-бар
                        Circle()
                            .trim(from: 0, to: progressPercentage)
                            .stroke(Color.orange, lineWidth: 6)
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .padding(10)
                    } else if isLifetime {
                        // Для пожизненных - голубой круг
                        Circle()
                            .stroke(Color.blue.opacity(0.6), lineWidth: 6)
                            .frame(width: 120, height: 120)
                            .padding(10)
                    } else if isCompleted {
                        // Для завершенных - зеленый круг
                        Circle()
                            .stroke(Color.green.opacity(0.6), lineWidth: 6)
                            .frame(width: 120, height: 120)
                            .padding(10)
                    }
                    
                    // Иконка категории
                    ZStack {
                        // Фон иконки
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 100, height: 100)
                        
                        // Иконка категории полупрозрачная
                        Image(systemName: askeza.category.systemImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                            .foregroundColor(askeza.category.mainColor)
                            .opacity(0.7)
                    }
                }
                .padding(.top, 25)
                .padding(.bottom, 30)
                
                // Если аскеза завершена, добавляем иконку завершения сверху между севером и востоком (1:30)
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.green)
                        .clipShape(Circle())
                        .offset(x: 45, y: -45)  // Позиция на 1:30 с значением 45
                        .zIndex(10) // Поверх всех элементов
                }
                
                // Информация поверх
                VStack(spacing: 0) {
                    // Верхняя строка: процент и статус
                    HStack {
                        // Процент выполнения в верхнем левом углу (для активных аскез)
                        if !isCompleted && !isLifetime {
                            Text("\(Int(progressPercentage * 100))%")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(4)
                        } else if case .days(let days) = askeza.duration {
                            Text("\(days) дн.")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(4)
                        } else {
                            Text("∞")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                        
                        // Статус
                        if isCompleted {
                            HStack(spacing: 2) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.green)
                                Text("Завершено")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.4))
                            .cornerRadius(4)
                        } else if isLifetime {
                            HStack(spacing: 2) {
                                Image(systemName: "infinity")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                                Text("Пожизненно")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.4))
                            .cornerRadius(4)
                        } else {
                            // Добавляем статус "Активная" для обычных активных аскез
                            HStack(spacing: 2) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                                Text("Активная")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.4))
                            .cornerRadius(4)
                        }
                    }
                    .padding(6)
                    
                    Spacer()
                    
                    // Прогресс бар внизу
                    VStack(spacing: 0) {
                        // Текущий день и оставшиеся дни с одинаковыми отступами и форматированием
                        HStack {
                            Text("День: \(askeza.progress)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if !isLifetime && !isCompleted, let daysLeft = askeza.daysLeft {
                                Text("Осталось: \(daysLeft)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                            } else if isLifetime {
                                Text("Серия")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                            } else if isCompleted {
                                Text("Выполнено")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                    }
                    .background(Color.black.opacity(0.4))
                }
            }
            .frame(height: 200)
            
            // Нижняя часть с заголовком
            Text(askeza.title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AskezaTheme.textColor)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(8)
                .frame(height: 45)
                .background(AskezaTheme.buttonBackground)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .contextMenu {
            // Кнопка для копирования хэштега
            Button(action: {
                UIPasteboard.general.string = formatAskezaHashtag()
                showCopiedToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showCopiedToast = false
                }
            }) {
                Label("Скопировать хэштег", systemImage: "doc.on.doc")
            }
            
            // Кнопка "Поделиться"
            Button(action: {
                // Здесь будет обработка поделиться, например, вызов shareSheet
                let shareText = formatAskezaHashtag()
                let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
                
                // Современный способ получения окна для представления контроллера
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(activityVC, animated: true, completion: nil)
                }
            }) {
                Label("Поделиться", systemImage: "square.and.arrow.up")
            }
            
            if !isCompleted && !isLifetime {
                Button(action: {
                    onComplete?()
                }) {
                    Label("Завершить", systemImage: "checkmark.circle")
                }
                
                Divider()
            }
            
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
        .alert("Удалить аскезу?", isPresented: $showingDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                onDelete()
            }
        }
        .overlay(
            Group {
                if showCopiedToast {
                    VStack {
                        Spacer()
                        Text("Скопировано!")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.75))
                            .cornerRadius(10)
                            .padding(.bottom, 32)
                    }
                }
            }
        )
    }
    
    // Вспомогательные методы
    
    private var borderColor: Color {
        if isCompleted {
            return Color.green
        } else if isLifetime {
            return askeza.category.mainColor.opacity(0.5)
        } else {
            return Color.clear
        }
    }
    
    private var borderWidth: CGFloat {
        if isCompleted {
            return 2
        } else if isLifetime {
            return 1
        } else {
            return 0
        }
    }
    
    private func formatAskezaHashtag() -> String {
        let hashtag = askeza.title
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "[^a-zа-яё0-9]", with: "", options: .regularExpression)
        
        let progress = askeza.progress
        var duration = ""
        
        if case .days(let days) = askeza.duration {
            duration = "\(progress)/\(days)"
        } else {
            duration = "\(progress)/∞"
        }
        
        return "\(duration)\n#\(hashtag)"
    }
}

#Preview {
    VStack(spacing: 16) {
        OptimizedAskezaGridCard(
            askeza: Askeza(
                title: "Бег каждый день",
                intention: "Укрепить тело и дух",
                duration: .days(30),
                progress: 15,
                category: .telo
            ),
            onDelete: {},
            onComplete: {},
            onExtend: {},
            onProgressUpdate: { _ in }
        )
        .frame(width: 160)
        
        OptimizedAskezaGridCard(
            askeza: Askeza(
                title: "Медитация",
                intention: "Обрести внутренний покой",
                duration: .lifetime,
                progress: 45,
                category: .um
            ),
            onDelete: {},
            onComplete: nil,
            onExtend: nil,
            onProgressUpdate: nil
        )
        .frame(width: 160)
        
        OptimizedAskezaGridCard(
            askeza: Askeza(
                title: "Отказ от сахара",
                intention: "Оздоровление",
                duration: .days(30),
                progress: 30,
                isCompleted: true,
                category: .osvobozhdenie
            ),
            onDelete: {},
            onComplete: nil,
            onExtend: nil,
            onProgressUpdate: nil
        )
        .frame(width: 160)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
} 