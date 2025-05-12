import Foundation
import SwiftUI
import Combine
import SwiftData

// Сервис для работы с шаблонами практик
public class TemplateService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // CRUD операции
    
    func fetchTemplates() -> [PracticeTemplate] {
        let descriptor = FetchDescriptor<PracticeTemplate>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func getTemplate(byID id: UUID) -> PracticeTemplate? {
        let allTemplates = fetchTemplates()
        return allTemplates.first { template in
            template.id == id
        }
    }
    
    func getTemplate(byTemplateId templateId: String) -> PracticeTemplate? {
        let allTemplates = fetchTemplates()
        return allTemplates.first { template in
            template.templateId == templateId
        }
    }
    
    func saveTemplate(_ template: PracticeTemplate) {
        modelContext.insert(template)
        try? modelContext.save()
    }
    
    func deleteTemplate(_ template: PracticeTemplate) {
        modelContext.delete(template)
        try? modelContext.save()
    }
    
    func filteredTemplates(category: AskezaCategory? = nil, 
                          difficulty: Int? = nil, 
                          duration: Int? = nil, 
                          searchText: String = "") -> [PracticeTemplate] {
        // Получаем все шаблоны
        let templatesDescriptor = FetchDescriptor<PracticeTemplate>()
        let allTemplates = (try? modelContext.fetch(templatesDescriptor)) ?? []
        
        // Фильтруем их в памяти
        return allTemplates.filter { template in
            // Проверяем соответствие категории, если задана
            if let category = category, template.category != category {
                return false
            }
            
            // Проверяем соответствие сложности, если задана
            if let difficulty = difficulty, template.difficulty != difficulty {
                return false
            }
            
            // Проверяем соответствие длительности, если задана
            if let duration = duration, template.duration != duration {
                return false
            }
            
            // Проверяем соответствие поисковому запросу, если задан
            if !searchText.isEmpty {
                let matchesTitle = template.title.localizedStandardContains(searchText)
                let matchesDescription = template.practiceDescription.localizedStandardContains(searchText)
                let matchesIntention = template.intention.localizedStandardContains(searchText)
                
                if !(matchesTitle || matchesDescription || matchesIntention) {
                    return false
                }
            }
            
            return true
        }
    }
    
    // Импорт шаблонов из JSON
    func importTemplatesFromJSON(_ jsonData: Data) -> Bool {
        do {
            // Используем TemplateImport для декодирования, так как PracticeTemplate не Decodable
            let templateImports = try JSONDecoder().decode([TemplateImport].self, from: jsonData)
            for templateData in templateImports {
                let template = templateData.toPracticeTemplate()
                saveTemplate(template)
            }
            return true
        } catch {
            print("Error importing templates: \(error)")
            return false
        }
    }
}

// Сервис для работы с прогрессом пользователя
public class ProgressService {
    private let modelContext: ModelContext
    private let userService: UserService
    
    init(modelContext: ModelContext, userService: UserService) {
        self.modelContext = modelContext
        self.userService = userService
    }
    
    func getProgress(forTemplateID templateID: UUID) -> TemplateProgress? {
        // Вместо прямого сравнения UUID создаем предикат более простым способом
        let allProgress = (try? modelContext.fetch(FetchDescriptor<TemplateProgress>())) ?? []
        
        // Фильтруем в коде
        return allProgress.first { progress in
            progress.templateID == templateID
        }
    }
    
    func getStatus(forTemplateID templateID: UUID) -> TemplateStatus {
        // Получаем все шаблоны и находим подходящий
        let templatesDescriptor = FetchDescriptor<PracticeTemplate>()
        let templates = (try? modelContext.fetch(templatesDescriptor)) ?? []
        
        // Ищем шаблон с нужным ID
        guard let template = templates.first(where: { $0.id == templateID }),
              let templateProgress = getProgress(forTemplateID: templateID) else {
            return .notStarted
        }
        
        return templateProgress.status(templateDuration: template.duration)
    }
    
