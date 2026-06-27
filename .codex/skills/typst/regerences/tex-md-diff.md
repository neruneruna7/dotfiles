# tex/mdとtypstの記法差分
次の書き方で差分を記述する
### 概念名
#### tex
texでの記法
#### md
mdでの記法
#### typst
typstでの記法

# tex/mdとtypstの記法差分

## 前提

この一覧では、`tex` は実務上よく使われる LaTeX 記法を指す。純粋な TeX primitive ではなく、LLMがTypstと混同しやすい LaTeX 記法を比較対象とする。

`md` は CommonMark を基本とする。ただし、表・数式・脚注などは CommonMark 標準ではなく、GitHub Flavored Markdown や Pandoc Markdown などの拡張で扱われる場合がある。

`typst` は `.typ` ソースとしてコンパイルされる記法を指す。

---

### 文書タイトル

#### tex

```tex
\title{文書タイトル}
\author{著者名}
\date{\today}

\maketitle
```

#### md

```md
# 文書タイトル
```

または処理系依存の front matter を使う。

```md
---
title: 文書タイトル
author: 著者名
---
```

#### typst

```typst
= 文書タイトル
```

または文書メタデータを設定する。

```typst
#set document(
  title: "文書タイトル",
  author: "著者名",
)
```

---

### 1階層見出し

#### tex

```tex
\section{見出し}
```

#### md

```md
# 見出し
```

#### typst

```typst
= 見出し
```

---

### 2階層見出し

#### tex

```tex
\subsection{見出し}
```

#### md

```md
## 見出し
```

#### typst

```typst
== 見出し
```

---

### 3階層見出し

#### tex

```tex
\subsubsection{見出し}
```

#### md

```md
### 見出し
```

#### typst

```typst
=== 見出し
```

---

### 見出し番号

#### tex

```tex
\section{導入}
\subsection{背景}
```

通常は文書クラス側で番号が付く。番号なしにする場合は `*` を使う。

```tex
\section*{導入}
```

#### md

```md
# 導入
## 背景
```

Markdown自体には標準的な見出し番号機能はない。レンダラ側で付与する。

#### typst

```typst
#set heading(numbering: "1.")

= 導入
== 背景
```

番号なしにする場合は、番号設定をしないか、個別に関数形式を使う。

```typst
#heading(numbering: none)[導入]
```

---

### 段落

#### tex

```tex
これは第一段落である。

これは第二段落である。
```

#### md

```md
これは第一段落である。

これは第二段落である。
```

#### typst

```typst
これは第一段落である。

これは第二段落である。
```

---

### 強制改行

#### tex

```tex
1行目\\
2行目
```

#### md

```md
1行目  
2行目
```

または処理系によっては次のように書く。

```md
1行目\
2行目
```

#### typst

```typst
1行目 \
2行目
```

---

### 改ページ

#### tex

```tex
\newpage
```

#### md

```md
<!-- Markdown標準には改ページ記法はない -->
```

HTMLやPandoc拡張を使う場合がある。

```md
<div style="page-break-after: always;"></div>
```

#### typst

```typst
#pagebreak()
```

---

### 太字

#### tex

```tex
\textbf{重要}
```

#### md

```md
**重要**
```

#### typst

```typst
*重要*
```

---

### 斜体・強調

#### tex

```tex
\emph{強調}
```

または

```tex
\textit{斜体}
```

#### md

```md
*強調*
```

または

```md
_強調_
```

#### typst

```typst
_強調_
```

関数形式も使える。

```typst
#emph[強調]
```

---

### 下線

#### tex

```tex
\underline{重要}
```

#### md

```md
<u>重要</u>
```

Markdown標準の記法ではない。HTMLを許す処理系で使われる。

#### typst

```typst
#underline[重要]
```

---

### 打ち消し線

#### tex

```tex
\sout{削除}
```

通常は `ulem` パッケージなどが必要である。

#### md

```md
~~削除~~
```

CommonMark標準ではない。GitHub Flavored Markdown などの拡張である。

#### typst

```typst
#strike[削除]
```

---

### インラインコード

#### tex

```tex
\texttt{let x = 1}
```

#### md

```md
`let x = 1`
```

#### typst

```typst
`let x = 1`
```

---

### コードブロック

#### tex

```tex
\begin{verbatim}
fn main() {
  println!("hello");
}
\end{verbatim}
```

#### md

````md
```rust
fn main() {
  println!("hello");
}
```
````

#### typst

````typst
```rust
fn main() {
  println!("hello");
}
```
````

