---
name: git-commit-message
description: gitのコミットメッセージを書くときの規約とテンプレを適用する。
---

次の規則に従う．
why　を記述することを心がける．
- add: <message>
  - 新しく機能を追加した時
  - 例: `add: ユーザー認証　<追加理由>`
- update: <message>
  - 既存の機能を更新した時
  - 例: `update: <更新内容> <更新理由>`
- remove: <message>
  - 機能を削除した時
  - 例: `remove: <削除内容> <削除理由>`
- fix: <message>
  - バグを修正した時
  - 例: `fix: <修正内容> <修正理由>`
- refactor: <message>
  - コードをリファクタリングした時
  - 例: `refactor: <リファクタリング内容> <リファクタリング理由>`
- chore: <message>
  - 雑な作業を行った時
  - 例: `chore: <作業内容> <作業理由>`
