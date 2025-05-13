import Foundation
import SwiftUI

// Вынесем все предустановленные аскезы в отдельный класс для лучшей организации кода
public struct PresetAskezaStore {
    public static let shared = PresetAskezaStore()
    
    public let askezasByCategory: [AskezaCategory: [PresetAskeza]]
    
    private init() {
        // Здесь используем AdditionalTemplates для получения шаблонов аскез
        let additionalTemplates = AdditionalTemplates.getHardcodedPresetAskezas()
        
        // Группируем аскезы по категориям
        var tempAskezasByCategory = [AskezaCategory: [PresetAskeza]]()
        
        // Добавляем аскезы из AdditionalTemplates
        for askeza in additionalTemplates {
            if tempAskezasByCategory[askeza.category] == nil {
                tempAskezasByCategory[askeza.category] = []
            }
            tempAskezasByCategory[askeza.category]?.append(askeza)
        }
        
        // Добавляем традиционные аскезы, если в какой-то категории нет аскез из AdditionalTemplates
        let traditionalAskezas = PresetAskezaStore.createTraditionalTemplates()
        for (category, askezas) in traditionalAskezas {
            if tempAskezasByCategory[category] == nil || tempAskezasByCategory[category]?.isEmpty == true {
                tempAskezasByCategory[category] = askezas
            } else {
                tempAskezasByCategory[category]?.append(contentsOf: askezas)
            }
        }
        
        self.askezasByCategory = tempAskezasByCategory
    }
    
