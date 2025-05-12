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
        let descriptor = FetchDescriptor<PracticeTemplate>(predicate: #Predicate { template in
            template.id == id
        })
        return try? modelContext.fetch(descriptor).first
    }
    
    func getTemplate(byTemplateId templateId: String) -> PracticeTemplate? {
        let descriptor = FetchDescriptor<PracticeTemplate>(predicate: #Predicate { template in
            template.templateId == templateId
        })
        return try? modelContext.fetch(descriptor).first
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
        var predicate: Predicate<PracticeTemplate>?
        
        if let category = category {
            let categoryPredicate = #Predicate<PracticeTemplate> { template in
                template.category == category
            }
            predicate = predicate == nil ? categoryPredicate : predicate!.and(categoryPredicate)
        }
        
        if let difficulty = difficulty {
            let difficultyPredicate = #Predicate<PracticeTemplate> { template in
                template.difficulty == difficulty
            }
            predicate = predicate == nil ? difficultyPredicate : predicate!.and(difficultyPredicate)
        }
        
        if let duration = duration {
            let durationPredicate = #Predicate<PracticeTemplate> { template in
                template.duration == duration
            }
            predicate = predicate == nil ? durationPredicate : predicate!.and(durationPredicate)
        }
        
        if !searchText.isEmpty {
            let searchPredicate = #Predicate<PracticeTemplate> { template in
                template.title.localizedStandardContains(searchText) ||
                template.description.localizedStandardContains(searchText) ||
                template.intention.localizedStandardContains(searchText)
            }
            predicate = predicate == nil ? searchPredicate : predicate!.and(searchPredicate)
        }
        
        let descriptor = FetchDescriptor<PracticeTemplate>(predicate: predicate)
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // Импорт шаблонов из JSON
    func importTemplatesFromJSON(_ jsonData: Data) -> Bool {
        do {
            let templates = try JSONDecoder().decode([PracticeTemplate].self, from: jsonData)
            for template in templates {
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
        let descriptor = FetchDescriptor<TemplateProgress>(predicate: #Predicate { progress in
            progress.templateID == templateID
        })
        return try? modelContext.fetch(descriptor).first
    }
    
    func getStatus(forTemplateID templateID: UUID) -> TemplateStatus {
        guard let template = try? modelContext.fetch(FetchDescriptor<PracticeTemplate>(predicate: #Predicate { template in
            template.id == templateID
        })).first,
              let templateProgress = getProgress(forTemplateID: templateID) else {
            return .notStarted
        }
        
        return templateProgress.status(templateDuration: template.duration)
    }
    
    func startTemplate(_ template: PracticeTemplate) -> Askeza {
        let askeza = template.createAskeza()
        
        // Создаем или обновляем прогресс
        if let existingProgress = getProgress(forTemplateID: template.id) {
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
        return askeza
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
    
    // MARK: - Rewards and Gamification
    
    func awardCompletionXP(forTemplateID templateID: UUID) {
        guard let template = try? modelContext.fetch(FetchDescriptor<PracticeTemplate>(predicate: #Predicate { template in
            template.id == templateID
        })).first,
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
        // Проверяем достижение "5 шаблонов одной категории"
        let categoryDescriptor = FetchDescriptor<TemplateProgress>(
            predicate: #Predicate { progress in
                if let template = try? self.modelContext.fetch(FetchDescriptor<PracticeTemplate>(predicate: #Predicate { t in
                    t.id == progress.templateID
                })).first {
                    return template.category == template.category && 
                           progress.status(templateDuration: template.duration) == .completed
                }
                return false
            }
        )
        
        if let completedInCategory = try? modelContext.fetch(categoryDescriptor).count,
           completedInCategory >= 5 {
            // Награда за 5 завершенных шаблонов в одной категории
            userService.addXP(50)
            // TODO: Добавить выдачу медали
        }
    }
    
    // MARK: - Course Management
    
    func getNextTemplateInCourse(afterTemplateID templateID: UUID) -> PracticeTemplate? {
        // Находим курс, содержащий этот шаблон
        let courseDescriptor = FetchDescriptor<CoursePath>(
            predicate: #Predicate { course in
                course.templateIDs.contains(templateID)
            }
        )
        
        guard let course = try? modelContext.fetch(courseDescriptor).first,
              let currentIndex = course.templateIDs.firstIndex(of: templateID),
              currentIndex + 1 < course.templateIDs.count else {
            return nil
        }
        
        let nextTemplateID = course.templateIDs[currentIndex + 1]
        let templateDescriptor = FetchDescriptor<PracticeTemplate>(
            predicate: #Predicate { template in
                template.id == nextTemplateID
            }
        )
        
        return try? modelContext.fetch(templateDescriptor).first
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
        
        // Получаем все активные аскезы пользователя
        let askezasDescriptor = FetchDescriptor<Askeza>(predicate: #Predicate { askeza in
            !askeza.isCompleted
        })
        let activeAskezas = (try? modelContext.fetch(askezasDescriptor)) ?? []
        
        // Анализируем категории активных аскез
        var categoryCounts: [AskezaCategory: Int] = [:]
        for askeza in activeAskezas {
            categoryCounts[askeza.category, default: 0] += 1
        }
        
        // Находим категории с наименьшим количеством аскез
        let sortedCategories = AskezaCategory.allCases.sorted { cat1, cat2 in
            categoryCounts[cat1, default: 0] < categoryCounts[cat2, default: 0]
        }
        
        // Рекомендуем шаблоны из недостающих категорий
        var recommendations: [PracticeTemplate] = []
        
        for category in sortedCategories {
            let categoryTemplates = allTemplates.filter { $0.category == category }
            let notStartedTemplates = categoryTemplates.filter { template in
                let progressDescriptor = FetchDescriptor<TemplateProgress>(predicate: #Predicate { progress in
                    progress.templateID == template.id && progress.dateStarted != nil
                })
                let hasProgress = ((try? modelContext.fetch(progressDescriptor).first) != nil)
                return !hasProgress
            }
            
            recommendations.append(contentsOf: notStartedTemplates.prefix(max(1, limit / 3)))
            
            if recommendations.count >= limit {
                break
            }
        }
        
        // Если у нас все еще недостаточно рекомендаций, добавим наиболее популярные шаблоны
        if recommendations.count < limit {
            let remainingCount = limit - recommendations.count
            let remainingTemplates = allTemplates
                .filter { !recommendations.contains(where: { $0.id == $1.id }) }
                .prefix(remainingCount)
            recommendations.append(contentsOf: remainingTemplates)
        }
        
        return Array(recommendations.prefix(limit))
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
            Askeza.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
        self.modelContext = ModelContext(container)
        
        // Инициализируем сервисы
        registerServices()
    }
    
    private func registerServices() {
        let userService = UserService(modelContext: modelContext)
        services["userService"] = userService
        
        let templateService = TemplateService(modelContext: modelContext)
        services["templateService"] = templateService
        
        let progressService = ProgressService(modelContext: modelContext, userService: userService)
        services["progressService"] = progressService
        
        let recommendationEngine = RecommendationEngine(modelContext: modelContext)
        services["recommendationEngine"] = recommendationEngine
    }
    
    public func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
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
        // Используем ServiceResolver для получения сервисов
        self.templateService = ServiceResolver.shared.resolve(TemplateService.self)!
        self.progressService = ServiceResolver.shared.resolve(ProgressService.self)!
        self.userService = ServiceResolver.shared.resolve(UserService.self)!
        self.recommendationEngine = ServiceResolver.shared.resolve(RecommendationEngine.self)!
        
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
    
    public func startTemplate(_ template: PracticeTemplate) -> Askeza {
        return progressService.startTemplate(template)
    }
    
    public func updateProgress(forTemplateID templateID: UUID, daysCompleted: Int, isCompleted: Bool = false) {
        progressService.updateProgress(forTemplateID: templateID, daysCompleted: daysCompleted, isCompleted: isCompleted)
    }
    
    public func updateStreak(forTemplateID templateID: UUID, streak: Int) {
        progressService.updateStreak(forTemplateID: templateID, streak: streak)
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
            
            // Создаем UUID кодировщик
            decoder.dataDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let string = try container.decode(String.self)
                
                if let uuid = UUID(uuidString: string) {
                    return uuid.uuid // Преобразуем UUID в его бинарное представление
                }
                
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid UUID string: \(string)"
                )
            }
            
            // Создаем десериализацию для категорий
            let templates = try decoder.decode([TemplateImport].self, from: data)
            
            for templateData in templates {
                let category = AskezaCategory.fromString(templateData.category)
                
                let template = PracticeTemplate(
                    id: UUID(uuidString: templateData.id) ?? UUID(),
                    templateId: templateData.templateId,
                    title: templateData.title,
                    category: category,
                    duration: templateData.duration,
                    quote: templateData.quote,
                    difficulty: templateData.difficulty,
                    description: templateData.description,
                    intention: templateData.intention
                )
                
                templateService.saveTemplate(template)
            }
            
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
            let bodyCourse = CoursePath(
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
            let mindCourse = CoursePath(
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
            let liberationCourse = CoursePath(
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
        
        // Сохраняем шаблоны
        addTemplate(coldShower)
        addTemplate(meditation)
        addTemplate(noSugar)
        addTemplate(gratitude)
        
        // Создаем курсы
        let bodyCourse = CoursePath(
            title: "Путь физического совершенства",
            description: "Последовательные практики для трансформации тела и энергии.",
            templateIDs: [coldShower.id, noSugar.id],
            category: .telo,
            difficulty: 2
        )
        
        let mindCourse = CoursePath(
            title: "Путь ясного ума",
            description: "Последовательные практики для трансформации ума и внимания.",
            templateIDs: [meditation.id, gratitude.id],
            category: .um,
            difficulty: 2
        )
        
        // TODO: Сохранить курсы через сервис
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