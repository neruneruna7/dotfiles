---
  name: coding
  description: プログラムをコーディングする際の汎用的な知識
---
## コードにはHowを記述する．
どのように実現するか．


## 変数の不変性
- why: 変数が不変であることにより．意図しない値の変更を防げる．これにより，バグを防止できる．
  - 人間が見ても見やすい
- how: 
  - js/ts: `const` を使う
  - python: 型ヒントで，`Final[T]`を使う．
    - 型チェックライブラリの併用必須

## コードの可読性を重視する
- why: コードの理解・保守を容易にするため．新規機能追加のアジリティを向上させるため．
- how:
  - 可能であれば，if式を使用する．
  - if式がなく，if文しかない場合がある．それでも三項演算子は使用しない．
```ts :good
let x_mut = init;
if (cond) {
  x_mut = A;
} else {
  x_mut = B;
}
const x = x_mut;
```
```ts :bad
const x = cond ? A : B;
```

- 変数・関数は適切に命名する
  - evolutionary-naming スキルを使用せよ．
