import SwiftUI

public struct AskezaCardView: View {
    public let askeza: Askeza
    private let onDelete: () -> Void
    @State private var showingDeleteAlert = false
    @State private var showingExtendDialog = false
    @State private var showingCompleteConfirmation = false
    @State private var showCopiedToast = false
    @State private var showingProgressEdit = false
    @State private var editedProgress = ""
    @State private var pulseAnimation = false // Для анимации пульсации
    var onComplete: (() -> Void)?
    var onExtend: (() -> Void)?
    var onProgressUpdate: ((Int) -> Void)?
    
    public init(askeza: Askeza, 
                onDelete: @escaping () -> Void,
                onComplete: (() -> Void)? = nil,
                onExtend: (() -> Void)? = nil,
                onProgressUpdate: ((Int) -> Void)? = nil) {
        self.askeza = askeza
        self.onDelete = onDelete
        self.onComplete = onComplete
        self.onExtend = onExtend
        self.onProgressUpdate = onProgressUpdate
    }
    
    private var isLifetime: Bool {
        if case .lifetime = askeza.duration {
            return true
        }
        return false
    }
    
    private var isCompleted: Bool {
        askeza.isCompleted || (askeza.daysLeft == 0)
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
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: askeza.category.systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(askeza.category.mainColor)
                
                Text(askeza.title)
                    .font(AskezaTheme.bodyFont)
                    .foregroundColor(.white)
                
                Spacer()
                
                if isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color.green)
                        Text("Завершенная")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.3))
                    .cornerRadius(4)
                } else if isLifetime {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(askeza.category.mainColor)
                        Text("Пожизненная")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(4)
                
                    HStack(spacing: 4) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(askeza.category.mainColor)
                        Text("Активная")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(askeza.category.mainColor.opacity(0.3))
                    .cornerRadius(4)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .cornerRadius(6)
                    
                    // Progress
                    Rectangle()
                        .fill(askeza.category.mainColor)
                        .frame(width: geometry.size.width * (isLifetime ? 1.0 : isCompleted ? 1.0 : askeza.progressPercentage))
                        .cornerRadius(6)
                }
            }
            .frame(height: 12)
            .padding(.vertical, 4)
            
            HStack {
                Text("День \(askeza.progress)")
                    .font(AskezaTheme.bodyFont)
                    .foregroundColor(Color.white.opacity(0.9))
                
                Spacer()
                
                if !isCompleted && !isLifetime, let daysLeft = askeza.daysLeft {
                    Text("Осталось: \(daysLeft)")
                        .font(AskezaTheme.bodyFont)
                        .foregroundColor(Color.white.opacity(0.9))
                }
            }
            
            // Отображаем намерение, если оно есть
            if let intention = askeza.intention, !intention.isEmpty {
                Text("Намерение: \(intention)")
                    .font(AskezaTheme.captionFont)
                    .foregroundColor(Color.white.opacity(0.8))
                    .lineLimit(2)
            }
            
            // Кнопки действий
            HStack(spacing: 16) {
                // Кнопка "Завершить" только для завершенных аскез, которые еще в активных
                if isCompleted && !askeza.isInCompletedList {
                    VStack(spacing: 8) {
                        Text("Поздравляем! Аскеза завершена!")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            showingCompleteConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                Text("Завершить")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green)
                            .cornerRadius(8)
                        }
                        .alert("Переместить аскезу в завершенные?", isPresented: $showingCompleteConfirmation) {
                            Button("Отмена", role: .cancel) { }
                            Button("Завершить") {
                                onComplete?()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Spacer()
                
                // Кнопка редактирования прогресса
                Button(action: {
                    editedProgress = "\(askeza.progress)"
                    showingProgressEdit = true
                }) {
                    Image(systemName: "pencil.circle")
                        .font(.system(size: 22))
                        .foregroundColor(Color.white.opacity(0.7))
                }
                .alert("Изменить прогресс", isPresented: $showingProgressEdit) {
                    TextField("Прогресс", text: $editedProgress)
                        .keyboardType(.numberPad)
                    
                    Button("Отмена", role: .cancel) { }
                    Button("Сохранить") {
                        if let newProgress = Int(editedProgress) {
                            onProgressUpdate?(newProgress)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
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
                // Пульсация только для завершенных аскез, которые еще в активных
                .scaleEffect(isCompleted && pulseAnimation && !askeza.isInCompletedList ? 1.03 : 1.0)
        )
        .onAppear {
            // Запускаем анимацию пульсации только для завершенных аскез, которые еще в активных
            if isCompleted && !askeza.isInCompletedList {
                withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
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
            
            if !isCompleted && !isLifetime {
                Button(action: {
                    showingCompleteConfirmation = true
                }) {
                    Label("Завершить", systemImage: "checkmark.circle")
                }
                
                Button(action: {
                    showingExtendDialog = true
                }) {
                    Label("Продлить", systemImage: "plus.circle")
                }
                
                Divider()
            }
            
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Удалить", systemImage: "trash")
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
        .alert("Удалить аскезу?", isPresented: $showingDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                onDelete()
            }
        }
        .alert("Продлить аскезу", isPresented: $showingExtendDialog) {
            Button("Отмена", role: .cancel) { }
            Button("Продлить на 7 дней") {
                onExtend?()
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AskezaCardView(
            askeza: Askeza(
                title: "Бег каждый день",
                intention: "Укрепить тело и дух",
                duration: .days(365),
                progress: 283,
                category: .telo
            ),
            onDelete: {}
        )
        
        AskezaCardView(
            askeza: Askeza(
                title: "Медитация каждое утро",
                intention: "Обрести внутренний покой",
                duration: .days(30)
            ),
            onDelete: {}
        )
        
        AskezaCardView(
            askeza: Askeza(
                title: "Завершенная аскеза",
                intention: "Путь осилит идущий",
                duration: .days(30),
                progress: 30,
                isCompleted: true
            ),
            onDelete: {}
        )
        
        AskezaCardView(
            askeza: Askeza(
                title: "Пожизненная аскеза",
                intention: "Каждый день — новая победа",
                duration: .lifetime
            ),
            onDelete: {}
        )
    }
    .padding()
} 