    func startTemplate(_ template: PracticeTemplate) -> Askeza? {
        // Проверяем, есть ли активный прогресс для этого шаблона
        if let existingProgress = getProgress(forTemplateID: template.id) {
            // Проверяем, не завершен ли шаблон
            let status = existingProgress.status(templateDuration: template.duration)
            if status == .inProgress {
                // Если шаблон уже в процессе, не позволяем создать новую аскезу
                return nil
            }
            
            // Обновляем прогресс, если это повторный запуск завершенного шаблона
            existingProgress.dateStarted = Date()
            existingProgress.currentStreak = 0
        } else {
            // Создаем новый прогресс
            let newProgress = TemplateProgress(
                templateID: template.id,
                dateStarted: Date()
            )
            modelContext.insert(newProgress)
        }
        
        try? modelContext.save()
        
        // Создаем аскезу
        return template.createAskeza()
    }
    
    func updateProgress(forTemplateID templateID: UUID, daysCompleted: Int, isCompleted: Bool = false) {
        if let existingProgress = getProgress(forTemplateID: templateID) {
            existingProgress.daysCompleted = daysCompleted
            
            // Если практика завершена, увеличиваем счетчик завершений
            if isCompleted {
                existingProgress.timesCompleted += 1
                
                // Проверяем, нужно ли выдать награду
                awardCompletionXP(forTemplateID: templateID)
                
                // Проверяем, можно ли разблокировать следующий шаг в курсе
                checkAndAdvanceCourse(templateID: templateID)
            }
            
            try? modelContext.save()
        }
    }
    
    func updateStreak(forTemplateID templateID: UUID, streak: Int) {
        if let existingProgress = getProgress(forTemplateID: templateID) {
            existingProgress.currentStreak = streak
            
            // Обновляем лучший стрик, если текущий больше
            if streak > existingProgress.bestStreak {
                existingProgress.bestStreak = streak
            }
            
            try? modelContext.save()
        }
    }
    
    func resetTemplateProgress(forTemplateID templateID: UUID) {
        if let existingProgress = getProgress(forTemplateID: templateID) {
            // Сбрасываем прогресс шаблона
            existingProgress.daysCompleted = 0
            existingProgress.currentStreak = 0
            existingProgress.dateStarted = nil
            
            // Сохраняем изменения
            try? modelContext.save()
        }
    }
    
    // MARK: - Rewards and Gamification
    
    func awardCompletionXP(forTemplateID templateID: UUID) {
        // Получаем все шаблоны и находим подходящий
        let templatesDescriptor = FetchDescriptor<PracticeTemplate>()
        let templates = (try? modelContext.fetch(templatesDescriptor)) ?? []
        
        // Ищем шаблон с нужным ID
        guard let template = templates.first(where: { $0.id == templateID }),
              let progress = getProgress(forTemplateID: templateID) else {
            return
        }
        
        let status = progress.status(templateDuration: template.duration)
        var xpAmount = 0
        
        switch status {
        case .completed:
            // XP за обычное завершение = длительность в днях
            xpAmount = template.duration
        case .mastered:
            // Тройная награда за мастерство
            xpAmount = template.duration * 3
        default:
            break
        }
        
        if xpAmount > 0 {
            userService.addXP(xpAmount)
        }
        
        // Проверяем, достигнуты ли ачивменты
        checkAchievements(forTemplate: template)
    }
    
    func checkAchievements(forTemplate template: PracticeTemplate) {
        // Получаем все прогрессы
        let allProgressDescriptor = FetchDescriptor<TemplateProgress>()
        let allProgress = (try? modelContext.fetch(allProgressDescriptor)) ?? []
        
        // Получаем все шаблоны
        let allTemplatesDescriptor = FetchDescriptor<PracticeTemplate>()
        let allTemplates = (try? modelContext.fetch(allTemplatesDescriptor)) ?? []
        
        // Фильтруем локально для подсчета завершенных шаблонов одной категории
        var completedInCategory = 0
        
        for progress in allProgress {
            if let progressTemplate = allTemplates.first(where: { $0.id == progress.templateID }),
               progressTemplate.category == template.category && 
               progress.status(templateDuration: progressTemplate.duration) == .completed {
                completedInCategory += 1
            }
        }
        
        if completedInCategory >= 5 {
            // Награда за 5 завершенных шаблонов в одной категории
            userService.addXP(50)
            // TODO: Добавить выдачу медали
        }
    }
    
