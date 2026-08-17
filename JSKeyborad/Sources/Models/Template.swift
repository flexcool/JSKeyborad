import Foundation

struct Template: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var folderId: UUID?
    var isPinned: Bool
    var useCount: Int
    var createdAt: Date
    var updatedAt: Date
    var customIcon: String?
    var customColor: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        folderId: UUID? = nil,
        isPinned: Bool = false,
        useCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        customIcon: String? = nil,
        customColor: String? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.folderId = folderId
        self.isPinned = isPinned
        self.useCount = useCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.customIcon = customIcon
        self.customColor = customColor
    }
    
    mutating func incrementUseCount() {
        useCount += 1
    }
}

extension Template {
    static let preview = Template(
        title: "示例模板",
        content: "这是一段示例文本，支持 {变量名} 语法",
        customIcon: "doc.text",
        customColor: "#007AFF"
    )
}
