import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var selectedTab: Tab = .templates
    @State private var searchText = ""
    
    enum Tab: String {
        case templates
        case folders
        case settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TemplateListView(searchText: $searchText)
                .tabItem {
                    Label("模板", systemImage: "doc.text")
                }
                .tag(Tab.templates)
            
            FolderListView()
                .tabItem {
                    Label("文件夹", systemImage: "folder")
                }
                .tag(Tab.folders)
            
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
