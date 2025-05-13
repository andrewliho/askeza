import SwiftUI

struct AskezaCreationFlowView: View {
    @ObservedObject var viewModel: AskezaViewModel
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    let onCreated: ((Askeza) -> Void)?
    
    @State private var selectedCategory: AskezaCategory?
    @State private var selectedPresetAskeza: PresetAskeza?
    @State private var showingPresetList = false
    @State private var showingCustomCreation = false
    @State private var createdAskeza: Askeza?
    
    // Добавляем явные свойства для хранения данных шаблона
    @State private var presetTitle: String = ""
    @State private var presetIntention: String = ""
    @State private var presetCategory: AskezaCategory = .custom
    
    // Словарь предустановленных аскез
    private let presetAskezas: [AskezaCategory: [PresetAskeza]] = [
        .osvobozhdenie: [
            PresetAskeza(title: "Отказ от алкоголя",
                        description: "Полный отказ от алкоголя ради ясности ума и энергии",
                        intention: "Обрести ясность ума и энергию",
                        category: .osvobozhdenie),
            PresetAskeza(title: "Отказ от никотина",
                        description: "Свобода от курения и вейпов. Возвращение к чистому дыханию",
                        intention: "Вернуться к чистому дыханию",
                        category: .osvobozhdenie),
            PresetAskeza(title: "Без сахара",
                        description: "Исключение сладостей ради контроля, энергии и ясности",
                        intention: "Обрести контроль над питанием и улучшить энергию",
                        category: .osvobozhdenie),
            PresetAskeza(title: "Без кофеина",
                        description: "Осознанный отдых от кофе, чая, энергетиков",
                        intention: "Восстановить естественную энергию без стимуляторов",
                        category: .osvobozhdenie),
            PresetAskeza(title: "Детокс от соцсетей",
                        description: "Неделя без Instagram, TikTok, VK. Цель — внимание и энергия",
                        intention: "Вернуть внимательность и время к важным вещам",
                        category: .osvobozhdenie),
            PresetAskeza(title: "Цифровой детокс",
                        description: "Каждый день минимум 1 час без экрана",
                        intention: "Жить в реальной жизни, а не только в сети",
                        category: .osvobozhdenie),
            PresetAskeza(title: "Антипрокрастинация",
                        description: "Делай главное дело дня без отлагательств",
                        intention: "Обрести продуктивность и довести дела до конца",
                        category: .osvobozhdenie)
        ],
        .telo: [
            PresetAskeza(title: "Холодный душ",
                        description: "Победа над комфортом каждое утро",
                        intention: "Укрепить силу воли и иммунитет",
                        category: .telo),
            PresetAskeza(title: "10 000 шагов",
                        description: "Прогулка как медитация в действии",
                        intention: "Улучшить здоровье и обрести ясность ума",
                        category: .telo),
            PresetAskeza(title: "Бег каждый день",
                        description: "Минимум 1 км или 10 минут пробежки в день",
                        intention: "Укрепить тело и дух через постоянное движение",
                        category: .telo),
            PresetAskeza(title: "Интервальное голодание",
                        description: "Питание в окне. Чистое тело — ясный ум",
                        intention: "Очистить организм и наладить обмен веществ",
                        category: .telo),
            PresetAskeza(title: "Утренняя растяжка",
                        description: "Активизация тела через 5–10 минут движения",
                        intention: "Начинать день с заботы о своем теле",
                        category: .telo)
        ],
        .um: [
            PresetAskeza(title: "Медитация",
                        description: "Ежедневная практика осознанности",
                        intention: "Обрести внутренний покой и ясность мышления",
                        category: .um),
            PresetAskeza(title: "Чтение книг",
                        description: "Ежедневное чтение для развития ума",
                        intention: "Развивать интеллект и эрудицию",
                        category: .um),
            PresetAskeza(title: "Изучение нового",
                        description: "Каждый день узнавать что-то новое",
                        intention: "Расширять кругозор и поддерживать гибкость ума",
                        category: .um),
            PresetAskeza(title: "Дневник осознанности",
                        description: "Запиши 3 осознанных момента дня",
                        intention: "Развивать осознанность и присутствие",
                        category: .um)
        ],
        .dukh: [
            PresetAskeza(title: "Благодарность",
                        description: "Практика благодарности каждое утро",
                        intention: "Культивировать чувство счастья и удовлетворенности",
                        category: .dukh),
            PresetAskeza(title: "Молитва",
                        description: "Ежедневная духовная практика",
                        intention: "Укрепить духовную связь и обрести спокойствие",
                        category: .dukh),
            PresetAskeza(title: "Безмолвие",
                        description: "Час тишины каждый день",
                        intention: "Услышать голос своей души и интуиции",
                        category: .dukh)
        ],
        .otnosheniya: [
            PresetAskeza(title: "Доброе слово",
                        description: "Говорить только добрые слова",
                        intention: "Создавать позитивную атмосферу вокруг себя",
                        category: .otnosheniya),
            PresetAskeza(title: "Благодарность близким",
                        description: "Выражать благодарность родным каждый день",
                        intention: "Укрепить связь с родными и любимыми",
                        category: .otnosheniya),
            PresetAskeza(title: "Качественное время",
                        description: "Час полного внимания близким каждый день",
                        intention: "Углубить отношения с близкими людьми",
                        category: .otnosheniya)
        ],
        .velikie: [
            PresetAskeza(title: "Путь воина",
                        description: "Ежедневное преодоление своих границ",
                        intention: "Становиться лучше себя вчерашнего",
                        category: .velikie),
            PresetAskeza(title: "Творческая дисциплина",
                        description: "Создавай каждый день, без исключений",
                        intention: "Развить мастерство через ежедневную практику",
                        category: .velikie),
            PresetAskeza(title: "Мастерство",
                        description: "Посвящай минимум 1 час в день своему мастерству",
                        intention: "Достичь высот в выбранном деле",
                        category: .velikie)
        ]
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AskezaTheme.backgroundColor
                    .ignoresSafeArea()
                
                if selectedCategory == nil {
                    // Шаг 1: Выбор категории
                    VStack(spacing: 24) {
                        Text("Выберите категорию аскезы")
                            .font(AskezaTheme.titleFont)
                            .foregroundColor(AskezaTheme.textColor)
                            .padding(.top)
                        
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(AskezaCategory.allCases.filter { $0 != .custom }, id: \.self) { category in
                                    Button {
                                        withAnimation {
                                            selectedCategory = category
                                            showingPresetList = true
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: category.systemImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(category.mainColor)
                                            
                                            VStack(alignment: .leading) {
                                                Text(category.rawValue)
                                                    .font(AskezaTheme.bodyFont)
                                                    .foregroundColor(Color.white)
                                                    .padding(.bottom, 2)
                                                
                                                Text(categoryDescription(for: category))
                                                    .font(.system(size: 14))
                                                    .foregroundColor(Color.white.opacity(0.7))
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(category.mainColor)
                                        }
                                        .padding()
                                        .background(AskezaTheme.buttonBackground)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                } else if showingPresetList {
                    // Шаг 2: Выбор готовой аскезы или создание своей
                    VStack(spacing: 20) {
                        HStack {
                            Button {
                                withAnimation {
                                    selectedCategory = nil
                                    showingPresetList = false
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(AskezaTheme.accentColor)
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            Text("Выберите аскезу")
                                .font(AskezaTheme.titleFont)
                                .foregroundColor(AskezaTheme.textColor)
                            
                            Spacer()
                            
                            Button {
                                dismiss()
                            } label: {
                                Text("Отмена")
                                    .foregroundColor(AskezaTheme.accentColor)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top)
                        
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                Button {
                                    // Сбрасываем все данные перед открытием формы создания своей аскезы
                                    selectedPresetAskeza = nil
                                    presetTitle = ""
                                    presetIntention = ""
                                    presetCategory = selectedCategory ?? .custom
                                    showingCustomCreation = true
                                } label: {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(AskezaTheme.accentColor)
                                            .font(.system(size: 30))
                                        
                                        Text("Своя аскеза")
                                            .font(AskezaTheme.bodyFont)
                                            .foregroundColor(AskezaTheme.accentColor)
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(AskezaTheme.buttonBackground)
                                    .cornerRadius(12)
                                }
                                
                                if let category = selectedCategory {
                                    ForEach(presetAskezas[category] ?? [], id: \.title) { askeza in
                                        Button {
                                            // Сохраняем данные шаблона в свойства представления
                                            selectedPresetAskeza = askeza
                                            presetTitle = askeza.title
                                            presetIntention = askeza.intention
                                            presetCategory = askeza.category
                                            
                                            // Даем время для сохранения данных перед открытием нового представления
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                showingCustomCreation = true
                                            }
                                        } label: {
                                            HStack(spacing: 16) {
                                                Image(systemName: askeza.category.systemImage)
                                                    .foregroundColor(askeza.category.mainColor)
                                                    .font(.system(size: 24))
                                                    .padding(.trailing, 4)
                                                
                                                VStack(alignment: .leading, spacing: 12) {
                                                    Text(askeza.title)
                                                        .font(AskezaTheme.bodyFont)
                                                        .foregroundColor(Color.white)
                                                    
                                                    Text(askeza.description)
                                                        .font(.system(size: 14))
                                                        .foregroundColor(Color.white.opacity(0.7))
                                                    
                                                    Text(askeza.intention)
                                                        .font(.system(size: 15, weight: .light, design: .serif))
                                                        .foregroundColor(AskezaTheme.intentColor)
                                                        .italic()
                                                }
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                            .background(AskezaTheme.buttonBackground)
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCustomCreation) {
                NavigationView {
                    if selectedPresetAskeza != nil {
                        // Используем сохраненные свойства вместо прямого доступа к selectedPresetAskeza
                        CreateAskezaView(
                            viewModel: viewModel,
                            isPresented: $showingCustomCreation,
                            presetTitle: presetTitle,
                            presetWish: presetIntention,
                            categoryHint: presetCategory
                        ) { newAskeza in
                            createdAskeza = newAskeza
                            onCreated?(newAskeza)
                            isPresented = false
                        }
                    } else {
                        CreateAskezaView(
                            viewModel: viewModel,
                            isPresented: $showingCustomCreation,
                            categoryHint: selectedCategory
                        ) { newAskeza in
                            createdAskeza = newAskeza
                            onCreated?(newAskeza)
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
    
    // Функция для получения описания категории
    private func categoryDescription(for category: AskezaCategory) -> String {
        switch category {
        case .telo:
            return "Практики для физического здоровья и дисциплины"
        case .um:
            return "Упражнения для ментальной ясности и фокуса"
        case .dukh:
            return "Практики для душевного равновесия и мудрости"
        case .otnosheniya:
            return "Упражнения для улучшения отношений с близкими"
        case .osvobozhdenie:
            return "Практики борьбы с вредными привычками и зависимостями"
        case .velikie:
            return "Серьезные практики для достижения мастерства"
        default:
            return ""
        }
    }
}

#Preview {
    AskezaCreationFlowView(
        viewModel: AskezaViewModel(),
        isPresented: .constant(true),
        onCreated: nil
    )
} 