    // MARK: - Course Management
    
    func getNextTemplateInCourse(afterTemplateID templateID: UUID) -> PracticeTemplate? {
        // Находим курс, содержащий этот шаблон
        let courseDescriptor = FetchDescriptor<CoursePath>()
        let courses = (try? modelContext.fetch(courseDescriptor)) ?? []
        
        // Получаем все шаблоны
        let templatesDescriptor = FetchDescriptor<PracticeTemplate>()
        let allTemplates = (try? modelContext.fetch(templatesDescriptor)) ?? []
        
        // Ищем курс, содержащий данный шаблон
        for course in courses {
            if let currentIndex = course.templateIDs.firstIndex(of: templateID),
               currentIndex + 1 < course.templateIDs.count {
                
                // Получаем следующий ID шаблона
                let nextTemplateID = course.templateIDs[currentIndex + 1]
                
                // Ищем соответствующий шаблон
                return allTemplates.first { template in
                    template.id == nextTemplateID
                }
            }
        }
        
        return nil
    }
    
    private func checkAndAdvanceCourse(templateID: UUID) {
        // Логика для продвижения по курсу
        if let nextTemplate = getNextTemplateInCourse(afterTemplateID: templateID) {
            // Можно разблокировать следующий шаблон или отправить уведомление
            print("Разблокирован следующий шаблон в курсе: \(nextTemplate.title)")
        }
    }
}

// Сервис для работы с профилем пользователя
public class UserService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // Создаем профиль пользователя, если его нет
        ensureUserProfileExists()
    }
    
    private func ensureUserProfileExists() {
        let descriptor = FetchDescriptor<UserProfile>()
        let profiles = (try? modelContext.fetch(descriptor)) ?? []
        
        if profiles.isEmpty {
            let newProfile = UserProfile(nickname: "Аскет")
            modelContext.insert(newProfile)
            try? modelContext.save()
        }
    }
    
    func getUserProfile() -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>()
        return (try? modelContext.fetch(descriptor).first)
    }
    
    func updateUserProfile(nickname: String? = nil, avatarURL: URL? = nil) {
        if let profile = getUserProfile() {
            if let nickname = nickname {
                profile.nickname = nickname
            }
            
            if let avatarURL = avatarURL {
                profile.avatarURL = avatarURL
            }
            
            try? modelContext.save()
        }
    }
    
    func addXP(_ amount: Int) {
        if let profile = getUserProfile() {
            let oldLevel = profile.level
            profile.addXP(amount)
            
            try? modelContext.save()
            
            // Проверяем повышение уровня
            if profile.level > oldLevel {
                // TODO: Запустить анимацию уровня
                print("Поздравляем! Вы достигли уровня \(profile.level)!")
            }
        }
    }
}

// Сервис рекомендаций
public class RecommendationEngine {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getRecommendedTemplates(limit: Int = 3) -> [PracticeTemplate] {
        // Получаем все шаблоны
        let allTemplatesDescriptor = FetchDescriptor<PracticeTemplate>()
        let allTemplates = (try? modelContext.fetch(allTemplatesDescriptor)) ?? []
        
        // Временное решение: вернуть первые limit шаблонов
        // TODO: Доработать алгоритм рекомендаций после добавления Askeza в схему SwiftData
        let recommendations = allTemplates.prefix(limit)
        return Array(recommendations)
    }
}

// Dependency Resolver для сервисов
public class ServiceResolver {
    public static let shared = ServiceResolver()
    
