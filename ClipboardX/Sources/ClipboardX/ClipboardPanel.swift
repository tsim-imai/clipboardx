import Cocoa
import CoreGraphics

class ClipboardPanel: NSPanel {
    private var contentStackView: NSStackView!
    private var clipboardManager: ClipboardManager?
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: [.nonactivatingPanel], backing: backingStoreType, defer: flag)
        
        setupPanel()
        setupUI()
    }
    
    private func setupPanel() {
        level = .floating
        acceptsMouseMovedEvents = true
        hidesOnDeactivate = false
        isFloatingPanel = true
        becomesKeyOnlyIfNeeded = true
        
        backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.95)
        hasShadow = true
        isOpaque = false
    }
    
    private func setupUI() {
        contentStackView = NSStackView()
        contentStackView.orientation = .vertical
        contentStackView.spacing = 4
        contentStackView.edgeInsets = NSEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        let titleLabel = NSTextField(labelWithString: "ClipboardX")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 12)
        titleLabel.alignment = .center
        
        contentStackView.addArrangedSubview(titleLabel)
        
        contentView = contentStackView
        
        setContentSize(NSSize(width: 300, height: 150))
    }
    
    func setClipboardManager(_ manager: ClipboardManager) {
        self.clipboardManager = manager
    }
    
    private func updateContent() {
        // 既存のボタンを削除（タイトル以外）
        let subviews = contentStackView.arrangedSubviews
        for i in 1..<subviews.count {
            contentStackView.removeArrangedSubview(subviews[i])
            subviews[i].removeFromSuperview()
        }
        
        // クリップボードアイテムを表示
        guard let manager = clipboardManager else { return }
        
        let itemsToShow = Array(manager.items.prefix(5)) // 最大5個表示
        
        if itemsToShow.isEmpty {
            let emptyLabel = NSTextField(labelWithString: "クリップボード履歴がありません")
            emptyLabel.font = NSFont.systemFont(ofSize: 10)
            emptyLabel.textColor = .secondaryLabelColor
            contentStackView.addArrangedSubview(emptyLabel)
        } else {
            for (index, item) in itemsToShow.enumerated() {
                let button = NSButton(title: item.displayText, target: self, action: #selector(clipboardItemClicked(_:)))
                button.tag = index
                button.bezelStyle = .rounded
                button.font = NSFont.systemFont(ofSize: 10)
                button.contentTintColor = .controlAccentColor
                contentStackView.addArrangedSubview(button)
            }
        }
        
        // パネルサイズを調整
        let newHeight = max(100, 50 + itemsToShow.count * 30)
        setContentSize(NSSize(width: 300, height: newHeight))
    }
    
    @objc private func clipboardItemClicked(_ sender: NSButton) {
        guard let manager = clipboardManager else { return }
        
        let index = sender.tag
        if index < manager.items.count {
            let item = manager.items[index]
            manager.copyToClipboard(item)
            print("クリップボードアイテムがクリックされました: \(item.displayText)")
        }
        
        hidePanel()
    }
    
    func showAtMouseLocation() {
        updateContent() // 最新のクリップボードデータで更新
        
        let mouseLocation = NSEvent.mouseLocation
        
        let screenFrame = NSScreen.main?.frame ?? NSRect.zero
        let panelSize = frame.size
        
        var origin = NSPoint(
            x: mouseLocation.x - panelSize.width / 2,
            y: mouseLocation.y - panelSize.height / 2
        )
        
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
        
        setFrameOrigin(origin)
        makeKeyAndOrderFront(nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
            self?.hidePanel()
        }
    }
    
    func hidePanel() {
        orderOut(nil)
    }
    
    
    override var canBecomeKey: Bool {
        return false
    }
}