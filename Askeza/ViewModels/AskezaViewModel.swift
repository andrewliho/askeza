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
                PresetAskeza(title: "30 дней оргазма",
                            description: "Ежедневная практика оргазма для одного из партнеров для укрепления отношений и повышения качества жизни",
                            intention: "Укрепить эмоциональную и физическую связь с партнером",
                            category: .otnosheniya,
                            difficulty: 3,
                            duration: 30),
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
                PresetAskeza(title: "Пожизненный отказ от алкоголя",
                            description: "Пожизненный полный отказ от любого алкоголя для духовного и физического очищения",
                            intention: "Достичь абсолютного контроля над собой и освободиться от зависимости навсегда",
                            category: .velikie,
                            difficulty: 5,
                            duration: 0),
                PresetAskeza(title: "Пожизненный отказ от никотина",
                            description: "Пожизненный отказ от курения, вейпов и любых никотиносодержащих продуктов",
                            intention: "Достичь полной свободы от никотиновой зависимости и оздоровить организм",
                            category: .velikie,
                            difficulty: 5,
                            duration: 0),
                PresetAskeza(title: "Ежедневные спортивные тренировки",
                            description: "Ежедневные интенсивные тренировки для достижения атлетической формы",
                            intention: "Трансформировать тело и укрепить силу духа через регулярные физические нагрузки",
                            category: .velikie,
                            difficulty: 5,
                            duration: 365),
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
    // Увеличиваем минимальный интервал до 5 секунд для предотвращения слишком частых обновлений
    private let minimumUpdateInterval: TimeInterval = 5.0
    
    private var lastTemplateAddedTime: [String: Date] = [:]
    
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
            name: Notification.Name.refreshWorkshopData,
            object: nil
        )
        
        // Подписываемся на уведомления о новых аскезах из шаблонов
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewAskeza(_:)),
            name: Notification.Name.askezaAddedFromTemplate,
            object: nil
        )
        
        // Подписываемся на уведомления о проверке активности шаблона
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkTemplateActivity(_:)),
            name: Notification.Name.checkTemplateActivity,
            object: nil
        )
    }
    
    @objc private func handleNewAskeza(_ notification: Notification) {
        if let askeza = notification.object as? Askeza {
            print("🔄 AskezaViewModel: Получено уведомление о новой аскезе: \(askeza.title) [id: \(askeza.id), templateID: \(askeza.templateID?.uuidString ?? "нет")]")
            
            // Проверка на дубликаты по ID
            print("📊 AskezaViewModel: Начинаем проверку дубликатов. Текущее количество активных аскез: \(activeAskezas.count)")
            
            // Проверяем, есть ли аскеза с таким же ID в активных
            let existingAskezaWithSameID = activeAskezas.first { $0.id == askeza.id }
            if existingAskezaWithSameID != nil {
                print("⚠️ AskezaViewModel: Дубликат аскезы с ID \(askeza.id) - пропускаем добавление")
                return
            }
            
            // Проверяем, есть ли аскеза с таким же templateID в активных
            if let templateID = askeza.templateID {
                let existingAskezaWithSameTemplateID = activeAskezas.first { $0.templateID == templateID }
                if existingAskezaWithSameTemplateID != nil {
                    print("⚠️ AskezaViewModel: Аскеза с templateID \(templateID) уже существует - пропускаем добавление")
                    return
                }
            }
            
            // Добавляем аскезу, если она прошла все проверки
            print("✅ AskezaViewModel: Добавлена новая аскеза из шаблона: \(askeza.title)")
            addAskezaToActive(askeza)
            
            // Переключаемся на вкладку Аскез
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.selectedTab = .askezas
                print("🔄 AskezaViewModel: Переключение на вкладку аскез после добавления")
            }
        }
    }
    
    @discardableResult
    public func createAskeza(title: String, intention: String, duration: AskezaDuration, category: AskezaCategory = .custom) -> Askeza {
        let newAskeza = Askeza(title: title,
                              intention: intention,
                              duration: duration,
                              category: category)
        addAskezaToActive(newAskeza)
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
        // Проверяем на корректность значения
        guard newProgress >= 0 else { return }
        
        // Поиск аскезы в списке активных
        if let index = activeAskezas.firstIndex(where: { $0.id == askeza.id }) {
            var updatedAskeza = activeAskezas[index]
            
            // Если аскеза завершена и уже в списке завершенных, не меняем прогресс
            if updatedAskeza.isCompleted && updatedAskeza.isInCompletedList {
                print("⚠️ AskezaViewModel.updateProgress: Аскеза '\(updatedAskeza.title)' уже завершена и в списке завершенных, пропускаем обновление прогресса")
                return
            }
            
            // Проверяем, должна ли аскеза быть завершена
            if case .days(let days) = updatedAskeza.duration, newProgress >= days {
                // Если прогресс достиг или превысил длительность, отмечаем как завершенную
                updatedAskeza.isCompleted = true
                
                // Обновляем связанный шаблон
                if let templateID = updatedAskeza.templateID {
                    print("✅ AskezaViewModel.updateProgress: Завершаем шаблон с ID: \(templateID)")
                    
                    PracticeTemplateStore.shared.updateProgress(
                        forTemplateID: templateID,
                        daysCompleted: days,
                        isCompleted: true
                    )
                }
                
                // Обновляем прогресс аскезы
                updatedAskeza.progress = newProgress
                
                // ВАЖНО: Сначала удаляем аскезу из активных, чтобы предотвратить дублирование
                activeAskezas.remove(at: index)
                
                // Затем вызываем метод завершения аскезы для перемещения в список завершенных
                print("✅ AskezaViewModel.updateProgress: Переводим аскезу '\(updatedAskeza.title)' в завершенные")
                completeAskeza(updatedAskeza)
            } else {
                // Для незавершенных аскез обновляем прогресс
                updatedAskeza.progress = newProgress
                
                // Обновляем аскезу в массиве активных
                activeAskezas[index] = updatedAskeza
                
                // Обновляем шаблон, если он есть
                if let templateID = updatedAskeza.templateID {
                    print("🔄 AskezaViewModel.updateProgress: Обновление прогресса для шаблона с ID: \(templateID), новый прогресс: \(newProgress)")
                    
                    PracticeTemplateStore.shared.updateProgress(
                        forTemplateID: templateID,
                        daysCompleted: newProgress,
                        isCompleted: false
                    )
                }
                
                saveData()
            }
        }
    }
    
    public func completeAskeza(_ askeza: Askeza) {
        // Проверяем, нет ли уже такой аскезы в завершенных (предотвращаем дубликат)
        if completedAskezas.contains(where: { $0.id == askeza.id }) {
            print("⚠️ AskezaViewModel: Аскеза '\(askeza.title)' с ID \(askeza.id) уже есть в списке завершенных, не добавляем дубликат")
            
            // Проверяем, остался ли дубликат в активных, и удаляем его
            if let index = activeAskezas.firstIndex(where: { $0.id == askeza.id }) {
                print("⚠️ AskezaViewModel: Удаляем дубликат аскезы '\(askeza.title)' из списка активных")
                activeAskezas.remove(at: index)
                saveData()
            }
            
            return
        }
        
        // Проверяем, существует ли аскеза в активных
        if let index = activeAskezas.firstIndex(where: { $0.id == askeza.id }) {
            var completedAskeza = activeAskezas[index]
            
            // ВАЖНО: Не выходим из метода если аскеза уже завершена,
            // а продолжаем выполнение, чтобы переместить её в завершенные
            if completedAskeza.isCompleted {
                print("⚠️ AskezaViewModel: Аскеза '\(completedAskeza.title)' уже отмечена как завершенная, перемещаем в завершенные")
            } else {
                // Отмечаем как завершенную, если еще не отмечена
                completedAskeza.isCompleted = true
            }
            
            // Всегда помечаем для перемещения в список завершенных
            completedAskeza.isInCompletedList = true
            
            // Если есть желание, устанавливаем статус "Ожидает исполнения"
            if completedAskeza.wish != nil {
                completedAskeza.wishStatus = .waiting
            }
            
            // Если аскеза связана с шаблоном, отмечаем завершение шаблона
            if let templateID = completedAskeza.templateID {
                // Получаем информацию о продолжительности шаблона
                if let template = PracticeTemplateStore.shared.getTemplate(byID: templateID) {
                    let daysCompleted = template.duration > 0 ? template.duration : completedAskeza.progress
                    
                    // Проверяем, не запущен ли уже процесс завершения для этого шаблона
                    if let progress = PracticeTemplateStore.shared.getProgress(forTemplateID: templateID), 
                       !progress.isProcessingCompletion {
                        print("✅ AskezaViewModel: Запускаем обновление прогресса для шаблона ID: \(templateID)")
                        // Устанавливаем флаг, что аскеза обрабатывается (для предотвращения дублирования)
                        PracticeTemplateStore.shared.updateProgress(forTemplateID: templateID, 
                                                                daysCompleted: daysCompleted,
                                                                isCompleted: true)
                    } else {
                        print("⚠️ AskezaViewModel: Пропускаем обновление прогресса для шаблона ID: \(templateID), так как процесс завершения уже запущен")
                    }
                }
            }
            
            // Удаляем из активных и добавляем в завершенные
            activeAskezas.remove(at: index)
            completedAskezas.append(completedAskeza)
            print("✅ AskezaViewModel: Аскеза '\(completedAskeza.title)' перемещена в завершенные")
            
            saveData()
        } else {
            // Аскеза не найдена в активных, проверим, нет ли её уже в завершенных
            if !completedAskezas.contains(where: { $0.id == askeza.id }) {
                // Копируем аскезу в завершенные с флагами завершения
                var completedAskeza = askeza
                completedAskeza.isCompleted = true
                completedAskeza.isInCompletedList = true
                
                if completedAskeza.wish != nil {
                    completedAskeza.wishStatus = .waiting
                }
                
                completedAskezas.append(completedAskeza)
                print("✅ AskezaViewModel: Аскеза '\(completedAskeza.title)' добавлена в завершенные (не была найдена в активных)")
                
                saveData()
            } else {
                print("⚠️ AskezaViewModel: Аскеза '\(askeza.title)' уже есть в списке завершенных")
            }
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
                
                // Если аскеза связана с шаблоном, сбрасываем прогресс шаблона
                if let templateID = askeza.templateID {
                    // Сбрасываем прогресс в мастерской, но сохраняем счетчик завершений
                    PracticeTemplateStore.shared.resetTemplateProgress(templateID)
                    
                    // Через небольшую задержку вызываем обновление для установки статуса "Активная"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        guard let _ = self else { return }
                        
                        // Искусственно увеличиваем прогресс на 1 день для получения статуса "Активная"
                        resetAskeza.progress = 1
                        
                        // Обновляем шаблон
                        PracticeTemplateStore.shared.updateProgress(
                            forTemplateID: templateID, 
                            daysCompleted: 1,
                            isCompleted: false
                        )
                        
                        // Отправляем дополнительное уведомление для обновления UI
                        NotificationCenter.default.post(
                            name: .refreshWorkshopData,
                            object: resetAskeza
                        )
                    }
                }
                
                // Отправляем уведомление для обновления UI
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .refreshWorkshopData,
                        object: resetAskeza
                    )
                }
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
            
            // Уведомляем об изменениях для обновления UI
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .refreshWorkshopData,
                    object: updatedAskeza
                )
            }
        }
        
        // Проверяем также в завершенных аскезах
        if let index = completedAskezas.firstIndex(where: { $0.id == askeza.id }) {
            var updatedAskeza = askeza
            updatedAskeza.wish = newWish
            updatedAskeza.wishStatus = newWish != nil ? .waiting : nil
            completedAskezas[index] = updatedAskeza
            saveData()
            
            // Уведомляем об изменениях для обновления UI
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .refreshWorkshopData,
                    object: updatedAskeza
                )
            }
        }
    }
    
    public func updateWishStatus(_ askeza: Askeza, status: WishStatus) {
        // Проверяем в активных аскезах
        if let index = activeAskezas.firstIndex(where: { $0.id == askeza.id }) {
            var updatedAskeza = activeAskezas[index]
            updatedAskeza.wishStatus = status
            activeAskezas[index] = updatedAskeza
            saveData()
            
            // Уведомляем об изменениях для обновления UI
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .refreshWorkshopData,
                    object: updatedAskeza
                )
            }
        }
        
        // Проверяем в завершенных аскезах
        if let index = completedAskezas.firstIndex(where: { $0.id == askeza.id }) {
            var updatedAskeza = completedAskezas[index]
            updatedAskeza.wishStatus = status
            completedAskezas[index] = updatedAskeza
            saveData()
            
            // Уведомляем об изменениях для обновления UI
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .refreshWorkshopData,
                    object: updatedAskeza
                )
            }
        }
    }
    
    // Метод для обновления прогресса всех активных аскез
    public func updateAllAskezasProgress(forceUpdate: Bool = false) {
        // Предотвращаем слишком частые обновления
        let now = Date()
        if !forceUpdate && now.timeIntervalSince(lastProgressUpdateTime) < minimumUpdateInterval {
            print("Слишком частый вызов updateAllAskezasProgress, пропускаем...")
            return
        }
        
        lastProgressUpdateTime = now
        isUpdatingProgress = true
        defer { isUpdatingProgress = false }
        
        let calendar = Calendar.current
        var updatedAnyAskeza = false
        
        // Создаем множество для отслеживания уже завершенных шаблонов
        var processedTemplateIDs = Set<UUID>()
        
        // Копируем массив активных аскез для безопасной итерации
        let askezasToProcess = activeAskezas
        
        // Обновляем прогресс для всех активных аскез
        for askeza in askezasToProcess {
            // Проверяем, существует ли аскеза в массиве активных (могла быть удалена в другом потоке)
            guard let index = activeAskezas.firstIndex(where: { $0.id == askeza.id }) else {
                print("⚠️ AskezaViewModel.updateAll: Аскеза '\(askeza.title)' не найдена в активных, пропускаем обновление")
                continue
            }
            
            // Пропускаем уже завершенные аскезы
            if askeza.isCompleted {
                // Перемещаем аскезу в завершенные, если она не там
                if !askeza.isInCompletedList {
                    print("⚠️ AskezaViewModel.updateAll: Аскеза '\(askeza.title)' отмечена как завершенная, но не в списке завершенных - исправляем")
                    completeAskeza(askeza)
                }
                continue
            }
            
            // Вычисляем прогресс на основе даты начала
            let components = calendar.dateComponents([.day], from: askeza.startDate, to: now)
            let totalDays = max(0, components.day ?? 0)
            
            // Обновляем прогресс только если он изменился естественным образом
            if totalDays > askeza.progress {
                var updatedAskeza = askeza
                updatedAskeza.progress = totalDays
                
                print("Обновление аскезы \(askeza.title): было \(askeza.progress), стало \(updatedAskeza.progress), дата начала не изменена")
                
                // Обновляем связанный шаблон, если есть
                if let templateID = updatedAskeza.templateID {
                    // Только если шаблон еще не обрабатывался в этом цикле
                    if !processedTemplateIDs.contains(templateID) {
                        PracticeTemplateStore.shared.updateProgress(forTemplateID: templateID, daysCompleted: updatedAskeza.progress)
                        // Запоминаем, что шаблон уже обработан
                        processedTemplateIDs.insert(templateID)
                    } else {
                        print("⚠️ AskezaViewModel: Пропускаем дублирующееся обновление прогресса для шаблона ID: \(templateID)")
                    }
                }
                
                // Проверяем, завершена ли аскеза по длительности
                if case .days(let duration) = updatedAskeza.duration, updatedAskeza.progress >= duration {
                    // Если аскеза достигла целевой продолжительности, завершаем её
                    updatedAskeza.isCompleted = true
                    updatedAskeza.isInCompletedList = true
                    
                    if updatedAskeza.wish != nil {
                        updatedAskeza.wishStatus = .waiting
                    }
                    
                    // Если аскеза связана с шаблоном, отмечаем завершение шаблона
                    if let templateID = updatedAskeza.templateID, !processedTemplateIDs.contains(templateID) {
                        // Проверяем, не запущен ли уже процесс завершения для этого шаблона
                        if let progress = PracticeTemplateStore.shared.getProgress(forTemplateID: templateID),
                           !progress.isProcessingCompletion {
                            print("✅ AskezaViewModel.updateAll: Запускаем обновление прогресса для шаблона ID: \(templateID)")
                            PracticeTemplateStore.shared.updateProgress(
                                forTemplateID: templateID,
                                daysCompleted: duration,
                                isCompleted: true
                            )
                            
                            // Запоминаем, что шаблон уже обработан
                            processedTemplateIDs.insert(templateID)
                        } else {
                            print("⚠️ AskezaViewModel.updateAll: Пропускаем обновление прогресса для шаблона ID: \(templateID), так как процесс завершения уже запущен")
                        }
                    }
                    
                    // Вместо обновления аскезы в массиве и последующего перемещения,
                    // сразу перемещаем её в завершенные
                    activeAskezas.remove(at: index)
                    
                    // Проверяем наличие дубликата в завершенных аскезах
                    if !completedAskezas.contains(where: { $0.id == updatedAskeza.id }) {
                        completedAskezas.append(updatedAskeza)
                        
                        print("✅ AskezaViewModel.updateAll: Аскеза \(updatedAskeza.title) автоматически перемещена в завершенные")
                        updatedAnyAskeza = true
                        // Не прерываем цикл, продолжаем обработку других аскез
                    } else {
                        print("⚠️ AskezaViewModel.updateAll: Аскеза '\(updatedAskeza.title)' с ID \(updatedAskeza.id) уже есть в списке завершенных, не добавляем дубликат")
                    }
                } else {
                    // Если аскеза не завершена, просто обновляем её в активных
                    activeAskezas[index] = updatedAskeza
                }
                
                updatedAnyAskeza = true
            }
        }
        
        // Сохраняем изменения
        if updatedAnyAskeza {
            saveData()
            print("Обновлен прогресс аскез")
            
            // Отправляем уведомление для обновления данных в мастерской
            print("📢 AskezaViewModel.updateAllAskezasProgress: Отправка уведомления об обновлении данных шаблонов")
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .refreshWorkshopData,
                    object: nil
                )
            }
        }
    }
    
    // Тестовый метод для принудительного обновления всех аскез (для отладки)
    public func forceUpdateAllAskezas() {
        print("Принудительная проверка завершенности аскез")
        forceCheckCompletedAskezas()
    }
    
    private func loadData() {
        if let activeData = userDefaults.data(forKey: activeAskezasKey),
           let activeAskezas = try? JSONDecoder().decode([Askeza].self, from: activeData) {
            // Проверка на дубликаты в активных аскезах
            var uniqueActiveAskezas: [Askeza] = []
            var seenIDs = Set<UUID>()
            
            for askeza in activeAskezas {
                if !seenIDs.contains(askeza.id) {
                    uniqueActiveAskezas.append(askeza)
                    seenIDs.insert(askeza.id)
                } else {
                    print("⚠️ AskezaViewModel.loadData: Обнаружен дубликат активной аскезы с ID \(askeza.id) - \(askeza.title), пропускаем")
                }
            }
            
            self.activeAskezas = uniqueActiveAskezas
        }
        
        if let completedData = userDefaults.data(forKey: completedAskezasKey),
           let completedAskezas = try? JSONDecoder().decode([Askeza].self, from: completedData) {
            // Проверка на дубликаты в завершенных аскезах
            var uniqueCompletedAskezas: [Askeza] = []
            var seenIDs = Set<UUID>()
            
            for var askeza in completedAskezas {
                if !seenIDs.contains(askeza.id) {
                    // Устанавливаем флаг isInCompletedList для всех завершенных аскез
                    askeza.isInCompletedList = true
                    askeza.isCompleted = true // Убеждаемся, что отмечены как завершенные
                    
                    uniqueCompletedAskezas.append(askeza)
                    seenIDs.insert(askeza.id)
                } else {
                    print("⚠️ AskezaViewModel.loadData: Обнаружен дубликат завершенной аскезы с ID \(askeza.id) - \(askeza.title), пропускаем")
                }
            }
            
            self.completedAskezas = uniqueCompletedAskezas
        }
        
        // Проверяем, нет ли аскез, которые одновременно в активных и завершенных
        var idsToRemoveFromActive = Set<UUID>()
        
        for completed in completedAskezas {
            if activeAskezas.contains(where: { $0.id == completed.id }) {
                idsToRemoveFromActive.insert(completed.id)
                print("⚠️ AskezaViewModel.loadData: Аскеза с ID \(completed.id) обнаружена и в активных, и в завершенных. Удаляем из активных")
            }
        }
        
        // Удаляем дубликаты из активных
        if !idsToRemoveFromActive.isEmpty {
            activeAskezas.removeAll { idsToRemoveFromActive.contains($0.id) }
            saveData() // Сохраняем исправленные данные
        }
        
        // Дополнительная проверка целостности - активные аскезы не должны быть помечены как isInCompletedList=true
        var activeAskezasNeedUpdate = false
        for i in 0..<activeAskezas.count {
            if activeAskezas[i].isInCompletedList {
                print("⚠️ AskezaViewModel.loadData: Исправляем активную аскезу \(activeAskezas[i].title) с isInCompletedList=true")
                var askeza = activeAskezas[i]
                askeza.isInCompletedList = false
                activeAskezas[i] = askeza
                activeAskezasNeedUpdate = true
            }
        }
        
        if activeAskezasNeedUpdate {
            saveData()
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
    public func addAskezaToActive(_ askeza: Askeza) {
        activeAskezas.append(askeza)
        saveData()
        
        // Обновляем только прогресс новой аскезы, не затрагивая существующие
        if let templateID = askeza.templateID {
            PracticeTemplateStore.shared.updateProgress(
                forTemplateID: templateID,
                daysCompleted: askeza.progress,
                isCompleted: false
            )
        }
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
        print("Обновление состояния аскез")
        
        // Обновляем прогресс активных аскез, но не принудительно
        updateAllAskezasProgress(forceUpdate: false)
        
        // Проверяем завершенные аскезы и помечаем их как завершенные, но не перемещаем
        forceCheckCompletedAskezas()
    }
    
    // Метод для принудительной проверки и пометки завершенных аскез
    public func forceCheckCompletedAskezas() {
        print("Принудительная проверка завершенных аскез")
        
        // Копируем массив для безопасной итерации
        let askezasToCheck = activeAskezas
        
        // Список ID аскез для удаления после обработки
        var askezasToRemove = [UUID]()
        
        // Проверяем все активные аскезы
        for askeza in askezasToCheck {
            // Проверяем, не должна ли аскеза быть завершена по длительности
            if case .days(let totalDays) = askeza.duration, askeza.progress >= totalDays {
                // Если уже отмечена как завершенная, но не перемещена в завершенные
                if askeza.isCompleted {
                    print("✅ forceCheckCompletedAskezas: Аскеза '\(askeza.title)' уже отмечена как завершенная, перемещаем в завершенные")
                    // Используем основной метод для перемещения в завершенные
                    completeAskeza(askeza)
                    
                    // Добавляем ID в список для удаления
                    askezasToRemove.append(askeza.id)
                    continue
                }
                
                // Если еще не отмечена как завершенная, но должна быть
                var updatedAskeza = askeza
                updatedAskeza.isCompleted = true
                
                // Если есть желание, устанавливаем статус "Ожидает исполнения"
                if updatedAskeza.wish != nil {
                    updatedAskeza.wishStatus = .waiting
                }
                
                // Если аскеза связана с шаблоном, отмечаем завершение шаблона
                if let templateID = updatedAskeza.templateID {
                    PracticeTemplateStore.shared.updateProgress(
                        forTemplateID: templateID,
                        daysCompleted: totalDays,
                        isCompleted: true
                    )
                }
                
                // Вместо обновления в массиве, используем метод для перемещения в завершенные
                print("✅ forceCheckCompletedAskezas: Отмечаем и перемещаем аскезу '\(askeza.title)' в завершенные")
                completeAskeza(updatedAskeza)
                
                // Добавляем ID в список для удаления
                askezasToRemove.append(askeza.id)
            }
        }
        
        // Сохраняем изменения только если были изменения
        if !askezasToRemove.isEmpty {
            print("✅ forceCheckCompletedAskezas: Перемещено \(askezasToRemove.count) завершенных аскез")
            saveData()
        }
    }
    
    // Метод для проверки и устранения дубликатов в активных и завершенных аскезах
    public func checkAndRemoveDuplicates() {
        print("🔍 AskezaViewModel: Проверка и устранение дубликатов")
        
        // Устраняем дубликаты в активных аскезах
        var uniqueActiveAskezas: [Askeza] = []
        var seenActiveIDs = Set<UUID>()
        var hasChanges = false
        
        for askeza in activeAskezas {
            if !seenActiveIDs.contains(askeza.id) {
                uniqueActiveAskezas.append(askeza)
                seenActiveIDs.insert(askeza.id)
            } else {
                print("⚠️ checkAndRemoveDuplicates: Удален дубликат активной аскезы с ID \(askeza.id) - \(askeza.title)")
                hasChanges = true
            }
        }
        
        // Устраняем дубликаты в завершенных аскезах
        var uniqueCompletedAskezas: [Askeza] = []
        var seenCompletedIDs = Set<UUID>()
        
        for askeza in completedAskezas {
            if !seenCompletedIDs.contains(askeza.id) {
                uniqueCompletedAskezas.append(askeza)
                seenCompletedIDs.insert(askeza.id)
            } else {
                print("⚠️ checkAndRemoveDuplicates: Удален дубликат завершенной аскезы с ID \(askeza.id) - \(askeza.title)")
                hasChanges = true
            }
        }
        
        // Удаляем из активных те, которые есть в завершенных
        for completedID in seenCompletedIDs {
            if seenActiveIDs.contains(completedID) {
                uniqueActiveAskezas.removeAll { $0.id == completedID }
                print("⚠️ checkAndRemoveDuplicates: Аскеза с ID \(completedID) обнаружена и в активных, и в завершенных - удалена из активных")
                hasChanges = true
            }
        }
        
        if hasChanges {
            activeAskezas = uniqueActiveAskezas
            completedAskezas = uniqueCompletedAskezas
            saveData()
            print("✅ checkAndRemoveDuplicates: Внесены исправления и сохранены данные")
        } else {
            print("✅ checkAndRemoveDuplicates: Дубликатов не обнаружено")
        }
    }
    
    // Метод для обновления данных через pull-to-refresh
    public func refreshData() {
        // Сначала устраняем возможные дубликаты
        checkAndRemoveDuplicates()
        
        // Синхронизируем данные между аскезами и шаблонами
        synchronizeWithTemplates()
        
        // Обновляем состояние всех аскез (проверяем прогресс и завершение)
        updateAskezaStates()
        
        // Перезагружаем данные из UserDefaults
        loadData()
        
        // Логируем информацию о данных
        print("Данные обновлены. Активных аскез: \(activeAskezas.count), Завершенных: \(completedAskezas.count)")
        
        // Обновляем дату последней проверки
        userDefaults.set(Date(), forKey: "lastCheckDate")
    }
    
    // Метод для синхронизации данных между аскезами и шаблонами
    private func synchronizeWithTemplates() {
        print("🔄 AskezaViewModel: Начинаем синхронизацию с шаблонами")
        
        // Перебираем все активные аскезы, связанные с шаблонами
        for (index, askeza) in activeAskezas.enumerated() {
            if let templateID = askeza.templateID {
                // Получаем информацию о шаблоне и его прогрессе
                if let template = PracticeTemplateStore.shared.getTemplate(byID: templateID),
                   let templateProgress = PracticeTemplateStore.shared.getProgress(forTemplateID: templateID) {
                    
                    // Проверяем статус шаблона
                    let status = templateProgress.status(templateDuration: template.duration)
                    
                    // Если шаблон отмечен как завершенный, но аскеза нет - синхронизируем
                    if (status == .completed || status == .mastered) && !askeza.isCompleted {
                        print("⚠️ AskezaViewModel.synchronizeWithTemplates: Шаблон '\(template.title)' завершен, но аскеза нет - исправляем")
                        var updatedAskeza = askeza
                        updatedAskeza.isCompleted = true
                        activeAskezas[index] = updatedAskeza
                        
                        // Перемещаем в завершенные аскезы
                        completeAskeza(updatedAskeza)
                    }
                    
                    // Если аскеза отмечена как завершенная, но шаблон нет - синхронизируем
                    if askeza.isCompleted && status == .inProgress && !templateProgress.isProcessingCompletion {
                        print("⚠️ AskezaViewModel.synchronizeWithTemplates: Аскеза '\(askeza.title)' завершена, но шаблон нет - исправляем")
                        
                        // Определяем, сколько дней было выполнено
                        let daysCompleted: Int
                        if case .days(let days) = askeza.duration {
                            daysCompleted = days
                        } else {
                            daysCompleted = askeza.progress
                        }
                        
                        // Обновляем прогресс шаблона только если процесс завершения не запущен
                        PracticeTemplateStore.shared.updateProgress(
                            forTemplateID: templateID,
                            daysCompleted: daysCompleted,
                            isCompleted: true
                        )
                    }
                    
                    // Синхронизируем прогресс по дням между аскезой и шаблоном для активных аскез
                    if !askeza.isCompleted && status == .inProgress && templateProgress.daysCompleted != askeza.progress {
                        // Берем максимальное значение из двух источников
                        let maxProgress = max(templateProgress.daysCompleted, askeza.progress)
                        
                        if maxProgress != askeza.progress {
                            print("⚠️ AskezaViewModel.synchronizeWithTemplates: Различается прогресс для '\(askeza.title)': аскеза=\(askeza.progress), шаблон=\(templateProgress.daysCompleted) - обновляем аскезу")
                            var updatedAskeza = askeza
                            updatedAskeza.progress = maxProgress
                            activeAskezas[index] = updatedAskeza
                        }
                        
                        if maxProgress != templateProgress.daysCompleted {
                            print("⚠️ AskezaViewModel.synchronizeWithTemplates: Обновляем прогресс шаблона '\(template.title)' с \(templateProgress.daysCompleted) на \(maxProgress)")
                            PracticeTemplateStore.shared.updateProgress(
                                forTemplateID: templateID,
                                daysCompleted: maxProgress,
                                isCompleted: false
                            )
                        }
                    }
                }
            }
        }
        
        // Проверяем завершенные аскезы, связанные с шаблонами
        for askeza in completedAskezas {
            if let templateID = askeza.templateID {
                // Получаем информацию о шаблоне и его прогрессе
                if let template = PracticeTemplateStore.shared.getTemplate(byID: templateID),
                   let templateProgress = PracticeTemplateStore.shared.getProgress(forTemplateID: templateID) {
                    
                    // Определяем, сколько дней было выполнено
                    let daysCompleted: Int
                    if case .days(let days) = askeza.duration {
                        daysCompleted = days 
                    } else {
                        daysCompleted = askeza.progress
                    }
                    
                    // Если шаблон не отмечен как завершенный и не обрабатывается в данный момент - синхронизируем
                    let status = templateProgress.status(templateDuration: template.duration)
                    if status != .completed && status != .mastered && !templateProgress.isProcessingCompletion {
                        print("⚠️ AskezaViewModel.synchronizeWithTemplates: Аскеза '\(askeza.title)' завершена, но шаблон нет - исправляем")
                        
                        // Обновляем прогресс шаблона
                        PracticeTemplateStore.shared.updateProgress(
                            forTemplateID: templateID,
                            daysCompleted: daysCompleted,
                            isCompleted: true
                        )
                    }
                } else {
                    print("⚠️ AskezaViewModel.synchronizeWithTemplates: Для завершенной аскезы '\(askeza.title)' не найден шаблон с ID \(templateID)")
                }
            }
        }
        
        // Сохраняем внесенные изменения
        saveData()
        print("✅ AskezaViewModel.synchronizeWithTemplates: Синхронизация завершена")
        
        // Обновляем данные в мастерской
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .refreshWorkshopData,
                object: nil
            )
        }
    }
    
    // Метод для обновления даты начала аскезы напрямую
    public func updateAskezaStartDate(_ askeza: Askeza, newStartDate: Date) {
        // Проверяем, что аскеза находится в активных
        if let index = activeAskezas.firstIndex(where: { $0.id == askeza.id }) {
            var updatedAskeza = activeAskezas[index]
            
            // Обновляем дату начала
            updatedAskeza.startDate = newStartDate
            
            // Вычисляем новый прогресс на основе новой даты начала
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: newStartDate, to: Date())
            let newProgress = max(0, components.day ?? 0)
            
            // Обновляем прогресс
            updatedAskeza.progress = newProgress
            
            // Обновляем аскезу в массиве активных
            activeAskezas[index] = updatedAskeza
            
            // Обновляем шаблон, если он есть
            if let templateID = updatedAskeza.templateID {
                print("🔄 AskezaViewModel.updateAskezaStartDate: Обновление даты начала для шаблона с ID: \(templateID), новый прогресс: \(newProgress)")
                
                // Получаем прогресс шаблона
                if let templateProgress = PracticeTemplateStore.shared.getProgress(forTemplateID: templateID) {
                    // Если шаблон был "не начат", обновляем его дату начала
                    if templateProgress.dateStarted == nil {
                        // Устанавливаем дату начала шаблона
                        PracticeTemplateStore.shared.updateTemplateStartDate(templateID, newStartDate: newStartDate)
                    }
                }
                
                // Обновляем прогресс шаблона
                PracticeTemplateStore.shared.updateProgress(
                    forTemplateID: templateID,
                    daysCompleted: newProgress,
                    isCompleted: false
                )
            }
            
            saveData()
            
            // Уведомляем об изменениях для обновления UI
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .refreshWorkshopData,
                    object: updatedAskeza
                )
            }
        }
    }
    
    // Метод для проверки активности шаблона
    @objc private func checkTemplateActivity(_ notification: Notification) {
        guard let templateID = notification.object as? UUID else {
            print("⚠️ AskezaViewModel.checkTemplateActivity: Не передан templateID")
            return
        }
        
        print("🔍 AskezaViewModel.checkTemplateActivity: Проверка активности шаблона \(templateID)")
        
        // Проверяем, есть ли активная аскеза с таким templateID
        let isActive = activeAskezas.contains { $0.templateID == templateID }
        
        // Если шаблон активен, но нет соответствующей записи в PracticeTemplateStore
        if isActive {
            print("✅ AskezaViewModel.checkTemplateActivity: Шаблон \(templateID) активен")
            
            // Получаем прогресс шаблона
            if let progress = PracticeTemplateStore.shared.getProgress(forTemplateID: templateID),
               let template = PracticeTemplateStore.shared.getTemplate(byID: templateID) {
                
                // Проверяем, соответствует ли статус шаблона его активности
                let status = progress.status(templateDuration: template.duration)
                
                // Обновляем информацию о прогрессе
                if let activeAskeza = activeAskezas.first(where: { $0.templateID == templateID }) {
                    // Если статус не соответствует активному, исправляем
                    if status != .inProgress {
                        print("🔄 AskezaViewModel.checkTemplateActivity: Принудительно обновляем статус шаблона на активный")
                        
                        // Устанавливаем дату начала, если она отсутствует
                        if progress.dateStarted == nil {
                            progress.dateStarted = activeAskeza.startDate
                        }
                        
                        // Обновляем прогресс
                        PracticeTemplateStore.shared.updateProgress(
                            forTemplateID: templateID,
                            daysCompleted: activeAskeza.progress,
                            isCompleted: false
                        )
                    } else {
                        // Если статус соответствует, просто синхронизируем прогресс
                        PracticeTemplateStore.shared.updateProgress(
                            forTemplateID: templateID,
                            daysCompleted: activeAskeza.progress,
                            isCompleted: false
                        )
                    }
                }
            }
        } else {
            print("ℹ️ AskezaViewModel.checkTemplateActivity: Шаблон \(templateID) не активен")
            
            // Если шаблон не активен, но в PracticeTemplateStore он помечен как активный
            // обновляем его статус на основе наличия завершений
            if let progress = PracticeTemplateStore.shared.getProgress(forTemplateID: templateID),
               let template = PracticeTemplateStore.shared.getTemplate(byID: templateID) {
                
                let status = progress.status(templateDuration: template.duration)
                
                // Если статус активный, но аскеза не активна, корректируем
                if status == .inProgress && progress.timesCompleted > 0 {
                    print("🔄 AskezaViewModel.checkTemplateActivity: Корректируем статус шаблона")
                    
                    // Сбрасываем прогресс, но сохраняем счетчик завершений
                    progress.daysCompleted = 0
                    
                    // Сохраняем изменения
                    PracticeTemplateStore.shared.saveContext()
                }
            }
        }
        
        // Отправляем уведомление для обновления UI в мастерской
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .refreshWorkshopData,
                object: nil
            )
        }
    }
} 