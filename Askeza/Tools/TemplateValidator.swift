import Foundation
import SwiftUI

/// Класс для валидации шаблонов практик
public class TemplateValidator {
    
    /// Проверяет все загруженные шаблоны на соответствие названия и продолжительности
    /// - Returns: Массив проблемных шаблонов, у которых название не соответствует продолжительности
    public static func checkAllTemplates() -> [TemplateValidationIssue] {
        let templateStore = PracticeTemplateStore.shared
        let templates = templateStore.templates
        
        var issues: [TemplateValidationIssue] = []
        
        for template in templates {
            if let issue = validateTemplateDuration(template) {
                issues.append(issue)
            }
        }
        
        return issues
    }
    
    /// Запускает проверку всех шаблонов и выводит результаты в консоль
    public static func validateAndLog() {
        let issues = checkAllTemplates()
        
        if issues.isEmpty {
            print("✅ TemplateValidator: Все шаблоны валидны, несоответствий не найдено")
        } else {
            print("⚠️ TemplateValidator: Найдены несоответствия в \(issues.count) шаблонах:")
            
            for (index, issue) in issues.enumerated() {
                print("  \(index + 1). \(issue.template.title):")
                print("     - ID: \(issue.template.templateId)")
                print("     - Проблема: \(issue.issueDescription)")
                if let daysInTitle = issue.daysInTitle {
                    print("     - Дней в названии: \(daysInTitle)")
                }
                print("     - Дней в поле duration: \(issue.template.duration)")
            }
        }
    }
    
    /// Проверяет соответствие названия шаблона и его продолжительности
    /// - Parameter template: Проверяемый шаблон
    /// - Returns: Объект с информацией о проблеме или nil, если проблем нет
    private static func validateTemplateDuration(_ template: PracticeTemplate) -> TemplateValidationIssue? {
        let title = template.title
        let durationValue = template.duration
        
        // Регулярное выражение для поиска числа дней в названии
        let pattern = "(\\d+)[ -]*(дней|дня|день|дневный)"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsString = title as NSString
            let matches = regex.matches(in: title, options: [], range: NSRange(location: 0, length: nsString.length))
            
            if !matches.isEmpty, let match = matches.first {
                let dayRange = match.range(at: 1)
                if dayRange.location != NSNotFound, let daysInTitle = Int(nsString.substring(with: dayRange)) {
                    // Если в названии указано количество дней, оно должно соответствовать значению duration
                    if daysInTitle != durationValue && durationValue != 0 { // 0 = lifetime
                        return TemplateValidationIssue(
                            template: template,
                            issueDescription: "Несоответствие между названием и продолжительностью",
                            daysInTitle: daysInTitle
                        )
                    }
                }
            }
            
            // Проверка для пожизненных аскез
            if durationValue == 0 && !(title.contains("Пожизненно") || title.contains("пожизненно") || title.contains("∞")) {
                return TemplateValidationIssue(
                    template: template,
                    issueDescription: "Пожизненная аскеза (duration = 0) без указания этого в названии",
                    daysInTitle: nil
                )
            }
            
            // Проверка для года
            if title.contains("Год") && durationValue != 365 {
                return TemplateValidationIssue(
                    template: template,
                    issueDescription: "В названии указан 'Год', но duration не равен 365",
                    daysInTitle: 365
                )
            }
            
        } catch {
            return TemplateValidationIssue(
                template: template,
                issueDescription: "Ошибка при проверке: \(error.localizedDescription)",
                daysInTitle: nil
            )
        }
        
        return nil // Нет проблем
    }
}

/// Структура для хранения информации о проблеме с шаблоном
public struct TemplateValidationIssue {
    public let template: PracticeTemplate
    public let issueDescription: String
    public let daysInTitle: Int?
} 