    private var modelContext: ModelContext
    private var services: [String: Any] = [:]
    
    private init() {
        // Создаем контейнер SwiftData
        let schema = Schema([
            PracticeTemplate.self,
            TemplateProgress.self,
            CoursePath.self,
            UserProfile.self,
            // Убираем Askeza, так как сейчас она не соответствует PersistentModel
            // Если требуется хранить ее в SwiftData, нужно будет модифицировать класс Askeza
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
        self.modelContext = ModelContext(container)
        
        // Инициализируем сервисы
        registerServices()
    }
    
    private func registerServices() {
        let userService = UserService(modelContext: modelContext)
        services["UserService"] = userService
        
        let templateService = TemplateService(modelContext: modelContext)
        services["TemplateService"] = templateService
        
        let progressService = ProgressService(modelContext: modelContext, userService: userService)
        services["ProgressService"] = progressService
        
        let recommendationEngine = RecommendationEngine(modelContext: modelContext)
        services["RecommendationEngine"] = recommendationEngine
    }
    
    public func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        print("Resolving service with key: \(key)")
        return services[key] as? T
    }
}

// Обновленная версия PracticeTemplateStore, которая использует новые сервисы
public class PracticeTemplateStore: ObservableObject {
    @Published public var templates: [PracticeTemplate] = []
    @Published public var progress: [TemplateProgress] = []
    @Published public var courses: [CoursePath] = []
    @Published public var userProfile: UserProfile?
    
    private let templateService: TemplateService
    private let progressService: ProgressService
    private let userService: UserService
    private let recommendationEngine: RecommendationEngine
    
    public static let shared = PracticeTemplateStore()
    
    private init() {
        // Проверяем, доступны ли сервисы, и инициализируем их с безопасным доступом
        guard let templateService = ServiceResolver.shared.resolve(TemplateService.self),
              let progressService = ServiceResolver.shared.resolve(ProgressService.self),
              let userService = ServiceResolver.shared.resolve(UserService.self),
              let recommendationEngine = ServiceResolver.shared.resolve(RecommendationEngine.self) else {
            // Если какой-то из сервисов не доступен, создаем новый ServiceResolver
            print("Warning: Services not found, initializing new resolver")
            
            // Создаем контейнер SwiftData
            let schema = Schema([
                PracticeTemplate.self,
                TemplateProgress.self,
                CoursePath.self,
                UserProfile.self
            ])
            
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
            let modelContext = ModelContext(container)
            
            // Создаем и сохраняем сервисы напрямую
            let userService = UserService(modelContext: modelContext)
            let templateService = TemplateService(modelContext: modelContext)
            let progressService = ProgressService(modelContext: modelContext, userService: userService)
            let recommendationEngine = RecommendationEngine(modelContext: modelContext)
            
            self.templateService = templateService
            self.progressService = progressService
            self.userService = userService
            self.recommendationEngine = recommendationEngine
            
            loadData()
            return
        }
        
        // Если все сервисы найдены, используем их
        self.templateService = templateService
        self.progressService = progressService
        self.userService = userService
        self.recommendationEngine = recommendationEngine
        
        loadData()
    }
    
    // MARK: - Data Management
    
    private func loadData() {
        templates = templateService.fetchTemplates()
        
        // Если шаблонов нет, создаем демо-данные
        if templates.isEmpty {
            createDemoTemplates()
        }
        
        userProfile = userService.getUserProfile()
    }
    
    // MARK: - Template Management
    
    public func addTemplate(_ template: PracticeTemplate) {
        templateService.saveTemplate(template)
        templates = templateService.fetchTemplates()
    }
    
    public func getTemplate(byID id: UUID) -> PracticeTemplate? {
        return templateService.getTemplate(byID: id)
    }
    
    public func getTemplate(byTemplateId templateId: String) -> PracticeTemplate? {
        return templateService.getTemplate(byTemplateId: templateId)
    }
    
