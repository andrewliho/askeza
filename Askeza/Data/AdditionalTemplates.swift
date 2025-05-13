import Foundation
import SwiftUI

/// Класс для дополнительных шаблонов аскез разной сложности и продолжительности
class AdditionalTemplates {
    /// Добавляет дополнительные шаблоны в хранилище шаблонов
    static func addTemplates(to store: PracticeTemplateStore) {
        print("Добавление дополнительных шаблонов аскез...")
        
        // Проверяем, есть ли в хранилище уже шаблоны с похожими templateId
        let existingTemplates = store.filteredTemplates()
        
        // Проверяем наличие критических шаблонов, которые должны быть всегда
        let hasIronDiscipline = existingTemplates.contains { 
            $0.templateId == "365-days-discipline" || 
            $0.title.contains("железной дисциплины") 
        }
        
        let hasVegetarian = existingTemplates.contains { 
            $0.templateId == "lifetime-vegetarian" || 
            $0.title.contains("Вегетарианство") 
        }
        
        if !hasIronDiscipline {
            print("⚠️ Добавляем отсутствующий шаблон 'Год железной дисциплины'")
            // Создаем шаблон "Год железной дисциплины"
            let ironDiscipline = PracticeTemplate(
                templateId: "365-days-discipline",
                title: "Год железной дисциплины",
                category: .dukh,
                duration: 365,
                quote: "Дисциплина — это мост между целями и достижениями.",
                difficulty: 5,
                description: "Комплексный режим дня с ранним подъёмом, физическими нагрузками, продуктивным днём и регулярной практикой саморазвития.",
                intention: "Сформировать несгибаемую силу воли и жизненную дисциплину"
            )
            store.addTemplate(ironDiscipline)
        }
        
        if !hasVegetarian {
            print("⚠️ Добавляем отсутствующий шаблон 'Вегетарианство'")
            // Создаем шаблон "Вегетарианство"
            let vegetarian = PracticeTemplate(
                templateId: "lifetime-vegetarian",
                title: "Вегетарианство",
                category: .osvobozhdenie,
                duration: 0, // пожизненная
                quote: "Ахимса - ненасилие во всех его проявлениях.",
                difficulty: 3,
                description: "Исключение из рациона мяса и рыбы. Трансформирует не только ваше здоровье, но и отношение к миру.",
                intention: "Уменьшить насилие в мире и практиковать сострадание"
            )
            store.addTemplate(vegetarian)
        }
        
        // Длительные аскезы (90-365 дней)
        let longTemplates = [
            // 100 дней
            PracticeTemplate(
                templateId: "100-days-pushups",
                title: "100 дней отжиманий",
                category: .telo,
                duration: 100,
                quote: "Дисциплина рождает силу.",
                difficulty: 4,
                description: "Ежедневные отжимания с постепенным увеличением количества. Начните с 10 отжиманий и добавляйте по 1 каждый день.",
                intention: "Укрепить верхнюю часть тела и развить силу воли"
            ),
            
            PracticeTemplate(
                templateId: "100-days-meditation",
                title: "100 дней медитации",
                category: .um,
                duration: 100,
                quote: "В тишине рождается мудрость.",
                difficulty: 3,
                description: "Ежедневная медитация продолжительностью 20 минут. Исследуйте различные техники медитации.",
                intention: "Достичь глубокой осознанности и внутреннего покоя"
            ),
            
            // 180 дней (полгода)
            PracticeTemplate(
                templateId: "180-days-health",
                title: "180 дней здорового образа жизни",
                category: .telo,
                duration: 180,
                quote: "Здоровье — это богатство, которое не купишь.",
                difficulty: 4,
                description: "Комплексная практика, включающая здоровое питание, отказ от вредных привычек, регулярные физические нагрузки и полноценный сон.",
                intention: "Трансформация образа жизни и оздоровление организма"
            ),
            
            // 365 дней (год)
            PracticeTemplate(
                templateId: "365-days-reading",
                title: "Год осознанного чтения",
                category: .um,
                duration: 365,
                quote: "Книги — корабли мысли, бороздящие океаны времени.",
                difficulty: 3,
                description: "Чтение минимум 20 страниц каждый день на протяжении года. Включает художественную и научно-популярную литературу.",
                intention: "Расширить кругозор и развить интеллект"
            ),
            
            PracticeTemplate(
                templateId: "365-days-discipline",
                title: "Год железной дисциплины",
                category: .dukh,
                duration: 365,
                quote: "Дисциплина — мост между целями и достижениями.",
                difficulty: 5,
                description: "Комплексный режим дня с ранним подъёмом, физическими нагрузками, продуктивным днём и регулярной практикой саморазвития.",
                intention: "Сформировать несгибаемую силу воли и жизненную дисциплину"
            )
        ]
        
        // Пожизненные аскезы
        let lifetimeTemplates = [
            PracticeTemplate(
                templateId: "lifetime-vegetarian",
                title: "Вегетарианство",
                category: .osvobozhdenie,
                duration: 0, // 0 означает пожизненную аскезу
                quote: "Ненасилие начинается с вашей тарелки.",
                difficulty: 4,
                description: "Отказ от мяса животных как способ практики ненасилия (ахимсы) и заботы о своём здоровье и планете.",
                intention: "Практика сострадания ко всем живым существам"
            ),
            
            PracticeTemplate(
                templateId: "lifetime-honesty",
                title: "Абсолютная честность",
                category: .dukh,
                duration: 0,
                quote: "Правда делает человека свободным.",
                difficulty: 4,
                description: "Отказ от любой лжи, включая «белую ложь» и умолчания. Практика полной искренности в словах и поступках.",
                intention: "Достичь внутренней гармонии через согласованность слов и действий"
            ),
            
            PracticeTemplate(
                templateId: "lifetime-mindfulness",
                title: "Постоянная осознанность",
                category: .um,
                duration: 0,
                quote: "Жизнь — это то, что происходит сейчас.",
                difficulty: 5,
                description: "Непрерывная практика присутствия в моменте и осознанного проживания каждого действия в повседневной жизни.",
                intention: "Жить полной жизнью, не упуская ни мгновения"
            ),
            
            PracticeTemplate(
                templateId: "lifetime-minimalism",
                title: "Минимализм",
                category: .osvobozhdenie,
                duration: 0,
                quote: "Меньше вещей — больше смысла.",
                difficulty: 3,
                description: "Осознанное отношение к потреблению и владению вещами. Избавление от лишнего, фокус на важном.",
                intention: "Освободиться от власти материального и обрести внутреннюю свободу"
            ),
            
            PracticeTemplate(
                templateId: "lifetime-gratitude",
                title: "Ежедневная благодарность",
                category: .dukh,
                duration: 0,
                quote: "Благодарность — это богатство души.",
                difficulty: 2,
                description: "Ежедневная практика благодарности за всё, что происходит в жизни, включая трудности и препятствия.",
                intention: "Преобразовать восприятие жизни через призму благодарности"
            )
        ]
        
        // Аскезы разных сложностей (от 1 до 5 звезд)
        let variedDifficultyTemplates = [
            // 1 звезда (легкие)
            PracticeTemplate(
                templateId: "14-days-smile",
                title: "14 дней улыбок",
                category: .otnosheniya,
                duration: 14,
                quote: "Улыбка — это кривая, которая выпрямляет всё.",
                difficulty: 1,
                description: "Осознанно улыбаться каждому человеку, которого встречаете в течение дня.",
                intention: "Улучшить качество социальных взаимодействий"
            ),
            
            // 2 звезды
            PracticeTemplate(
                templateId: "21-days-early-rise",
                title: "21 день раннего подъёма",
                category: .telo,
                duration: 21,
                quote: "Рано ложиться и рано вставать — здоровье, богатство и мудрость.",
                difficulty: 2,
                description: "Подъём каждый день в 5:30 утра, включая выходные.",
                intention: "Перестроить свой режим дня для максимальной продуктивности"
            ),
            
            // 3 звезды (средние)
            PracticeTemplate(
                templateId: "30-days-digital-detox",
                title: "30 дней цифрового детокса",
                category: .osvobozhdenie,
                duration: 30,
                quote: "Иногда нужно отключиться, чтобы восстановить связь.",
                difficulty: 3,
                description: "Ограничение использования смартфона и социальных сетей до 30 минут в день.",
                intention: "Вернуть контроль над своим вниманием и временем"
            ),
            
            // 4 звезды
            PracticeTemplate(
                templateId: "60-days-vegan",
                title: "60 дней веганства",
                category: .osvobozhdenie,
                duration: 60,
                quote: "Мы — то, что мы едим.",
                difficulty: 4,
                description: "Полный отказ от продуктов животного происхождения на два месяца.",
                intention: "Очистить организм и исследовать новый способ питания"
            ),
            
            // 5 звезд (сложные)
            PracticeTemplate(
                templateId: "90-days-cold-shower",
                title: "90 дней холодного душа",
                category: .telo,
                duration: 90,
                quote: "Комфорт — враг прогресса.",
                difficulty: 5,
                description: "Ежедневный холодный душ продолжительностью минимум 3 минуты, даже зимой.",
                intention: "Укрепить силу воли и иммунитет до невероятного уровня"
            )
        ]
        
        // Счетчики для отслеживания статистики добавления
        var addedCount = 0
        var skippedCount = 0
        
        // Функция для безопасного добавления шаблона с проверкой на дубликаты
        func safelyAddTemplate(_ template: PracticeTemplate) {
            // Проверяем, существует ли уже шаблон с таким же templateId
            if store.getTemplate(byTemplateId: template.templateId) != nil {
                print("⚠️ Пропускаем добавление шаблона: \(template.title) - шаблон с templateId \(template.templateId) уже существует")
                skippedCount += 1
                return
            }
            
            // Проверяем валидность шаблона
            if !template.validateDuration() {
                print("⚠️ Предупреждение: шаблон \(template.title) имеет несоответствие между названием и продолжительностью")
            }
            
            // Добавляем шаблон только если он прошел проверки
            store.addTemplate(template)
            print("Добавлен шаблон: \(template.title)")
            addedCount += 1
        }
        
        // Добавляем все шаблоны
        for template in longTemplates {
            safelyAddTemplate(template)
        }
        
        // Пожизненные аскезы
        for template in lifetimeTemplates {
            safelyAddTemplate(template)
        }
        
        // Аскезы разных сложностей
        for template in variedDifficultyTemplates {
            safelyAddTemplate(template)
        }
        
        print("Итого: добавлено \(addedCount) новых шаблонов, пропущено \(skippedCount) дубликатов.")
        print("📋 Templates added to store")
    }
    
