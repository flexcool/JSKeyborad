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
                templateBar
                
                HStack(spacing: 0) {
                    searchBarButton
                    
                    Spacer(minLength: 8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        folderTabs
                    }
                    .frame(height: 36)
                }
                
                templatesGrid
            }
            
            bottomToolbar
        }
        .background(backgroundColor)
        .onAppear {
            viewModel.loadData()
        }
    }
    
    // MARK: - Template Bar
    
    private var templateBar: some View {
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
        .padding(.vertical, 6)
        .frame(height: viewModel.selectedTemplate != nil ? 36 : 0)
        .clipped()
    }
    
    // MARK: - Search Bar Button
    
    private var searchBarButton: some View {
        Button {
            isSearchMode = true
        } label: {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                Text("搜索")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(6)
            .frame(maxWidth: 80)
        }
    }
    
    // MARK: - Folder Tabs
    
    private var folderTabs: some View {
        HStack(spacing: 6) {
            ForEach(viewModel.folders) { folder in
                Button {
                    viewModel.selectFolder(folder)
                } label: {
                    HStack(spacing: 2) {
                        Image(systemName: folder.icon)
                            .font(.caption2)
                        Text(folder.name)
                            .font(.caption2)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(viewModel.selectedFolder?.id == folder.id ? Color.accentColor : Color(.tertiarySystemBackground))
                    .foregroundColor(viewModel.selectedFolder?.id == folder.id ? .white : .primary)
                    .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Templates Grid
    
    private var templatesGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 6) {
                ForEach(viewModel.filteredTemplates) { template in
                    templateCard(template: template)
                        .onTapGesture {
                            insertTemplate(template)
                        }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 4)
        }
    }
    
    // MARK: - Template Card
    
    private func templateCard(template: Template) -> some View {
        VStack(alignment: .leading, spacing: 2) {
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
                .lineLimit(1)
        }
        .padding(6)
        .frame(minHeight: 50)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(6)
    }
    
    // MARK: - Bottom Toolbar
    
    private var bottomToolbar: some View {
        HStack(spacing: 12) {
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
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(6)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
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
    
    func updateAppearance(isDark: Bool) {
        self.isDark = isDark
    }
    
    private var backgroundColor: Color {
        isDark ? Color(.systemBackground) : Color(.secondarySystemBackground)
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
