import Foundation
import SwiftUI

// Вынесем все предустановленные аскезы в отдельный класс для лучшей организации кода
public struct PresetAskezaStore {
    public static let shared = PresetAskezaStore()
    
    public let askezasByCategory: [AskezaCategory: [PresetAskeza]]
    
    private init() {
        self.askezasByCategory = [
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
                PresetAskeza(title: "Минимализм",
                            description: "Освобождай пространство и голову",
                            intention: "Упростить жизнь и сфокусироваться на важном",
                            category: .um),
                PresetAskeza(title: "Slow Life",
                            description: "Замедление — акт мудрости",
                            intention: "Жить осознанно и наслаждаться каждым моментом",
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
                PresetAskeza(title: "Без критики",
                            description: "Воздержание от критики и осуждения",
                            intention: "Практиковать принятие и понимание других",
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
                            category: .velikie),
                PresetAskeza(title: "Одиночество мудреца",
                            description: "Время наедине с собой для глубокого созерцания",
                            intention: "Познать истинного себя через уединение",
                            category: .velikie)
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
            
            activeAskezas[index] = updatedAskeza
            
            // Проверяем, не завершена ли аскеза
            if case .days(let total) = updatedAskeza.duration, newProgress >= total {
                completeAskeza(updatedAskeza)
            } else {
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
            
            activeAskezas.remove(at: index)
            completedAskezas.append(completedAskeza)
            saveData()
        }
    }
    
    public func resetAskeza(_ askeza: Askeza) {
        if let index = activeAskezas.firstIndex(where: { $0.id == askeza.id }) {
            var resetAskeza = activeAskezas[index]
            resetAskeza.progress = 0
            resetAskeza.startDate = Date() // Обновляем дату начала при сбросе
            activeAskezas[index] = resetAskeza
            saveData()
        }
    }
    
    public func deleteAskeza(_ askeza: Askeza) {
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
        completedAskezas.append(contentsOf: askezasToComplete)
        
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
        print("🔄 Принудительное обновление всех аскез")
        let calendar = Calendar.current
        let now = Date()
        var askezasToComplete: [Askeza] = []
        var indexesToRemove: [Int] = []
        
        // Обновляем прогресс для всех активных аскез
        for i in 0..<activeAskezas.count {
            let askeza = activeAskezas[i]
            var updatedAskeza = askeza
            
            // Принудительно увеличиваем прогресс на 1
            updatedAskeza.progress = askeza.progress + 1
            
            // Корректируем дату начала, чтобы она соответствовала новому прогрессу
            if let newStartDate = calendar.date(byAdding: .day, value: -(updatedAskeza.progress), to: now) {
                updatedAskeza.startDate = newStartDate
            }
            
            print("Обновление аскезы \(askeza.title): было \(askeza.progress), стало \(updatedAskeza.progress)")
            
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
        completedAskezas.append(contentsOf: askezasToComplete)
        
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
        
        let calendar = Calendar.current
        var askezasToComplete = [Askeza]()
        var updatedActiveAskezas = [Askeza]()
        
        // Обновляем состояние каждой активной аскезы
        for askeza in activeAskezas {
            var updatedAskeza = askeza
            
            // Получаем количество дней между датой начала и текущей датой
            let components = calendar.dateComponents([.day], from: updatedAskeza.startDate, to: now)
            let totalDays = max(0, components.day ?? 0)
            
            // Обновляем прогресс
            if totalDays > updatedAskeza.progress {
                updatedAskeza.progress = totalDays
            }
            
            // Проверяем, завершилась ли аскеза
            if case .days(let duration) = updatedAskeza.duration, updatedAskeza.progress >= duration {
                updatedAskeza.isCompleted = true
                if updatedAskeza.wish != nil {
                    updatedAskeza.wishStatus = .waiting
                }
                askezasToComplete.append(updatedAskeza)
            } else {
                updatedActiveAskezas.append(updatedAskeza)
            }
        }
        
        // Обновляем массивы
        activeAskezas = updatedActiveAskezas
        completedAskezas.append(contentsOf: askezasToComplete)
        
        // Сохраняем изменения
        saveData()
        isUpdatingProgress = false
    }
} 