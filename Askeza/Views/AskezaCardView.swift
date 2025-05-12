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
                } else {
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
            
            // Добавляем разделитель и намерение
            if let intention = askeza.intention, !intention.isEmpty {
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)
                    .padding(.vertical, 8)
                
                // Бронзовый цвет для цитат
                Text("\"\(intention)\"")
                    .font(.system(size: 15, weight: .light, design: .serif))
                    .italic()
                    .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.4)) // Бронзовый цвет
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(AskezaTheme.buttonBackground) // Используем стиль как в карточках желаний
        .cornerRadius(12)
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
        } message: {
            Text("Это действие нельзя отменить.")
        }
        .alert("Завершить аскезу?", isPresented: $showingCompleteConfirmation) {
            Button("Отмена", role: .cancel) { }
            Button("Завершить", role: .destructive) {
                if let onComplete = onComplete {
                    onComplete()
                }
            }
        } message: {
            Text("Вы уверены, что хотите завершить эту аскезу? Это действие нельзя отменить.")
        }
        .onChange(of: showingExtendDialog) { oldValue, newValue in
            if newValue && onExtend != nil {
                onExtend?()
            }
        }
        .alert("Изменить прогресс", isPresented: $showingProgressEdit) {
            TextField("Количество дней", text: $editedProgress)
                .keyboardType(.numberPad)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if let days = Int(editedProgress), let onUpdate = onProgressUpdate {
                    onUpdate(days)
                }
            }
        } message: {
            Text("Введите текущий прогресс аскезы (количество пройденных дней).")
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