Typstでもバッククォートによる raw text/code block を使う。ただし、Typst全体をMarkdownのコードフェンスで囲むのは `.typ` ソースとしては誤りである。

---

### 箇条書きリスト

#### tex

```tex
\begin{itemize}
  \item 項目A
  \item 項目B
\end{itemize}
```

#### md

```md
- 項目A
- 項目B
```

#### typst

```typst
- 項目A
- 項目B
```

---

### 番号付きリスト

#### tex

```tex
\begin{enumerate}
  \item 項目A
  \item 項目B
\end{enumerate}
```

#### md

```md
1. 項目A
2. 項目B
```

#### typst

```typst
+ 項目A
+ 項目B
```

明示的な番号を使うこともできる。

```typst
1. 項目A
2. 項目B
```

LLMに生成させる場合は、Markdownとの混同を避けるため、Typstでは `+` を優先する。

---

### 引用ブロック

#### tex

```tex
\begin{quote}
引用文
\end{quote}
```

#### md

```md
> 引用文
```

#### typst

```typst
#quote(block: true)[
  引用文
]
```

---

### 水平線・区切り線

#### tex

```tex
\hrule
```

またはLaTeXでは次のように書くことが多い。

```tex
\noindent\rule{\linewidth}{0.4pt}
```

#### md

```md
---
```

または

```md
***
```

#### typst

```typst
#line(length: 100%)
```

---

### リンク

#### tex

```tex
\href{https://example.com}{Example}
```

通常は `hyperref` パッケージが必要である。

#### md

```md
[Example](https://example.com)
```

#### typst

```typst
#link("https://example.com")[Example]
```

---

### URLそのもの

#### tex

```tex
\url{https://example.com}
```

通常は `hyperref` または `url` パッケージを使う。

#### md

```md
<https://example.com>
```

#### typst

```typst
#link("https://example.com")
```

または表示文字列を明示する。

```typst
#link("https://example.com")[https://example.com]
```

---

### 画像

#### tex

```tex
\includegraphics[width=0.8\linewidth]{image.png}
```

通常は `graphicx` パッケージが必要である。

#### md

```md
![代替テキスト](image.png)
```

#### typst

```typst
#image("image.png", width: 80%)
```

---

### 図キャプション

#### tex

```tex
\begin{figure}
  \centering
  \includegraphics[width=0.8\linewidth]{image.png}
  \caption{図の説明}
  \label{fig:sample}
\end{figure}
```

#### md

```md
![図の説明](image.png)
```

Markdown標準には図番号・図参照の機能はない。処理系依存である。

#### typst

```typst
#figure(
  image("image.png", width: 80%),
  caption: [図の説明],
) <fig:sample>
```

---

### 表

#### tex

```tex
\begin{tabular}{ll}
A & B \\
1 & 2 \\
\end{tabular}
```

#### md

```md
| A | B |
|---|---|
| 1 | 2 |
```

これはCommonMark標準ではなく、GitHub Flavored Markdownなどの拡張である。

#### typst

```typst
#table(
  columns: 2,
  [A], [B],
  [1], [2],
)
```

---

### インライン数式

#### tex

```tex
$x^2 + y^2 = z^2$
```

#### md

```md
$x^2 + y^2 = z^2$
```

Markdown標準には数式記法はない。MathJax、KaTeX、Pandocなどの拡張で使われる。

#### typst

```typst
$x^2 + y^2 = z^2$
```

---

### ディスプレイ数式

#### tex

```tex
\[
x^2 + y^2 = z^2
\]
```

または

```tex
$$
x^2 + y^2 = z^2
$$
```

#### md

```md
$$
x^2 + y^2 = z^2
$$
```

Markdown標準には数式記法はない。処理系依存の拡張である。

#### typst

```typst
$ x^2 + y^2 = z^2 $
```

Typstでは `$` の内側に前後空白を置くと、ブロック数式として扱われる。

---

### 分数

#### tex

```tex
\frac{a}{b}
```

#### md

```md
$\frac{a}{b}$
```

Markdown標準ではなく、LaTeX数式を受け付ける数式拡張に依存する。

#### typst

```typst
$ frac(a, b) $
```

または単純な場合は次のようにも書ける。

```typst
$ a / b $
```

---

### 平方根

#### tex

```tex
\sqrt{x}
```

#### md

```md
$\sqrt{x}$
```

Markdown標準ではなく、数式拡張に依存する。

#### typst

```typst
$ sqrt(x) $
```

---

### ギリシャ文字

#### tex

