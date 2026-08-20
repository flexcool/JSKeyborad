import Foundation

struct VariableProcessor {
    static let shared = VariableProcessor()
    
    private init() {}
    
    func process(_ template: String, variables: [String: String] = [:]) -> String {
        var result = template
        
        let systemValues = getSystemValues()
        for (key, value) in systemValues {
            result = result.replacingOccurrences(of: "{\(key)}", with: value)
        }
        
        for (key, value) in variables {
            result = result.replacingOccurrences(of: "{\(key)}", with: value)
        }
        
        return result
    }
    
    private func getSystemValues() -> [String: String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        
        let calendar = Calendar.current
        let now = Date()
        
        formatter.dateFormat = "yyyy年MM月dd日"
        let today = formatter.string(from: now)
        
        formatter.dateFormat = "HH:mm"
        let time = formatter.string(from: now)
        
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: now)
        
        formatter.dateFormat = "HH:mm:ss"
        let fullTime = formatter.string(from: now)
        
        let weekdaySymbols = ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
        let weekdayIndex = calendar.component(.weekday, from: now) - 1
        let weekday = weekdaySymbols[weekdayIndex]
        
        formatter.dateFormat = "MM"
        let month = formatter.string(from: now)
        
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: now)
        
        return [
            "today": today,
            "now": time,
            "date": date,
            "time": fullTime,
            "weekday": weekday,
            "month": month,
            "year": year
        ]
    }
    
    func extractVariables(from template: String) -> [String] {
        var variables: [String] = []
        let pattern = "\\{(\\w+)\\}"
        
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let nsString = template as NSString
            let matches = regex.matches(in: template, range: NSRange(location: 0, length: nsString.length))
            
            for match in matches where match.numberOfRanges > 1 {
                let variableName = nsString.substring(with: match.range(at: 1))
                if !variables.contains(variableName) {
                    variables.append(variableName)
                }
            }
        }
        
        return variables
    }
    
    func hasVariables(_ template: String) -> Bool {
        !extractVariables(from: template).isEmpty
    }
}
