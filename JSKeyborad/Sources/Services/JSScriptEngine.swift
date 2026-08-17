import Foundation
import JavaScriptCore

class JSScriptEngine {
    static let shared = JSScriptEngine()
    
    private let context: JSContext
    
    private init() {
        context = JSContext()
        setupConsoleLog()
    }
    
    private func setupConsoleLog() {
        let consoleLog: @convention(block) (String) -> Void = { message in
            print("[JS Console] \(message)")
        }
        context.setObject(consoleLog, forKeyedSubscript: "consoleLog" as NSString)
        context.evaluateScript("var console = { log: consoleLog };")
    }
    
    func execute(_ script: String, args: [String] = []) -> String? {
        var scriptWithArgs = script
        
        if !args.isEmpty {
            let argsArray = args.map { "\"\($0.replacingOccurrences(of: "\"", with: "\\\""))\"" }
                .joined(separator: ", ")
            scriptWithArgs = "var args = [\(argsArray)];\n\(script)"
        }
        
        context.evaluateScript(scriptWithArgs)
        
        if let result = context.evaluateScript("__result")?.toString() {
            return result
        }
        
        if let exception = context.exception {
            print("[JS Error] \(exception.toString() ?? "Unknown error")")
            return nil
        }
        
        return nil
    }
    
    func validate(_ script: String) -> Bool {
        let testScript = """
        try {
            \(script)
            true
        } catch(e) {
            false
        }
        """
        return context.evaluateScript(testScript)?.toBool() ?? false
    }
    
    func reset() {
        context.evaluateScript("var __result = undefined;")
    }
}
