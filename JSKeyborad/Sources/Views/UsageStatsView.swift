import SwiftUI

struct UsageStatsView: View {
    @ObservedObject var statsManager = UsageStatsManager.shared
    @ObservedObject var dataStore = DataStore.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summaryCards
                    
                    weeklyChart
                    
                    topTemplatesSection
                    
                    monthlyOverview
                }
                .padding()
            }
            .navigationTitle("使用统计")
        }
    }
    
    // MARK: - Summary Cards
    
    private var summaryCards: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "本周",
                value: "\(statsManager.getWeeklyTotal())",
                icon: "chart.bar",
                color: .blue
            )
            
            StatCard(
                title: "本月",
                value: "\(statsManager.getMonthlyTotal())",
                icon: "calendar",
                color: .green
            )
            
            StatCard(
                title: "总计",
                value: "\(statsManager.totalInsertions)",
                icon: "arrow.up.circle",
                color: .orange
            )
        }
    }
    
    // MARK: - Weekly Chart
    
    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近7天")
                .font(.headline)
            
            let dailyStats = statsManager.getDailyStats(for: 7)
            let maxValue = dailyStats.map(\.insertions).max() ?? 1
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(dailyStats) { stat in
                    VStack(spacing: 4) {
                        Text("\(stat.insertions)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(stat.insertions > 0 ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(
                                width: 30,
                                height: max(CGFloat(stat.insertions) / CGFloat(maxValue) * 100, 4)
                            )
                        
                        Text(formatDate(stat.date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 140)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Top Templates
    
    private var topTemplatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最常用模板")
                .font(.headline)
            
            if statsManager.topTemplates.isEmpty {
                Text("暂无使用记录")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(statsManager.getTopTemplates(limit: 5)) { usage in
                    HStack {
                        if let template = dataStore.templates.first(where: { $0.id == usage.templateId }) {
                            if let iconName = template.customIcon {
                                Image(systemName: iconName)
                                    .foregroundColor(colorFromHex(template.customColor ?? "#007AFF"))
                            }
                        }
                        
                        Text(usage.templateTitle)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(usage.count) 次")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    if usage.id != statsManager.getTopTemplates(limit: 5).last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Monthly Overview
    
    private var monthlyOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("月度概览")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("日均使用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    let monthlyTotal = statsManager.getMonthlyTotal()
                    let dailyAverage = monthlyTotal / 30
                    Text("\(dailyAverage)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("活跃天数")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    let activeDays = Set(statsManager.dailyStats.filter { $0.insertions > 0 }.map { Calendar.current.startOfDay(for: $0.date) }).count
                    Text("\(activeDays)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    UsageStatsView()
}
