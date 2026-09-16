import SwiftUI

struct FolderListView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var isAddingFolder = false
    @State private var editingFolder: Folder?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dataStore.folders) { folder in
                    FolderRow(folder: folder)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if !folder.isSystem {
                                editingFolder = folder
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if !folder.isSystem {
                                Button(role: .destructive) {
                                    deleteFolder(folder)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                        }
                }
            }
            .listStyle(.plain)
            .navigationTitle("文件夹")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isAddingFolder = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingFolder) {
                FolderEditView(folder: nil)
            }
            .sheet(item: $editingFolder) { folder in
                FolderEditView(folder: folder)
            }
        }
    }
    
    private func deleteFolder(_ folder: Folder) {
        withAnimation {
            dataStore.deleteFolder(folder)
        }
    }
}

struct FolderRow: View {
    let folder: Folder
    
    var body: some View {
        HStack {
            Image(systemName: folder.icon)
                .font(.title2)
                .foregroundColor(colorFromHex(folder.color))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(folder.name)
                    .font(.headline)
                
                Text(folder.isSystem ? "系统文件夹" : "自定义文件夹")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
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

struct FolderEditView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    
    let folder: Folder?
    
    @State private var name = ""
    @State private var icon = "folder"
    @State private var color = "#007AFF"
    
    @State private var showIconPicker = false
    @State private var showColorPicker = false
    
    let iconOptions = [
        "folder", "folder.fill",
        "star", "star.fill",
        "heart", "heart.fill",
        "briefcase", "briefcase.fill",
        "person", "person.fill",
        "house", "house.fill",
        "envelope", "envelope.fill",
        "phone", "phone.fill",
        "message", "message.fill",
        "doc", "doc.fill",
        "photo", "photo.fill",
        "music.note", "film",
        "gamecontroller", "gamecontroller.fill"
    ]
    
    let colorOptions = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#AF52DE", "#5856D6", "#FF2D55", "#00C7BE",
        "#FFD60A", "#8E8E93"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("文件夹信息") {
                    TextField("名称", text: $name)
                    
                    Button {
                        showIconPicker = true
                    } label: {
                        HStack {
                            Text("图标")
                            Spacer()
                            Image(systemName: icon)
                                .foregroundColor(colorFromHex(color))
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
                                .fill(colorFromHex(color))
                                .frame(width: 24, height: 24)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(folder == nil ? "新建文件夹" : "编辑文件夹")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveFolder()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerSheet(selectedIcon: $icon, icons: iconOptions)
            }
            .sheet(isPresented: $showColorPicker) {
                ColorPickerSheet(selectedColor: $color, colors: colorOptions)
            }
            .onAppear {
                if let folder = folder {
                    name = folder.name
                    icon = folder.icon
                    color = folder.color
                }
            }
        }
    }
    
    private func saveFolder() {
        if let existingFolder = folder {
            var updatedFolder = existingFolder
            updatedFolder.name = name
            updatedFolder.icon = icon
            updatedFolder.color = color
            dataStore.updateFolder(updatedFolder)
        } else {
            let newFolder = Folder(
                name: name,
                icon: icon,
                color: color,
                sortOrder: dataStore.folders.count
            )
            dataStore.addFolder(newFolder)
        }
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

#Preview {
    FolderListView()
        .environmentObject(DataStore.shared)
}