    public func filteredTemplates(category: AskezaCategory? = nil, 
                                difficulty: Int? = nil, 
                                duration: Int? = nil,
                                searchText: String = "") -> [PracticeTemplate] {
        return templateService.filteredTemplates(
            category: category,
            difficulty: difficulty,
            duration: duration,
            searchText: searchText
        )
    }
    
    // MARK: - Progress Management
    
    public func getProgress(forTemplateID templateID: UUID) -> TemplateProgress? {
        return progressService.getProgress(forTemplateID: templateID)
    }
    
    public func getStatus(forTemplateID templateID: UUID) -> TemplateStatus {
        return progressService.getStatus(forTemplateID: templateID)
    }
    
    public func startTemplate(_ template: PracticeTemplate) -> Askeza? {
        return progressService.startTemplate(template)
    }
    
    public func updateProgress(forTemplateID templateID: UUID, daysCompleted: Int, isCompleted: Bool = false) {
        progressService.updateProgress(forTemplateID: templateID, daysCompleted: daysCompleted, isCompleted: isCompleted)
    }
    
    public func updateStreak(forTemplateID templateID: UUID, streak: Int) {
        progressService.updateStreak(forTemplateID: templateID, streak: streak)
    }
    
    public func resetTemplateProgress(_ templateID: UUID) {
        progressService.resetTemplateProgress(forTemplateID: templateID)
    }
    
    // MARK: - Course Management
    
    public func getNextTemplateInCourse(afterTemplateID templateID: UUID) -> PracticeTemplate? {
        return progressService.getNextTemplateInCourse(afterTemplateID: templateID)
    }
    
    // MARK: - Recommendations
    
    public func getRecommendedTemplates(limit: Int = 3) -> [PracticeTemplate] {
        return recommendationEngine.getRecommendedTemplates(limit: limit)
    }
    
    // MARK: - User Profile
    
    public func addXP(_ amount: Int) {
        userService.addXP(amount)
        userProfile = userService.getUserProfile()
    }
    
    public func updateUserProfile(nickname: String? = nil, avatarURL: URL? = nil) {
        userService.updateUserProfile(nickname: nickname, avatarURL: avatarURL)
        userProfile = userService.getUserProfile()
    }
    
    // MARK: - Demo Data
    
    private func createDemoTemplates() {
        // Пробуем импортировать шаблоны из JSON файла
        if !importTemplatesFromJSONFile() {
            // Если импорт не удался, создаем базовые шаблоны программно
            createBasicTemplates()
        }
    }
    
    private func importTemplatesFromJSONFile() -> Bool {
        guard let url = Bundle.main.url(forResource: "Templates", withExtension: "json") else {
            print("Templates.json file not found in bundle")
            return false
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            // Используем TemplateImport для декодирования, который уже соответствует Decodable
            let templateImports = try decoder.decode([TemplateImport].self, from: data)
            
            for templateData in templateImports {
                // Используем конвертер для создания PracticeTemplate из TemplateImport
                let template = templateData.toPracticeTemplate()
                templateService.saveTemplate(template)
            }
            
            // Обновляем локальную копию шаблонов
            templates = templateService.fetchTemplates()
            
            // Создаем курсы на основе импортированных шаблонов
            createCoursesFromTemplates()
            
            return true
        } catch {
            print("Error importing templates from JSON: \(error)")
            return false
        }
    }
    
