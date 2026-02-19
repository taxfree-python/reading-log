# 論文共有会 チェックリスト (2026/02/19)

## セクション 1: 最新モデル動向 (Qwen 3.5 & GLM-5)

### A: Contribution
- [x] この紹介の貢献: 2月に立て続けにリリースされた中国発フロンティア級オープンモデル2つの技術的な差分と設計思想を比較する
- [x] 公開日: Qwen 3.5: 2026/02/16, GLM-5: 2026/02/11
- [x] 組織: Qwen 3.5 → Alibaba, GLM-5 → Zhipu AI (Z.ai)
- [x] なぜ今?: 今月立て続けにリリースされてTwitterで盛り上がっていた。ベンチマーク性能がproprietaryに並ぶと話題。中国勢はアーキテクチャを工夫している (Gated DeltaNet, Muon Split等) のでテクニカルにおもしろい
- [x] 使えるとしたら何ができる?: 自分たちでホストしてLoRA等のfine-tuningでラボ用にカスタムできる (データの安全性的に自前ホストが必要なケースに対応)。トークン単価が安い (Opus比10x以上) ので、論文の要約など雑にたくさん投げる系のタスクに向く
- [x] リンク:
  - Qwen 3.5: https://github.com/QwenLM/Qwen3.5
  - GLM-5: https://huggingface.co/zai-org/GLM-5
  - GLM-5 tech report: https://arxiv.org/abs/2602.15763

### B: Method
- [x] 対象(入力→出力): text (+ image/video for Qwen 3.5) → text
- [x] キモ(新規点):
  - **Qwen 3.5**: 397B MoE (17B active). 75%の層でstandard attentionをGated DeltaNet(Mamba2 gated decay + delta rule)に置換 → 準線形スケーリング。Native multimodal (text/image/video単一モデル)。語彙250K (201言語)。Native FP8学習
  - **GLM-5**: 744B MoE (40B active, 256 experts top-8). MLA (Multi-Latent Attention) + DSA (DeepSeek Sparse Attention)。**Muon Split**: attention headごとに独立した行列直交化を適用し、headごとに異なるスケールでweight更新。MTP 3層パラメータ共有 (speculative decoding用)。80層 (GLM-4.5より削減、expert parallelism overhead低減)。全てHuawei Ascend 910B + MindSporeで学習
- [x] 流れ:
  - **Qwen 3.5**: trillions of multimodal tokensでearly fusion pre-training → massive-scale RL (million-agent environments)
  - **GLM-5**: 3段階pre-training (27T tokens, code/reasoning重視 → context拡張 32K→128K→200K → DSA適応 20B tokens) → 4段階post-training RL (Reasoning RL → Agentic RL → General RL → On-Policy Cross-Stage Distillation)。RLはslimeフレームワーク (非同期RL, APRIL最適化)
- [x] 評価のしかた: AIME 2026, SWE-bench Verified, BrowseComp, Humanity's Last Exam, MMLU, GPQA Diamond, LiveCodeBench v6, Terminal-Bench 2 等

### C: Results
- [x] Evidence 1 (ベンチマーク比較)
  - 条件: フロンティアモデル (GPT-5.2, Claude Opus 4.5, Gemini 3 Pro) との主要ベンチマーク比較
  - 結論:
    | Benchmark | Qwen 3.5 | GLM-5 | GPT-5.2 | Opus 4.5 | Gemini 3 Pro |
    |---|---|---|---|---|---|
    | AIME 2026 | 91.3 | 92.7 | 96.7 | 93.3 | - |
    | SWE-bench Verified | 76.4 | 77.8 | 76.2 | 80.9 | 80.0 |
    | BrowseComp | 78.6 | 75.9 | 59.2 | 67.8 | 65.8 |
    | Humanity's Last Exam | - | **50.4** | 45.8 | 43.4 | 45.5 |
    | LiveCodeBench v6 | 83.6 | - | - | - | - |
    | Terminal-Bench 2 | 52.5 | 56.2 | 54.2 | 59.3 | 54.0 |
  - 意味: 中国発オープンモデルがfrontier級に到達。Qwen 3.5はagentic search (BrowseComp)に強く、GLM-5はknowledge reliability (HLE, hallucination低減)に強い。ただしcoding (SWE-bench)ではOpus 4.5がリード
