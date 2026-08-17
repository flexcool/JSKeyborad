import SwiftUI

struct TemplateEditView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    
    let template: Template?
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedFolderId: UUID? = nil
    @State private var customIcon: String = "doc.text"
    @State private var customColor: String = "#007AFF"
    @State private var isPinned = false
    
    @State private var showIconPicker = false
    @State private var showColorPicker = false
    
    let iconOptions = [
        "doc.text", "doc.plaintext", "doc.richtext",
        "message", "envelope", "phone",
        "location", "link", "calendar",
        "clock", "star", "heart",
        "briefcase", "person", "house"
    ]
    
    let colorOptions = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#AF52DE", "#5856D6", "#FF2D55", "#00C7BE"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("标题", text: $title)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("内容")
                        TextEditor(text: $content)
                            .frame(minHeight: 100)
                    }
                    
                    Picker("文件夹", selection: $selectedFolderId) {
                        Text("无").tag(nil as UUID?)
                        ForEach(dataStore.folders) { folder in
                            Text(folder.name).tag(folder.id as UUID?)
                        }
                    }
                }
                
                Section("外观") {
                    Button {
                        showIconPicker = true
                    } label: {
                        HStack {
                            Text("图标")
                            Spacer()
                            Image(systemName: customIcon)
                                .foregroundColor(colorFromHex(customColor))
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button {
                        showColorPicker = true
                    } label: {
                        HStack {
                            Text("颜色")
                            Spacer()
                            Circle()
                                .fill(colorFromHex(customColor))
                                .frame(width: 24, height: 24)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Toggle("置顶", isOn: $isPinned)
                }
                
                Section {
                    Button("预览变量处理结果") {
                        let processed = VariableProcessor.shared.process(content)
                        print("Processed: \(processed)")
                    }
                }
            }
            .navigationTitle(template == nil ? "新建模板" : "编辑模板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveTemplate()
                        dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerSheet(selectedIcon: $customIcon, icons: iconOptions)
            }
            .sheet(isPresented: $showColorPicker) {
                ColorPickerSheet(selectedColor: $customColor, colors: colorOptions)
            }
            .onAppear {
                if let template = template {
                    title = template.title
                    content = template.content
                    selectedFolderId = template.folderId
                    customIcon = template.customIcon ?? "doc.text"
                    customColor = template.customColor ?? "#007AFF"
                    isPinned = template.isPinned
                }
            }
        }
    }
    
    private func saveTemplate() {
        var newTemplate = Template(
            title: title,
            content: content,
            folderId: selectedFolderId,
            isPinned: isPinned,
            customIcon: customIcon,
            customColor: customColor
        )
        
        if let existingTemplate = template {
            newTemplate = Template(
                id: existingTemplate.id,
                title: title,
                content: content,
                folderId: selectedFolderId,
                isPinned: isPinned,
                useCount: existingTemplate.useCount,
                createdAt: existingTemplate.createdAt,
                updatedAt: Date(),
                customIcon: customIcon,
                customColor: customColor
            )
            dataStore.updateTemplate(newTemplate)
        } else {
            dataStore.addTemplate(newTemplate)
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

struct IconPickerSheet: View {
    @Binding var selectedIcon: String
    let icons: [String]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 20) {
                    ForEach(icons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                            dismiss()
                        } label: {
                            Image(systemName: icon)
                                .font(.title2)
                                .frame(width: 50, height: 50)
                                .background(selectedIcon == icon ? Color.accentColor.opacity(0.2) : Color(.secondarySystemBackground))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("选择图标")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ColorPickerSheet: View {
    @Binding var selectedColor: String
    let colors: [String]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                    ForEach(colors, id: \.self) { color in
                        Button {
                            selectedColor = color
                            dismiss()
                        } label: {
                            Circle()
                                .fill(colorFromHex(color))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("选择颜色")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
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

#Preview {
    TemplateEditView(template: nil)
        .environmentObject(DataStore.shared)
}