    // Создает традиционные шаблоны аскез, которые использовались ранее
    private static func createTraditionalTemplates() -> [AskezaCategory: [PresetAskeza]] {
        return [
            .osvobozhdenie: [
                PresetAskeza(title: "Отказ от алкоголя",
                            description: "Полный отказ от алкоголя ради ясности ума и энергии",
                            intention: "Обрести ясность ума и энергию",
                            category: .osvobozhdenie,
                            difficulty: 3,
                            duration: 30),
                PresetAskeza(title: "Отказ от никотина",
                            description: "Свобода от курения и вейпов. Возвращение к чистому дыханию",
                            intention: "Вернуться к чистому дыханию",
                            category: .osvobozhdenie,
                            difficulty: 4,
                            duration: 30),
                PresetAskeza(title: "Без сахара",
                            description: "Исключение сладостей ради контроля, энергии и ясности",
                            intention: "Обрести контроль над питанием и улучшить энергию",
                            category: .osvobozhdenie,
                            difficulty: 3,
                            duration: 21),
                PresetAskeza(title: "Без кофеина",
                            description: "Осознанный отдых от кофе, чая, энергетиков",
                            intention: "Восстановить естественную энергию без стимуляторов",
                            category: .osvobozhdenie,
                            difficulty: 2,
                            duration: 14),
                PresetAskeza(title: "Детокс от соцсетей",
                            description: "Неделя без Instagram, TikTok, VK. Цель — внимание и энергия",
                            intention: "Вернуть внимательность и время к важным вещам",
                            category: .osvobozhdenie,
                            difficulty: 2,
                            duration: 7),
                PresetAskeza(title: "Информационная диета",
                            description: "Отказ от новостей и шума ради внутреннего покоя",
                            intention: "Найти внутреннюю тишину и спокойствие",
                            category: .osvobozhdenie),
                PresetAskeza(title: "Без порнографии",
                            description: "Очищение сознания от зависимости. Возврат к реальности",
                            intention: "Восстановить естественное восприятие интимных отношений",
                            category: .osvobozhdenie),
                PresetAskeza(title: "Сексуальное воздержание",
                            description: "Сохранение энергии и усиление фокуса",
                            intention: "Трансформировать сексуальную энергию в творческую",
                            category: .osvobozhdenie),
                PresetAskeza(title: "Цифровой детокс",
                            description: "Каждый день минимум 1 час без экрана",
                            intention: "Жить в реальной жизни, а не только в сети",
                            category: .osvobozhdenie),
                PresetAskeza(title: "Антипрокрастинация",
                            description: "Делай главное дело дня без отлагательств",
                            intention: "Обрести продуктивность и довести дела до конца",
                            category: .osvobozhdenie),
                PresetAskeza(title: "Без жалоб",
                            description: "Полный отказ от жалоб и негативных высказываний",
                            intention: "Трансформировать негативное мышление",
                            category: .osvobozhdenie,
                            difficulty: 3,
                            duration: 21)
            ],
            .telo: [
                PresetAskeza(title: "Утренняя пробежка",
                            description: "Ежедневная утренняя пробежка на свежем воздухе",
                            intention: "Укрепить тело и дух",
                            category: .telo,
                            difficulty: 3,
                            duration: 30),
                PresetAskeza(title: "Холодный душ",
                            description: "Начало дня с бодрящего холодного душа",
                            intention: "Закалить тело и волю",
                            category: .telo,
                            difficulty: 4,
                            duration: 14),
                PresetAskeza(title: "Планка каждый день",
                            description: "Ежедневная практика удержания планки с увеличением времени",
                            intention: "Укрепить корпус и развить дисциплину",
                            category: .telo,
                            difficulty: 2,
                            duration: 30),
                PresetAskeza(title: "Правильная осанка",
                            description: "Сознательный контроль осанки в течение дня",
                            intention: "Исправить осанку и предотвратить проблемы со спиной",
                            category: .telo,
                            difficulty: 1,
                            duration: 21),
                PresetAskeza(title: "Раннее пробуждение",
                            description: "Подъём каждый день в 5:30 утра",
                            intention: "Перестроить режим дня для максимальной продуктивности",
                            category: .telo,
                            difficulty: 3,
                            duration: 30),
                PresetAskeza(title: "10 000 шагов",
                            description: "Прогулка как медитация в действии",
                            intention: "Улучшить здоровье и обрести ясность ума",
                            category: .telo),
                PresetAskeza(title: "Бег каждый день",
                            description: "Минимум 1 км или 10 минут пробежки в день",
                            intention: "Укрепить тело и дух через постоянное движение",
                            category: .telo),
                PresetAskeza(title: "День поста",
                            description: "Очищение и контроль",
                            intention: "Очистить организм и развить самодисциплину",
                            category: .telo),
                PresetAskeza(title: "Интервальное голодание",
                            description: "Питание в окне. Чистое тело — ясный ум",
                            intention: "Очистить организм и наладить обмен веществ",
                            category: .telo),
                PresetAskeza(title: "Утренняя растяжка",
                            description: "Активизация тела через 5–10 минут движения",
                            intention: "Начинать день с заботы о своем теле",
                            category: .telo),
                PresetAskeza(title: "Осанка",
                            description: "Осознанность в положении тела в течение дня",
                            intention: "Развить красивую осанку и уверенность",
                            category: .telo)
            ],
            .um: [
                PresetAskeza(title: "Медитация",
                            description: "Ежедневная практика осознанности и внимательности",
                            intention: "Обрести внутренний покой",
                            category: .um,
                            difficulty: 2,
                            duration: 21),
                PresetAskeza(title: "Чтение книг",
                            description: "Ежедневное чтение полезной литературы",
                            intention: "Расширить кругозор и развить интеллект",
                            category: .um,
                            difficulty: 2,
                            duration: 30),
                PresetAskeza(title: "Изучение нового",
                            description: "Каждый день узнавать что-то новое",
                            intention: "Расширять кругозор и поддерживать гибкость ума",
                            category: .um),
                PresetAskeza(title: "Минимализм",
                            description: "Освобождай пространство и голову",
                            intention: "Упростить жизнь и сфокусироваться на важном",
                            category: .um),
                PresetAskeza(title: "Slow Life",
                            description: "Замедление — акт мудрости",
                            intention: "Жить осознанно и наслаждаться каждым моментом",
                            category: .um),
                PresetAskeza(title: "Дневник благодарности",
                            description: "Записывать 3 вещи, за которые ты благодарен каждый день",
                            intention: "Развить чувство благодарности",
                            category: .um,
                            difficulty: 1,
                            duration: 30),
                PresetAskeza(title: "Практика внимательности",
                            description: "Осознанное проживание обычных действий: еда, ходьба, дыхание",
                            intention: "Научиться жить в настоящем моменте",
                            category: .um,
                            difficulty: 2,
                            duration: 14),
                PresetAskeza(title: "Урок нового навыка",
                            description: "Ежедневное изучение чего-то нового: язык, инструмент, навык",
                            intention: "Развить мозг и выйти из зоны комфорта",
                            category: .um,
                            difficulty: 3,
                            duration: 30)
            ],
            .dukh: [
                PresetAskeza(title: "Ежедневная молитва",
                            description: "Посвящать время духовной практике каждый день",
                            intention: "Укрепить духовную связь",
                            category: .dukh,
                            difficulty: 2,
                            duration: 40),
                PresetAskeza(title: "Практика благодарности",
                            description: "Записывать 3 вещи, за которые ты благодарен каждый день",
                            intention: "Развить чувство благодарности",
                            category: .dukh,
                            difficulty: 1,
                            duration: 21),
                PresetAskeza(title: "Добрые дела",
                            description: "Совершать одно доброе дело ежедневно, не ожидая ничего взамен",
                            intention: "Развить сострадание и щедрость",
                            category: .dukh,
                            difficulty: 2,
                            duration: 30),
                PresetAskeza(title: "Духовное чтение",
                            description: "Чтение духовной литературы для вдохновения",
                            intention: "Найти духовные ориентиры",
                            category: .dukh,
                            difficulty: 1,
                            duration: 40),
                PresetAskeza(title: "Созерцание",
                            description: "Время наедине с собой для глубокого размышления",
                            intention: "Достичь глубокого самопознания",
                            category: .dukh,
                            difficulty: 3,
                            duration: 14),
                PresetAskeza(title: "Благодарность",
                            description: "Практика благодарности каждое утро",
                            intention: "Культивировать чувство счастья и удовлетворенности",
                            category: .dukh),
                PresetAskeza(title: "Служение",
                            description: "Ежедневная помощь другим",
                            intention: "Развивать щедрость и бескорыстную любовь",
                            category: .dukh),
                PresetAskeza(title: "Молитва",
                            description: "Ежедневная духовная практика",
                            intention: "Укрепить духовную связь и обрести спокойствие",
                            category: .dukh),
                PresetAskeza(title: "Прощение",
                            description: "Отпускать обиды и негативные эмоции",
                            intention: "Освободиться от груза обид и негатива",
                            category: .dukh),
                PresetAskeza(title: "Безмолвие",
                            description: "Час тишины каждый день",
                            intention: "Услышать голос своей души и интуиции",
                            category: .dukh)
            ],
            .otnosheniya: [
                PresetAskeza(title: "Признательность",
                            description: "Ежедневно выражать искреннюю благодарность близким",
                            intention: "Укрепить связи с окружающими",
                            category: .otnosheniya,
                            difficulty: 1,
                            duration: 14),
                PresetAskeza(title: "Активное слушание",
                            description: "Практика полного внимания к собеседнику без перебивания",
                            intention: "Улучшить навыки общения",
                            category: .otnosheniya,
                            difficulty: 2,
                            duration: 21),
                PresetAskeza(title: "Звонок родителям",
                            description: "Ежедневный звонок родителям или другим близким людям",
                            intention: "Укрепить семейные связи",
                            category: .otnosheniya,
                            difficulty: 1,
                            duration: 30),
                PresetAskeza(title: "Без критики",
                            description: "Отказ от любых форм критики и осуждения других",
                            intention: "Создать атмосферу принятия",
                            category: .otnosheniya,
                            difficulty: 3,
                            duration: 14),
                PresetAskeza(title: "Новые знакомства",
                            description: "Знакомиться с одним новым человеком каждый день",
                            intention: "Расширить социальный круг",
                            category: .otnosheniya,
                            difficulty: 4,
                            duration: 7),
                PresetAskeza(title: "Доброе слово",
                            description: "Говорить только добрые слова",
                            intention: "Создавать позитивную атмосферу вокруг себя",
                            category: .otnosheniya),
                PresetAskeza(title: "Внимательность",
                            description: "Практика активного слушания",
                            intention: "Стать лучшим слушателем и другом",
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
                            category: .velikie,
                            difficulty: 5,
                            duration: 90),
                PresetAskeza(title: "Творческая дисциплина",
                            description: "Создавай каждый день, без исключений",
                            intention: "Развить мастерство через ежедневную практику",
                            category: .velikie,
                            difficulty: 4,
                            duration: 100),
                PresetAskeza(title: "Мастерство",
                            description: "Посвящай минимум 1 час в день своему мастерству",
                            intention: "Достичь высот в выбранном деле",
                            category: .velikie,
                            difficulty: 4,
                            duration: 365),
                PresetAskeza(title: "Одиночество мудреца",
                            description: "Время наедине с собой для глубокого созерцания",
                            intention: "Познать истинного себя через уединение",
                            category: .velikie,
                            difficulty: 5,
                            duration: 40)
            ]
        ]
    }
    
