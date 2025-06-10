# macOS Swift ClipboardX 開発TODO

## Phase 0: 環境構築・プロジェクト初期化

### 1. 開発環境準備
- [ ] Xcode最新版インストール（Xcode 15.0+）
- [ ] macOS Deployment Target設定（macOS 12.0+）
- [ ] Swift Package Manager設定

### 2. プロジェクト作成
- [ ] Xcodeで新しいmacOSアプリプロジェクト作成
- [ ] Bundle Identifier設定（com.imai.clipboardx）
- [ ] App Sandbox無効化（システム権限のため）
- [ ] Hardened Runtime設定

### 3. 必要な権限・Entitlements設定
- [ ] Info.plistにNSAccessibilityUsageDescription追加
- [ ] entitlementsファイル作成
- [ ] com.apple.security.automation.apple-events = true
- [ ] Disable Library Validation = true

### 4. 基本プロジェクト構造作成
- [ ] フォルダ構造作成（App/, Core/, Models/, UI/, Utils/）
- [ ] 基本的なSwiftファイル作成
- [ ] .gitignore設定
- [ ] README.md作成

### 5. 依存関係・フレームワーク
- [ ] Carbon.framework追加（グローバルホットキー用）
- [ ] AppKit.framework確認
- [ ] CoreData.framework（データ永続化用）

### 6. ビルド・実行確認
- [ ] 基本アプリのビルド成功
- [ ] 権限ダイアログ表示確認
- [ ] システム環境設定での権限許可テスト

### 7. 初期コード実装
- [ ] AppDelegate.swift作成（NSApplicationDelegateProtocol）
- [ ] メインウィンドウ非表示設定
- [ ] システムトレイアイコン表示
- [ ] アプリ終了処理

### 重要な設定ファイル例

#### Info.plist追加項目
```xml
<key>NSAccessibilityUsageDescription</key>
<string>ClipboardXはグローバルホットキーとクリップボード管理のためにアクセシビリティ権限が必要です。</string>
<key>LSUIElement</key>
<true/>
<key>LSBackgroundOnly</key>
<false/>
```

#### entitlements設定
```xml
<key>com.apple.security.automation.apple-events</key>
<true/>
<key>com.apple.security.app-sandbox</key>
<false/>
<key>com.apple.security.cs.disable-library-validation</key>
<true/>
```

#### 必要な import文
```swift
import Cocoa
import Carbon
import CoreData
import CoreGraphics
```

## Phase 1: 最小限機能（最優先）

### 1. ホットキーでマウス座標にアプリ表示
- [ ] グローバルホットキー登録（Cmd+Shift+V）
- [ ] マウス座標取得（CGEvent API）
- [ ] NSPanelウィンドウをマウス位置に表示
- [ ] マルチディスプレイ対応

### 2. テキストボックスのフォーカスを外さない
- [ ] NSPanel設定でcanBecomeKeyWindow = false
- [ ] フロントアプリのフォーカス状態を保持
- [ ] ホットキー実行時のフォーカス管理

### 3. アプリをフォーカスせずにボタンを触れる
- [ ] NSPanel acceptsFirstMouse実装
- [ ] クリックスルー機能
- [ ] ボタンホバー・クリック処理

### 4. ボタンクリックで貼り付け
- [ ] クリップボード履歴データ構造
- [ ] 選択したアイテムをクリップボードに設定
- [ ] 元のアプリにフォーカスを戻して貼り付け実行
- [ ] NSPanelを自動非表示

## Phase 2: コア機能

### クリップボード監視
- [ ] NSPasteboard監視
- [ ] 変更検知とハッシュ化
- [ ] 重複除去
- [ ] 履歴件数制限（50件）

### データ永続化
- [ ] CoreData設計
- [ ] JSON永続化（代替案）
- [ ] アプリ起動時データ読み込み
- [ ] 自動保存機能

### UI基本機能
- [ ] SwiftUIまたはAppKit選択
- [ ] リスト表示
- [ ] 検索機能
- [ ] キーボードナビゲーション

## Phase 3: 高度な機能

### システム統合
- [ ] システムトレイアイコン
- [ ] コンテキストメニュー
- [ ] 起動時自動開始
- [ ] アクセシビリティ権限チェック

### UI/UX改善
- [ ] ダークモード対応
- [ ] アニメーション
- [ ] プレビュー機能
- [ ] コンテンツタイプ検出（URL、JSON等）

### 拡張機能
- [ ] ブックマーク機能
- [ ] タグ付け
- [ ] IPアドレス履歴
- [ ] 使用統計

## Phase 4: 高級機能

### 詳細設定
- [ ] 設定画面
- [ ] ホットキーカスタマイズ
- [ ] 履歴件数設定
- [ ] 自動クリーンアップ設定

### エクスポート・インポート
- [ ] データエクスポート
- [ ] 設定バックアップ
- [ ] 他アプリとの連携

### パフォーマンス最適化
- [ ] メモリ使用量最適化
- [ ] 大容量コンテンツ対応
- [ ] バックグラウンド処理最適化

## 技術仕様

### 使用技術スタック
- **言語**: Swift 5.9+
- **UI**: SwiftUI（推奨）またはAppKit
- **データ**: CoreData または Codable + FileManager
- **システム**: Carbon.framework（ホットキー）、AppKit.framework

### アーキテクチャ
```
ClipboardX/
├── App/
│   ├── ClipboardXApp.swift
│   └── ContentView.swift
├── Core/
│   ├── ClipboardManager.swift
│   ├── HotkeyManager.swift
│   └── DataManager.swift
├── Models/
│   ├── ClipboardItem.swift
│   └── AppSettings.swift
├── UI/
│   ├── PanelWindow.swift
│   └── ItemListView.swift
└── Utils/
    ├── MouseTracker.swift
    └── FocusManager.swift
```

### 重要なNSPanel設定
```swift
// フォーカスを奪わない設定
panel.canBecomeKeyWindow = false
panel.level = .floating
panel.acceptsMouseMovedEvents = true
panel.hidesOnDeactivate = false

// クリックスルー実装
override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
    return true
}
```

## 注意事項

### セキュリティ・権限
- アクセシビリティ権限が必要
- グローバルホットキーにはCarbon.frameworkが必要
- クリップボードアクセスは自動的に許可される

### パフォーマンス考慮
- クリップボード監視は適切な間隔で実行
- 大容量コンテンツの処理
- メモリリーク防止

### 互換性
- macOS 12.0+対応
- Intel/Apple Silicon両対応
- 複数ディスプレイ環境対応

---

**最初のマイルストーン**: Phase 1の4機能を完成させる
**目標**: Tauriで実現できなかったNSPanel機能の完全実装