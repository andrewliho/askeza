import SwiftUI

struct CreateAskezaView: View {
    @ObservedObject var viewModel: AskezaViewModel
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    let onCreated: ((Askeza) -> Void)?
    
    @State private var title: String
    @State private var selectedDuration: Int = 7
    @State private var wish: String = ""
    @State private var showingDurationPicker = false
    @State private var showingSuccessToast = false
    @State private var navigateToDetail = false
    @State private var createdAskeza: Askeza?
    @State private var showingWishVisualization = false
    
    // Сохраняем начальные значения, чтобы иметь возможность восстановить их при необходимости
    private let initialTitle: String
    private let initialWish: String
    
    private let durations = [
        1: "1 день",
        7: "7 дней",
        30: "30 дней",
        100: "100 дней",
        365: "1 год",
        -1: "Пожизненно (∞)"
    ]
    
    let existingAskeza: Askeza?
    let isExtending: Bool
    let categoryHint: AskezaCategory?
    
    init(viewModel: AskezaViewModel,
         isPresented: Binding<Bool>,
         presetTitle: String = "",
         presetWish: String = "",
         existingAskeza: Askeza? = nil,
         categoryHint: AskezaCategory? = nil,
         onCreated: ((Askeza) -> Void)? = nil) {
        self.viewModel = viewModel
        self._isPresented = isPresented
        
        // Проверяем, создается ли своя аскеза (когда и title и wish пустые)
        let isCustomAskeza = presetTitle.isEmpty && presetWish.isEmpty && existingAskeza == nil
        
        // Детальная отладочная информация
        print("--- Инициализация CreateAskezaView ---")
        print("presetTitle: '\(presetTitle)'")
        print("presetWish: '\(presetWish)'")
        print("isCustomAskeza: \(isCustomAskeza)")
        print("categoryHint: \(categoryHint?.rawValue ?? "нет")")
        
        // Убедимся, что у нас есть непустые значения, или пустые для своей аскезы
        let title = isCustomAskeza ? "" : presetTitle
        let wish = isCustomAskeza ? "" : presetWish
        
        self._title = State(initialValue: title)
        self._wish = State(initialValue: wish)
        self.existingAskeza = existingAskeza
        self.isExtending = existingAskeza != nil
        self.categoryHint = categoryHint
        self.onCreated = onCreated
        
        // Сохраняем начальные значения
        self.initialTitle = title
        self.initialWish = wish
        
        // Более подробный вывод в консоль для отладки
        print("CreateAskezaView initialized with title: '\(title)', wish: '\(wish)', isCustom: \(isCustomAskeza)")
        print("--- Конец инициализации CreateAskezaView ---")
        
        // Теперь по умолчанию используем пожизненную длительность (-1),
        // кроме случаев продления аскезы (для которых сохраняем дневную логику)
        if existingAskeza != nil {
            self._selectedDuration = State(initialValue: 7)
        } else {
            self._selectedDuration = State(initialValue: -1)
        }
    }
    
    var currentProgress: Int {
        existingAskeza?.progress ?? 0
    }
    
