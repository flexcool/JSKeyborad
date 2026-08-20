import SwiftUI

struct KeyboardSearchView: View {
    @Binding var searchText: String
    let onTemplateSelect: (Template) -> Void
    let onCancel: () -> Void
    
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                
                TextField("搜索模板...", text: $searchText)
                    .font(.subheadline)
                    .focused($isSearchFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }
            }
            .padding(8)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(8)
            
            Button("取消") {
                searchText = ""
                isSearchFocused = false
                onCancel()
            }
            .font(.subheadline)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .onAppear {
            isSearchFocused = true
        }
    }
}

struct QuickSearchResultsView: View {
    let templates: [Template]
    let onTemplateSelect: (Template) -> Void
    
    var body: some View {
        if templates.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.secondary)
                Text("未找到匹配的模板")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(templates) { template in
                        SearchResultRow(template: template)
                            .onTapGesture {
                                onTemplateSelect(template)
                            }
                        
                        if template.id != templates.last?.id {
                            Divider()
                                .padding(.leading, 44)
                        }
                    }
                }
            }
        }
    }
}

struct SearchResultRow: View {
    let template: Template
    
    var body: some View {
        HStack(spacing: 12) {
            if let iconName = template.customIcon {
                Image(systemName: iconName)
                    .font(.body)
                    .foregroundColor(colorFromHex(template.customColor ?? "#007AFF"))
                    .frame(width: 32, height: 32)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(template.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(template.content)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if template.useCount > 0 {
                Text("\(template.useCount)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Image(systemName: "arrow.up.left")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
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
    VStack {
        KeyboardSearchView(
            searchText: .constant("测试"),
            onTemplateSelect: { _ in },
            onCancel: {}
        )
        
        QuickSearchResultsView(
            templates: [Template.preview],
            onTemplateSelect: { _ in }
        )
    }
}