- [x] Evidence 2 (設計思想の違い)
  - 条件: アーキテクチャと学習戦略の比較
  - 結論:
    - Qwen 3.5: Gated DeltaNetで**attentionそのものを置換** → 長文推論速度に全振り (8.6x faster @32K, 19x @256K vs Qwen3)。Multimodal native
    - GLM-5: MLA + DSAで**attentionを効率化** + Muon Splitで**optimizerを改良**。slimeで非同期RL。NVIDIA非依存を達成
  - 意味: "attentionをどう扱うか"で設計思想が分岐。Qwen=置換路線、GLM=効率化路線。どちらもfrontier級に到達しており、attention設計の正解は一つではない

### D: Gaps & Next Step
- [x] Gap 1 (ベンチマーク≠実用の乖離)
  - Applicability Gap: ベンチマーク上ではproprietaryモデルに並んでいるが、GLM-5のverbosity (評価中に他モデル中央値15Mに対し110M tokens生成) のように、実際のユースケースでは大きな挙動差がある可能性。コスト・レイテンシ・出力品質のバランスがベンチ数値だけでは見えない
  - Evidence status: ベンチマークは標準タスク (coding, math, search) が中心。AI for Scienceのような専門的・長期的・multi-stepなタスクでの挙動は未評価
  - Minimal test: AI4S系の具体タスク (例: 論文要約→仮説生成→実験計画) を2-3個用意し、proprietary (GPT-5.2/Opus 4.5) とopen (Qwen 3.5/GLM-5) で出力を比較。verbosity, hallucination率, 指示追従性を定性評価
- [x] Gap 2 (AI4Sハイエンドタスクの評価不在)
  - Applicability Gap: 既存ベンチマーク (AIME, SWE-bench等) は汎用タスク。AI4Sで求められる「ドメイン知識の正確さ」「実験設計の妥当性」「不確実性の表現」などはカバーされていない
  - Evidence status: FrontierScience (前回紹介) のようなscience-specificベンチは存在するが、これらのモデルでの評価結果は未公開
  - Minimal test: FrontierScienceの公開問題やdomain-specificな質問セットでopen vs proprietaryを走らせ、専門家評価で差を定量化
- [x] Next step: (i) AI4S系タスクでの簡易比較実験を設計 (ii) verbosity/cost比を含む実用指標での評価フレームワークを検討 (iii) 前回紹介したFrontierScienceベンチで走らせてみる

---

## セクション 2: DeepSeek-OCR 2

### A: Contribution
- [x] この論文の貢献: CLIP ViTをLLMアーキテクチャ (Qwen2-0.5B) に置換したvision encoderで、文書の意味的な読み順を自律学習するVisual Causal Flowを提案。3B params (500M active) で学術論文OCRのSoTAを達成
- [x] 著者/組織: DeepSeek AI (Haoran Wei, Yaofeng Sun, Yukun Li et al.)
- [x] 公開日: 2026/01/27
- [x] なぜ今?: visionを使ったAI4Sに興味がある。少し前に話題になっていた。科学文書は複雑レイアウト (multi-column, 数式, 表) が多くVisual Causal Flowが効くドメイン
- [x] 使えるとしたら何ができる?: (1) 論文の高速な文字起こし→埋め込みパイプラインに使える (3B/500M activeで16GB GPU単体で動く) (2) bidirectional encoderにcausal queryを追加するという設計発想を、他のvision系モデルや実験ノート・分析チャートの読み取りなど別ドメインに応用できる可能性
- [x] 論文リンク: https://arxiv.org/abs/2601.20552

### B: Method
- [x] 対象(入力→出力): 文書画像 (images/PDFs/tables/数式) → Markdown/HTML/テキスト (レイアウト保持)
- [x] キモ(新規点): (1) DeepEncoder V2: CLIP ViTをQwen2-0.5Bで置換し、LLMアーキテクチャをvision encoderとして使用。dual-stream attention (visual tokens=双方向, learnable queries=causal) で意味的な読み順を自律学習 (2) Visual Causal Flow: raster scan (左上→右下固定) ではなく、queryが「次にどこを読むか」を学習。reorderされたquery tokensのみdecoderに渡す
- [x] 流れ: SAM-base vision tokenizer (16x圧縮) → DeepEncoder V2 (dual-stream attention) → reordered query tokens → DeepSeek-3B MoE decoder。学習は3段階: (1) encoder pretraining (100M image-text pairs, 160 A100) → (2) encoder+decoder joint training → (3) decoder-only continue-training (encoder凍結, 学習速度2倍)
- [x] 評価のしかた: OmniDocBench v1.5 (edit distance, Formula CDM, Table TEDS, reading order edit distance)