    var currentDuration: Int {
        if let askeza = existingAskeza,
           case .days(let days) = askeza.duration {
            return days
        }
        return 0
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AskezaTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text(isExtending ? "Продление Аскезы" : "Создание Аскезы")
                            .font(AskezaTheme.titleFont)
                            .foregroundColor(AskezaTheme.textColor)
                        
                        if isExtending {
                            VStack(spacing: 8) {
                                Text("Текущий прогресс: \(currentProgress) дней")
                                    .font(AskezaTheme.bodyFont)
                                    .foregroundColor(AskezaTheme.secondaryTextColor)
                                Text("Текущий срок: \(currentDuration) дней")
                                    .font(AskezaTheme.bodyFont)
                                    .foregroundColor(AskezaTheme.secondaryTextColor)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Что ты обещаешь?")
                                .font(AskezaTheme.bodyFont)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                            
                            AskezaTextField(placeholder: "Введите текст аскезы", text: $title)
                                .disabled(isExtending)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Желание (необязательно)")
                                .font(AskezaTheme.bodyFont)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                            
                            AskezaTextField(placeholder: "Что ты хочешь получить?", text: $wish)
                                .disabled(isExtending)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(isExtending ? "На сколько дней продлить?" : "Выберите срок")
                                .font(AskezaTheme.bodyFont)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                            
                            Button(action: {
                                showingDurationPicker = true
                            }) {
                                HStack {
                                    Text(durations[selectedDuration] ?? "")
                                        .foregroundColor(AskezaTheme.textColor)
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundColor(AskezaTheme.accentColor)
                                }
                                .padding()
                                .background(AskezaTheme.buttonBackground)
                                .cornerRadius(12)
                            }
                        }
                        
                        AskezaButton(
                            title: isExtending 
                                ? "Продлить" 
                                : (wish.isEmpty ? "Дать обет" : "Дать обет и визуализировать желание")
                        ) {
                            createOrExtendAskeza()
                        }
                        .disabled(title.isEmpty)
                        .opacity(title.isEmpty ? 0.5 : 1)
                    }
                    .padding()
                }
            }
            .navigationDestination(isPresented: $navigateToDetail) {
                if let askeza = createdAskeza {
                    AskezaDetailView(askeza: askeza, viewModel: viewModel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        isPresented = false
                        dismiss()
                    }
                    .foregroundColor(AskezaTheme.accentColor)
                }
            }
            .sheet(isPresented: $showingDurationPicker) {
                NavigationView {
                    ZStack {
                        AskezaTheme.backgroundColor
                            .ignoresSafeArea()
                        
                        List {
                            ForEach(Array(durations.keys.sorted()), id: \.self) { days in
                                if days != -1 || !isExtending { // Скрываем "Пожизненно" при продлении
                                Button(action: {
                                    selectedDuration = days
                                        showingDurationPicker = false
                                }) {
                                    HStack {
                                        Text(durations[days] ?? "")
                                            .foregroundColor(AskezaTheme.textColor)
                                        
                                        Spacer()
                                        
                                        if selectedDuration == days {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(AskezaTheme.accentColor)
                                        }
                                    }
                                    }
                                    .listRowBackground(AskezaTheme.buttonBackground)
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                        }
                    .navigationTitle(isExtending ? "Выберите срок продления" : "Выберите срок")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Готово") {
                                showingDurationPicker = false
                            }
                            .foregroundColor(AskezaTheme.accentColor)
                        }
                    }
                }
            }
            .askezaToast(message: "Аскеза успешно создана! 🎉", isPresented: $showingSuccessToast)
            .sheet(isPresented: $showingWishVisualization) {
                WishVisualizationView {
                    finishCreatingAskeza()
                }
            }
        }
        .onAppear {
            // Проверяем данные при появлении представления
            print("CreateAskezaView appeared with title: '\(title)', wish: '\(wish)'")
            
            // Если заголовок пустой, но у нас есть initialTitle, восстанавливаем его
            if title.isEmpty && !initialTitle.isEmpty {
                title = initialTitle
            }
            
            // Если желание пустое, но у нас есть initialWish, восстанавливаем его
            if wish.isEmpty && !initialWish.isEmpty {
                wish = initialWish
            }
        }
    }
    
    private func createOrExtendAskeza() {
        if isExtending, let existingAskeza = existingAskeza {
            // Логика продления существующей аскезы
            let newDuration: AskezaDuration
            
            if selectedDuration == -1 {
                newDuration = .lifetime
            } else {
                if case .days(let currentDays) = existingAskeza.duration {
                    newDuration = .days(currentDays + selectedDuration)
                } else {
                    newDuration = .days(selectedDuration)
                }
            }
            
            var updatedAskeza = existingAskeza
            updatedAskeza.duration = newDuration
            
            viewModel.updateAskeza(updatedAskeza)
            isPresented = false
        } else {
            // Если есть желание, показываем экран визуализации
            if !wish.isEmpty {
                showingWishVisualization = true
            } else {
                // Если желания нет, создаем аскезу сразу
                finishCreatingAskeza()
            }
        }
    }
    
    // Выносим логику создания аскезы в отдельный метод
    private func finishCreatingAskeza() {
        // Логика создания новой аскезы
        let duration: AskezaDuration = selectedDuration == -1 ? .lifetime : .days(selectedDuration)
        
        // Используем .custom как категорию по умолчанию
        let category: AskezaCategory = .custom
        
        let newAskeza = Askeza(
            title: title,
            intention: nil,
            duration: duration,
            category: category,
            wish: wish.isEmpty ? nil : wish,
            wishStatus: wish.isEmpty ? nil : .waiting
        )
        
        // Используем DispatchQueue.main.async для вызова @MainActor-isolated метода
        DispatchQueue.main.async {
            viewModel.addAskezaToActive(newAskeza)
        }
        
        if let onCreated = onCreated {
            onCreated(newAskeza)
        }
        
        createdAskeza = newAskeza
        showingSuccessToast = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isPresented = false
        }
    }
}

#Preview {
    NavigationView {
    CreateAskezaView(
        viewModel: AskezaViewModel(),
        isPresented: .constant(true),
        presetTitle: "Медитация каждое утро",
        presetWish: "Стать более спокойным и сосредоточенным"
    )
    }
} 