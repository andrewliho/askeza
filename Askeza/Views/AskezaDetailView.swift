import SwiftUI
import Combine

public struct AskezaDetailView: View {
    private let askezaId: UUID
    @ObservedObject public var viewModel: AskezaViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - View State
    @StateObject private var state = AskezaDetailViewState()
    @State private var currentProgress: Int = 0
    
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
        _currentProgress = State(initialValue: askeza.progress)
    }
    
    public var body: some View {
        ZStack {
            AskezaTheme.backgroundColor
                .ignoresSafeArea()
            
            if let currentAskeza = askeza {
                mainContent(for: currentAskeza)
                    .onAppear {
                        currentProgress = currentAskeza.progress
                    }
                    .onChange(of: currentAskeza.progress) { oldValue, newValue in
                        if oldValue != newValue {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                currentProgress = newValue
                            }
                        }
                    }
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
            currentProgress: $currentProgress,
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
    @Published var selectedStartDate: Date = Date()
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
    let currentProgress: Binding<Int>
    let dismiss: DismissAction
    
    // Добавляем статистику связанной практики
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
                    Text("\(currentProgress.wrappedValue)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AskezaTheme.accentColor)
                        .id("progress_\(currentProgress.wrappedValue)")
                    
                    Text("/")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                    
                    Group {
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
                }
                .padding(.top, 8)
                .transaction { transaction in
                    transaction.animation = .easeInOut(duration: 0.3)
                }
                
                // Then header
                AskezaHeaderView(askeza: askeza)
                
                // Then countdown
                ProgressSectionView(
                    askeza: askeza,
                    viewModel: viewModel,
                    currentProgress: currentProgress
                )
                
                // Если аскеза связана с практикой, показываем информацию из практики
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
    let currentProgress: Binding<Int>
    @State private var currentDate = Date()
    @State private var timer: Timer?
    @State private var lastMidnightCheck = Date()
    @State private var lastProgress: Int = 0
    
    private var isCompleted: Bool {
        viewModel.completedAskezas.contains(where: { $0.id == askeza.id })
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Time details
            VStack(spacing: 8) {
                // Сначала показываем дату начала для всех аскез
                startDateView
                
                // Затем показываем заголовок
                timeHeaderView
                
                // Используем текущую дату для пересчета компонентов времени
                let timeComponents = calculateTimeComponents(for: currentDate)
                
                VStack(spacing: 8) {
                    VStack(spacing: 20) {
                        timeComponentsView(timeComponents: timeComponents)
                    }
                    .padding(.top, 8)
                    .transaction { transaction in
                        transaction.animation = .easeInOut(duration: 0.3)
                    }
                    // Добавляем ID с текущей датой, чтобы заставить SwiftUI обновлять представление
                    .id("time_components_\(Int(currentDate.timeIntervalSince1970))")
                    
                    progressBarView
                }
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
            lastProgress = currentProgress.wrappedValue // Запоминаем текущий прогресс
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: currentProgress.wrappedValue) { oldValue, newValue in
            // Форсируем обновление при изменении прогресса
            if oldValue != newValue {
                withAnimation {
                    currentDate = Date() // Обновляем дату, чтобы пересчитать компоненты времени
                }
            }
        }
    }
    
    private var timeHeaderView: some View {
        Group {
            if isCompleted {
                Text("аскеза завершена")
                    .font(.system(size: 16, weight: .light, design: .serif))
                    .foregroundColor(AskezaTheme.accentColor)
                    .italic()
            } else if case .lifetime = askeza.duration {
                Text("аскеза в течение")
                    .font(.system(size: 16, weight: .light, design: .serif))
                    .foregroundColor(Color.indigo)
                    .italic()
            } else if case .days(_) = askeza.duration {
                Text("до завершения аскезы")
                    .font(.system(size: 16, weight: .light, design: .serif))
                    .foregroundColor(AskezaTheme.accentColor)
                    .italic()
            }
        }
        .padding(.bottom, 4)
    }
    
    private var startDateView: some View {
        // Показываем дату начала для всех типов аскез с улучшенным стилем
        HStack(spacing: 4) {
            Image(systemName: "calendar")
                .font(.system(size: 12))
                .foregroundColor(AskezaTheme.secondaryTextColor)
            
            Text("начало:")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AskezaTheme.secondaryTextColor)
            
            Text(formatStartDate())
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(askeza.duration == .lifetime ? Color.indigo : AskezaTheme.accentColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AskezaTheme.backgroundColor)
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        )
        .padding(.bottom, 4)
        .id("start_date_\(askeza.id)")
    }
    
    private func formatStartDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: askeza.startDate)
    }
    
    @ViewBuilder
    private func timeComponentsView(timeComponents: (years: Int, months: Int, days: Int, hours: Int, minutes: Int, seconds: Int)) -> some View {
        if case .lifetime = askeza.duration {
            // Для пожизненной аскезы показываем годы, дни, часы, минуты и секунды
            HStack(spacing: 8) {
                if timeComponents.years > 0 {
                    TimeUnitView(
                        value: timeComponents.years,
                        unit: "год",
                        color: Color.green
                    )
                    .id("years_\(timeComponents.years)_\(Int(currentDate.timeIntervalSince1970))")
                }
                
                if timeComponents.months > 0 {
                    TimeUnitView(
                        value: timeComponents.months,
                        unit: "месяц",
                        color: Color.indigo
                    )
                    .id("months_\(timeComponents.months)_\(Int(currentDate.timeIntervalSince1970))")
                }
                
                TimeUnitView(
                    value: timeComponents.days,
                    unit: "день",
                    color: Color.indigo
                )
                .id("days_\(timeComponents.days)_\(Int(currentDate.timeIntervalSince1970))")
                
                TimeUnitView(
                    value: timeComponents.hours,
                    unit: "час",
                    color: Color.indigo.opacity(0.8)
                )
                .id("hours_\(timeComponents.hours)_\(Int(currentDate.timeIntervalSince1970))")
                
                TimeUnitView(
                    value: timeComponents.minutes,
                    unit: "минута",
                    color: Color.indigo.opacity(0.6)
                )
                .id("minutes_\(timeComponents.minutes)_\(Int(currentDate.timeIntervalSince1970))")
                
                SecondsView(seconds: timeComponents.seconds)
            }
            .padding(.horizontal, 8)
        }
        // Для завершенных аскез показываем только дни, без часов/минут/секунд
        else if isCompleted {
            TimeUnitView(
                value: currentProgress.wrappedValue,
                unit: "день",
                color: AskezaTheme.accentColor
            )
            .id("completed_days_\(currentProgress.wrappedValue)")
        } else {
            HStack(spacing: 8) {
                if timeComponents.years > 0 {
                    TimeUnitView(
                        value: timeComponents.years,
                        unit: "год",
                        color: AskezaTheme.accentColor
                    )
                    .id("years_\(timeComponents.years)_\(Int(currentDate.timeIntervalSince1970))")
                }
                
                if timeComponents.months > 0 {
                    TimeUnitView(
                        value: timeComponents.months,
                        unit: "месяц",
                        color: AskezaTheme.accentColor.opacity(0.9)
                    )
                    .id("months_\(timeComponents.months)_\(Int(currentDate.timeIntervalSince1970))")
                }
                
                TimeUnitView(
                    value: timeComponents.days,
                    unit: "день",
                    color: AskezaTheme.accentColor.opacity(0.8)
                )
                .id("days_\(timeComponents.days)_\(Int(currentDate.timeIntervalSince1970))")
                
                TimeUnitView(
                    value: timeComponents.hours,
                    unit: "час",
                    color: AskezaTheme.accentColor.opacity(0.7)
                )
                .id("hours_\(timeComponents.hours)_\(Int(currentDate.timeIntervalSince1970))")
                
                TimeUnitView(
                    value: timeComponents.minutes,
                    unit: "минута",
                    color: AskezaTheme.accentColor.opacity(0.6)
                )
                .id("minutes_\(timeComponents.minutes)_\(Int(currentDate.timeIntervalSince1970))")
                
                SecondsView(seconds: timeComponents.seconds)
            }
            .padding(.horizontal, 8)
        }
    }
    
    private var progressBarView: some View {
        let isPermanent = askeza.duration == .lifetime
        let totalDays: Int? = {
            if case .days(let days) = askeza.duration { return days }
            return nil
        }()
        
        return CustomProgressBar(
            isPermanent: isPermanent,
            progress: currentProgress.wrappedValue,
            totalDays: totalDays
        )
        .frame(height: 12)
        .padding(.horizontal)
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            // Обновляем текущую дату без анимации, чтобы не было задержек
            currentDate = Date()
            checkMidnight(currentDate)
        }
        
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func calculateTimeComponents(for date: Date) -> (years: Int, months: Int, days: Int, hours: Int, minutes: Int, seconds: Int) {
        let calendar = Calendar.current
        
        if case .lifetime = askeza.duration {
            // Для пожизненных аскез показываем прогресс с момента создания аскезы
            // Рассчитываем время, прошедшее с момента создания
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: askeza.startDate, to: date)
            
            return (
                years: components.year ?? 0,
                months: components.month ?? 0,
                days: components.day ?? 0,
                hours: components.hour ?? 0,
                minutes: components.minute ?? 0,
                seconds: components.second ?? 0
            )
        } else if case .days(let duration) = askeza.duration {
            // Для обычной аскезы показываем оставшееся время
            let remainingDays = max(0, duration - currentProgress.wrappedValue)
            
            // Конвертируем оставшиеся дни в годы, месяцы и дни
            let years = remainingDays / 365
            let remainingAfterYears = remainingDays % 365
            let months = remainingAfterYears / 30
            let days = remainingAfterYears % 30
            
            // Получаем следующую полночь для расчета оставшихся часов, минут и секунд
            var nextMidnightComponents = DateComponents()
            nextMidnightComponents.day = 1
            nextMidnightComponents.second = 0
            let nextMidnight = calendar.startOfDay(for: calendar.date(byAdding: nextMidnightComponents, to: date) ?? date)
            let remainingComponents = calendar.dateComponents([.hour, .minute, .second], from: date, to: nextMidnight)
            
            return (
                years: years,
                months: months,
                days: days,
                hours: remainingComponents.hour ?? 0,
                minutes: remainingComponents.minute ?? 0,
                seconds: remainingComponents.second ?? 0
            )
        }
        
        return (0, 0, 0, 0, 0, 0)
    }
    
    private func checkMidnight(_ now: Date) {
        let calendar = Calendar.current
        if !calendar.isDate(lastMidnightCheck, inSameDayAs: now) {
            // Обновляем прогресс для всех типов аскез
            // Вместо изменения прогресса напрямую, мы будем обновлять дату начала
            let components = calendar.dateComponents([.day], from: askeza.startDate, to: now)
            let totalDays = max(0, components.day ?? 0)
            
            // Проверяем, изменился ли прогресс
            if totalDays != currentProgress.wrappedValue {
                // Обновляем дату начала аскезы
                viewModel.updateAskezaStartDate(askeza, newStartDate: askeza.startDate)
            }
            
            lastMidnightCheck = now
        }
    }
}

