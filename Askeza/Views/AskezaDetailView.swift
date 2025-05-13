import SwiftUI

public struct AskezaDetailView: View {
    private let askezaId: UUID
    @ObservedObject public var viewModel: AskezaViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - View State
    @StateObject private var state = AskezaDetailViewState()
    
    private var askeza: Askeza? {
        viewModel.activeAskezas.first(where: { $0.id == askezaId }) ?? 
        viewModel.completedAskezas.first(where: { $0.id == askezaId })
    }
    
    private var isCompleted: Bool {
        viewModel.completedAskezas.contains(where: { $0.id == askezaId })
    }
    
    private let presetAskezas: [AskezaCategory: [PresetAskeza]] = PresetAskezaStore.shared.askezasByCategory
    
    public init(askeza: Askeza, viewModel: AskezaViewModel) {
        self.askezaId = askeza.id
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            AskezaTheme.backgroundColor
                .ignoresSafeArea()
            
            if let currentAskeza = askeza {
                mainContent(for: currentAskeza)
            } else {
                Text("Аскеза не найдена")
                    .foregroundColor(AskezaTheme.textColor)
            }
        }
    }
    
    @ViewBuilder
    private func mainContent(for askeza: Askeza) -> some View {
        AskezaContentView(
            askeza: askeza,
            viewModel: viewModel,
            state: state,
            dismiss: dismiss
        )
    }
}

// MARK: - View State
fileprivate class AskezaDetailViewState: ObservableObject {
    @Published var showingResetAlert = false
    @Published var showingProgressEdit = false
    @Published var showingExtendDialog = false
    @Published var showingWishInput = false
    @Published var showingDeleteAlert = false
    @Published var showingWishStatusSheet = false
    @Published var showingWishEdit = false
    @Published var editedProgress: String = ""
    @Published var selectedDuration: Int = 7
    @Published var showingSuccessToast = false
    @Published var wishText: String = ""
    @Published var editedWishText = ""
    @Published var showingVisualization = false
    @Published var tempWishText = ""
    @Published var showingEditOptions = false
    @Published var showingCompleteConfirmation = false
    @Published var showingCompletionView = false
}

// MARK: - Content View
fileprivate struct AskezaContentView: View {
    let askeza: Askeza
    @ObservedObject var viewModel: AskezaViewModel
    @ObservedObject var state: AskezaDetailViewState
    let dismiss: DismissAction
    
    // Добавляем статистику связанного шаблона
    private var templateInfo: (PracticeTemplate?, TemplateProgress?)? {
        if let templateID = askeza.templateID {
            let template = PracticeTemplateStore.shared.getTemplate(byID: templateID)
            let progress = PracticeTemplateStore.shared.getProgress(forTemplateID: templateID)
            return (template, progress)
        }
        return nil
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Progress first
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(askeza.progress)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AskezaTheme.accentColor)
                    
                    Text("/")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                    
                    if case .days(let duration) = askeza.duration {
                        Text("\(duration)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(AskezaTheme.secondaryTextColor)
                    } else {
                        Text("∞")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(AskezaTheme.secondaryTextColor)
                    }
                }
                .padding(.top, 8)
                
                // Then header
                AskezaHeaderView(askeza: askeza)
                
                // Then countdown
                ProgressSectionView(
                    askeza: askeza,
                    viewModel: viewModel
                )
                
                // Если аскеза связана с шаблоном, показываем информацию из шаблона
                if let (template, progress) = templateInfo {
                    TemplateInfoView(template: template, progress: progress)
                }
                
                WishSectionContainer(
                    askeza: askeza,
                    showingWishInput: $state.showingWishInput,
                    showingWishStatusSheet: $state.showingWishStatusSheet
                )
                
                ActionButtonsView(
                    askeza: askeza,
                    onExtend: { state.showingExtendDialog = true },
                    onReset: { state.showingResetAlert = true },
                    onEdit: { state.showingEditOptions = true },
                    onShare: { shareAskeza(askeza) },
                    onComplete: { state.showingCompleteConfirmation = true }
                )
            }
            .padding(.vertical, 12)
        }
        .askezaAlerts(
            askeza: askeza,
            viewModel: viewModel,
            state: state,
            dismiss: dismiss
        )
        .sheet(isPresented: $state.showingCompletionView) {
            CompletionView(
                viewModel: viewModel,
                askeza: askeza,
                isPresented: $state.showingCompletionView,
                onShare: { shareAskeza(askeza) },
                onDismiss: { dismiss() }
            )
        }
    }
    
    private func shareAskeza(_ askeza: Askeza) {
        let text = "Я держу аскезу \"\(askeza.title)\" уже \(askeza.progress) дней! 💪"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootViewController.view
            rootViewController.present(activityVC, animated: true)
        }
    }
}