```tex
\alpha + \beta
```

#### md

```md
$\alpha + \beta$
```

Markdown標準ではなく、数式拡張に依存する。

#### typst

```typst
$ alpha + beta $
```

---

### 上付き・下付き

#### tex

```tex
x_i^2
```

#### md

```md
$x_i^2$
```

Markdown標準ではなく、数式拡張に依存する。

#### typst

```typst
$ x_i^2 $
```

本文中の上付き・下付きは関数を使う。

```typst
H#sub[2]O
x#super[2]
```

---

### ラベル

#### tex

```tex
\section{導入}
\label{sec:intro}
```

#### md

```md
# 導入 {#sec-intro}
```

Markdown標準ではない。Pandocなどの拡張である。

#### typst

```typst
= 導入 <sec:intro>
```

---

### 相互参照

#### tex

```tex
\ref{sec:intro}
```

または

```tex
\autoref{sec:intro}
```

#### md

```md
[導入](#sec-intro)
```

Markdown標準のリンクで代替する。番号付き参照は処理系依存である。

#### typst

```typst
@sec:intro
```

---

### 脚注

#### tex

```tex
本文\footnote{脚注の内容}
```

#### md

```md
本文[^1]

[^1]: 脚注の内容
```

脚注はCommonMark標準ではなく、Markdown処理系の拡張である。

#### typst

```typst
本文#footnote[脚注の内容]
```

---

### 引用・文献参照

#### tex

```tex
\cite{knuth1984}
```

#### md

```md
[@knuth1984]
```

Pandoc Markdownなどの拡張である。Markdown標準には文献参照はない。

#### typst

```typst
@knuth1984
```

関数形式も使える。

```typst
#cite(<knuth1984>)
```

---

### 参考文献リスト

#### tex

```tex
\bibliographystyle{plain}
\bibliography{refs}
```

またはBibLaTeXでは次のように書く。

```tex
\printbibliography
```

#### md

```md
---
bibliography: refs.bib
---
```

Pandocなどの処理系に依存する。

#### typst

```typst
#bibliography("refs.bib")
```

---

### コメント

#### tex

```tex
% コメント
```

#### md

```md
<!-- コメント -->
```

#### typst

```typst
// 行コメント

/*
ブロックコメント
*/
```

---

### マクロ・コマンド定義

#### tex

```tex
\newcommand{\term}[1]{\textbf{#1}}
```

#### md

```md
<!-- Markdown標準にはマクロ定義はない -->
```

#### typst

```typst
#let term(body) = strong(body)

#term[重要語]
```

またはマークアップを返す関数として書く。

```typst
#let term(body) = [*#body*]
```

---

### 変数定義

#### tex

```tex
\newcommand{\mytitle}{文書タイトル}
```

#### md

```md
<!-- Markdown標準には変数定義はない -->
```

front matter やテンプレートエンジンで代替する場合がある。

#### typst

```typst
#let mytitle = "文書タイトル"

= #mytitle
```

---

### 条件分岐

#### tex

```tex
\ifdefined\draft
Draft
\else
Final
\fi
```

#### md

```md
<!-- Markdown標準には条件分岐はない -->
```

#### typst

```typst
#let draft = true

#if draft [
  Draft
] else [
  Final
]
```

---

### 繰り返し

#### tex

```tex
% 通常のLaTeX本文では標準的な繰り返し記法は使わない。
% 必要ならTeXマクロやパッケージに依存する。
```

#### md

```md
<!-- Markdown標準には繰り返しはない -->
```

#### typst

```typst
#for item in ("A", "B", "C") [
  - #item
]
```

---

### 外部ファイル読み込み

#### tex

```tex
\input{chapter1.tex}
```

または

```tex
\include{chapter1}
```

#### md

```md
<!-- Markdown標準には外部ファイル読み込みはない -->
```

Pandocなどでは拡張やビルドツールで処理する。

#### typst

```typst
#include "chapter1.typ"
```

---

### モジュール・定義のインポート

#### tex

```tex
\usepackage{amsmath}
```

#### md

```md
<!-- Markdown標準にはパッケージ読み込みはない -->
```

#### typst

```typst
#import "template.typ": template
```

Typst Universe のパッケージを使う場合は次のように書く。

```typst
#import "@preview/package-name:version": name
```

---

### ページ設定

#### tex

```tex
\documentclass[a4paper]{article}
\usepackage[margin=25mm]{geometry}
```

#### md

```md
---
paper: a4
margin: 25mm
---
```

処理系依存である。

#### typst

