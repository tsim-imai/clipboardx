import Cocoa

@MainActor
class SimplePanel {
    private var panel: NSPanel?
    private var clipboardManager: ClipboardManager?
    private var contentStackView: NSStackView?
    
    init() {
        createPanel()
    }
    
    func setClipboardManager(_ manager: ClipboardManager) {
        self.clipboardManager = manager
    }
    
    private func createPanel() {
        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 250, height: 150),
            styleMask: [.nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        guard let panel = panel else { return }
        
        panel.level = .floating
        panel.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.95)
        panel.hasShadow = true
        panel.isOpaque = false
        
        // StackViewベースのレイアウト
        contentStackView = NSStackView()
        guard let stackView = contentStackView else { return }
        
        stackView.orientation = .vertical
        stackView.spacing = 4
        stackView.edgeInsets = NSEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        let titleLabel = NSTextField(labelWithString: "ClipboardX")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 12)
        titleLabel.alignment = .center
        
        stackView.addArrangedSubview(titleLabel)
        panel.contentView = stackView
    }
    
    @objc private func clipboardItemClicked(_ sender: NSButton) {
        guard let manager = clipboardManager else { return }
        
        let index = sender.tag
        if index < manager.items.count {
            let item = manager.items[index]
            manager.copyToClipboard(item)
            print("クリップボードアイテムがクリックされました: \(item.displayText)")
        }
        
        hide()
    }
    
    private func updateContent() {
        guard let stackView = contentStackView else { return }
        
        // 既存のボタンを削除（タイトル以外）
        let subviews = stackView.arrangedSubviews
        for i in 1..<subviews.count {
            stackView.removeArrangedSubview(subviews[i])
            subviews[i].removeFromSuperview()
        }
        
        // クリップボードアイテムを表示
        guard let manager = clipboardManager else {
            let emptyLabel = NSTextField(labelWithString: "クリップボード履歴がありません")
            emptyLabel.font = NSFont.systemFont(ofSize: 10)
            emptyLabel.textColor = .secondaryLabelColor
            stackView.addArrangedSubview(emptyLabel)
            return
        }
        
        let itemsToShow = Array(manager.items.prefix(6)) // 最大6個表示
        
        if itemsToShow.isEmpty {
            let emptyLabel = NSTextField(labelWithString: "クリップボード履歴がありません")
            emptyLabel.font = NSFont.systemFont(ofSize: 10)
            emptyLabel.textColor = .secondaryLabelColor
            stackView.addArrangedSubview(emptyLabel)
        } else {
            for (index, item) in itemsToShow.enumerated() {
                let button = NSButton(title: item.displayText, target: self, action: #selector(clipboardItemClicked(_:)))
                button.tag = index
                button.bezelStyle = .rounded
                button.font = NSFont.systemFont(ofSize: 10)
                button.contentTintColor = .controlAccentColor
                
                // アイテムタイプに応じてアイコンを追加
                switch item.contentType {
                case .url:
                    button.title = "🔗 " + item.displayText
                case .email:
                    button.title = "📧 " + item.displayText
                default:
                    button.title = "📄 " + item.displayText
                }
                
                stackView.addArrangedSubview(button)
            }
        }
        
        // パネルサイズを調整
        let newHeight = max(100, 50 + itemsToShow.count * 25)
        panel?.setContentSize(NSSize(width: 320, height: newHeight))
    }
    
    func showAtMouseLocation() {
        guard let panel = panel else { 
            print("パネルが作成されていません")
            return 
        }
        
        print("パネル表示処理開始")
        updateContent() // 最新のクリップボードデータで更新
        
        let mouseLocation = NSEvent.mouseLocation
        print("マウス位置: \(mouseLocation)")
        
        let screenFrame = NSScreen.main?.frame ?? NSRect.zero
        let panelSize = panel.frame.size
        
        var origin = NSPoint(
            x: mouseLocation.x - panelSize.width / 2,
            y: mouseLocation.y - panelSize.height / 2
        )
        
        // 画面境界チェック
        if origin.x < screenFrame.minX {
            origin.x = screenFrame.minX + 10
        } else if origin.x + panelSize.width > screenFrame.maxX {
            origin.x = screenFrame.maxX - panelSize.width - 10
        }
        
        if origin.y < screenFrame.minY {
            origin.y = screenFrame.minY + 10
        } else if origin.y + panelSize.height > screenFrame.maxY {
            origin.y = screenFrame.maxY - panelSize.height - 10
        }
        
        print("パネル表示位置: \(origin)")
        
        panel.setFrameOrigin(origin)
        panel.makeKeyAndOrderFront(nil)
        
        print("パネルを表示しました")
        
        // 10秒後に自動で非表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
            self?.hide()
        }
    }
    
    func hide() {
        panel?.orderOut(nil)
        print("パネルを非表示にしました")
    }
}