// MARK: - Supporting Views
private struct AskezaHeaderView: View {
    let askeza: Askeza
    
    var body: some View {
        VStack(spacing: 8) {
            Text(askeza.title)
                .font(AskezaTheme.titleFont)
                .foregroundColor(AskezaTheme.textColor)
                .multilineTextAlignment(.center)
            
            if let intention = askeza.intention {
                Text(intention)
                    .font(AskezaTheme.bodyFont)
                    .foregroundColor(AskezaTheme.secondaryTextColor)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal)
    }
}

private struct WishSectionContainer: View {
    let askeza: Askeza
    @Binding var showingWishInput: Bool
    @Binding var showingWishStatusSheet: Bool
    
    var body: some View {
        if let wish = askeza.wish {
            WishSectionView(
                wish: wish,
                status: askeza.wishStatus,
                onStatusTap: { showingWishStatusSheet = true }
            )
        } else {
            AddWishButton {
                showingWishInput = true
            }
        }
    }
}

private struct WishSectionView: View {
    let wish: String
    let status: WishStatus?
    let onStatusTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            WishCardView(
                wish: wish,
                wishStatus: status,
                showingWishInput: .constant(false)
            )
            
            Button(action: onStatusTap) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 22))
                    Text("Статус желания")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(Color("PurpleAccent"))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
        }
        .padding(.horizontal)
    }
}

private struct AddWishButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "gift.fill")
                    .font(.system(size: 22))
                Text("Загадать желание")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(AskezaTheme.accentColor)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(AskezaTheme.buttonBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

private struct ActionButtonsView: View {
    let askeza: Askeza
    let onExtend: () -> Void
    let onReset: () -> Void
    let onEdit: () -> Void
    let onShare: () -> Void
    let onComplete: () -> Void
    
    private var isCompleted: Bool {
        askeza.isCompleted || (askeza.daysLeft == 0)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Для завершенных аскез показываем только кнопку "Делиться"
            if isCompleted {
                HStack {
                    Spacer()
                    ActionButton(
                        icon: "square.and.arrow.up",
                        text: "Делиться",
                        action: onShare
                    )
                    Spacer()
                }
            }
            // Кнопки для пожизненных аскез
            else if case .lifetime = askeza.duration {
                HStack(spacing: 20) {
                    Spacer()
                    ActionButton(
                        icon: "arrow.counterclockwise",
                        text: "Сброс",
                        action: onReset
                    )
                    
                    ActionButton(
                        icon: "pencil",
                        text: "Изменить",
                        action: onEdit
                    )
                    
                    ActionButton(
                        icon: "square.and.arrow.up",
                        text: "Делиться",
                        action: onShare
                    )
                    Spacer()
                }
            } else {
                // Кнопки для обычных аскез с ограниченным сроком
                HStack(spacing: 20) {
                    Spacer()
                    ActionButton(
                        icon: "plus",
                        text: "Продлить",
                        action: onExtend
                    )
                    
                    ActionButton(
                        icon: "arrow.counterclockwise",
                        text: "Сброс",
                        action: onReset
                    )
                    
                    ActionButton(
                        icon: "checkmark.circle",
                        text: "Завершить",
                        action: onComplete
                    )
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    Spacer()
                    ActionButton(
                        icon: "pencil",
                        text: "Изменить",
                        action: onEdit
                    )
                    
                    ActionButton(
                        icon: "square.and.arrow.up",
                        text: "Делиться",
                        action: onShare
                    )
                    Spacer()
                }
            }
        }
    }
}

private struct ActionButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Circle()
                    .fill(Color("GoldAccent").opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundColor(Color("GoldAccent"))
                    )
                
                Text(text)
                    .font(.system(size: 10))
                    .foregroundColor(Color("GoldAccent"))
            }
        }
    }
}

