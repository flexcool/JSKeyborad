import SwiftUI

struct TemplateDetailView: View {
    @EnvironmentObject var dataStore: DataStore
    let template: Template
    
    @State private var showCopyAlert = false
    @State private var variables: [String: String] = [:]
    @State private var showVariableInput = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection
                
                Divider()
                
                contentSection
                
                if !extractedVariables.isEmpty {
                    Divider()
                    variablesSection
                }
                
                Divider()
                infoSection
            }
            .padding()
        }
        .navigationTitle("模板详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button {
                        copyToClipboard()
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    
                    Button {
                        showVariableInput.toggle()
                    } label: {
                        Image(systemName: "variable")
                    }
                    .disabled(extractedVariables.isEmpty)
                }
            }
        }
        .alert("已复制", isPresented: $showCopyAlert) {
            Button("好的", role: .cancel) {}
        } message: {
            Text("模板内容已复制到剪贴板")
        }
        .sheet(isPresented: $showVariableInput) {
            NavigationStack {
                VariableInputView(variables: $variables, template: template)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("插入") {
                                insertWithVariables()
                                showVariableInput = false
                            }
                        }
                    }
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            if let iconName = template.customIcon {
                Image(systemName: iconName)
                    .font(.title)
                    .foregroundColor(colorFromHex(template.customColor ?? "#007AFF"))
            }
            
            VStack(alignment: .leading) {
                Text(template.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let folder = dataStore.folders.first(where: { $0.id == template.folderId }) {
                    Text(folder.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if template.isPinned {
                Image(systemName: "pin.fill")
                    .foregroundColor(.orange)
            }
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("内容")
                .font(.headline)
            
            Text(processedContent)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
        }
    }
    
    private var variablesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("变量")
                .font(.headline)
            
            ForEach(extractedVariables, id: \.self) { variable in
                HStack {
                    Text("{\(variable)}")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                    
                    Spacer()
                    
                    if let value = variables[variable] {
                        Text(value)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("使用次数", systemImage: "arrow.up.circle")
                Spacer()
                Text("\(template.useCount)")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("创建时间", systemImage: "calendar")
                Spacer()
                Text(template.createdAt, style: .date)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("更新时间", systemImage: "clock")
                Spacer()
                Text(template.updatedAt, style: .date)
                    .foregroundColor(.secondary)
            }
        }
        .font(.subheadline)
    }
    
    private var extractedVariables: [String] {
        VariableProcessor.shared.extractVariables(from: template.content)
    }
    
    private var processedContent: String {
        VariableProcessor.shared.process(template.content, variables: variables)
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = processedContent
        showCopyAlert = true
        dataStore.incrementUseCount(template)
    }
    
    private func insertWithVariables() {
        let processed = VariableProcessor.shared.process(template.content, variables: variables)
        UIPasteboard.general.string = processed
        showCopyAlert = true
        dataStore.incrementUseCount(template)
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
    TemplateDetailView(template: Template.preview)
        .environmentObject(DataStore.shared)
}
