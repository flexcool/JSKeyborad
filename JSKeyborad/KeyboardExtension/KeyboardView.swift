import SwiftUI

protocol KeyboardContextProviding {
    var documentContextBeforeInput: String? { get }
    var documentContextAfterInput: String? { get }
    var hasFullAccess: Bool { get }
}

struct KeyboardView: View {
    let onTextInsert: (String) -> Void
    let onTextDelete: () -> Void
    let onNextKeyboard: () -> Void
    let contextProvider: KeyboardContextProviding
    
    @StateObject private var viewModel = KeyboardViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var isDark: Bool = false
    @State private var isSearchMode: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            if isSearchMode {
                KeyboardSearchView(
                    searchText: $viewModel.searchText,
                    onTemplateSelect: { template in
                        insertTemplate(template)
                        isSearchMode = false
                        viewModel.searchText = ""
                    },
                    onCancel: {
                        isSearchMode = false
                        viewModel.searchText = ""
                    }
                )
                
                QuickSearchResultsView(
                    templates: viewModel.searchResults,
                    onTemplateSelect: { template in
                        insertTemplate(template)
                        isSearchMode = false
                        viewModel.searchText = ""
                    }
                )
            } else {
                TemplateBar
                SearchBarButton
                ScrollView(.horizontal, showsIndicators: false) {
                    FolderTabs
                }
                .frame(height: 36)
                
                TemplatesGrid
            }
            
            BottomToolbar
        }
        .background(backgroundColor)
        .onAppear {
            viewModel.loadData()
        }
    }
    
    // MARK: - Template Bar
    
    private var TemplateBar: some View {
        HStack {
            if let selected = viewModel.selectedTemplate {
                Text(selected.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                Button {
                    insertTemplate(selected)
                } label: {
                    Text("插入")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .frame(height: viewModel.selectedTemplate != nil ? 44 : 0)
        .clipped()
    }
    
    // MARK: - Search Bar Button
    
    private var SearchBarButton: some View {
        Button {
            isSearchMode = true
        } label: {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                Text("搜索模板...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(8)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Folder Tabs
    
    private var FolderTabs: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.folders) { folder in
                Button {
                    viewModel.selectFolder(folder)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: folder.icon)
                            .font(.caption)
                        Text(folder.name)
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(viewModel.selectedFolder?.id == folder.id ? Color.accentColor : Color(.tertiarySystemBackground))
                    .foregroundColor(viewModel.selectedFolder?.id == folder.id ? .white : .primary)
                    .cornerRadius(16)
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Templates Grid
    
    private var TemplatesGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(viewModel.filteredTemplates) { template in
                    TemplateCard(template: template)
                        .onTapGesture {
                            viewModel.selectTemplate(template)
                        }
                        .onLongPressGesture {
                            viewModel.selectedTemplate = template
                        }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Template Card
    
    private func TemplateCard(template: Template) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if let iconName = template.customIcon {
                    Image(systemName: iconName)
                        .font(.caption)
                        .foregroundColor(colorFromHex(template.customColor ?? "#007AFF"))
                }
                
                Spacer()
                
                if template.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            
            Text(template.title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text(template.content)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
    
    // MARK: - Bottom Toolbar
    
    private var BottomToolbar: some View {
        HStack(spacing: 16) {
            Button {
                onNextKeyboard()
            } label: {
                Image(systemName: "globe")
                    .font(.title3)
            }
            
            Spacer()
            
            Button {
                onTextDelete()
            } label: {
                Image(systemName: "delete.left")
                    .font(.title3)
            }
            
            Button {
                onTextInsert("\n")
            } label: {
                Text("换行")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Helpers
    
    private func insertTemplate(_ template: Template) {
        let processed = VariableProcessor.shared.process(template.content)
        onTextInsert(processed)
        viewModel.incrementUseCount(template)
        viewModel.selectedTemplate = nil
        
        if contextProvider.hasFullAccess {
            ClipboardManager.shared.copyToClipboard(processed, source: template.title)
            UsageStatsManager.shared.recordInsertion(templateId: template.id, templateTitle: template.title)
        }
    }
    
    private func updateAppearance(isDark: Bool) {
        self.isDark = isDark
    }
    
    private var backgroundColor: Color {
        isDark ? Color(.systemBackground) : Color(.secondarySystemBackground)
    }
    
    private func colorFromHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        return Color(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

#Preview {
    KeyboardView(
        onTextInsert: { _ in },
        onTextDelete: {},
        onNextKeyboard: {},
        contextProvider: PreviewKeyboardContext()
    )
}

class PreviewKeyboardContext: KeyboardContextProviding {
    var documentContextBeforeInput: String? { "Preview " }
    var documentContextAfterInput: String? { nil }
    var hasFullAccess: Bool { false }
}
