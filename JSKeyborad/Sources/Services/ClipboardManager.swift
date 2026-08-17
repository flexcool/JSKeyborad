import Foundation

class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()
    
    @Published var history: [ClipboardItem] = []
    @Published var maxHistoryCount: Int = 50
    
    private let appGroupId = "group.com.jskeyboard.app"
    private let historyKey = "clipboard_history"
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }
    
    private init() {
        loadHistory()
    }
    
    func copyToClipboard(_ text: String, source: String = "手动复制") {
        UIPasteboard.general.string = text
        
        let item = ClipboardItem(
            content: text,
            source: source,
            timestamp: Date()
        )
        
        history.insert(item, at: 0)
        
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }
        
        saveHistory()
    }
    
    func removeFromHistory(_ item: ClipboardItem) {
        history.removeAll { $0.id == item.id }
        saveHistory()
    }
    
    func clearHistory() {
        history.removeAll()
        saveHistory()
    }
    
    func getPinnedItems() -> [ClipboardItem] {
        history.filter { $0.isPinned }
    }
    
    func togglePin(_ item: ClipboardItem) {
        if let index = history.firstIndex(where: { $0.id == item.id }) {
            history[index].isPinned.toggle()
            saveHistory()
        }
    }
    
    func searchHistory(query: String) -> [ClipboardItem] {
        guard !query.isEmpty else { return history }
        let lowercasedQuery = query.lowercased()
        return history.filter {
            $0.content.lowercased().contains(lowercasedQuery) ||
            $0.source.lowercased().contains(lowercasedQuery)
        }
    }
    
    private func loadHistory() {
        guard let data = sharedDefaults?.data(forKey: historyKey) else { return }
        if let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
            history = decoded
        }
    }
    
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            sharedDefaults?.set(data, forKey: historyKey)
        }
    }
}

struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    let content: String
    let source: String
    let timestamp: Date
    var isPinned: Bool
    
    init(
        id: UUID = UUID(),
        content: String,
        source: String,
        timestamp: Date = Date(),
        isPinned: Bool = false
    ) {
        self.id = id
        self.content = content
        self.source = source
        self.timestamp = timestamp
        self.isPinned = isPinned
    }
}