fileprivate struct CustomProgressBar: View {
    let isPermanent: Bool
    let progress: Int
    let totalDays: Int?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Фон
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.15))
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                // Прогресс
                progressFill(width: calculateWidth(geometry.size.width))
                    .animation(.easeInOut, value: progress)
                
                // Текст прогресса
                if let total = totalDays, total > 0 {
                    Text("\(progress)/\(total)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 1)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                } else if isPermanent {
                    Text("∞")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 1)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
    
    @ViewBuilder
    private func progressFill(width: CGFloat) -> some View {
        if isPermanent {
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.indigo, Color.indigo.opacity(0.7)]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: width)
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [AskezaTheme.accentColor, AskezaTheme.accentColor.opacity(0.7)]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: width)
        }
    }
    
    private func calculateWidth(_ totalWidth: CGFloat) -> CGFloat {
        if isPermanent {
            return totalWidth
        }
        
        guard let total = totalDays, total > 0 else {
            return 0
        }
        
        let ratio = min(1.0, max(0, CGFloat(progress) / CGFloat(total)))
        return totalWidth * ratio
    }
}

fileprivate struct TimeUnitView: View {
    let value: Int
    let unit: String
    let color: Color
    
    private var label: String {
        getLabel(value: value, unit: unit)
    }
    
    // Добавляем анимацию для секунд
    private var isSeconds: Bool {
        unit == "секунда"
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Улучшенный фон для цифр
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 42)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    .scaleEffect(isSeconds ? 1.0 + sin(Double(value) * 0.1) * 0.08 : 1.0)
                
                Text("\(value)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(color)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.horizontal, 2)
                    .scaleEffect(isSeconds ? 1.0 + sin(Double(value) * 0.1) * 0.05 : 1.0)
            }
            .animation(isSeconds ? .easeInOut(duration: 0.08) : nil, value: value)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AskezaTheme.secondaryTextColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(width: 50)
    }
    
    private func getLabel(value: Int, unit: String) -> String {
        switch unit {
        case "год":
            switch value {
            case 1: return "год"
            case 2...4: return "года"
            default: return "лет"
            }
        case "месяц":
            switch value {
            case 1: return "месяц"
            case 2...4: return "месяца"
            default: return "месяцев"
            }
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
            case 1: return "сек"
            case 2...4: return "сек"
            default: return "сек"
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
        Button("Изменить дату начала") {
            state.selectedStartDate = askeza.startDate
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
            .sheet(isPresented: $state.showingProgressEdit) {
                DatePickerView(
                    startDate: $state.selectedStartDate,
                    askeza: askeza,
                    viewModel: viewModel
                )
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

// Компонент для отображения статуса практики
private struct TemplateStatusBadge: View {
    let status: TemplateStatus
    let timesCompleted: Int
    let isPermanent: Bool
    
    init(status: TemplateStatus, timesCompleted: Int = 0, isPermanent: Bool = false) {
        self.status = status
        self.timesCompleted = timesCompleted
        self.isPermanent = isPermanent
    }
    
    var body: some View {
        Text(statusText)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundOpacity)
            .cornerRadius(6)
    }
    
    private var backgroundOpacity: some View {
        statusColor.opacity(0.2)
    }
    
    private var statusText: String {
        if isPermanent && status == .inProgress {
            return "Пожизненная ∞"
        }
        
        switch status {
        case .notStarted:
            return "Не начата"
        case .inProgress:
            return "В процессе"
        case .completed:
            return "Завершена"
        case .mastered:
            if isPermanent {
                return "Освоена ∞"
            } else {
                return "Освоена"
            }
        }
    }
    
    private var statusColor: Color {
        if isPermanent && (status == .inProgress || status == .mastered) {
            return Color.indigo
        }
        
        switch status {
        case .notStarted:
            return Color.gray
        case .inProgress:
            return Color.blue
        case .completed:
            return Color.green
        case .mastered:
            if isPermanent {
                return Color.indigo
            } else {
                return Color.purple
            }
        }
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

// Добавляем представление для информации о практике аскезы
private struct TemplateInfoView: View {
    let template: PracticeTemplate?
    let progress: TemplateProgress?
    
    var body: some View {
        if let template = template {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Информация о практике")
                            .font(.headline)
                            .foregroundColor(AskezaTheme.textColor)
                        
                        if let progress = progress, progress.timesCompleted > 0 {
                            Text("Пройдено \(progress.timesCompleted) \(pluralForm(progress.timesCompleted))")
                                .font(.subheadline)
                                .foregroundColor(AskezaTheme.accentColor)
                        }
                    }
                    
                    Spacer()
                    
                    // Статус практики
                    if let progress = progress {
                        let status = progress.status(templateDuration: template.duration)
                        TemplateStatusBadge(
                            status: status, 
                            timesCompleted: progress.timesCompleted,
                            isPermanent: template.duration == 0  // true для пожизненных практик
                        )
                    }
                }
                
                // Если есть цитата из практики, показываем ее
                if !template.quote.isEmpty {
                    Text("«\(template.quote)»")
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .italic()
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                        .padding(.vertical, 4)
                }
                
                // Если есть описание в практике, показываем его
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
}

// Новое представление для выбора даты начала
fileprivate struct DatePickerView: View {
    @Binding var startDate: Date
    let askeza: Askeza
    let viewModel: AskezaViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Выберите дату начала аскезы")
                    .font(.headline)
                    .padding(.top)
                
                DatePicker(
                    "Дата начала",
                    selection: $startDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Text("Текущий прогресс: \(calculateProgress()) дней")
                    .font(.subheadline)
                    .foregroundColor(AskezaTheme.secondaryTextColor)
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Изменить дату начала", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Отмена") {
                    dismiss()
                },
                trailing: Button("Сохранить") {
                    // Обновляем дату начала аскезы
                    viewModel.updateAskezaStartDate(askeza, newStartDate: startDate)
                    dismiss()
                }
            )
        }
    }
    
    private func calculateProgress() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: Date())
        return max(0, components.day ?? 0)
    }
}

// Добавляем специальный вид для секунд с более заметной анимацией
fileprivate struct SecondsView: View {
    let seconds: Int
    let color: Color
    
    init(seconds: Int, color: Color = AskezaTheme.accentColor.opacity(0.4)) {
        self.seconds = seconds
        self.color = color
    }
    
    var body: some View {
        // Вызываем TimeUnitView с уникальной ID для анимации
        TimeUnitView(
            value: seconds,
            unit: "секунда",
            color: color
        )
        .id("seconds_\(seconds)_\(UUID())")
        .transition(.opacity.combined(with: .scale))
        .animation(.spring(response: 0.18, dampingFraction: 0.7), value: seconds)
        // Добавляем эффект пульсации
        .modifier(PulseModifier(seconds: seconds))
    }
}

// Модификатор для создания эффекта пульсации
struct PulseModifier: ViewModifier {
    let seconds: Int
    
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.03 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
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