// MARK: - Progress Section
fileprivate struct ProgressSectionView: View {
    let askeza: Askeza
    @ObservedObject var viewModel: AskezaViewModel
    @State private var currentDate = Date()
    @State private var timer: Timer?
    @State private var lastMidnightCheck = Date()
    
    private var isCompleted: Bool {
        // Проверяем, находится ли аскеза в списке завершенных
        viewModel.completedAskezas.contains(where: { $0.id == askeza.id })
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Time details
            VStack(spacing: 8) {
                if isCompleted {
                    // Для завершенных аскез показываем другую фразу
                    Text("аскеза завершена")
                        .font(.system(size: 15, weight: .light, design: .serif))
                        .foregroundColor(AskezaTheme.accentColor)
                        .italic()
                } else if case .lifetime = askeza.duration {
                    Text("аскеза в течение")
                        .font(.system(size: 15, weight: .light, design: .serif))
                        .foregroundColor(AskezaTheme.accentColor)
                        .italic()
                } else if case .days(_) = askeza.duration {
                    Text("до завершения аскезы")
                        .font(.system(size: 15, weight: .light, design: .serif))
                        .foregroundColor(AskezaTheme.accentColor)
                        .italic()
                }
                
                let timeComponents = calculateTimeComponents()
                
                VStack(spacing: 20) {
                    if case .lifetime = askeza.duration {
                        // Для пожизненной аскезы показываем годы
                        if timeComponents.years > 0 {
                            TimeUnitView(
                                value: timeComponents.years,
                                unit: "год",
                                color: Color.green
                            )
                            .id("years_\(timeComponents.years)")
                        }
                    }
                    
                    // Для завершенных аскез показываем только дни, без часов/минут/секунд
                    if isCompleted {
                        TimeUnitView(
                            value: askeza.progress,
                            unit: "день",
                            color: AskezaTheme.accentColor
                        )
                        .id("completed_days_\(askeza.progress)")
                    } else {
                        HStack(spacing: 20) {
                            TimeUnitView(
                                value: timeComponents.days,
                                unit: "день",
                                color: AskezaTheme.accentColor
                            )
                            .id("days_\(timeComponents.days)")
                            
                            TimeUnitView(
                                value: timeComponents.hours,
                                unit: "час",
                                color: AskezaTheme.accentColor.opacity(0.8)
                            )
                            .id("hours_\(timeComponents.hours)")
                            
                            TimeUnitView(
                                value: timeComponents.minutes,
                                unit: "минута",
                                color: AskezaTheme.accentColor.opacity(0.6)
                            )
                            .id("minutes_\(timeComponents.minutes)")
                            
                            TimeUnitView(
                                value: timeComponents.seconds,
                                unit: "секунда",
                                color: AskezaTheme.accentColor.opacity(0.4)
                            )
                            .id("seconds_\(timeComponents.seconds)")
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: currentDate)
                
                // Progress bar - always show
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(askeza.duration == .lifetime ? 
                                Color("PurpleAccent").opacity(0.2) :
                                AskezaTheme.accentColor.opacity(0.2))
                            .cornerRadius(6)
                        
                        Rectangle()
                            .fill(askeza.duration == .lifetime ? 
                                Color("PurpleAccent") :
                                AskezaTheme.accentColor)
                            .frame(width: calculateProgressWidth(geometry: geometry))
                            .cornerRadius(6)
                    }
                }
                .frame(height: 12)
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .padding(.horizontal)
        .onAppear {
            // Запускаем таймер только для активных аскез
            if !isCompleted {
                startTimer()
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let now = Date()
            withAnimation {
                currentDate = now
                checkMidnight(now)
            }
        }
        
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func calculateTimeComponents() -> (years: Int, days: Int, hours: Int, minutes: Int, seconds: Int) {
        let calendar = Calendar.current
        let now = Date()
        
        // Всегда считаем компоненты от startDate
        let totalComponents = calendar.dateComponents([.year, .day, .hour, .minute, .second], from: askeza.startDate, to: now)
        
        if case .lifetime = askeza.duration {
            return (
                years: totalComponents.year ?? 0,
                days: totalComponents.day ?? 0,
                hours: totalComponents.hour ?? 0,
                minutes: totalComponents.minute ?? 0,
                seconds: totalComponents.second ?? 0
            )
        } else if case .days(let duration) = askeza.duration {
            // Для обычной аскезы показываем оставшееся время
            let totalDays = totalComponents.day ?? 0
            let remainingDays = max(0, duration - totalDays)
            
            // Получаем следующую полночь для расчета оставшихся часов, минут и секунд
            var nextMidnightComponents = DateComponents()
            nextMidnightComponents.day = 1
            nextMidnightComponents.second = 0
            let nextMidnight = calendar.startOfDay(for: calendar.date(byAdding: nextMidnightComponents, to: now) ?? now)
            let remainingComponents = calendar.dateComponents([.hour, .minute, .second], from: now, to: nextMidnight)
            
            return (
                years: 0,
                days: remainingDays,
                hours: remainingComponents.hour ?? 0,
                minutes: remainingComponents.minute ?? 0,
                seconds: remainingComponents.second ?? 0
            )
        }
        
        return (0, 0, 0, 0, 0)
    }
    
    private func checkMidnight(_ now: Date) {
        let calendar = Calendar.current
        if !calendar.isDate(lastMidnightCheck, inSameDayAs: now) {
            // Обновляем прогресс на основе дней с момента startDate
            let components = calendar.dateComponents([.day], from: askeza.startDate, to: now)
            let totalDays = max(0, components.day ?? 0)
            viewModel.updateProgress(askeza, newProgress: totalDays)
            lastMidnightCheck = now
        }
    }
    
    private func calculateProgressWidth(geometry: GeometryProxy) -> CGFloat {
        switch askeza.duration {
        case .lifetime:
            return geometry.size.width
        case .days(let duration):
            let progress = CGFloat(askeza.progress) / CGFloat(duration)
            return geometry.size.width * min(1.0, progress)
        }
    }
}

fileprivate struct TimeUnitView: View {
    let value: Int
    let unit: String
    let color: Color
    
    private var label: String {
        getLabel(value: value, unit: unit)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AskezaTheme.secondaryTextColor)
        }
    }
    
    private func getLabel(value: Int, unit: String) -> String {
        switch unit {
        case "день":
            switch value {
            case 1: return "день"
            case 2...4: return "дня"
            default: return "дней"
            }
        case "час":
            switch value {
            case 1: return "час"
            case 2...4: return "часа"
            default: return "часов"
            }
        case "минута":
            switch value {
            case 1: return "минута"
            case 2...4: return "минуты"
            default: return "минут"
            }
        case "секунда":
            switch value {
            case 1: return "секунда"
            case 2...4: return "секунды"
            default: return "секунд"
            }
        default:
            return unit
        }
    }
}

// MARK: - Alert Builders
fileprivate extension AskezaAlertsModifier {
    @ViewBuilder
    func editOptionsDialog() -> some View {
        Button("Изменить прогресс") {
            state.editedProgress = String(askeza.progress)
            state.showingProgressEdit = true
        }
        if askeza.wish != nil {
            Button("Перезагадать желание") {
                state.editedWishText = askeza.wish ?? ""
                state.showingWishEdit = true
            }
        }
        Button("Отмена", role: .cancel) { }
    }
    
    @ViewBuilder
    func wishInputAlert() -> some View {
        TextField("Ваше желание", text: $state.wishText)
        Button("Отмена", role: .cancel) {
            state.wishText = ""
        }
        Button("Визуализировать") {
            state.tempWishText = state.wishText
            state.showingWishInput = false
            state.showingVisualization = true
        }
    }
    
    @ViewBuilder
    func wishEditAlert() -> some View {
        TextField("Ваше желание", text: $state.editedWishText)
        Button("Отмена", role: .cancel) {
            state.editedWishText = ""
        }
        Button("Визуализировать") {
            state.tempWishText = state.editedWishText
            state.showingWishEdit = false
            state.showingVisualization = true
        }
    }
    
    @ViewBuilder
    func wishStatusButtons() -> some View {
        Button("Исполнилось") {
            viewModel.updateWishStatus(askeza, status: .fulfilled)
        }
        Button("Ожидает исполнения") {
            viewModel.updateWishStatus(askeza, status: .waiting)
        }
        Button("Отмена", role: .cancel) {}
    }
    
    @ViewBuilder
    func extendButtons() -> some View {
        ForEach([7, 30, 100], id: \.self) { days in
            Button("\(days) дней") {
                viewModel.extendAskeza(askeza: askeza, additionalDays: days)
            }
        }
        Button("Отмена", role: .cancel) { }
    }
}

// MARK: - Alerts ViewModifier
fileprivate struct AskezaAlertsModifier: ViewModifier {
    let askeza: Askeza
    @ObservedObject var viewModel: AskezaViewModel
    @ObservedObject var state: AskezaDetailViewState
    let dismiss: DismissAction
    
    func body(content: Content) -> some View {
        content
            .confirmationDialog("Что изменить?", isPresented: $state.showingEditOptions) {
                editOptionsDialog()
            }
            .alert("Загадать желание", isPresented: $state.showingWishInput) {
                wishInputAlert()
            }
            .alert("Перезагадать желание", isPresented: $state.showingWishEdit) {
                wishEditAlert()
            }
            .sheet(isPresented: $state.showingVisualization) {
                WishVisualizationView {
                    viewModel.updateWish(askeza, newWish: state.tempWishText)
                }
            }
            .confirmationDialog("Статус желания", isPresented: $state.showingWishStatusSheet) {
                wishStatusButtons()
            }
            .alert("Сбросить прогресс?", isPresented: $state.showingResetAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Сбросить", role: .destructive) {
                    viewModel.resetAskeza(askeza)
                }
            } message: {
                Text("Весь прогресс будет утерян")
            }
            .alert("Удалить аскезу?", isPresented: $state.showingDeleteAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Удалить", role: .destructive) {
                    viewModel.deleteAskeza(askeza)
                    dismiss()
                }
            } message: {
                Text("Это действие нельзя отменить")
            }
            .alert("Изменить прогресс", isPresented: $state.showingProgressEdit) {
                TextField("Количество дней", text: $state.editedProgress)
                    .keyboardType(.numberPad)
                Button("Отмена", role: .cancel) { }
                Button("Сохранить") {
                    if let days = Int(state.editedProgress) {
                        viewModel.updateProgress(askeza, newProgress: days)
                    }
                }
            }
            .confirmationDialog("Продлить аскезу", isPresented: $state.showingExtendDialog) {
                extendButtons()
            }
            .alert("Завершить аскезу?", isPresented: $state.showingCompleteConfirmation) {
                Button("Отмена", role: .cancel) { }
                Button("Завершить", role: .destructive) {
                    viewModel.completeAskeza(askeza)
                    state.showingCompletionView = true
                }
            } message: {
                Text("Вы уверены, что хотите завершить эту аскезу? Это действие нельзя отменить.")
            }
    }
}

