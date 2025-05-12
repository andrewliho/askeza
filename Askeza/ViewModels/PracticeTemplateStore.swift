import Foundation
import SwiftUI
import Combine

public class PracticeTemplateStore: ObservableObject {
    @Published public var templates: [PracticeTemplate] = []
    @Published public var progress: [TemplateProgress] = []
    @Published public var courses: [CoursePath] = []
    
    private let userDefaults = UserDefaults.standard
    private let templatesKey = "practiceTemplates"
    private let progressKey = "templateProgress"
    private let coursesKey = "coursePaths"
    
    public static let shared = PracticeTemplateStore()
    
    private init() {
        loadData()
        
        // Если шаблонов нет, создаем демо-данные
        if templates.isEmpty {
            createDemoTemplates()
        }
    }
    
    // MARK: - Data Management
    
    private func loadData() {
        if let templatesData = userDefaults.data(forKey: templatesKey),
           let decodedTemplates = try? JSONDecoder().decode([PracticeTemplate].self, from: templatesData) {
            self.templates = decodedTemplates
        }
        
        if let progressData = userDefaults.data(forKey: progressKey),
           let decodedProgress = try? JSONDecoder().decode([TemplateProgress].self, from: progressData) {
            self.progress = decodedProgress
        }
        
        if let coursesData = userDefaults.data(forKey: coursesKey),
           let decodedCourses = try? JSONDecoder().decode([CoursePath].self, from: coursesData) {
            self.courses = decodedCourses
        }
    }
    
    private func saveData() {
        if let encodedTemplates = try? JSONEncoder().encode(templates) {
            userDefaults.set(encodedTemplates, forKey: templatesKey)
        }
        
        if let encodedProgress = try? JSONEncoder().encode(progress) {
            userDefaults.set(encodedProgress, forKey: progressKey)
        }
        
        if let encodedCourses = try? JSONEncoder().encode(courses) {
            userDefaults.set(encodedCourses, forKey: coursesKey)
        }
    }
    
    // MARK: - Template Management
    
    public func addTemplate(_ template: PracticeTemplate) {
        templates.append(template)
        saveData()
    }
    
    public func getTemplate(byID id: UUID) -> PracticeTemplate? {
        return templates.first { $0.id == id }
    }
    
    public func getTemplate(byTemplateId templateId: String) -> PracticeTemplate? {
        return templates.first { $0.templateId == templateId }
    }
    
    public func filteredTemplates(category: AskezaCategory? = nil, difficulty: Int? = nil, duration: Int? = nil) -> [PracticeTemplate] {
        return templates.filter { template in
            let categoryMatch = category == nil || template.category == category
            let difficultyMatch = difficulty == nil || template.difficulty == difficulty
            let durationMatch = duration == nil || template.duration == duration
            
            return categoryMatch && difficultyMatch && durationMatch
        }
    }
    
    // MARK: - Progress Management
    
    public func getProgress(forTemplateID templateID: UUID) -> TemplateProgress? {
        return progress.first { $0.templateID == templateID }
    }
    
    public func getStatus(forTemplateID templateID: UUID) -> TemplateStatus {
        guard let template = getTemplate(byID: templateID),
              let templateProgress = getProgress(forTemplateID: templateID) else {
            return .notStarted
        }
        
        return templateProgress.status(templateDuration: template.duration)
    }
    
    public func startTemplate(_ template: PracticeTemplate) -> Askeza {
        let askeza = template.createAskeza()
        
        // Создаем или обновляем прогресс
        if let existingProgress = getProgress(forTemplateID: template.id) {
            var updatedProgress = existingProgress
            updatedProgress.dateStarted = Date()
            updatedProgress.currentStreak = 0
            
            // Обновляем прогресс в массиве
            if let index = progress.firstIndex(where: { $0.id == existingProgress.id }) {
                progress[index] = updatedProgress
            }
        } else {
            // Создаем новый прогресс
            let newProgress = TemplateProgress(
                templateID: template.id,
                dateStarted: Date()
            )
            progress.append(newProgress)
        }
        
        saveData()
        return askeza
    }
    
    public func updateProgress(forTemplateID templateID: UUID, daysCompleted: Int, isCompleted: Bool = false) {
        if let existingProgressIndex = progress.firstIndex(where: { $0.templateID == templateID }) {
            var updatedProgress = progress[existingProgressIndex]
            updatedProgress.daysCompleted = daysCompleted
            
            // Если практика завершена, увеличиваем счетчик завершений
            if isCompleted {
                updatedProgress.timesCompleted += 1
                
                // Для отслеживания следующего курса, если это часть курса
                checkAndAdvanceCourse(templateID: templateID)
            }
            
            progress[existingProgressIndex] = updatedProgress
            saveData()
        }
    }
    
    public func updateStreak(forTemplateID templateID: UUID, streak: Int) {
        if let existingProgressIndex = progress.firstIndex(where: { $0.templateID == templateID }) {
            var updatedProgress = progress[existingProgressIndex]
            updatedProgress.currentStreak = streak
            
            // Обновляем лучший стрик, если текущий больше
            if streak > updatedProgress.bestStreak {
                updatedProgress.bestStreak = streak
            }
            
            progress[existingProgressIndex] = updatedProgress
            saveData()
        }
    }
    
    // MARK: - Course Management
    
    public func getCourse(byID id: UUID) -> CoursePath? {
        return courses.first { $0.id == id }
    }
    
    public func getNextTemplateInCourse(afterTemplateID templateID: UUID) -> PracticeTemplate? {
        // Находим курс, содержащий этот шаблон
        guard let course = courses.first(where: { $0.templateIDs.contains(templateID) }),
              let currentIndex = course.templateIDs.firstIndex(of: templateID),
              currentIndex + 1 < course.templateIDs.count else {
            return nil
        }
        
        let nextTemplateID = course.templateIDs[currentIndex + 1]
        return getTemplate(byID: nextTemplateID)
    }
    
    private func checkAndAdvanceCourse(templateID: UUID) {
        // TODO: Логика для продвижения по курсу
    }
    
    // MARK: - Demo Data
    
    private func createDemoTemplates() {
        // Инициализируем шаблоны аскез на основе спецификации
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
        templates = [coldShower, meditation, noSugar, gratitude]
        
        // Создаем курс
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
        
        courses = [bodyCourse, mindCourse]
        
        saveData()
    }
} 