    public func getPresetAskeza(title: String, category: AskezaCategory) -> PresetAskeza? {
        return askezasByCategory[category]?.first(where: { $0.title == title })
    }
    
    public func getAllPresets() -> [PresetAskeza] {
        var allPresets = [PresetAskeza]()
        for presets in askezasByCategory.values {
            allPresets.append(contentsOf: presets)
        }
        return allPresets
    }
}

@MainActor
public class AskezaViewModel: ObservableObject {
    @Published public var activeAskezas: [Askeza] = []
    @Published public var completedAskezas: [Askeza] = []
    @Published public var selectedTab: Tab = .askezas
    @Published public var isUpdatingProgress = false
    
    private let userDefaults = UserDefaults.standard
    private let activeAskezasKey = "activeAskezas"
    private let completedAskezasKey = "completedAskezas"
    
    private var lastProgressUpdateTime = Date()
    private let minimumUpdateInterval: TimeInterval = 2.0 // Минимальный интервал между обновлениями прогресса (в секундах)
    
    public enum Tab {
        case askezas
        case workshop
        case wishes
        case profile
    }
    
    public init() {
        loadData()
        
        // Подписываемся на уведомления о новых аскезах
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewAskeza(_:)),
            name: Notification.Name("AddAskezaNotification"),
            object: nil
        )
    }
    
    @objc private func handleNewAskeza(_ notification: Notification) {
        if let askeza = notification.object as? Askeza {
            // Проверяем, не существует ли уже такая аскеза
            let exists = activeAskezas.contains { $0.title == askeza.title && $0.templateID == askeza.templateID }
            if !exists {
                // Добавляем новую аскезу в список активных
                DispatchQueue.main.async {
                    self.activeAskezas.append(askeza)
                    self.saveData()
                    print("AskezaViewModel: Добавлена новая аскеза из шаблона: \(askeza.title)")
                }
            }
        }
    }
    
    @discardableResult
    public func createAskeza(title: String, intention: String, duration: AskezaDuration, category: AskezaCategory = .custom) -> Askeza {
        let newAskeza = Askeza(title: title,
                              intention: intention,
                              duration: duration,
                              category: category)
        activeAskezas.append(newAskeza)
        saveData()
        return newAskeza
    }
    
    public func extendAskeza(askeza: Askeza, additionalDays: Int) {
        if let index = activeAskezas.firstIndex(where: { $0.id == askeza.id }) {
            var updatedAskeza = activeAskezas[index]
            
            // Обновляем продолжительность
            if case .days(let currentDays) = updatedAskeza.duration {
                let totalDays = currentDays + additionalDays
                updatedAskeza.duration = .days(totalDays)
                activeAskezas[index] = updatedAskeza
                saveData()
            }
        }
    }
    
    public func updateProgress(_ askeza: Askeza, newProgress: Int) {
        if let index = activeAskezas.firstIndex(where: { $0.id == askeza.id }) {
            var updatedAskeza = activeAskezas[index]
            updatedAskeza.progress = max(0, newProgress)
            
            // Вычисляем новую дату начала на основе текущего прогресса
            let calendar = Calendar.current
            if let newStartDate = calendar.date(byAdding: .day, value: -newProgress, to: Date()) {
                updatedAskeza.startDate = newStartDate
            }
            
            // Синхронизируем прогресс с шаблоном, если аскеза связана с шаблоном
            if let templateID = updatedAskeza.templateID {
                PracticeTemplateStore.shared.updateProgress(forTemplateID: templateID, daysCompleted: newProgress)
            }
            
            // Проверяем, не завершена ли аскеза
            if case .days(let total) = updatedAskeza.duration, newProgress >= total {
                // Если аскеза завершена, удаляем её из активных и добавляем в завершенные
                updatedAskeza.isCompleted = true
                if updatedAskeza.wish != nil {
                    updatedAskeza.wishStatus = .waiting
                }
                
                // Удаляем из активных
                activeAskezas.remove(at: index)
                
                // Добавляем в завершенные
                completedAskezas.append(updatedAskeza)
                
                // Если аскеза связана с шаблоном, отмечаем завершение шаблона
                if let templateID = updatedAskeza.templateID {
                    PracticeTemplateStore.shared.updateProgress(forTemplateID: templateID, 
                                                             daysCompleted: total,
                                                             isCompleted: true)
                }
                
                saveData()
            } else {
                // Если аскеза не завершена, обновляем её в списке активных
                activeAskezas[index] = updatedAskeza
                saveData()
            }
        }
    }
    
    public func completeAskeza(_ askeza: Askeza) {
        if let index = activeAskezas.firstIndex(where: { $0.id == askeza.id }) {
            var completedAskeza = activeAskezas[index]
            completedAskeza.isCompleted = true
            
            // Если есть желание, устанавливаем статус "Ожидает исполнения"
            if completedAskeza.wish != nil {
                completedAskeza.wishStatus = .waiting
            }
            
            // Если аскеза связана с шаблоном, отмечаем завершение шаблона
            if let templateID = completedAskeza.templateID {
                // Получаем информацию о продолжительности шаблона
                if let template = PracticeTemplateStore.shared.getTemplate(byID: templateID) {
                    let daysCompleted = template.duration > 0 ? template.duration : completedAskeza.progress
                    PracticeTemplateStore.shared.updateProgress(forTemplateID: templateID, 
                                                             daysCompleted: daysCompleted,
                                                             isCompleted: true)
                }
            }
            
            // Удаляем из активных и добавляем в завершенные
            activeAskezas.remove(at: index)
            completedAskezas.append(completedAskeza)
            saveData()
        }
    }
    
    public func resetAskeza(_ askeza: Askeza) {
        // Проверяем, что аскеза находится в активных и не завершена
        if let index = activeAskezas.firstIndex(where: { $0.id == askeza.id }) {
            // Проверяем, что аскеза не завершена
            if !askeza.isCompleted {
                var resetAskeza = activeAskezas[index]
                resetAskeza.progress = 0
                resetAskeza.startDate = Date() // Обновляем дату начала при сбросе
                activeAskezas[index] = resetAskeza
                saveData()
            }
        }
    }
    
    public func deleteAskeza(_ askeza: Askeza) {
        // Если аскеза связана с шаблоном, сбрасываем прогресс шаблона
        if let templateID = askeza.templateID {
            PracticeTemplateStore.shared.resetTemplateProgress(templateID)
        }
        
        // Проверяем в активных аскезах
        if let index = activeAskezas.firstIndex(where: { $0.id == askeza.id }) {
            activeAskezas.remove(at: index)
            saveData()
        }
        
        // Проверяем в завершенных аскезах
        if let index = completedAskezas.firstIndex(where: { $0.id == askeza.id }) {
            completedAskezas.remove(at: index)
            saveData()
        }
    }
    
    public func updateWish(_ askeza: Askeza, newWish: String?) {
        if let index = activeAskezas.firstIndex(where: { $0.id == askeza.id }) {
            var updatedAskeza = askeza
            updatedAskeza.wish = newWish
            updatedAskeza.wishStatus = newWish != nil ? .waiting : nil  // Сбрасываем статус если удаляем желание
            activeAskezas[index] = updatedAskeza
            saveData()
        }
        
        // Проверяем также в завершенных аскезах
        if let index = completedAskezas.firstIndex(where: { $0.id == askeza.id }) {
            var updatedAskeza = askeza
            updatedAskeza.wish = newWish
            updatedAskeza.wishStatus = newWish != nil ? .waiting : nil
            completedAskezas[index] = updatedAskeza
            saveData()
        }
    }
    
    public func updateWishStatus(_ askeza: Askeza, status: WishStatus) {
        // Проверяем в активных аскезах
        if let index = activeAskezas.firstIndex(where: { $0.id == askeza.id }) {
            var updatedAskeza = activeAskezas[index]
            updatedAskeza.wishStatus = status
            activeAskezas[index] = updatedAskeza
            saveData()
        }
        
        // Проверяем в завершенных аскезах
        if let index = completedAskezas.firstIndex(where: { $0.id == askeza.id }) {
            var updatedAskeza = completedAskezas[index]
            updatedAskeza.wishStatus = status
            completedAskezas[index] = updatedAskeza
            saveData()
        }
    }
    
    // Метод для обновления прогресса всех активных аскез
    public func updateAllAskezasProgress() {
        // Защита от слишком частых вызовов
        let now = Date()
        if now.timeIntervalSince(lastProgressUpdateTime) < minimumUpdateInterval {
            print("Слишком частый вызов updateAllAskezasProgress, пропускаем...")
            return
        }
        
        // Устанавливаем флаг обновления, чтобы избежать проблем с зависанием
        isUpdatingProgress = true
        defer {
            isUpdatingProgress = false
            lastProgressUpdateTime = now
        }
        
        let calendar = Calendar.current
        var updatedAnyAskeza = false
        var askezasToComplete: [Askeza] = []
        var indexesToRemove: [Int] = []
        
        // Сохраняем последнюю дату проверки
        let lastCheckDateKey = "lastCheckDate"
        let lastCheckDate = userDefaults.object(forKey: lastCheckDateKey) as? Date ?? now
        
        // Проверяем, изменился ли день с последней проверки
        let dayChanged = !calendar.isDate(lastCheckDate, inSameDayAs: now)
        print("Проверка полуночи: последняя проверка \(lastCheckDate), текущее время \(now), день изменился: \(dayChanged)")
        
        // Сохраняем текущую дату как дату последней проверки
        userDefaults.set(now, forKey: lastCheckDateKey)
        
        // Принудительно обновляем, если день изменился или если это первый запуск приложения
        let forceUpdate = dayChanged
        
        // Проверяем проблемные аскезы для отладки (например, "булинг")
        let debugAskeza = activeAskezas.first(where: { $0.title.lowercased().contains("булинг") })
        if let askeza = debugAskeza {
            print("📊 Обнаружена аскеза 'булинг': progress=\(askeza.progress), startDate=\(askeza.startDate)")
        }
        
        // Обновляем прогресс для всех активных аскез
        for i in 0..<activeAskezas.count {
            let askeza = activeAskezas[i]
            
            // Пропускаем уже завершенные аскезы
            if askeza.isCompleted {
                // Если аскеза завершена, добавляем её в список для перемещения
                if !completedAskezas.contains(where: { $0.id == askeza.id }) {
                    askezasToComplete.append(askeza)
                }
                indexesToRemove.append(i)
                continue
            }
            
            // Получаем количество дней между датой начала и текущей датой
            let components = calendar.dateComponents([.day], from: askeza.startDate, to: now)
            let totalDays = max(0, components.day ?? 0)
            
            // Вычисляем "точную" дату начала, отматывая назад от текущей даты
            // количество дней, равное прогрессу аскезы
            
            // Если день изменился с момента последней проверки или есть разница в расчетах
            if forceUpdate || totalDays > askeza.progress {
                var updatedAskeza = askeza
                
                if forceUpdate {
                    // При смене дня увеличиваем прогресс на 1
                    updatedAskeza.progress = askeza.progress + 1
                    
                    // Корректируем дату начала, чтобы она соответствовала новому прогрессу
                    if let newStartDate = calendar.date(byAdding: .day, value: -(updatedAskeza.progress), to: now) {
                        updatedAskeza.startDate = newStartDate
                    }
                    
                    print("Принудительное обновление аскезы \(askeza.title): было \(askeza.progress), стало \(updatedAskeza.progress)")
                } else {
                    // Стандартное обновление на основе разницы дней
                    updatedAskeza.progress = totalDays
                    print("Обновление аскезы \(askeza.title): было \(askeza.progress), стало \(updatedAskeza.progress)")
                }
                
                // Синхронизируем прогресс с шаблоном, если аскеза связана с шаблоном
                if let templateID = updatedAskeza.templateID {
                    PracticeTemplateStore.shared.updateProgress(forTemplateID: templateID, daysCompleted: updatedAskeza.progress)
                }
                
                // Проверяем, не завершена ли аскеза
                if case .days(let duration) = updatedAskeza.duration, updatedAskeza.progress >= duration {
                    var completedAskeza = updatedAskeza
                    completedAskeza.isCompleted = true
                    if completedAskeza.wish != nil {
                        completedAskeza.wishStatus = .waiting
                    }
                    
                    // Добавляем в список для завершения
                    askezasToComplete.append(completedAskeza)
                    indexesToRemove.append(i)
                    
                    // Если аскеза связана с шаблоном, отмечаем завершение шаблона
                    if let templateID = completedAskeza.templateID {
                        PracticeTemplateStore.shared.updateProgress(
                            forTemplateID: templateID,
                            daysCompleted: duration,
                            isCompleted: true
                        )
                    }
                    
                    print("Аскеза \(askeza.title) завершена: прогресс \(completedAskeza.progress), длительность \(duration)")
                } else {
                    activeAskezas[i] = updatedAskeza
                }
                
                updatedAnyAskeza = true
            }
        }
        
        // Удаляем завершенные аскезы из активных и добавляем в завершенные
        // Удаляем с конца, чтобы индексы не сбивались
        for index in indexesToRemove.sorted(by: >) {
            activeAskezas.remove(at: index)
        }
        
        // Добавляем в завершенные
        for completedAskeza in askezasToComplete {
            // Проверяем, нет ли уже такой аскезы в завершенных
            if !completedAskezas.contains(where: { $0.id == completedAskeza.id }) {
                completedAskezas.append(completedAskeza)
            }
        }
        
        // Сохраняем данные, если были изменения
        if updatedAnyAskeza || !askezasToComplete.isEmpty {
            saveData()
            print("Данные сохранены после обновления прогресса")
        } else {
            print("Обновление не требуется: ни одна аскеза не изменилась")
        }
    }
    
    // Тестовый метод для принудительного обновления всех аскез (для отладки)
    public func forceUpdateAllAskezas() {
        let now = Date()
        let calendar = Calendar.current
        var askezasToComplete: [Askeza] = []
        var indexesToRemove: [Int] = []
        
        // Обновляем прогресс для всех активных аскез
        for i in 0..<activeAskezas.count {
            let askeza = activeAskezas[i]
            
            // Пропускаем уже завершенные аскезы
            if askeza.isCompleted {
                // Если аскеза завершена, добавляем её в список для перемещения
                if !completedAskezas.contains(where: { $0.id == askeza.id }) {
                    askezasToComplete.append(askeza)
                }
                indexesToRemove.append(i)
                continue
            }
            
            var updatedAskeza = askeza
            
            // Получаем количество дней между датой начала и текущей датой
            let components = calendar.dateComponents([.day], from: askeza.startDate, to: now)
            let totalDays = max(0, components.day ?? 0)
            
            // Обновляем прогресс
            updatedAskeza.progress = totalDays
            
            // Синхронизируем прогресс с шаблоном, если аскеза связана с шаблоном
            if let templateID = updatedAskeza.templateID {
                PracticeTemplateStore.shared.updateProgress(forTemplateID: templateID, daysCompleted: totalDays)
            }
            
            // Проверяем, не завершена ли аскеза
            if case .days(let duration) = updatedAskeza.duration, updatedAskeza.progress >= duration {
                var completedAskeza = updatedAskeza
                completedAskeza.isCompleted = true
                if completedAskeza.wish != nil {
                    completedAskeza.wishStatus = .waiting
                }
                
                // Добавляем в список для завершения
                askezasToComplete.append(completedAskeza)
                indexesToRemove.append(i)
                
                // Если аскеза связана с шаблоном, отмечаем завершение шаблона
                if let templateID = completedAskeza.templateID {
                    PracticeTemplateStore.shared.updateProgress(
                        forTemplateID: templateID,
                        daysCompleted: duration,
                        isCompleted: true
                    )
                }
                
                print("Аскеза \(askeza.title) завершена: прогресс \(completedAskeza.progress), длительность \(duration)")
            } else {
                activeAskezas[i] = updatedAskeza
            }
        }
        
        // Удаляем завершенные аскезы из активных и добавляем в завершенные
        // Удаляем с конца, чтобы индексы не сбивались
        for index in indexesToRemove.sorted(by: >) {
            activeAskezas.remove(at: index)
        }
        
        // Добавляем в завершенные
        for completedAskeza in askezasToComplete {
            // Проверяем, нет ли уже такой аскезы в завершенных
            if !completedAskezas.contains(where: { $0.id == completedAskeza.id }) {
                completedAskezas.append(completedAskeza)
            }
        }
        
        // Сохраняем данные
        saveData()
        print("Данные сохранены после принудительного обновления")
        
        // Устанавливаем новую дату последней проверки
        userDefaults.set(now, forKey: "lastCheckDate")
    }
    
    private func loadData() {
        if let activeData = userDefaults.data(forKey: activeAskezasKey),
           let activeAskezas = try? JSONDecoder().decode([Askeza].self, from: activeData) {
            self.activeAskezas = activeAskezas
        }
        
        if let completedData = userDefaults.data(forKey: completedAskezasKey),
           let completedAskezas = try? JSONDecoder().decode([Askeza].self, from: completedData) {
            self.completedAskezas = completedAskezas
        }
    }
    
    private func saveData() {
        if let activeData = try? JSONEncoder().encode(activeAskezas) {
            userDefaults.set(activeData, forKey: activeAskezasKey)
        }
        
        if let completedData = try? JSONEncoder().encode(completedAskezas) {
            userDefaults.set(completedData, forKey: completedAskezasKey)
        }
    }
    
    func resetAllData() {
        // Очищаем все аскезы
        activeAskezas.removeAll()
        completedAskezas.removeAll()
        
        // Сбрасываем выбранную вкладку
        selectedTab = .askezas
        
        // Очищаем UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
        
        // Сбрасываем прогресс всех шаблонов
        PracticeTemplateStore.shared.resetAllTemplateProgress()
        
        // Сохраняем пустое состояние
        saveData()
    }
    
    // Метод для получения информации о последней проверке
    public func getLastCheckInfo() -> String {
        let lastCheckDateKey = "lastCheckDate"
        let lastCheckDate = userDefaults.object(forKey: lastCheckDateKey) as? Date
        
        if let date = lastCheckDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            return "Последняя проверка: \(formatter.string(from: date))"
        } else {
            return "Последняя проверка: Никогда"
        }
    }
    
    // Метод для получения статистики аскез
    public func getActiveAskezasStats() -> String {
        let total = activeAskezas.count
        let totalDays = activeAskezas.reduce(0) { $0 + $1.progress }
        
        var lifetimeCount = 0
        for askeza in activeAskezas {
            if case .lifetime = askeza.duration {
                lifetimeCount += 1
            }
        }
        
        return "Активных аскез: \(total) (дней всего: \(totalDays), пожизненных: \(lifetimeCount))"
    }
    
    // Метод для добавления новой аскезы
    public func addAskeza(_ askeza: Askeza) {
        activeAskezas.append(askeza)
        saveData()
    }
    
    // Метод для обновления существующей аскезы
    public func updateAskeza(_ askeza: Askeza) {
        if let index = activeAskezas.firstIndex(where: { $0.id == askeza.id }) {
            activeAskezas[index] = askeza
            saveData()
        } else if let index = completedAskezas.firstIndex(where: { $0.id == askeza.id }) {
            completedAskezas[index] = askeza
            saveData()
        }
    }
    
    // Метод для получения предустановленной аскезы - оптимизированный
    public func getPresetAskeza(title: String, category: AskezaCategory) -> PresetAskeza? {
        return PresetAskezaStore.shared.getPresetAskeza(title: title, category: category)
    }
    
    // Метод для обновления состояния аскез
    public func updateAskezaStates() {
        // Предотвращаем слишком частые обновления
        let now = Date()
        if now.timeIntervalSince(lastProgressUpdateTime) < minimumUpdateInterval {
            return
        }
        
        lastProgressUpdateTime = now
        isUpdatingProgress = true
        defer { isUpdatingProgress = false }
        
        let calendar = Calendar.current
        var askezasToComplete = [Askeza]()
        var indexesToRemove = [Int]()
        
        // Сначала проверяем завершенные аскезы, которые могли остаться в активных
        for (index, askeza) in activeAskezas.enumerated() {
            // Проверяем явно отмеченные как завершенные
            if askeza.isCompleted {
                // Если аскеза уже помечена как завершенная, но все еще в активных
                if !completedAskezas.contains(where: { $0.id == askeza.id }) {
                    completedAskezas.append(askeza)
                }
                indexesToRemove.append(index)
                continue
            }
            
            // Проверяем, не должна ли аскеза быть завершена по длительности
            if case .days(let totalDays) = askeza.duration, askeza.progress >= totalDays {
                var completedAskeza = askeza
                completedAskeza.isCompleted = true
                
                // Если есть желание, устанавливаем статус "Ожидает исполнения"
                if completedAskeza.wish != nil {
                    completedAskeza.wishStatus = .waiting
                }
                
                // Добавляем в список для завершения
                askezasToComplete.append(completedAskeza)
                indexesToRemove.append(index)
                
                // Обновляем статус связанного шаблона, если он есть
                if let templateID = completedAskeza.templateID {
                    PracticeTemplateStore.shared.updateProgress(
                        forTemplateID: templateID,
                        daysCompleted: totalDays,
                        isCompleted: true
                    )
                }
                
                continue
            }
            
            // Обновляем прогресс для незавершенных аскез
            let components = calendar.dateComponents([.day], from: askeza.startDate, to: now)
            let calculatedDays = max(0, components.day ?? 0)
            
            if calculatedDays > askeza.progress {
                // Обновляем прогресс только если расчетное значение больше текущего
                var updatedAskeza = askeza
                updatedAskeza.progress = calculatedDays
                
                // Обновляем связанный шаблон, если есть
                if let templateID = updatedAskeza.templateID {
                    PracticeTemplateStore.shared.updateProgress(
                        forTemplateID: templateID,
                        daysCompleted: calculatedDays
                    )
                }
                
                // Проверяем, не завершилась ли аскеза после обновления прогресса
                if case .days(let totalDays) = updatedAskeza.duration, updatedAskeza.progress >= totalDays {
                    updatedAskeza.isCompleted = true
                    if updatedAskeza.wish != nil {
                        updatedAskeza.wishStatus = .waiting
                    }
                    
                    askezasToComplete.append(updatedAskeza)
                    indexesToRemove.append(index)
                    
                    // Обновляем статус шаблона
                    if let templateID = updatedAskeza.templateID {
                        PracticeTemplateStore.shared.updateProgress(
                            forTemplateID: templateID,
                            daysCompleted: totalDays,
                            isCompleted: true
                        )
                    }
                } else {
                    // Обновляем аскезу в массиве
                    activeAskezas[index] = updatedAskeza
                }
            }
        }
        
        // Удаляем завершенные аскезы из активных (в обратном порядке, чтобы индексы не сбивались)
        for index in indexesToRemove.sorted(by: >) {
            activeAskezas.remove(at: index)
        }
        
        // Добавляем новые завершенные аскезы в массив завершенных
        for askeza in askezasToComplete {
            if !completedAskezas.contains(where: { $0.id == askeza.id }) {
                completedAskezas.append(askeza)
            }
        }
        
        // Сохраняем изменения
        if !indexesToRemove.isEmpty || !askezasToComplete.isEmpty {
            saveData()
            print("Данные обновлены: перемещено \(askezasToComplete.count) завершенных аскез")
        }
    }
    
    // Метод для принудительной проверки и перемещения завершенных аскез
    public func forceCheckCompletedAskezas() {
        print("Принудительная проверка завершенных аскез")
        
        var askezasToComplete = [Askeza]()
        var indexesToRemove = [Int]()
        
        // Проверяем все активные аскезы
        for (index, askeza) in activeAskezas.enumerated() {
            // Проверяем явно отмеченные как завершенные
            if askeza.isCompleted {
                // Если аскеза уже помечена как завершенная, но все еще в активных
                if !completedAskezas.contains(where: { $0.id == askeza.id }) {
                    completedAskezas.append(askeza)
                }
                indexesToRemove.append(index)
                continue
            }
            
            // Проверяем, не должна ли аскеза быть завершена по длительности
            if case .days(let totalDays) = askeza.duration, askeza.progress >= totalDays {
                var completedAskeza = askeza
                completedAskeza.isCompleted = true
                
                // Если есть желание, устанавливаем статус "Ожидает исполнения"
                if completedAskeza.wish != nil {
                    completedAskeza.wishStatus = .waiting
                }
                
                // Добавляем в список для завершения
                askezasToComplete.append(completedAskeza)
                indexesToRemove.append(index)
                
                // Обновляем статус связанного шаблона, если он есть
                if let templateID = completedAskeza.templateID {
                    PracticeTemplateStore.shared.updateProgress(
                        forTemplateID: templateID,
                        daysCompleted: totalDays,
                        isCompleted: true
                    )
                }
            }
        }
        
        // Удаляем завершенные аскезы из активных (в обратном порядке, чтобы индексы не сбивались)
        for index in indexesToRemove.sorted(by: >) {
            activeAskezas.remove(at: index)
        }
        
        // Добавляем новые завершенные аскезы в массив завершенных
        for askeza in askezasToComplete {
            if !completedAskezas.contains(where: { $0.id == askeza.id }) {
                completedAskezas.append(askeza)
            }
        }
        
        // Сохраняем изменения
        if !indexesToRemove.isEmpty || !askezasToComplete.isEmpty {
            saveData()
            print("Принудительная проверка: перемещено \(askezasToComplete.count) завершенных аскез")
        }
    }
    
    // Метод для обновления данных через pull-to-refresh
    public func refreshData() {
        // Обновляем состояние всех аскез (проверяем прогресс и завершение)
        updateAskezaStates()
        
        // Перезагружаем данные из UserDefaults
        loadData()
        
        // Логируем информацию о данных
        print("Данные обновлены. Активных аскез: \(activeAskezas.count), Завершенных: \(completedAskezas.count)")
        
        // Обновляем дату последней проверки
        userDefaults.set(Date(), forKey: "lastCheckDate")
    }
} 