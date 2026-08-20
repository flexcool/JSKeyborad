import SwiftUI

struct TemplateListView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var searchText: String
    @State private var isAddingTemplate = false
    @State private var isAddingFolder = false
    @State private var editingFolder: Folder? = nil
    @State private var selectedTemplates: Set<UUID> = []
    @State private var isEditing = false
    @State private var selectedFolder: UUID? = nil
    @State private var showAddMenu = false
    
    var filteredTemplates: [Template] {
        if searchText.isEmpty {
            return dataStore.getTemplates(for: selectedFolder)
        }
        return dataStore.searchTemplates(query: searchText)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FolderFilterBar(selectedFolder: $selectedFolder, onManageFolders: {
                    isAddingFolder = true
                })
                
                if filteredTemplates.isEmpty {
                    EmptyStateView(
                        icon: "doc.text",
                        title: "没有模板",
                        message: "点击 + 创建你的第一个模板"
                    )
                } else {
                    List {
                        ForEach(filteredTemplates) { template in
                            TemplateRow(template: template, isEditing: isEditing, isSelected: selectedTemplates.contains(template.id))
                                .onTapGesture {
                                    if isEditing {
                                        if selectedTemplates.contains(template.id) {
                                            selectedTemplates.remove(template.id)
                                        } else {
                                            selectedTemplates.insert(template.id)
                                        }
                                    }
                                }
                        }
                        .onDelete(perform: deleteTemplates)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("模板")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEditing ? "完成" : "选择") {
                        isEditing.toggle()
                        if !isEditing {
                            selectedTemplates.removeAll()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if isEditing && !selectedTemplates.isEmpty {
                            Menu {
                                Button("移动到...") {
                                }
                                Button("删除", role: .destructive) {
                                    deleteSelectedTemplates()
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                        
                        Button {
                            showAddMenu = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .confirmationDialog("添加", isPresented: $showAddMenu) {
                Button("新建模板") {
                    isAddingTemplate = true
                }
                Button("新建文件夹") {
                    isAddingFolder = true
                }
                Button("取消", role: .cancel) {}
            }
            .sheet(isPresented: $isAddingTemplate) {
                TemplateEditView(template: nil)
                    .environmentObject(dataStore)
            }
            .sheet(isPresented: $isAddingFolder) {
                FolderEditView(folder: nil)
                    .environmentObject(dataStore)
            }
            .sheet(item: $editingFolder) { folder in
                FolderEditView(folder: folder)
                    .environmentObject(dataStore)
            }
        }
    }
    
    private func deleteTemplates(at offsets: IndexSet) {
        let templatesToDelete = offsets.map { filteredTemplates[$0] }
        for template in templatesToDelete {
            dataStore.deleteTemplate(template)
        }
    }
    
    private func deleteSelectedTemplates() {
        dataStore.deleteTemplates(selectedTemplates)
        selectedTemplates.removeAll()
        isEditing = false
    }
}

struct FolderFilterBar: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var selectedFolder: UUID?
    var onManageFolders: (() -> Void)?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(title: "全部", isSelected: selectedFolder == nil) {
                    selectedFolder = nil
                }
                
                ForEach(dataStore.folders) { folder in
                    FilterChip(title: folder.name, isSelected: selectedFolder == folder.id) {
                        selectedFolder = folder.id
                    }
                    .contextMenu {
                        if !folder.isSystem {
                            Button {
                                selectedFolder = folder.id
                                onManageFolders?()
                            } label: {
                                Label("编辑", systemImage: "pencil")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct TemplateRow: View {
    let template: Template
    let isEditing: Bool
    let isSelected: Bool
    
    var body: some View {
        HStack {
            if isEditing {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .accentColor : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if let iconName = template.customIcon {
                        Image(systemName: iconName)
                            .foregroundColor(colorFromHex(template.customColor ?? "#007AFF"))
                    }
                    
                    Text(template.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if template.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Text(template.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    if template.useCount > 0 {
                        Label("\(template.useCount)", systemImage: "arrow.up.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(template.updatedAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func colorFromHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3:
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }
        return Color(.sRGB, red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, opacity: Double(alpha) / 255)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.medium)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    TemplateListView(searchText: .constant(""))
        .environmentObject(DataStore.shared)
}
