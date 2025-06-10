import Foundation

struct ClipboardItem {
    let id: UUID
    let content: String
    let timestamp: Date
    let contentType: ContentType
    
    enum ContentType {
        case text
        case url
        case email
        case other
    }
    
    init(content: String) {
        self.id = UUID()
        self.content = content
        self.timestamp = Date()
        self.contentType = Self.detectContentType(content)
    }
    
    private static func detectContentType(_ content: String) -> ContentType {
        if content.hasPrefix("http://") || content.hasPrefix("https://") {
            return .url
        }
        if content.contains("@") && content.contains(".") {
            return .email
        }
        return .text
    }
    
    var displayText: String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count > 50 {
            return String(trimmed.prefix(50)) + "..."
        }
        return trimmed.isEmpty ? "(空のテキスト)" : trimmed
    }
}