### C: Results
- [x] Evidence 1 (OmniDocBench v1.5 SoTA)
  - 条件: OmniDocBench v1.5で他モデル (Gemini-3 Pro, Qwen3-VL-235B, DeepSeek-OCR 1) と比較
  - 結論: Overall 91.09% (SoTA)。Gemini-3 Pro 88.03%, Qwen3-VL-235B 89.15%を上回る。数式CDM 84.14→90.31% (+6.17%)、読み順 edit distance 0.085→0.057 (-33%)
  - 意味: 3B params (500M active) という軽量モデルが235Bクラスを上回る。学術論文 edit distance 0.013、研究レポート 0.008 と科学文書が最も得意なカテゴリ
- [x] Evidence 2 (Visual Causal Flowの効果)
  - 条件: OCR 1 (raster scan) vs OCR 2 (Visual Causal Flow) で文書タイプ別に比較
  - 結論: colorful textbook 0.130→0.053、handwritten 0.145→0.068、PowerPoint 0.052→0.031 と複雑レイアウトで大幅改善。ただし新聞 0.131→0.139 と悪化 (学習データ不足)
  - 意味: causal flowが複雑レイアウトの読み順改善に効いている。一方でデータ不足カテゴリには効かない → 学習データ設計が重要

### D: Gaps & Next Step
- [x] Gap 1 (科学文書の「意味理解」はしない)
  - Applicability Gap: OCR (テキスト抽出) は強力だが、図・ダイアグラム・実験結果の**意味的な理解**は対象外。AI4Sでは図の解釈や表の数値の妥当性チェックも必要
  - Evidence status: OmniDocBenchは文字列の正確さを測る指標が中心。意味的な正しさ (例: 数式の物理的妥当性) は評価していない
  - Minimal test: 論文のfigure captionと図の対応関係、表中の数値の単位・桁の整合性チェックをOCR出力に対して行い、semantic errorの割合を測る
- [x] Gap 2 (single-pass処理の限界)
  - Applicability Gap: iterative refinementがないため、1回の処理で読み取れなかった箇所を修正できない。dense pageではvisual token上限 (1,120) が制約になる
  - Evidence status: 新聞のような高密度レイアウトでは実際に悪化。著者も「longer causal flow tokens for multiple re-examinations」を将来課題として言及
  - Minimal test: 科学論文のsupplementary materials (dense tables, multi-panel figures) で処理し、エラーが集中する箇所のパターンを分析
- [x] Next step: (i) 手元の論文PDFでOCR精度を確認 (特に数式・表) (ii) 16GB GPU単体でのデプロイを試す (iii) 抽出テキストをLLMに渡すパイプライン (OCR→要約→Q&A) の構築可能性を検討

---

## セクション 3: Reinforced Attention Learning (RAL)

### A: Contribution
- [x] この論文の貢献: マルチモーダルLLMのRL post-trainingで、出力トークンではなくattention分布をpolicy-gradientで直接最適化する手法を提案。GRPOが画像理解を劣化させる問題を解決し、image/video両方で一貫した改善を達成
- [x] 著者/組織: UC Davis, Google DeepMind, Princeton (Bangzheng Li, Jianmo Ni, Muhao Chen, Derek Zhiyuan Cheng et al.)
- [x] 公開日: 2026/02/04
- [x] なぜ今?: AI4S文脈でのVQAに興味がある。DeepSeek-OCR 2と組み合わせればmulti-panelや複雑な図の読解に使えそう。東工大TSUBAMEのH100を使えば~20,000円で再現できるので経済的にも現実的
- [x] 使えるとしたら何ができる?: 「どこを見るか」が重要な複雑なVQA等のmultimodal系タスク。科学画像 (顕微鏡画像、スペクトル、multi-panel figure) など情報密度の高い入力でvisual tokenが多いほどRALの優位性が拡大する性質と相性が良い
- [x] 論文リンク: https://arxiv.org/abs/2602.04884

