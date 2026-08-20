import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var selectedTab: Tab = .templates
    @State private var searchText = ""
    
    enum Tab: String {
        case templates
        case clipboard
        case stats
        case settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TemplateListView(searchText: $searchText)
                .tabItem {
                    Label("模板", systemImage: "doc.text")
                }
                .tag(Tab.templates)
            
            ClipboardHistoryView()
                .tabItem {
                    Label("剪贴板", systemImage: "doc.on.clipboard")
                }
                .tag(Tab.clipboard)
            
            UsageStatsView()
                .tabItem {
                    Label("统计", systemImage: "chart.bar")
                }
                .tag(Tab.stats)
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
                .tag(Tab.settings)
        }
        .searchable(text: $searchText, prompt: "搜索模板")
    }
}

#Preview {
    ContentView()
        .environmentObject(DataStore.shared)
}