    /// Преобразует шаблоны практик в PresetAskeza объекты для использования в WorkshopView
    static func getPresetAskezas() -> [PresetAskeza] {
        // Получаем хранилище шаблонов
        let store = PracticeTemplateStore.shared
        print("Получен доступ к PracticeTemplateStore.shared")
        
        // Получаем шаблоны из хранилища
        var templates: [PracticeTemplate] = []
        
        // Безопасно вызываем метод filteredTemplates()
        templates = store.filteredTemplates()
        print("Загружено \(templates.count) шаблонов из PracticeTemplateStore")
        
        // Если шаблоны были успешно загружены, преобразуем их в PresetAskeza
        if !templates.isEmpty {
            return templates.map { template in
                PresetAskeza(
                    title: template.title,
                    description: template.practiceDescription,
                    intention: template.intention,
                    category: template.category,
                    difficulty: template.difficulty,
                    duration: template.duration == 0 ? 0 : template.duration // 0 для пожизненных
                )
            }
        } else {
            // Если не удалось получить шаблоны, используем хардкодированные
            print("Шаблоны не найдены в PracticeTemplateStore, используем хардкодированные")
            return getHardcodedPresetAskezas()
        }
    }
    
    /// Возвращает жестко закодированный список PresetAskeza объектов в случае,
    /// если не удалось получить шаблоны из хранилища
    static func getHardcodedPresetAskezas() -> [PresetAskeza] {
        print("💾 AdditionalTemplates - Возвращаем хардкодированные шаблоны аскез")
        
        // Длительные аскезы
        let longTemplates: [PresetAskeza] = [
            PresetAskeza(
                title: "100 дней отжиманий",
                description: "Ежедневные отжимания с постепенным увеличением количества. Начните с 10 отжиманий и добавляйте по 1 каждый день.",
                intention: "Укрепить верхнюю часть тела и развить силу воли",
                category: .telo,
                difficulty: 4,
                duration: 100
            ),
            PresetAskeza(
                title: "100 дней медитации",
                description: "Ежедневная медитация продолжительностью 20 минут. Исследуйте различные техники медитации.",
                intention: "Достичь глубокой осознанности и внутреннего покоя",
                category: .um,
                difficulty: 3,
                duration: 100
            ),
            PresetAskeza(
                title: "180 дней здорового образа жизни",
                description: "Комплексная практика, включающая здоровое питание, отказ от вредных привычек, регулярные физические нагрузки и полноценный сон.",
                intention: "Трансформация образа жизни и оздоровление организма",
                category: .telo,
                difficulty: 4,
                duration: 180
            ),
            // Добавляем шаблон "Год железной дисциплины" для исправления проблемы
            PresetAskeza(
                title: "Год железной дисциплины",
                description: "Комплексный режим дня с ранним подъёмом, физическими нагрузками, продуктивным днём и регулярной практикой саморазвития.",
                intention: "Сформировать несгибаемую силу воли и жизненную дисциплину",
                category: .dukh,
                difficulty: 5,
                duration: 365
            )
        ]
        
        print("💾 AdditionalTemplates - Создано \(longTemplates.count) длительных шаблонов, включая 'Год железной дисциплины'")
        
        // Пожизненные аскезы
        let lifetimeTemplates: [PresetAskeza] = [
            PresetAskeza(
                title: "Вегетарианство",
                description: "Отказ от мяса животных как способ практики ненасилия (ахимсы) и заботы о своём здоровье и планете.",
                intention: "Практика сострадания ко всем живым существам",
                category: .osvobozhdenie,
                difficulty: 4,
                duration: 0
            ),
            PresetAskeza(
                title: "Абсолютная честность",
                description: "Отказ от любой лжи, включая «белую ложь» и умолчания. Практика полной искренности в словах и поступках.",
                intention: "Достичь внутренней гармонии через согласованность слов и действий",
                category: .dukh,
                difficulty: 4,
                duration: 0
            )
        ]
        
        // Аскезы разной сложности
        let variedDifficultyTemplates: [PresetAskeza] = [
            PresetAskeza(
                title: "14 дней улыбок",
                description: "Осознанно улыбаться каждому человеку, которого встречаете в течение дня.",
                intention: "Улучшить качество социальных взаимодействий",
                category: .otnosheniya,
                difficulty: 1,
                duration: 14
            ),
            PresetAskeza(
                title: "30 дней цифрового детокса",
                description: "Ограничение использования смартфона и социальных сетей до 30 минут в день.",
                intention: "Вернуть контроль над своим вниманием и временем",
                category: .osvobozhdenie,
                difficulty: 3,
                duration: 30
            ),
            PresetAskeza(
                title: "90 дней холодного душа",
                description: "Ежедневный холодный душ продолжительностью минимум 3 минуты, даже зимой.",
                intention: "Укрепить силу воли и иммунитет до невероятного уровня",
                category: .telo,
                difficulty: 5,
                duration: 90
            )
        ]
        
        // Объединяем все шаблоны в один массив и возвращаем его
        return longTemplates + lifetimeTemplates + variedDifficultyTemplates
    }
} 