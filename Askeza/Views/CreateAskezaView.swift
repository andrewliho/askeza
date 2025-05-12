import SwiftUI

struct CreateAskezaView: View {
    @ObservedObject var viewModel: AskezaViewModel
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    let onCreated: ((Askeza) -> Void)?
    
    @State private var title: String
    @State private var selectedDuration: Int = 7
    @State private var intention: String = ""
    @State private var showingDurationPicker = false
    @State private var showingCategoryPicker = false
    @State private var showingSuccessToast = false
    @State private var navigateToDetail = false
    @State private var createdAskeza: Askeza?
    
    // Сохраняем начальные значения, чтобы иметь возможность восстановить их при необходимости
    private let initialTitle: String
    private let initialIntention: String
    private let initialCategory: AskezaCategory
    
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
    @State private var selectedCategory: AskezaCategory
    
    init(viewModel: AskezaViewModel,
         isPresented: Binding<Bool>,
         presetTitle: String = "",
         presetIntention: String = "",
         existingAskeza: Askeza? = nil,
         category: AskezaCategory = .custom,
         onCreated: ((Askeza) -> Void)? = nil) {
        self.viewModel = viewModel
        self._isPresented = isPresented
        
        // Проверяем, создается ли своя аскеза (когда и title и intention пустые)
        let isCustomAskeza = presetTitle.isEmpty && presetIntention.isEmpty && existingAskeza == nil
        
        // Убедимся, что у нас есть непустые значения, или пустые для своей аскезы
        let title = isCustomAskeza ? "" : presetTitle
        let intention = isCustomAskeza ? "" : presetIntention
        
        self._title = State(initialValue: title)
        self._intention = State(initialValue: intention)
        self.existingAskeza = existingAskeza
        self.isExtending = existingAskeza != nil
        self._selectedCategory = State(initialValue: category)
        self.onCreated = onCreated
        
        // Сохраняем начальные значения
        self.initialTitle = title
        self.initialIntention = intention
        self.initialCategory = category
        
        // Более подробный вывод в консоль для отладки
        print("CreateAskezaView initialized with title: '\(title)', intention: '\(intention)', category: \(category.rawValue), isCustom: \(isCustomAskeza)")
        
        // Автоматически устанавливаем пожизненную длительность для определенных аскез
        if presetTitle == "Отказ от алкоголя" || presetTitle == "Отказ от никотина" {
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
                        HStack {
                            Image(systemName: selectedCategory.systemImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(AskezaTheme.accentColor)
                            
                            Text(isExtending ? "Продление Аскезы" : "Создание Аскезы")
                            .font(AskezaTheme.titleFont)
                            .foregroundColor(AskezaTheme.textColor)
                        }
                        
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
                            Text("Намерение (необязательно)")
                                .font(AskezaTheme.bodyFont)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                            
                            AskezaTextField(placeholder: "Для чего ты это делаешь?", text: $intention)
                                .disabled(isExtending)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Выберите категорию")
                                .font(AskezaTheme.bodyFont)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                            
                            Button(action: {
                                showingCategoryPicker = true
                            }) {
                                HStack {
                                    let categoryColor = selectedCategory.mainColor
                                    
                                    Image(systemName: selectedCategory.systemImage)
                                        .foregroundColor(categoryColor)
                                    
                                    Text(selectedCategory.rawValue)
                                        .foregroundColor(Color.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundColor(categoryColor)
                                }
                                .padding()
                                .background(AskezaTheme.buttonBackground)
                                .cornerRadius(12)
                            }
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
                        
                        AskezaButton(title: isExtending ? "Продлить" : "Дать обет") {
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
            .sheet(isPresented: $showingCategoryPicker) {
                NavigationView {
                    ZStack {
                        AskezaTheme.backgroundColor
                            .ignoresSafeArea()
                        
                        List {
                            ForEach(AskezaCategory.allCases.filter { $0 != .custom }, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                    showingCategoryPicker = false
                                }) {
                                    HStack {
                                        let categoryColor = category.mainColor
                                        
                                        Image(systemName: category.systemImage)
                                            .foregroundColor(categoryColor)
                                        
                                        Text(category.rawValue)
                                            .foregroundColor(Color.white)
                                        
                                        Spacer()
                                        
                                        if selectedCategory == category {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(categoryColor)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AskezaTheme.buttonBackground)
                                    .cornerRadius(8)
                                }
                                .listRowBackground(AskezaTheme.buttonBackground)
                                .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                    }
                    .navigationTitle("Выберите категорию")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Готово") {
                                showingCategoryPicker = false
                            }
                            .foregroundColor(AskezaTheme.accentColor)
                        }
                    }
                }
            }
            .askezaToast(message: "Аскеза успешно продлена! 🎉", isPresented: $showingSuccessToast)
        }
        .onAppear {
            // Проверяем данные при появлении представления
            print("CreateAskezaView appeared with title: '\(title)', intention: '\(intention)', category: \(selectedCategory.rawValue)")
            
            // Если заголовок пустой, но у нас есть initialTitle, восстанавливаем его
            if title.isEmpty && !initialTitle.isEmpty {
                title = initialTitle
            }
            
            // Если намерение пустое, но у нас есть initialIntention, восстанавливаем его
            if intention.isEmpty && !initialIntention.isEmpty {
                intention = initialIntention
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
            // Логика создания новой аскезы
            let duration: AskezaDuration = selectedDuration == -1 ? .lifetime : .days(selectedDuration)
            
            let newAskeza = Askeza(
                title: title,
                intention: intention.isEmpty ? nil : intention,
                duration: duration,
                category: selectedCategory
            )
            
            viewModel.addAskeza(newAskeza)
            
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
}

#Preview {
    NavigationView {
    CreateAskezaView(
        viewModel: AskezaViewModel(),
        isPresented: .constant(true),
        presetTitle: "Медитация каждое утро",
        presetIntention: "Обрести внутренний покой"
    )
    }
} 