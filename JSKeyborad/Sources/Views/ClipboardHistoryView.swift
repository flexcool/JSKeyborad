import SwiftUI

struct ClipboardHistoryView: View {
    @ObservedObject var clipboardManager = ClipboardManager.shared
    @State private var searchText = ""
    @State private var isEditing = false
    @State private var selectedItems: Set<UUID> = []
    
    var filteredItems: [ClipboardItem] {
        if searchText.isEmpty {
            return clipboardManager.history
        }
        return clipboardManager.searchHistory(query: searchText)
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !clipboardManager.getPinnedItems().isEmpty && searchText.isEmpty {
                    Section("置顶") {
                        ForEach(clipboardManager.getPinnedItems()) { item in
                            ClipboardItemRow(item: item, isEditing: isEditing, isSelected: selectedItems.contains(item.id))
                                .onTapGesture {
                                    if isEditing {
                                        toggleSelection(item)
                                    } else {
                                        copyToClipboard(item.content)
                                    }
                                }
                        }
                    }
                }
                
                Section("历史记录") {
                    ForEach(filteredItems.filter { !$0.isPinned }) { item in
                        ClipboardItemRow(item: item, isEditing: isEditing, isSelected: selectedItems.contains(item.id))
                            .onTapGesture {
                                if isEditing {
                                    toggleSelection(item)
                                } else {
                                    copyToClipboard(item.content)
                                }
                            }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("剪贴板历史")
            .searchable(text: $searchText, prompt: "搜索历史记录")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEditing ? "完成" : "选择") {
                        isEditing.toggle()
                        if !isEditing {
                            selectedItems.removeAll()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if isEditing && !selectedItems.isEmpty {
                            Menu {
                                Button("删除", role: .destructive) {
                                    deleteSelected()
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                        
                        if !clipboardManager.history.isEmpty {
                            Button(role: .destructive) {
                                clipboardManager.clearHistory()
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    private func toggleSelection(_ item: ClipboardItem) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }
    
    private func deleteSelected() {
        for itemId in selectedItems {
            if let item = clipboardManager.history.first(where: { $0.id == itemId }) {
                clipboardManager.removeFromHistory(item)
            }
        }
        selectedItems.removeAll()
        isEditing = false
    }
}

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let isEditing: Bool
    let isSelected: Bool
    
    var body: some View {
        HStack {
            if isEditing {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .accentColor : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.content)
                    .font(.body)
                    .lineLimit(3)
                
                HStack {
                    Text(item.source)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(item.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if item.isPinned {
                Image(systemName: "pin.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ClipboardHistoryView()
}
