import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Pro 功能") {
                    if dataStore.settings.isProUser {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Pro 用户")
                        }
                    } else {
                        Button {
                            // TODO: StoreKit purchase
                        } label: {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                Text("升级到 Pro")
                            }
                        }
                    }
                }
                
                Section("显示设置") {
                    Toggle("显示使用次数", isOn: $dataStore.settings.showUseCount)
                    
                    Picker("默认排序", selection: $dataStore.settings.defaultSortOrder) {
                        Text("手动排序").tag(SortOrder.manual)
                        Text("使用频次").tag(SortOrder.useCount)
                        Text("最近使用").tag(SortOrder.recent)
                        Text("按名称").tag(SortOrder.alphabetical)
                    }
                    
                    Picker("键盘高度", selection: $dataStore.settings.keyboardHeight) {
                        Text("紧凑").tag(KeyboardHeight.compact)
                        Text("标准").tag(KeyboardHeight.standard)
                        Text("较高").tag(KeyboardHeight.tall)
                    }
                }
                
                Section("数据管理") {
                    Button {
                        isExporting = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("导出数据")
                        }
                    }
                    
                    Button {
                        isImporting = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("导入数据")
                        }
                    }
                    
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("清除所有数据")
                        }
                    }
                }
                
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://github.com/flexcool/JSKeyborad")!) {
                        HStack {
                            Image(systemName: "github")
                            Text("GitHub")
                        }
                    }
                    
                    Link(destination: URL(string: "https://github.com/flexcool/JSKeyborad/issues")!) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("反馈问题")
                        }
                    }
                }
                
                Section("隐私政策") {
                    Text("JSKeyborad 不收集任何用户数据。所有模板数据仅存储在您的设备本地。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("设置")
            .fileExporter(
                isPresented: $isExporting,
                document: JSONDocument(data: dataStore.exportData()),
                contentType: .json,
                defaultFilename: "JSKeyborad_Export"
            ) { result in
                switch result {
                case .success:
                    print("导出成功")
                case .failure:
                    print("导出失败")
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.json]
            ) { result in
                switch result {
                case .success(let url):
                    importData(from: url)
                case .failure:
                    print("导入失败")
                }
            }
            .alert("确认清除", isPresented: $showResetAlert) {
                Button("取消", role: .cancel) {}
                Button("确认清除", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("此操作将删除所有模板和文件夹数据，且无法恢复。")
            }
            .onChange(of: dataStore.settings.showUseCount) { _ in
                dataStore.saveSettings()
            }
            .onChange(of: dataStore.settings.defaultSortOrder) { _ in
                dataStore.saveSettings()
            }
            .onChange(of: dataStore.settings.keyboardHeight) { _ in
                dataStore.saveSettings()
            }
        }
    }
    
    private func importData(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        if let data = try? Data(contentsOf: url) {
            _ = dataStore.importData(from: data)
        }
    }
    
    private func resetAllData() {
        dataStore.templates.removeAll()
        dataStore.folders = Folder.defaultFolders
        dataStore.saveTemplates()
        dataStore.saveFolders()
    }
}

struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    let data: Data?
    
    init(data: Data?) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = self.data ?? Data()
        return FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataStore.shared)
}
