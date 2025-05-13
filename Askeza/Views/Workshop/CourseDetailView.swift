import SwiftUI

struct CourseDetailView: View {
    let course: CoursePath
    let templateStore: PracticeTemplateStore
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTemplate: PracticeTemplate?
    @State private var showingTemplateDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AskezaTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Заголовок
                        VStack(alignment: .center, spacing: 8) {
                            Text(course.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AskezaTheme.textColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            HStack {
                                Image(systemName: course.category.systemImage)
                                    .foregroundColor(course.category.mainColor)
                                
                                Text(course.category.rawValue)
                                    .foregroundColor(AskezaTheme.secondaryTextColor)
                            }
                            
                            // Сложность
                            HStack(spacing: 4) {
                                Text("Сложность:")
                                    .font(.caption)
                                    .foregroundColor(AskezaTheme.secondaryTextColor)
                                
                                ForEach(1...5, id: \.self) { i in
                                    Image(systemName: i <= course.difficulty ? "star.fill" : "star")
                                        .font(.system(size: 10))
                                        .foregroundColor(i <= course.difficulty ? .yellow : Color.gray.opacity(0.3))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AskezaTheme.buttonBackground)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Описание
                        VStack(alignment: .leading, spacing: 8) {
                            Text("О пути")
                                .font(.headline)
                                .foregroundColor(AskezaTheme.textColor)
                            
                            Text(course.courseDescription)
                                .foregroundColor(AskezaTheme.secondaryTextColor)
                        }
                        .padding()
                        .background(AskezaTheme.buttonBackground)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Шаги
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Шаги")
                                .font(.headline)
                                .foregroundColor(AskezaTheme.textColor)
                                .padding(.horizontal)
                            
                            VStack(spacing: 16) {
                                ForEach(course.templateIDs, id: \.self) { templateID in
                                    if let template = templateStore.getTemplate(byID: templateID) {
                                        CourseStepView(
                                            template: template,
                                            progress: templateStore.getProgress(forTemplateID: templateID),
                                            onTap: {
                                                selectedTemplate = template
                                                showingTemplateDetail = true
                                            }
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Закрыть") {
                            dismiss()
                        }
                        .foregroundColor(AskezaTheme.accentColor)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text("Путь")
                            .font(.headline)
                            .foregroundColor(AskezaTheme.textColor)
                    }
                }
                .sheet(isPresented: $showingTemplateDetail) {
                    if let template = selectedTemplate {
                        TemplateDetailView(
                            template: template,
                            templateStore: templateStore
                        )
                    }
                }
            }
        }
    }
}

struct CourseStepView: View {
    let template: PracticeTemplate
    let progress: TemplateProgress?
    let onTap: () -> Void
    
    var status: TemplateStatus {
        if let progress = progress {
            return progress.status(templateDuration: template.duration)
        }
        return .notStarted
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Статус индикатор
                ZStack {
                    Circle()
                        .fill(status.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: status.icon)
                        .font(.system(size: 20))
                        .foregroundColor(status.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AskezaTheme.textColor)
                        .lineLimit(1)
                    
                    Text("\(template.duration) дней • Сложность: \(difficultyText(template.difficulty))")
                        .font(.caption)
                        .foregroundColor(AskezaTheme.secondaryTextColor)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AskezaTheme.secondaryTextColor)
            }
            .padding()
            .background(AskezaTheme.buttonBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func difficultyText(_ level: Int) -> String {
        switch level {
        case 1:
            return "★"
        case 2:
            return "★★"
        case 3:
            return "★★★"
        case 4:
            return "★★★★"
        case 5:
            return "★★★★★"
        default:
            return "Неизвестно"
        }
    }
}

#Preview {
    // Создаем тестовый курс для предпросмотра
    let course = CoursePath(
        id: UUID(),
        title: "Путь медитатора",
        description: "Последовательные практики для развития навыков медитации и осознанности.",
        templateIDs: [UUID(), UUID(), UUID()],
        category: .um,
        difficulty: 3
    )
    
    CourseDetailView(course: course, templateStore: PracticeTemplateStore.shared)
} 