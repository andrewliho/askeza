import SwiftUI
import CoreHaptics

/// Оптимизированная версия карточки аскезы для списка в горизонтальном стиле
struct OptimizedAskezaGridCard: View {
    let askeza: Askeza
    let onDelete: () -> Void
    let onComplete: (() -> Void)?
    let onExtend: (() -> Void)?
    let onProgressUpdate: ((Int) -> Void)?
    
    @State private var showingContextMenu = false
    @State private var showingDeleteAlert = false
    @State private var showCopiedToast = false
    @State private var pulseAnimation = false // Для анимации пульсации
    @State private var progressAnimationValue: Double = 0.0 // Для анимации прогресс-бара
    
    @State private var hapticEngine: CHHapticEngine?
    
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
        ZStack {
            // Фон карточки
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    isCompleted ? 
                    LinearGradient(
                        gradient: Gradient(colors: [askeza.category.mainColor.opacity(0.7), Color.green.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) : 
                    LinearGradient(
                        gradient: Gradient(colors: [askeza.category.mainColor.opacity(0.3), askeza.category.mainColor.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: isCompleted ? Color.green.opacity(0.5) : Color.black.opacity(0.3), radius: isCompleted ? 8 : 4)
                .scaleEffect(isCompleted && pulseAnimation && !askeza.isInCompletedList ? 1.03 : 1.0)
            
            // Содержимое карточки в горизонтальном виде
            HStack(spacing: 16) {
                // Левая часть с прогресс-кольцом и иконкой
                ZStack {
                    // Круговой прогресс-бар
                    Circle()
                        .stroke(lineWidth: 6)
                        .opacity(0.3)
                        .foregroundColor(Color.white)
                    
                    Circle()
                        .trim(from: 0.0, to: isLifetime || isCompleted ? 1.0 : CGFloat(progressAnimationValue))
                        .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                        .foregroundColor(isCompleted ? Color.green : askeza.category.mainColor)
                        .rotationEffect(Angle(degrees: 270.0))
                    
                    // Фон для иконки внутри кольца
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    // Иконка категории
                    Image(systemName: askeza.category.systemImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                    
                    // Если аскеза завершена, добавляем значок завершения
                    if isCompleted {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 36, y: -36)  // Позиционирование в верхнем правом углу
                    }
                }
                .frame(width: 110, height: 110)
                .padding(.leading, 12)
                
                // Правая часть с информацией
                VStack(alignment: .leading, spacing: 8) {
                    // Верхняя строка с днями 
                    HStack {
                        Spacer()
                        
                        // Дни в правом верхнем углу
                        if case .days(let days) = askeza.duration {
                            HStack(spacing: 4) {
                                Text("\(askeza.progress)/\(days)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("дн.")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(12)
                        } else {
                            HStack(spacing: 4) {
                                Text("\(askeza.progress)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("дн.")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(12)
                        }
                        
                        // Статус (перемещен сюда)
                        if isCompleted {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                Text("Завершена")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.5))
                            .cornerRadius(12)
                        } else if isLifetime {
                            HStack(spacing: 4) {
                                Image(systemName: "infinity")
                                    .font(.system(size: 10))
                                Text("Пожизненно")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.5))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Название аскезы 
                    Text(askeza.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Показываем оставшиеся дни
                    if !isCompleted && !isLifetime, let daysLeft = askeza.daysLeft {
                        Text("Осталось: \(daysLeft) дн.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    // Нижняя строка с процентом и кнопкой завершения
                    HStack {
                        // Кнопка завершения для завершенных аскез, которые еще не в списке завершенных
                        if isCompleted && !askeza.isInCompletedList {
                            Button(action: {
                                playHapticSuccess()
                                onComplete?()
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12))
                                    Text("Завершить")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                        }
                        
                        Spacer()
                        
                        // Процент выполнения в правом нижнем углу (для активных аскез)
                        if !isLifetime && !isCompleted {
                            Text("\(Int(progressPercentage * 100))%")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(askeza.category.mainColor.opacity(0.7))
                                )
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.trailing, 12)
            }
        }
        .onAppear {
            prepareHaptics()
            
            // Запускаем анимацию прогресс-бара
            withAnimation(.easeInOut(duration: 1.0)) {
                progressAnimationValue = progressPercentage
            }
            
            // Запускаем анимацию пульсации только для завершенных аскез, которые еще в активных
            if isCompleted && !askeza.isInCompletedList {
                withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            }
        }
        .onChange(of: askeza.progress) { oldValue, newValue in
            // Анимация прогресс-бара при изменении прогресса
            withAnimation(.easeInOut(duration: 1.0)) {
                progressAnimationValue = progressPercentage
            }
            
            // Тактильная обратная связь при изменении прогресса
            if oldValue != newValue {
                playProgressHaptic()
            }
        }
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
                    playHapticSuccess()
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
    
    // MARK: - Haptic Feedback
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Error creating haptic engine: \(error.localizedDescription)")
        }
    }
    
    private func playProgressHaptic() {
        // Simple vibration feedback for progress change
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func playHapticSuccess() {
        // Play a success haptic pattern
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
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
        .frame(width: 350, height: 170)
        
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
        .frame(width: 350, height: 170)
        
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
        .frame(width: 350, height: 170)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}

// Добавим вспомогательное расширение для создания закругления определенных углов
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
} 