fileprivate extension View {
    func askezaAlerts(
        askeza: Askeza,
        viewModel: AskezaViewModel,
        state: AskezaDetailViewState,
        dismiss: DismissAction
    ) -> some View {
        modifier(AskezaAlertsModifier(
            askeza: askeza,
            viewModel: viewModel,
            state: state,
            dismiss: dismiss
        ))
    }
}

// Добавляем представление для информации о шаблоне аскезы
private struct TemplateInfoView: View {
    let template: PracticeTemplate?
    let progress: TemplateProgress?
    
    var body: some View {
        if let template = template {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Информация о шаблоне")
                            .font(.headline)
                            .foregroundColor(AskezaTheme.textColor)
                        
                        if let progress = progress, progress.timesCompleted > 0 {
                            Text("Пройдено \(progress.timesCompleted) \(pluralForm(progress.timesCompleted))")
                                .font(.subheadline)
                                .foregroundColor(AskezaTheme.accentColor)
                        }
                    }
                    
                    Spacer()
                    
                    // Статус шаблона
                    if let progress = progress {
                        let status = progress.status(templateDuration: template.duration)
                        TemplateStatusBadge(status: status)
                    }
                }
                
                // Если есть цитата из шаблона, показываем ее
                if !template.quote.isEmpty {
                    Text("«\(template.quote)»")
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .italic()
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                        .padding(.vertical, 4)
                }
                
