@preconcurrency import Carbon
@preconcurrency import Cocoa

class HotkeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private let hotKeySignature: FourCharCode = 0x4b555244 // 'KURD'
    private let hotKeyID: UInt32 = 1
    
    private var callback: (() -> Void)?
    
    init() {
        installEventHandler()
    }
    
    deinit {
        unregisterHotkey()
    }
    
    func registerHotkey(callback: @escaping () -> Void) {
        self.callback = callback
        
        let modifiers = UInt32(cmdKey | shiftKey)
        let keyCode = UInt32(kVK_ANSI_V)
        
        let hotKeyID = EventHotKeyID(signature: hotKeySignature, id: self.hotKeyID)
        
        var mutableHotKeyID = hotKeyID
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            mutableHotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status != noErr {
            print("Failed to register hotkey: \(status)")
        } else {
            print("Hotkey registered successfully: Cmd+Shift+V")
        }
    }
    
    private func unregisterHotkey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }
    
    private func installEventHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (handler, event, userData) -> OSStatus in
                guard let userData = userData else { return OSStatus(eventNotHandledErr) }
                let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                
                var hotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    event,
                    OSType(kEventParamDirectObject),
                    OSType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                
                if status == noErr && hotKeyID.signature == manager.hotKeySignature && hotKeyID.id == manager.hotKeyID {
                    manager.callback?()
                    return noErr
                }
                
                return OSStatus(eventNotHandledErr)
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            nil
        )
    }
}