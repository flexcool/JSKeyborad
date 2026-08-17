import Foundation

class DataStore: ObservableObject {
    static let shared = DataStore()
    
    private let appGroupId = "group.com.jskeyboard.app"
    private let templatesKey = "templates"
    private let foldersKey = "folders"
    private let settingsKey = "settings"
    
    @Published var templates: [Template] = []
    @Published var folders: [Folder] = []
    @Published var settings: AppSettings = AppSettings()
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }
    
    private var sharedContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId)
    }
    
    private init() {
        loadData()
    }
    
    // MARK: - Load Data
    
    func loadData() {
        loadTemplates()
        loadFolders()
        loadSettings()
        
        if folders.isEmpty {
            folders = Folder.defaultFolders
            saveFolders()
        }
    }
    
    private func loadTemplates() {
        guard let data = sharedDefaults?.data(forKey: templatesKey) else { return }
        if let decoded = try? JSONDecoder().decode([Template].self, from: data) {
            templates = decoded
        }
    }
    
    private func loadFolders() {
        guard let data = sharedDefaults?.data(forKey: foldersKey) else { return }
        if let decoded = try? JSONDecoder().decode([Folder].self, from: data) {
            folders = decoded
        }
    }
    
    private func loadSettings() {
        guard let data = sharedDefaults?.data(forKey: settingsKey) else { return }
        if let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }
    
    // MARK: - Save Data
    
    func saveTemplates() {
        if let data = try? JSONEncoder().encode(templates) {
            sharedDefaults?.set(data, forKey: templatesKey)
        }
    }
    
    func saveFolders() {
        if let data = try? JSONEncoder().encode(folders) {
            sharedDefaults?.set(data, forKey: foldersKey)
        }
    }
    
    func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            sharedDefaults?.set(data, forKey: settingsKey)
        }
    }
    
    // MARK: - Template Operations
    
    func addTemplate(_ template: Template) {
        templates.append(template)
        saveTemplates()
    }
    
 func updateTemplate(_ template: Template) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
            saveTemplates()
        }
    }
    
    func deleteTemplate(_ template: Template) {
        templates.removeAll { $0.id == template.id }
        saveTemplates()
    }
    
    func deleteTemplates(_ templateIds: Set<UUID>) {
        templates.removeAll { templateIds.contains($0.id) }
        saveTemplates()
    }
    
    func moveTemplates(_ templateIds: Set<UUID>, to folderId: UUID?) {
        for i in templates.indices {
            if templateIds.contains(templates[i].id) {
                templates[i].folderId = folderId
            }
        }
        saveTemplates()
    }
    
    func togglePin(_ template: Template) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index].isPinned.toggle()
            saveTemplates()
        }
    }
    
    func incrementUseCount(_ template: Template) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index].incrementUseCount()
            saveTemplates()
        }
    }
    
    func getTemplates(for folderId: UUID?) -> [Template] {
        templates.filter { $0.folderId == folderId }
    }
    
    func getPinnedTemplates() -> [Template] {
        templates.filter { $0.isPinned }
    }
    
    func getMostUsedTemplates(limit: Int = 6) -> [Template] {
        Array(templates.sorted { $0.useCount > $1.useCount }.prefix(limit))
    }
    
    func searchTemplates(query: String) -> [Template] {
        guard !query.isEmpty else { return templates }
        let lowercasedQuery = query.lowercased()
        return templates.filter {
            $0.title.lowercased().contains(lowercasedQuery) ||
            $0.content.lowercased().contains(lowercasedQuery)
        }
    }
    
    // MARK: - Folder Operations
    
    func addFolder(_ folder: Folder) {
        folders.append(folder)
        saveFolders()
    }
    
    func updateFolder(_ folder: Folder) {
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index] = folder
            saveFolders()
        }
    }
    
    func deleteFolder(_ folder: Folder) {
        guard !folder.isSystem else { return }
        for i in templates.indices {
            if templates[i].folderId == folder.id {
                templates[i].folderId = nil
            }
        }
        folders.removeAll { $0.id == folder.id }
        saveFolders()
        saveTemplates()
    }
    
    // MARK: - Export / Import
    
    func exportData() -> Data? {
        let export = ExportData(
            templates: templates,
            folders: folders,
            settings: settings,
            exportDate: Date()
        )
        return try? JSONEncoder().encode(export)
    }
    
    func importData(from data: Data) -> Bool {
        guard let importData = try? JSONDecoder().decode(ExportData.self, from: data) else {
            return false
        }
        templates = importData.templates
        folders = importData.folders
        settings = importData.settings
        saveTemplates()
        saveFolders()
        saveSettings()
        return true
    }
}

// MARK: - App Settings

struct AppSettings: Codable {
    var isProUser: Bool = false
    var showUseCount: Bool = true
    var defaultSortOrder: SortOrder = .manual
    var keyboardHeight: KeyboardHeight = .standard
}

enum SortOrder: String, Codable, CaseIterable {
    case manual
    case useCount
    case recent
    case alphabetical
}

enum KeyboardHeight: String, Codable, CaseIterable {
    case compact
    case standard
    case tall
}

// MARK: - Export Data

struct ExportData: Codable {
    let templates: [Template]
    let folders: [Folder]
    let settings: AppSettings
    let exportDate: Date
}