    private func createCoursesFromTemplates() {
        // Путь здорового тела
        let bodyTemplates = templates.filter { $0.category == .telo }
        if bodyTemplates.count >= 2 {
            let _ = CoursePath(
                title: "Путь физического совершенства",
                description: "Последовательные практики для трансформации тела и энергии.",
                templateIDs: Array(bodyTemplates.prefix(3).map { $0.id }),
                category: .telo,
                difficulty: 2
            )
            // TODO: Сохранить курс через сервис
        }
        
        // Путь ясного ума
        let mindTemplates = templates.filter { $0.category == .um }
        if mindTemplates.count >= 2 {
            let _ = CoursePath(
                title: "Путь ясного ума",
                description: "Последовательные практики для трансформации ума и внимания.",
                templateIDs: Array(mindTemplates.prefix(3).map { $0.id }),
                category: .um,
                difficulty: 2
            )
            // TODO: Сохранить курс через сервис
        }
        
        // Путь освобождения
        let liberationTemplates = templates.filter { $0.category == .osvobozhdenie }
        if liberationTemplates.count >= 2 {
            let _ = CoursePath(
                title: "Путь освобождения",
                description: "Последовательные практики для избавления от зависимостей и ограничений.",
                templateIDs: Array(liberationTemplates.prefix(3).map { $0.id }),
                category: .osvobozhdenie,
                difficulty: 3
            )
            // TODO: Сохранить курс через сервис
        }
    }
    
    // Создание базовых шаблонов, если не удалось импортировать из JSON
    private func createBasicTemplates() {
        let coldShower = PracticeTemplate(
            templateId: "cold-shower-14",
            title: "14-дневный челлендж холодного душа",
            category: .telo,
            duration: 14,
            quote: "Дисциплина — мать свободы.",
            difficulty: 2,
            description: "Победа над комфортом каждое утро. Начните с 30 секунд и постепенно увеличивайте время.",
            intention: "Укрепить силу воли и иммунитет"
        )
        
        let meditation = PracticeTemplate(
            templateId: "daily-meditation-21",
            title: "21 день медитации",
            category: .um,
            duration: 21,
            quote: "Ты — это тишина между мыслями.",
            difficulty: 1,
            description: "Ежедневная практика осознанности. Начните с 5 минут утром и вечером.",
            intention: "Обрести внутренний покой и ясность мышления"
        )
        
        let noSugar = PracticeTemplate(
            templateId: "no-sugar-30",
            title: "30 дней без сахара",
            category: .osvobozhdenie,
            duration: 30,
            quote: "Сладкая жизнь не нуждается в сахаре.",
            difficulty: 3,
            description: "Исключение сладостей и переработанного сахара ради энергии и ясности.",
            intention: "Обрести контроль над питанием и улучшить энергию"
        )
        
        let gratitude = PracticeTemplate(
            templateId: "gratitude-practice-7",
            title: "7 дней благодарности",
            category: .dukh,
            duration: 7,
            quote: "Благодарность превращает то, что у нас есть, в достаточное.",
            difficulty: 1,
            description: "Каждый день записывайте три вещи, за которые вы благодарны.",
            intention: "Культивировать чувство счастья и удовлетворенности"
        )
        
        let digitalDetox = PracticeTemplate(
            templateId: "digital-detox-7",
            title: "7 дней цифрового детокса",
            category: .osvobozhdenie,
            duration: 7,
            quote: "Иногда нужно отключиться, чтобы восстановить связь.",
            difficulty: 2,
            description: "Ограничение использования смартфона и социальных сетей до 30 минут в день.",
            intention: "Вернуть контроль над своим вниманием и временем"
        )
        
        // Сохраняем шаблоны
        addTemplate(coldShower)
        addTemplate(meditation)
        addTemplate(noSugar)
        addTemplate(gratitude)
        addTemplate(digitalDetox)
        
        // Создаем курсы
        let _ = CoursePath(
            title: "Путь физического совершенства",
            description: "Последовательные практики для трансформации тела и энергии.",
            templateIDs: [coldShower.id, noSugar.id],
            category: .telo,
            difficulty: 2
        )
        
        let _ = CoursePath(
            title: "Путь ясного ума",
            description: "Последовательные практики для трансформации ума и внимания.",
            templateIDs: [meditation.id, gratitude.id],
            category: .um,
            difficulty: 2
        )
        
        // TODO: Сохранить курсы через сервис
    }

