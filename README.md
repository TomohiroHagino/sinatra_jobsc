# 求人情報スクレイピングアプリケーション

DDD+オニオンアーキテクチャで構築されたSinatraアプリケーションです。
有名な求人サイトからRails/Laravel/Next.js/Reactの求人情報を自動収集し、保存・管理できます。

## 機能

- **自動スクレイピング**: 10サイトから求人情報を自動収集
- **条件フィルタリング**: 月100万円以上、海外参画可能、応募中のみ
- **保存機能**: 気になる求人を保存
- **検索機能**: 保存された求人を検索
- **モダンUI**: Bootstrap 5を使用したレスポンシブデザイン

## 対象サイト

1. Findy
2. チョクフリ
3. Offers
4. Wantedly
5. Indeed
6. ITプロパートナーズ

## 技術スタック

- **フレームワーク**: Sinatra
- **アーキテクチャ**: DDD + オニオンアーキテクチャ
- **データベース**: SQLite3
- **ORM**: ActiveRecord
- **スクレイピング**: Nokogiri + HTTParty
- **UI**: Bootstrap 5 + Font Awesome

## セットアップ

### 1. 依存関係のインストール

```bash
bundle install
```

### 2. データベースの初期化とセットアップ

```bash
ruby setup.rb
```

### 3. アプリケーションの起動

```bash
bundle exec rackup
```

ブラウザで `http://localhost:9292` にアクセスしてください。

## 使用方法

1. **求人情報の取得**: 「求人情報を取得」ボタンをクリック
2. **保存**: 気になる求人に「保存」ボタンをクリック
3. **管理**: ホーム画面で保存された求人を確認・削除
4. **検索**: 検索機能で条件に合う求人を絞り込み

## 他の層との関係
```
プレゼンテーション層 (Controllers, Views)
    ↓ 依存
アプリケーション層 (Application Services)
    ↓ 依存  
ドメイン層 (Entities, Value Objects)
    ↑ 依存
インフラ層 (Repositories, External Services)
```

## プロジェクト構造

```
app/
├── domain/                # ドメイン層
│   ├── entities/          # エンティティ (Job, SavedJob)
│   ├── value_objects/     # 値オブジェクト (SalaryRange)
│   ├── repositories/      # リポジトリインターフェース
│   ├── services/         # ドメインサービス (JobDomainService)
│   └── factories/        # ファクトリー (JobFactory)
├── application/           # アプリケーション層
│   ├── services/         # アプリケーションサービス
│   ├── use_cases/        # ユースケース (ScrapeJobsUseCase, SaveJobUseCase等)
│   └── dtos/             # データ転送オブジェクト (JobDto, JobSearchCriteriaDto)
├── infrastructure/       # インフラストラクチャ層
│   ├── repositories/     # リポジトリ実装 (ActiveRecordJobRepository)
│   └── external_services/ # 外部サービス (JobScrapingService)
└── presentation/         # プレゼンテーション層
    ├── controllers/      # コントローラー (JobsController)
    ├── views/            # ビューテンプレート
    └── public/           # 静的ファイル
```

## 注意事項

- スクレイピングは各サイトの利用規約を遵守してください
- 過度なアクセスは避け、適切な間隔を空けてください
- 実際のサイト構造に合わせてスクレイピングロジックを調整してください
