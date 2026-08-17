import Foundation

struct Folder: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var color: String
    var isSystem: Bool
    var sortOrder: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "folder",
        color: String = "#007AFF",
        isSystem: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.isSystem = isSystem
        self.sortOrder = sortOrder
    }
}

extension Folder {
    static let defaultFolders: [Folder] = [
        Folder(name: "常用", icon: "star.fill", color: "#FFD60A", isSystem: true, sortOrder: 0),
        Folder(name: "工作", icon: "briefcase.fill", color: "#007AFF", isSystem: true, sortOrder: 1),
        Folder(name: "个人", icon: "person.fill", color: "#34C759", isSystem: true, sortOrder: 2)
    ]
    
    static let preview = Folder(name: "示例文件夹", icon: "folder.fill", color: "#FF9500")
}
