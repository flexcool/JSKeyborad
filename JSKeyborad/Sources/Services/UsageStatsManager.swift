import Foundation

class UsageStatsManager: ObservableObject {
    static let shared = UsageStatsManager()
    
    @Published var dailyStats: [DailyUsage] = []
    @Published var totalInsertions: Int = 0
    @Published var topTemplates: [TemplateUsage] = []
    
    private let appGroupId = "group.com.jskeyboard.app"
    private let statsKey = "usage_stats"
    private let insertionsKey = "total_insertions"
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }
    
    private init() {
        loadStats()
    }
    
    func recordInsertion(templateId: UUID, templateTitle: String) {
        totalInsertions += 1
        
        let today = Calendar.current.startOfDay(for: Date())
        
        if let index = dailyStats.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            dailyStats[index].insertions += 1
            dailyStats[index].templateCounts[templateId, default: 0] += 1
        } else {
            let newStat = DailyUsage(
                date: today,
                insertions: 1,
                templateCounts: [templateId: 1]
            )
            dailyStats.append(newStat)
        }
        
        if let index = topTemplates.firstIndex(where: { $0.templateId == templateId }) {
            topTemplates[index].count += 1
        } else {
            let newUsage = TemplateUsage(templateId: templateId, templateTitle: templateTitle, count: 1)
            topTemplates.append(newUsage)
        }
        
        topTemplates.sort { $0.count > $1.count }
        
        saveStats()
    }
    
    func getDailyStats(for days: Int = 7) -> [DailyUsage] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<days).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                return nil
            }
            return dailyStats.first { calendar.isDate($0.date, inSameDayAs: date) }
        }.reversed()
    }
    
    func getWeeklyTotal() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
        
        return dailyStats
            .filter { $0.date >= weekAgo }
            .reduce(0) { $0 + $1.insertions }
    }
    
    func getMonthlyTotal() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: today)!
        
        return dailyStats
            .filter { $0.date >= monthAgo }
            .reduce(0) { $0 + $1.insertions }
    }
    
    func getTopTemplates(limit: Int = 5) -> [TemplateUsage] {
        Array(topTemplates.prefix(limit))
    }
    
    func resetStats() {
        dailyStats.removeAll()
        totalInsertions = 0
        topTemplates.removeAll()
        saveStats()
    }
    
    private func loadStats() {
        if let data = sharedDefaults?.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode([DailyUsage].self, from: data) {
            dailyStats = decoded
        }
        totalInsertions = sharedDefaults?.integer(forKey: insertionsKey) ?? 0
        
        if let data = sharedDefaults?.data(forKey: "top_templates"),
           let decoded = try? JSONDecoder().decode([TemplateUsage].self, from: data) {
            topTemplates = decoded
        }
    }
    
    private func saveStats() {
        if let data = try? JSONEncoder().encode(dailyStats) {
            sharedDefaults?.set(data, forKey: statsKey)
        }
        sharedDefaults?.set(totalInsertions, forKey: insertionsKey)
        
        if let data = try? JSONEncoder().encode(topTemplates) {
            sharedDefaults?.set(data, forKey: "top_templates")
        }
    }
}

struct DailyUsage: Codable, Identifiable {
    var id: Date { date }
    let date: Date
    var insertions: Int
    var templateCounts: [UUID: Int]
}

struct TemplateUsage: Codable, Identifiable {
    var id: UUID { templateId }
    let templateId: UUID
    let templateTitle: String
    var count: Int
}