```typst
#set page(
  paper: "a4",
  margin: 25mm,
)
```

---

### フォント設定

#### tex

```tex
\usepackage{fontspec}
\setmainfont{Noto Serif}
```

XeLaTeXやLuaLaTeXなどのエンジンに依存する。

#### md

```md
<!-- Markdown標準にはフォント設定はない -->
```

CSSや出力テンプレートで指定する場合がある。

#### typst

```typst
#set text(
  font: "Noto Serif",
  size: 11pt,
)
```

---

### 中央揃え

#### tex

```tex
\begin{center}
中央揃え
\end{center}
```

#### md

```md
<div align="center">
中央揃え
</div>
```

Markdown標準ではない。HTMLに依存する。

#### typst

```typst
#align(center)[
  中央揃え
]
```

---

### 右揃え

#### tex

```tex
\begin{flushright}
右揃え
\end{flushright}
```

#### md

```md
<div align="right">
右揃え
</div>
```

Markdown標準ではない。HTMLに依存する。

#### typst

```typst
#align(right)[
  右揃え
]
```

---

### 余白・スペース

#### tex

```tex
\vspace{1em}
\hspace{1em}
```

#### md

```md
<!-- Markdown標準には明示的な余白制御はない -->
```

HTMLやCSSで代替する場合がある。

#### typst

```typst
#v(1em)
#h(1em)
```

---

### 目次

#### tex

```tex
\tableofcontents
```

#### md

```md
<!-- Markdown標準には目次生成はない -->
```

レンダラや拡張で `[TOC]` などを使う場合がある。

#### typst

```typst
#outline()
```

---

### 関数呼び出し

#### tex

```tex
\command{argument}
```

#### md

```md
<!-- Markdown標準には関数呼び出しはない -->
```

#### typst

```typst
#function(argument)
```

内容ブロックを渡す場合は次のように書く。

```typst
#function[
  content
]
```

---

### スタイルの一括設定

#### tex

```tex
\renewcommand{\familydefault}{\sfdefault}
```

またはパッケージ・文書クラス・マクロで設定する。

#### md

```md
<!-- Markdown標準にはスタイルの一括設定はない -->
```

CSSやテンプレートで行う。

#### typst

```typst
#set text(font: "Noto Sans", size: 11pt)
#set heading(numbering: "1.")
```

---

### 既存要素の表示規則変更

#### tex

```tex
\renewcommand{\thesection}{\Roman{section}}
```

#### md

```md
<!-- Markdown標準には表示規則変更はない -->
```

#### typst

```typst
#show heading: it => [
  #block(above: 1em, below: 0.5em)[
    #strong(it.body)
  ]
]
```

---

### raw文字列・そのまま表示

#### tex

```tex
\verb|a_b_c|
```

または

```tex
\begin{verbatim}
a_b_c
\end{verbatim}
```

#### md

```md
`a_b_c`
```

またはコードブロックを使う。

#### typst

```typst
`a_b_c`
```

またはrawブロックを使う。

````typst
```
a_b_c
```
````

---

### エスケープ

#### tex

```tex
\%
\&
\_
```

#### md

```md
\*
\[
\]
```

#### typst

```typst
\*
\_
\#
```

Typstでは `#` がcode modeへの入口であるため、文字として出したい場合はエスケープする。

---

### TeXコマンドを本文中に例示する場合

#### tex

```tex
\verb|\section{Title}|
```

#### md

```md
`\section{Title}`
```

#### typst

```typst
`\section{Title}`
```

Typst本文にLaTeXコマンドをそのまま書くと、意図しない構文やエラーになる可能性がある。TeX記法を例示する場合は raw text として囲む。

---

### Markdown記法を本文中に例示する場合

#### tex

```tex
\verb|# Heading|
```

#### md

```md
`# Heading`
```

#### typst

```typst
`# Heading`
```

Typstでは `# Heading` はMarkdown見出しではない。見出しには `= Heading` を使う。

---

### LLMに禁止すべき典型混入

#### tex

```tex
\section{Title}
\textbf{bold}
\frac{a}{b}
\includegraphics{image.png}
```

#### md

```md
# Title
**bold**
![alt](image.png)
[link](https://example.com)
```

#### typst

```typst
= Title

*bold*

$ frac(a, b) $

#image("image.png")

#link("https://example.com")[link]
```

LLMにTypstを生成させる場合、`tex` と `md` の欄にある記法は、Typstソース中では原則として出力禁止にする。ただし、コード例として示す場合は raw text/code block に閉じ込める。
