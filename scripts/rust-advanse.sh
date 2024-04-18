# binstall
# バイナリをインストールして，インストールを高速化する
cargo install cargo-binstall
# ~/.cargo/以下から不要なファイルを削除する
cargo binstall cargo-cache
# 再帰的にtargetディレクトリを削除する
cargo binstall cargo-clean-recursive
# タスクランナー
cargo binstall cargo-make
# 使用クレートにセキュリティ脆弱性が報告されているかチェック
cargo binstall cargo-audit
# 変更を監視
cargo binstall cargo-watch
# インタラクティブな操作でコンパイルを最適化設定をする
cargo binstall cargo-wizard
# 不要な依存関係を削除
cargo binstall cargo-machete
# 実行バイナリのバージョンアップを確認，管理する
cargo binstall cargo-update
# 依存するCrateのトレンドグラフを生成する
cargo binstall cargo-trend
# 依存関係を Lint する
cargo binstall cargo-deny
# 共有ビルドキャッシュ
cargo binstall sccache