### B: Method
- [x] 対象(入力→出力): マルチモーダル入力 (image/video + text) → テキスト回答。内部的にはattention分布を最適化対象とする
- [x] キモ(新規点): (1) attention分布をRL policy化: 最終層の全headの平均attention weightをpolicy p_theta^tとし、正解時→JSD最小化(パターン強化)、不正解時→JSD最大化(パターン回避)。L_total = L_RL(GRPO) + λ * L_AttnRL。トークンレベルのO(T)に対しattentionレベルはO(T^2)の勾配信号 → denser supervision (2) On-Policy Attention Distillation: 32B teacher→7B studentへattention分布も蒸留 (出力分布だけでなく「どこを見るか」も模倣)
- [x] 流れ: SFT (Video-R1-COT-165k, 8xH100 ~10h) → RL with RAL (Video-R1-260kから51.2k, G=8 rollouts, 8xH100 ~120h)。visual encoder/projectorは凍結、LM backboneのみ更新。報酬: 0.9*accuracy(exact match) + 0.1*format(think/answer template)
- [x] 評価のしかた: image 8ベンチ (V*, MMMU Pro, MME, MuirBench, ChartQA, VizWiz, Blink, CVBench) + video 7ベンチ (LongVideoBench, NExTQA, VideoMME, VideoMMMU, LVBench, MVBench, TempCompass)

### C: Results
- [x] Evidence 1 (GRPOの画像劣化問題をRALが解決)
  - 条件: Qwen-2.5-VL-7BにGRPO vs RALを適用し、image/videoベンチで比較
  - 結論: GRPOは画像ベンチ8つ中5つでbase modelより悪化 (V* 70.7→68.6, MME 2309→2259, ChartQA 84.0→81.7)。RALは8つ全てで改善 (V* →73.3, MME →2353, ChartQA →86.4)。videoでも7つ中6つでGRPOを上回る
  - 意味: RL post-trainingをマルチモーダルに適用する際の「視覚能力劣化」という根本問題にattention最適化が有効。GRPOをそのまま使うのは危険という警告でもある
- [x] Evidence 2 (visual token数が増えるほど優位性拡大)
  - 条件: V*Benchで画像解像度 (visual token数) を512→2048に変化させてRAL vs GRPOを比較
  - 結論: 512 tokensで+1.6の差が、2048 tokensで+6.3に拡大。RAL-zero (CoTなし) でもGRPO+CoTに勝利
  - 意味: visual情報が多い=attentionの割り当てが重要なタスクほどRALが効く。AI4Sの科学画像・実験動画など情報密度の高い入力に特に有望。CoTなしでも効くのは「見る能力」が本質的なボトルネックだった証拠

### D: Gaps & Next Step
- [x] Gap 1 (Qwen-2.5-VLのみの検証)
  - Applicability Gap: 実験はQwen-2.5-VL (7B/32B) のみ。他アーキテクチャ (InternVL, LLaVA等) やより大きなモデルでの汎化は未確認。最終層attention head平均という設計がアーキテクチャ依存の可能性
  - Evidence status: 単一モデルファミリーでの一貫した改善は示されている
  - Minimal test: InternVLやLLaVA-NeXTなど別アーキテクチャで同じ手法を適用し、改善が再現するか確認
- [x] Gap 2 (exact-match報酬の限界)
  - Applicability Gap: 報酬がexact match (1 or 0) のみ。AI4Sでの科学的推論 (仮説の妥当性、実験計画の質) はopen-endedで二値評価できない
  - Evidence status: 選択式・短答式タスクでの改善のみ。生成型タスクや段階的評価での効果は未検証
  - Minimal test: LLM-as-a-judgeなどの連続報酬でRALが機能するか、science QAタスクで試す
- [x] Next step: (i) 手元のscience VQAタスクでGRPO vs RALの差を確認 (ii) attention可視化で「何を見ているか」を定性分析 (論文にないので自分でやる価値あり) (iii) 科学画像 (顕微鏡画像、スペクトル等) での効果を検証
