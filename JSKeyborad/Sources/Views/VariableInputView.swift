import SwiftUI

struct VariableInputView: View {
    @Binding var variables: [String: String]
    let template: Template
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("填入变量值")
                .font(.headline)
            
            ForEach(extractedVariables, id: \.self) { variable in
                HStack {
                    Text("{\(variable)}")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    TextField("输入值", text: binding(for: variable))
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            if extractedVariables.isEmpty {
                Text("此模板没有变量")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private var extractedVariables: [String] {
        VariableProcessor.shared.extractVariables(from: template.content)
    }
    
    private func binding(for key: String) -> Binding<String> {
        Binding(
            get: { variables[key] ?? "" },
            set: { variables[key] = $0 }
        )
    }
}

#Preview {
    VariableInputView(
        variables: .constant(["name": "张三"]),
        template: Template(title: "测试", content: "你好，{name}！今天是{date}")
    )
}
