import Cocoa
import Foundation

@MainActor
class ClipboardManager: ObservableObject {
    @Published var items: [ClipboardItem] = []
    private var lastChangeCount: Int = 0
    private var timer: Timer?
    
    private let maxItems = 20
    
    init() {
        startMonitoring()
        // テスト用のサンプルデータを追加
        addSampleData()
    }
    
    private func addSampleData() {
        items = [
            ClipboardItem(content: "こんにちは、世界！"),
            ClipboardItem(content: "https://github.com/apple/swift"),
            ClipboardItem(content: "test@example.com"),
            ClipboardItem(content: "今日は良い天気ですね。明日の会議の準備をしなければなりません。")
        ]
    }
    
    func startMonitoring() {
        lastChangeCount = NSPasteboard.general.changeCount
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkClipboard()
            }
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let currentChangeCount = pasteboard.changeCount
        
        if currentChangeCount != lastChangeCount {
            lastChangeCount = currentChangeCount
            
            if let content = pasteboard.string(forType: .string) {
                addItem(content: content)
            }
        }
    }
    
    private func addItem(content: String) {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedContent.isEmpty else { return }
        
        // 重複チェック
        if let existingIndex = items.firstIndex(where: { $0.content == trimmedContent }) {
            // 既存アイテムを先頭に移動
            let existingItem = items.remove(at: existingIndex)
            items.insert(existingItem, at: 0)
            return
        }
        
        let newItem = ClipboardItem(content: trimmedContent)
        items.insert(newItem, at: 0)
        
        // 最大数を超えた場合は古いものを削除
        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }
        
        print("クリップボードに新しいアイテムが追加されました: \(newItem.displayText)")
    }
    
    func copyToClipboard(_ item: ClipboardItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.content, forType: .string)
        
        // アイテムを先頭に移動
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            let movedItem = items.remove(at: index)
            items.insert(movedItem, at: 0)
        }
        
        print("クリップボードにコピーしました: \(item.displayText)")
    }
}