    // Метод для предварительной загрузки данных шаблона перед отображением
    func preloadTemplateData(for templateID: String) {
        print("⬇️ PracticeTemplateStore - Начата предварительная загрузка данных для шаблона ID: \(templateID)")
        
        // Убедиться, что данные о шаблоне загружены
        var template: PracticeTemplate?
        let isDigitalDetox = templateID.contains("digital-detox") || templateID.contains("цифров")
        
        // Для шаблона цифрового детокса используем фиксированное значение ID
        let templateIdToUse = isDigitalDetox ? "digital-detox-7" : templateID
        
        // Получение шаблона
        template = getTemplate(byTemplateId: templateIdToUse)
        
        // Если не найден по templateId, проверяем особые случаи
        if template == nil {
            if templateID.contains("iron-discipline") || templateID.contains("железн") {
                // Особый случай для "Год железной дисциплины"
                template = templates.first(where: { $0.title.contains("железной") || $0.title.contains("Iron Discipline") })
                print("⚠️ PracticeTemplateStore - Поиск по альтернативному названию для 'Год железной дисциплины'")
            } else if templateID.contains("vegetarian") || templateID.contains("вегет") {
                // Особый случай для "Вегетарианство"
                template = templates.first(where: { $0.title.contains("Вегетарианство") || $0.title.contains("Vegetarian") })
                print("⚠️ PracticeTemplateStore - Поиск по альтернативному названию для 'Вегетарианство'")
            } else if isDigitalDetox {
                // Особый случай для "7 дней цифрового детокса"
                template = templates.first(where: { $0.title.contains("цифрового") || $0.title.contains("digital detox") })
                print("⚠️ PracticeTemplateStore - Поиск по альтернативному названию для '7 дней цифрового детокса'")
                
                // Если шаблон все еще не найден, создаем его
                if template == nil {
                    print("🔨 PracticeTemplateStore - Создаю шаблон '7 дней цифрового детокса'")
                    
                    // Создаем шаблон с уникальным идентификатором
                    let digitalDetoxUUID = UUID()
                    print("🔑 PracticeTemplateStore - Назначен UUID для цифрового детокса: \(digitalDetoxUUID)")
                    
                    let digitalDetox = PracticeTemplate(
                        id: digitalDetoxUUID,
                        templateId: "digital-detox-7",
                        title: "7 дней цифрового детокса",
                        category: .osvobozhdenie,
                        duration: 7,
                        quote: "Иногда нужно отключиться, чтобы восстановить связь.",
                        difficulty: 2,
                        description: "Ограничение использования смартфона и социальных сетей до 30 минут в день.",
                        intention: "Вернуть контроль над своим вниманием и временем"
                    )
                    
                    // Добавляем шаблон
                    addTemplate(digitalDetox)
                    print("✅ PracticeTemplateStore - Создан шаблон цифрового детокса")
                    
                    // Сохраняем ссылку на созданный шаблон
                    template = digitalDetox
                    
                    // Даем базе данных время на сохранение и обработку
                    DispatchQueue.main.async {
                        // Повторно проверяем, доступен ли теперь шаблон
                        if let savedTemplate = self.getTemplate(byTemplateId: "digital-detox-7") {
                            print("✅ PracticeTemplateStore - Шаблон цифрового детокса успешно сохранен в базе")
                            
                            // Создаем прогресс для шаблона
                            self.ensureProgressExists(for: savedTemplate)
                        } else {
                            print("⚠️ PracticeTemplateStore - Шаблон цифрового детокса не найден в базе после сохранения")
                        }
                    }
                    
                    // Форсированно обновляем локальные данные сразу
                    templates = templateService.fetchTemplates()
                }
            }
        }
        
        // Если шаблон найден, загружаем данные
        if let template = template {
            print("✅ PracticeTemplateStore - Шаблон найден: \(template.title), UUID: \(template.id)")
            
            // Для шаблона цифрового детокса делаем дополнительные проверки
            if isDigitalDetox {
                // Проверяем, что templateId установлен правильно
                if template.templateId != "digital-detox-7" {
                    print("⚠️ PracticeTemplateStore - Исправляем templateId для шаблона цифрового детокса")
                    template.templateId = "digital-detox-7"
                }
                
                // Обеспечиваем существование прогресса для цифрового детокса
                ensureProgressExists(for: template)
            }
            
            // Убедиться, что данные о прогрессе загружены
            let progress = getProgress(forTemplateID: template.id)
            if let progress = progress {
                print("✅ PracticeTemplateStore - Прогресс загружен: \(progress.daysCompleted) дней")
            } else {
                print("ℹ️ PracticeTemplateStore - Прогресс отсутствует, создаем пустую запись")
                
                // Если прогресса нет, создаем его
                ensureProgressExists(for: template)
            }
            
            // Убедиться, что статус загружен
            let status = getStatus(forTemplateID: template.id)
            print("✅ PracticeTemplateStore - Статус: \(status.rawValue)")
        } else {
            print("❌ PracticeTemplateStore - Шаблон не найден для ID: \(templateID)")
            
            // Если это цифровой детокс, пытаемся создать его еще раз
            if isDigitalDetox {
                print("🔄 PracticeTemplateStore - Повторная попытка создания шаблона цифрового детокса")
                
                let digitalDetox = PracticeTemplate(
                    templateId: "digital-detox-7",
                    title: "7 дней цифрового детокса",
                    category: .osvobozhdenie,
                    duration: 7,
                    quote: "Иногда нужно отключиться, чтобы восстановить связь.",
                    difficulty: 2,
                    description: "Ограничение использования смартфона и социальных сетей до 30 минут в день.",
                    intention: "Вернуть контроль над своим вниманием и временем"
                )
                
                addTemplate(digitalDetox)
                print("✅ PracticeTemplateStore - Повторное создание шаблона цифрового детокса")
                
                // Обновляем локальный список шаблонов
                templates = templateService.fetchTemplates()
            }
            
            // Выводим список доступных шаблонов для отладки
            print("📋 PracticeTemplateStore - Доступные шаблоны:")
            for (index, availableTemplate) in templates.prefix(5).enumerated() {
                print("  \(index + 1). \(availableTemplate.title) (ID: \(availableTemplate.templateId))")
            }
            if templates.count > 5 {
                print("  ... и еще \(templates.count - 5) шаблонов")
            }
        }
    }
    
