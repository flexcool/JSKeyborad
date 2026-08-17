import WidgetKit
import SwiftUI

struct TemplateWidget: Widget {
    let kind: String = "TemplateWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TemplateWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("常用模板")
        .description("快速复制常用模板到剪贴板")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), templates: Template.previewArray)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), templates: loadTemplates())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = SimpleEntry(date: Date(), templates: loadTemplates())
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300)))
        completion(timeline)
    }
    
    private func loadTemplates() -> [Template] {
        let appGroupId = "group.com.jskeyboard.app"
        guard let defaults = UserDefaults(suiteName: appGroupId),
              let data = defaults.data(forKey: "templates"),
              let templates = try? JSONDecoder().decode([Template].self, from: data) else {
            return []
        }
        return Array(templates.sorted { $0.useCount > $1.useCount }.prefix(6))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let templates: [Template]
}

struct TemplateWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(templates: Array(entry.templates.prefix(3)))
        case .systemMedium:
            MediumWidgetView(templates: Array(entry.templates.prefix(6)))
        default:
            SmallWidgetView(templates: Array(entry.templates.prefix(3)))
        }
    }
}

struct SmallWidgetView: View {
    let templates: [Template]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.accentColor)
                Text("常用模板")
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
            }
            
            ForEach(templates) { template in
                TemplateRowView(template: template)
            }
            
            if templates.isEmpty {
                Text("暂无模板")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct MediumWidgetView: View {
    let templates: [Template]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.accentColor)
                Text("常用模板")
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                
                Link(destination: URL(string: "jskeyborad://templates")!) {
                    Text("查看全部")
                        .font(.caption2)
                        .foregroundColor(.accentColor)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(templates) { template in
                    TemplateGridItem(template: template)
                }
            }
            
            if templates.isEmpty {
                Text("暂无模板")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
    }
}

struct TemplateRowView: View {
    let template: Template
    
    var body: some View {
        Link(destination: URL(string: "jskeyborad://copy/\(template.id.uuidString)")!) {
            HStack {
                if let iconName = template.customIcon {
                    Image(systemName: iconName)
                        .font(.caption)
                        .foregroundColor(colorFromHex(template.customColor ?? "#007AFF"))
                }
                
                Text(template.title)
                    .font(.caption)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "doc.on.doc")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(6)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(6)
        }
    }
    
    private func colorFromHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        return Color(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

struct TemplateGridItem: View {
    let template: Template
    
    var body: some View {
        Link(destination: URL(string: "jskeyborad://copy/\(template.id.uuidString)")!) {
            VStack(spacing: 4) {
                if let iconName = template.customIcon {
                    Image(systemName: iconName)
                        .font(.title3)
                        .foregroundColor(colorFromHex(template.customColor ?? "#007AFF"))
                }
                
                Text(template.title)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(8)
        }
    }
    
    private func colorFromHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        return Color(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

extension Template {
    static let previewArray: [Template] = [
        Template(title: "地址模板", content: "北京市朝阳区...", customIcon: "location.fill", customColor: "#FF3B30"),
        Template(title: "邮件签名", content: "Best regards,\n张三", customIcon: "envelope.fill", customColor: "#007AFF"),
        Template(title: "工作话术", content: "您好，关于...", customIcon: "briefcase.fill", customColor: "#34C759")
    ]
}

@main
struct TemplateWidgetBundle: WidgetBundle {
    var body: some Widget {
        TemplateWidget()
    }
}
