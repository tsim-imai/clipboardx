@preconcurrency import Cocoa
@preconcurrency import Carbon

@MainActor
class ClipboardXApp: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var hotkeyManager: HotkeyManager?
    private var simplePanel: SimplePanel?
    private var clipboardManager: ClipboardManager?
    
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.title = "📋"
            button.toolTip = "ClipboardX"
        }
        
        setupMenu()
        setupClipboardManager()
        setupSimplePanel()
        setupHotkey()
        
        print("ClipboardX started successfully")
    }
    
    private func setupHotkey() {
        hotkeyManager = HotkeyManager()
        hotkeyManager?.registerHotkey { [weak self] in
            print("ホットキーが押されました！")
            print("パネル表示を試行中...")
            
            Task { @MainActor in
                if let panel = self?.simplePanel {
                    print("シンプルパネルが見つかりました")
                    panel.showAtMouseLocation()
                } else {
                    print("シンプルパネルが見つかりません")
                }
            }
        }
    }
    
    private func setupClipboardManager() {
        clipboardManager = ClipboardManager()
    }
    
    private func setupSimplePanel() {
        simplePanel = SimplePanel()
        if let manager = clipboardManager {
            simplePanel?.setClipboardManager(manager)
        }
        print("シンプルパネルを作成しました")
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "ClipboardX", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @MainActor @objc private func quit() {
        NSApplication.shared.terminate(self)
    }
}

let app = NSApplication.shared
let delegate = ClipboardXApp()
app.delegate = delegate
app.run()