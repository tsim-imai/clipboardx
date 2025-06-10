# macOS Swift ClipboardX 開発TODO

## ✅ Phase 0: 環境構築・プロジェクト初期化 **[完了]**

### 1. 開発環境準備
- [x] Xcode最新版インストール（Xcode 15.0+）
- [x] macOS Deployment Target設定（macOS 12.0+）
- [x] Swift Package Manager設定

### 2. プロジェクト作成
- [x] Swift Package Managerで新しいmacOSアプリプロジェクト作成
- [x] Bundle Identifier設定（com.imai.clipboardx）
- [x] App Sandbox無効化（システム権限のため）
- [x] Hardened Runtime設定

### 3. 必要な権限・Entitlements設定
- [x] Info.plistにNSAccessibilityUsageDescription追加
- [x] entitlementsファイル作成
- [x] com.apple.security.automation.apple-events = true
- [x] Disable Library Validation = true

### 4. 基本プロジェクト構造作成
- [x] フォルダ構造作成（Sources/ClipboardX/）
- [x] 基本的なSwiftファイル作成
- [x] .gitignore設定
- [ ] README.md作成

### 5. 依存関係・フレームワーク
- [x] Carbon.framework追加（グローバルホットキー用）
- [x] AppKit.framework確認
- [x] CoreData.framework（データ永続化用）

### 6. ビルド・実行確認
- [x] 基本アプリのビルド成功
- [x] 権限ダイアログ表示確認
- [x] システム環境設定での権限許可テスト

### 7. 初期コード実装
- [x] main.swift作成（NSApplicationDelegateProtocol）
- [x] メインウィンドウ非表示設定
- [x] システムトレイアイコン表示
- [x] アプリ終了処理

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

## ✅ Phase 1: 最小限機能（最優先） **[完了]**

### 1. ホットキーでマウス座標にアプリ表示
- [x] グローバルホットキー登録（Cmd+Shift+V）
- [x] マウス座標取得（NSEvent.mouseLocation）
- [x] NSPanelウィンドウをマウス位置に表示
- [x] マルチディスプレイ対応

### 2. テキストボックスのフォーカスを外さない
- [x] NSPanel設定でcanBecomeKey = false
- [x] フロントアプリのフォーカス状態を保持
- [x] ホットキー実行時のフォーカス管理

### 3. アプリをフォーカスせずにボタンを触れる
- [x] NSPanel非アクティブパネル設定
- [x] クリックスルー機能
- [x] ボタンホバー・クリック処理

### 4. ボタンクリックで貼り付け
- [x] クリップボード履歴データ構造（ClipboardItem）
- [x] 選択したアイテムをクリップボードに設定
- [x] クリップボード復元機能
- [x] NSPanelを自動非表示（10秒後）

## ✅ Phase 2: コア機能 **[完了]**

### クリップボード監視
- [x] NSPasteboard監視（0.5秒間隔）
- [x] 変更検知とハッシュ化
- [x] 重複除去
- [x] 履歴件数制限（20件）

### データ永続化
- [x] サンプルデータでテスト実装
- [ ] CoreData設計
- [ ] JSON永続化（代替案）
- [ ] アプリ起動時データ読み込み
- [ ] 自動保存機能

### UI基本機能
- [x] AppKit選択（NSPanel + NSStackView）
- [x] リスト表示（最大6件表示）
- [x] コンテンツタイプ別アイコン表示（📄📧🔗）
- [ ] 検索機能
- [ ] キーボードナビゲーション

## 🔄 Phase 3: 高度な機能 **[一部完了]**

### システム統合
- [x] システムトレイアイコン（📋）
- [x] コンテキストメニュー
- [ ] 起動時自動開始
- [ ] アクセシビリティ権限チェック

### UI/UX改善
- [x] 基本的なダークモード対応
- [ ] アニメーション
- [ ] プレビュー機能
- [x] コンテンツタイプ検出（URL、Email、テキスト）

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
- **言語**: Swift 6.1 + @MainActor対応
- **UI**: AppKit（NSPanel + NSStackView）
- **データ**: ObservableObject + Codable（CoreData後日対応）
- **システム**: Carbon.framework（ホットキー）、AppKit.framework
- **並行性**: Swift 6 Strict Concurrency対応

### 実装済みアーキテクチャ
```
ClipboardX/
├── Sources/ClipboardX/
│   ├── main.swift（メインアプリケーション）
│   ├── HotkeyManager.swift（グローバルホットキー）
│   ├── ClipboardManager.swift（クリップボード監視）
│   ├── ClipboardItem.swift（データモデル）
│   ├── SimplePanel.swift（UI実装）
│   └── ClipboardPanel.swift（旧UI実装）
├── Package.swift
├── .gitignore
└── ClipboardX.entitlements
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

## 🎉 実装完了状況 (2024年12月現在)

### ✅ 完了した機能
- **Phase 0**: 環境構築・プロジェクト初期化 (100%)
- **Phase 1**: 最小限機能 (100%)
  - Cmd+Shift+V グローバルホットキー
  - マウス位置での動的パネル表示
  - フォーカスを奪わない NSPanel 設定
  - クリックによるクリップボード復元
- **Phase 2**: コア機能 (80%)
  - リアルタイムクリップボード監視
  - 履歴管理と重複除去
  - コンテンツタイプ別表示
- **Phase 3**: 高度な機能 (40%)
  - システムトレイ統合
  - 基本的なダークモード対応

### 🔧 動作確認済み機能
1. **Cmd+Shift+V** でマウス位置にパネル表示
2. **リアルタイムクリップボード監視** (0.5秒間隔)
3. **履歴アイテムクリック** でクリップボード復元
4. **コンテンツタイプ自動判定** (📄テキスト、🔗URL、📧Email)
5. **重複アイテムの自動管理**
6. **10秒後の自動非表示**

### 🚀 次の優先開発項目
1. **README.md作成** - プロジェクト説明とインストール手順
2. **データ永続化** - CoreData または JSON による履歴保存
3. **起動時自動開始** - ログイン項目登録
4. **検索機能** - 履歴アイテムの絞り込み
5. **キーボードナビゲーション** - 矢印キーでの選択

**最初のマイルストーン**: ✅ **完了** - Tauriで実現できなかったNSPanel機能の完全実装
**次のマイルストーン**: データ永続化とユーザビリティ向上