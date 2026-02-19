// 朝活: DNA Foundation Models スライド
// Typst + Touying Metropolis テーマ

#import "@preview/touying:0.6.1": *
#import themes.metropolis: *

// 日本語フォント設定
#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [DNA Foundation Models を読み解く],
    subtitle: [HyenaDNA → Evo → Evo 2｜7B scratch 学習の作り手目線],
    author: [tax_free],
    date: [2026/02/14],
  ),
)

// 日本語フォントをグローバルに設定
#set text(font: ("Hiragino Sans", "Hiragino Kaku Gothic ProN"), lang: "ja")

// タイトルスライド
#title-slide()

// ========================================
// 概要
// ========================================
== 今日の3本

+ *HyenaDNA*（arXiv 2023）
+ *Evo (Science)*（7B, OpenGenome 300B tokens）
+ *Evo 2 (bioRxiv 2025)*（7B / 40B, OpenGenome2 9.3T tokens）

*視点*: 「7B を scratch で学習させる作り手目線」で、アーキテクチャ・データ設計・学習戦略・インフラ・意思決定のポイントに絞って整理

// ========================================
// HyenaDNA
// ========================================
= ① HyenaDNA

== 🎯 何を解決したいモデルか？

従来のDNA LMの課題：

- Transformer（attention）が *O(L²)* で長文が不可能
- 512–4k tokenしか扱えない
- k-mer tokenizationで単塩基分解能を失う

→ 「*長距離 × 単塩基分解能*」を両立したい。

== 🧠 アーキテクチャ設計思想

*Hyena operator（implicit long convolution）*

- FFTベースの long convolution（O(L log L)）
- Dense + Conv + Gate 構造
- MLP expansion factor = 4x / Order-N = 2
- 0.4M〜6.6M params / 最大 1M context

*作る側の意思決定*
- Attentionを捨てる
- Context拡張を最優先
- 幅よりも長さに振る設計

== 📊 学習データ設計

- *単一の human reference genome*
- 次トークン予測（autoregressive）
- 単塩基トークン（4 token）

*重要：*
- 「巨大データで汎化」ではなく → *長距離構造を掴めるかの実験モデル*

== ⚙ 学習設定

- AdamW / LR: 1.5e-4 – 6e-4 / Cosine decay
- 10–20k global steps
- 1M contextモデルは *2T tokens / 4週間*

*最大の工夫：Sequence Length Warm-up*
- 徐々に context を伸ばす
- 450k fine-tune時も warm-up使用

→ *超長文は一気に学習しない*

== 🧩 HyenaDNA：作る側から学べること

- 長文学習は「スケジューリング問題」
- データ量より「構造の帰納バイアス」
- Warm-up無しで1Mはほぼ不可能

// ========================================
// Evo
// ========================================
= ② Evo (Science, 7B)

== 🎯 Evoの狙い

HyenaDNAをスケールさせ *Genome-scale foundation model* を構築。

- 7B parameters
- 131k context

== 🧠 アーキテクチャ：StripedHyena

- 29 hyena layers + 3 attention layers (10%)
- RoPE positional encoding
- 単塩基 tokenization

→ 完全attentionではない。Hyena主体＋少量attention

== 📊 データ設計：OpenGenome

- 300B tokens
- 80,000+ prokaryotic genomes
- ウイルス（euk感染）は除外

== ⚙ 学習戦略

*2段階 pretraining*
- 8k → 131k context
- 合計 340B tokens
- 64 H100 + 128 A100

== 📈 Scaling lawを事前分析

- 300+ models を事前に実験
- compute-optimal 7Bは 250B tokens
- 実際は300B tokens（17% overtrain）

→ 7Bなら 250B前後が理論最適

== 🧩 Evo：作る側から学べること

- 7Bを作る前に scaling law を作れ
- Transformer++ は byte-level で不安定
- Hyena系は安定

// ========================================
// Evo 2
// ========================================
= ③ Evo 2 (7B / 40B)

== 🎯 スケールアップ

- 7B: 2.4T tokens
- 40B: 9.3T tokens
- 1M context

== 🧠 StripedHyena 2

- Multi-hybrid convolution + attention
- 1M contextで 3× 高速
- 7B: 32 layers, hidden 4096

== 📊 データ工夫が最大の進化

*OpenGenome2*: 8.8T nucleotides

*重要な発見：*
- 「whole genomeをそのまま入れると性能が落ちる」
- → genic windowsを重視
- データ構成変更で AUROC 大幅改善

== ⚙ Loss再設計

- repetitive regionを0.1重み
- reweightなしだと性能悪化

→ DNA特有の loss engineering

== 🧩 Evo 2：作る側から学べること

- 「量より構成」
- noncodingを入れすぎると性能低下
- 7Bでも 2.4T tokens 必要

// ========================================
// 横断まとめ
// ========================================
= 🔥 横断まとめ：7B scratchでやるなら

== 1️⃣ アーキテクチャ

- Transformer単体は不利（byte-levelで不安定）
- Hyena/StripedHyena系が有利
- Context拡張は2段階以上が必須

== 2️⃣ データ規模

#table(
  columns: (1fr, 1fr),
  align: (left, left),
  table.header([*モデル*], [*Tokens*]),
  [HyenaDNA], [2T（1M context例）],
  [Evo 7B], [340B],
  [Evo2 7B], [2.4T],
)

- 7Bで最低 300B以上
- 本気なら 1–2T

== 3️⃣ 学習設計の鍵

- Sequence length warm-up
- 8k → 131k → 1M の段階拡張
- Loss reweighting

== 4️⃣ Compute

- *Evo:* 64 H100 + 128 A100
- *Evo2:* 9.3T tokens 40Bモデル

→ 7Bでも数百GPU-week規模
