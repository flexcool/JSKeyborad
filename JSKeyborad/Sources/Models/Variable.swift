import Foundation

struct Variable: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var defaultValue: String?
    var isSystem: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        defaultValue: String? = nil,
        isSystem: Bool = false
    ) {
        self.id = id
        self.name = name
        self.defaultValue = defaultValue
        self.isSystem = isSystem
    }
}

extension Variable {
    static let systemVariables: [Variable] = [
        Variable(name: "today", defaultValue: nil, isSystem: true),
        Variable(name: "now", defaultValue: nil, isSystem: true),
        Variable(name: "date", defaultValue: nil, isSystem: true),
        Variable(name: "time", defaultValue: nil, isSystem: true),
        Variable(name: "weekday", defaultValue: nil, isSystem: true),
        Variable(name: "month", defaultValue: nil, isSystem: true),
        Variable(name: "year", defaultValue: nil, isSystem: true)
    ]
    
    static let preview = Variable(name: "name", defaultValue: "用户")
}
