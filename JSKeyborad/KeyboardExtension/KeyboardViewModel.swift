import Foundation

class KeyboardViewModel: ObservableObject {
    @Published var templates: [Template] = []
    @Published var folders: [Folder] = []
    @Published var searchText = ""
    @Published var selectedFolder: Folder? = nil
    @Published var selectedTemplate: Template? = nil
    
    private let appGroupId = "group.com.jskeyboard.app"
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }
    
    private let clipboardManager = ClipboardManager.shared
    private let statsManager = UsageStatsManager.shared
    
    func loadData() {
        loadFolders()
        loadTemplates()
    }
    
    private func loadTemplates() {
        guard let data = sharedDefaults?.data(forKey: "templates") else { return }
        if let decoded = try? JSONDecoder().decode([Template].self, from: data) {
            templates = decoded
        }
    }
    
    private func loadFolders() {
        guard let data = sharedDefaults?.data(forKey: "folders") else { return }
        if let decoded = try? JSONDecoder().decode([Folder].self, from: data) {
            folders = decoded
            if selectedFolder == nil {
                selectedFolder = folders.first
            }
        }
    }
    
    var filteredTemplates: [Template] {
        var result = templates
        
        if let folderId = selectedFolder?.id {
            result = result.filter { $0.folderId == folderId }
        }
        
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.content.lowercased().contains(query)
            }
        }
        
        return result.sorted { t1, t2 in
            if t1.isPinned != t2.isPinned {
                return t1.isPinned
            }
            return t1.useCount > t2.useCount
        }
    }
    
    func selectFolder(_ folder: Folder) {
        selectedFolder = folder
    }
    
    func selectTemplate(_ template: Template) {
        selectedTemplate = template
    }
    
    func search() {
        if searchText.isEmpty {
            selectedFolder = folders.first
        } else {
            selectedFolder = nil
        }
    }
    
    func incrementUseCount(_ template: Template) {
        guard let index = templates.firstIndex(where: { $0.id == template.id }) else { return }
        templates[index].incrementUseCount()
        saveTemplates()
    }
    
    private func saveTemplates() {
        if let data = try? JSONEncoder().encode(templates) {
            sharedDefaults?.set(data, forKey: "templates")
        }
    }
}