    // Вспомогательный метод для обеспечения существования прогресса
    private func ensureProgressExists(for template: PracticeTemplate) {
        if getProgress(forTemplateID: template.id) == nil {
            print("🔨 PracticeTemplateStore - Инициализируем прогресс для шаблона: \(template.title)")
            
            // Вставляем прогресс в базу данных напрямую через startTemplate
            _ = progressService.startTemplate(template)
            print("✅ PracticeTemplateStore - Инициализирован прогресс для шаблона")
        }
    }
}

// Вспомогательная структура для десериализации шаблонов из JSON
struct TemplateImport: Codable {
    let id: String
    let templateId: String
    let title: String
    let category: String
    let duration: Int
    let quote: String
    let difficulty: Int
    let description: String
    let intention: String
    
    func toPracticeTemplate() -> PracticeTemplate {
        return PracticeTemplate(
            id: UUID(uuidString: id) ?? UUID(),
            templateId: templateId,
            title: title,
            category: AskezaCategory.fromString(category),
            duration: duration,
            quote: quote,
            difficulty: difficulty,
            description: description,
            intention: intention
        )
    }
}

// Расширение для преобразования строки категории в enum
extension AskezaCategory {
    static func fromString(_ string: String) -> AskezaCategory {
        switch string.lowercased() {
        case "telo":
            return .telo
        case "um":
            return .um
        case "dukh":
            return .dukh
        case "otnosheniya":
            return .otnosheniya
        case "osvobozhdenie":
            return .osvobozhdenie
        case "velikie":
            return .velikie
        default:
            return .custom
        }
    }
}