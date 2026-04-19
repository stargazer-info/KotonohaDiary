# ことのは日記

語彙・フレーズを収集する「ことのは」機能と、画像付き日記を記録する「日記」機能を持つ iOS アプリです。

## 機能

### ことのはタブ
気になった語彙やフレーズをテキストまたは画像で保存できます。保存したことのはを選択して、まとめて日記に書き出すこともできます。

### 日記タブ
テキストと複数枚の画像を添付した日記を記録できます。ページめくりで日付順に閲覧できます。

### iCloud 同期
iCloud Drive を使ってデータを複数の端末間で自動的に同期します。

## 動作環境

- iOS 26.0 以上

---

## 開発者向け情報

### ビルド方法

Xcode でプロジェクトを開きます。

```bash
open KotonohaDiary.xcodeproj
```

スキームを **KotonohaDiary SwiftUI** に切り替えてビルドしてください。

> **Note**
> `project.pbxproj` に含まれる `DEVELOPMENT_TEAM` は筆者のチーム ID です。
> ビルド時は Xcode の **Signing & Capabilities** で自分のチームに変更してください。

コマンドラインからのビルド・テストは以下のコマンドで実行できます。

```bash
# ビルド
xcodebuild -project KotonohaDiary.xcodeproj -scheme KotonohaDiary build

# テスト
xcodebuild -project KotonohaDiary.xcodeproj -scheme KotonohaDiary test
```

### ディレクトリ構成

| ディレクトリ | 内容 |
|---|---|
| `KotonohaDiary SwiftUI/` | アクティブな SwiftUI アプリ（全ての新規実装はここ） |
| `KotonohaDiary/` | レガシー UIKit 版（データ移行の参照用として保持） |

### アーキテクチャ（MVVM）

| 層 | ファイル |
|---|---|
| Model | `DiaryDocument.swift`, `KotonohaDocument.swift` |
| ViewModel | `DiaryStore.swift`, `KotonohaStore.swift` |
| View | `DiaryViewer.swift`, `DiaryView.swift`, `KotonohaList.swift` など |
| Entry point | `KotonohaDiary_SwiftUIApp.swift` → `ContentView`（TabView） |

### データ永続化

iCloud Drive（`iCloud.com.stargazer.KotonohaDiary`、未利用時はローカル Documents）にファイルとして保存されます。

```
Documents/
  diaries/{uuid}.kdiary/
    content.json
    images/0.jpg, 1.jpg, …
  kotonohas/{uuid}.kotonoha
  kotonohas/{uuid}.jpg
```

### CoreData からの移行

v2.x 以前は CoreData でデータを管理していました。初回起動時に `CoreDataMigrator.swift` が旧 CoreData ストアを検出し、上記のファイルベース形式へ自動的に移行します。

## ライセンス

Copyright © 2023 Stargazer Information. All rights reserved.