                // Если есть описание в шаблоне, показываем его
                if !template.practiceDescription.isEmpty {
                    Text(template.practiceDescription)
                        .font(.body)
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                        .padding(.top, 2)
                }
            }
            .padding()
            .background(AskezaTheme.buttonBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
    
    // Вспомогательная функция для склонения слова "раз"
    private func pluralForm(_ number: Int) -> String {
        let lastDigit = number % 10
        let lastTwoDigits = number % 100
        
        if lastDigit == 1 && lastTwoDigits != 11 {
            return "раз"
        } else if (lastDigit >= 2 && lastDigit <= 4) && !(lastTwoDigits >= 12 && lastTwoDigits <= 14) {
            return "раза"
        } else {
            return "раз"
        }
    }
}

// Компонент для отображения статуса шаблона
private struct TemplateStatusBadge: View {
    let status: TemplateStatus
    
    var body: some View {
        Text(statusText)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .cornerRadius(6)
    }
    
    private var statusText: String {
        switch status {
        case .notStarted:
            return "Не начат"
        case .inProgress:
            return "В процессе"
        case .completed:
            return "Завершен"
        case .mastered:
            return "Освоен"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .notStarted:
            return Color.gray
        case .inProgress:
            return Color.blue
        case .completed:
            return Color.green
        case .mastered:
            return Color.purple
        }
    }
}

#Preview {
    NavigationView {
        AskezaDetailView(
            askeza: Askeza(
                title: "Медитация каждое утро",
                intention: "Обрести внутренний покой",
                duration: .lifetime
            ),
            viewModel: AskezaViewModel()
        )
    }
} 