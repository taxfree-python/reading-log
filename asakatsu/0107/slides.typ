// 朝活: 論文共有会スライド
// Typst + Touying Metropolis テーマ

#import "@preview/touying:0.6.1": *
#import themes.metropolis: *

// 日本語フォント設定
#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [最近読んだ面白い論文 (AI for Science も含む)],
    subtitle: [2026/1/07 \@slack],
    author: [tax_free],
    date: datetime.today().display("[year]/[month]/[day]"),
  ),
  config-common(
    // 日本語フォントを設定(macOSの場合)
    // Windows: "Yu Gothic", "Meiryo"
    // Linux: "Noto Sans CJK JP"
  ),
)

// 日本語フォントをグローバルに設定
#set text(font: ("Hiragino Sans", "Hiragino Kaku Gothic ProN"), lang: "ja")

// タイトルスライド
#title-slide()

// ========================================
// 目的確認スライド
// ========================================
== 会の目的

*目的*
- AI for Science に使えそうな研究を catch up する
- Slack に論文を貼るだけでなく、集まってチームで議論したい
- 朝にやることで生活リズムを整える(朝活)

*1行ルール*
- 論文の網羅紹介はたぶんしません。「どうすれば AI for Science に応用できそうか」「どこがおもしろいのか」など個人の視点を中心に話します。

// ========================================
// 論文 1
// ========================================
= 論文 1: Evaluating AI's ability to perform scientific research tasks

== A: Contribution

- *この論文の貢献*: 既存のベンチマークでサチっていた/十分な数なかった科学に関する高品質なベンチマークを公開した
- *著者/組織*: OpenAI
- *公開日*: 2025/12/16
- *なぜ今?*: 12/26 の定例で尾崎先生に紹介してもらったのと、科学的な質問に対する回答の評価方法を調べていたから
- *使えるとしたら何ができる?*: 難しい科学的な問題に対する評価方法を参考にして独自のベンチマーク作成に使用できる
- *論文リンク*: https://openai.com/index/frontierscience/

== B: Method

+ *対象(入力→出力)*: 専門家が書いた科学タスク(物理/化学/生物)→ モデルの解答 → 正誤/スコア(Olympiad: 正誤、Research: 10点ルーブリック)
+ *キモ(新規点)*: (1) "サチってない"難問を専門家が新規作成 (2) 研究っぽいopen-endedを「チェック可能なルーブリック」に落としてスケール評価(2トラック構成)
+ *流れ*: 作問(専門家)→ 相互レビュー → 不一致解消 → 改訂で品質担保。Gold setを公開・残りは保持して汚染追跡
+ *評価のしかた*: Olympiad=数式/数値/文字列の同値判定、Research=10点rubricで採点(≥7/10を正解扱い)＋モデル採点(GPT-5 grader)

== C-1: Results(フロンティアモデル比較)

*Evidence 1*
- 条件: FrontierScience-Olympiad(100問)/ Research(60問)で複数フロンティアモデルを比較
- 結論: GPT-5.2がトップ(Olympiad 77% / Research 25%)。OlympiadはGemini 3 Proが76%で僅差
- 意味: 「閉じた難問(Olympiad)はかなり解ける」一方で「研究サブタスク(Research)はまだ余白大」＝評価軸を分けて見る必要あり

== C-2: Results(reasoning effortの影響)

*Evidence 2*
- 条件: reasoning effort(test-time compute / thinking time)を変えてGPT-5.2とo3を比較
- 結論: GPT-5.2はOlympiad 67.5%→77.1%、Research 18%→25%(より長く考えるほど改善)
- 意味: ベンチマーク設計的に、手法差だけでなく推論予算差も明示しないと比較が崩れる

== D-1: Gaps(LLM-as-a-judgeの揺れ)

*Gap 1*
- *Applicability Gap*: rubric＋LLM採点はスケールするが、採点プロンプト依存の揺れやverbosity bias、「自分の出力をよく見積もる」系のバイアスが入りやすい
- *Evidence status*: GPT-5をmodel-graderとして使い、Researchは10点rubricで≥7/10を正解扱い(=人手スケール不可の現実的解)
- *Minimal test*: 1〜3問で高品質評価データを作り、モデル名/effortを隠したブラインド採点→採点プロンプトを2〜3通りに言い換えてスコア分散を見る

== D-2: Gaps("科学的な取り組み"の評価は未知数)& Next Step

*Gap 2*
- *Applicability Gap*: 今やってるのは解ける問題。実際には実験しながらデータを集めて検証するプランニングまで評価する必要がある
- *Evidence status*: 制約付きの問題文を解いているので、仮説を作る・計画をたてるという部分は評価できていない
- *Minimal test*: in silicoで完結する環境の整備? 自動実験設備との接続?

*Next step*: まずFrontierScienceをそのまま動かして評価用promptを少し変えるとどうなるかを確認。良さそうならrubricや問題を真似して作って評価してみる

// ========================================
// 論文 2
// ========================================
= 論文 2: Gemma Scope 2: helping the AI safety community deepen understanding of complex language model behavior

== A: Contribution

- *この論文の貢献*: そこそこ賢い Gemma 3 のモデル内部の解釈をサポートする SAE を作った
- *著者/組織*: Google DeepMind
- *公開日*: 2025/09/16
- *なぜ今?*: 一ヶ月くらい前に出たのとCyberAgentのblogを読んだから
- *使えるとしたら何ができる?*: 質問がどういった特徴量に分解できるのかを定量的に測れる(例: rejectされた質問がなぜrejectされたのか)
- *論文リンク*: https://deepmind.google/blog/gemma-scope-2-helping-the-ai-safety-community-deepen-understanding-of-complex-language-model-behavior/

== B: Method

+ *対象(入力→出力)*: Gemma 3 の各層の activation x → JumpReLU SAE のスパース latent f(x) → 再構成 x̂
+ *キモ(新規点)*: JumpReLU+L0でスパース性を直接制御 / skip connection付きtranscoderでMLPの線形成分を分離
+ *流れ*: データからactivation抽出 → 3箇所/層にSAE学習+各層transcoder学習 → E2E finetune → 再構成・解釈性・circuit graphで評価
+ *評価のしかた*: reconstruction fidelity (delta LM loss/FVU) / 自動解釈(説明文生成→発火の二値分類) / circuit graphの疎さ

== C: Results

*Evidence 1(解釈性の手応え)*
- 条件: latentが発火する/しないシーケンスを集め、モデルに「説明」を作らせ、その説明で発火例を当てられるか
- 結論: 低頻度(あまり発火しない)latentほど解釈しやすい傾向がある
- 意味: AI4S 系の拒否/安全系の挙動を追うなら、"たまにだけ出るトリガー特徴"が見つけやすい可能性

*Evidence 2(Transcoderでcircuit graphが扱いやすくなる)*
- 条件: transcoder/CLTでskip connectionあり vs なしを比較(FVU–L0のトレードオフ、circuit graphの疎さ)
- 結論: skipありが再構成を改善し、グラフがより疎(少ないノード/エッジで影響を説明)になりやすい
- 意味: 拒否が起きるまでの"経路"を辿るとき、説明が短い回路に圧縮されるとデバッグが現実的になる

== D: Gaps & Next Step

*Gap 1(lifescience領域の"不要な拒否"に直結するか)*
- *Applicability Gap*: 論文は一般的な安全・信頼性タスクを念頭。lifescienceの"良性質問が拒否される"ケースへの転用は未検証
- *Evidence status*: 「全層SAE/Transcoder＋評価枠組み」のツール土台提供が主
- *Minimal test*: lifescience質問を拒否/回答に分けた小セットで発火latentを集計し、拒否を予測するlatentを抽出

*Gap 2("解釈できた"の信頼性)*
- *Applicability Gap*: 自動解釈スコアは便利だが、人間にとっての意味解釈やドメイン知識(生物/化学)に対する妥当性は別問題
- *Evidence status*: 解釈性評価は自動解釈(説明生成→二値分類)が中心
- *Minimal test*: 拒否関連latent上位20個に人手で「何に反応してそうか」ラベルを付け、正当トリガー vs スプリアスに二分してfalse positive割合を見積もる

*Next step*: Gemma Scope 2のlatentを使って「lifescience質問の拒否を説明するlatent catalog」を作り、不要な拒否の典型パターンを可視化する

// ========================================
// 論文 3
// ========================================
= 論文 3: Youtu-Agent: Scaling Agent Productivity with Automated Generation and Hybrid Policy Optimization

== A: Contribution

- *この論文の貢献*: context を自動で最適化する training-free の GRPO-like な手法を提案していてソースコードが公開されている (性能改善は怪しい)
- *著者/組織*: Tencent
- *公開日*: 2025/12/26
- *なぜ今?*: Huggingface paper で上位だったから
- *使えるとしたら何ができる?*: ベンチマーク (評価系) さえ用意すれば自動でそれを解くための Agent を作ってくれる
- *論文リンク*: https://arxiv.org/abs/2512.24615

== B: Method

+ *対象(入力→出力)*: (1) タスク記述 → agent設定(YAML)+tool群(既存or自動生成Python) (2) 少数タスク集合 → "経験メモリ"をcontextへ注入(Practice) (3) 環境付き長軌道タスク → モデル重み更新(Agent RL)
+ *キモ(新規点)*: 自動生成(tool検索+不足分はPython toolを合成しYAML組み立て) / Practice(複数rollout→LLM評価で成功/失敗の差分からsemantic group advantageを蒸留→contextに入れる、重み更新なし)
+ *流れ*: タスク記述 → Agent自動生成 → 実行 → Practiceで並列rollout+LLM評価 → 経験テキスト蓄積 → 本番はそれをpromptに注入
+ *評価のしかた*: 生成品質=AgentGen-80で設定妥当性/ツール実行性/タスク完遂 / Practice=AIME 2024/2025をMean\@32 / RL=7Bで数学・検索系ベンチ前後比較

== C-1: Results(General agent能力:GAIA)

*Evidence 1*
- 条件: GAIA(466問)のtext-only subsetで、pass\@1 accuracyを評価(webツール＋ドキュメント解析＋コード実行を付与)
- 結論: GAIA text-onlyで72.8% pass\@1
- 意味: 「ツール選択＋多段推論」込みの総合力は一応高い。ただしtext-only subsetなので、マルチモーダル含む難しさへの外挿は注意

== C-2: Results(数学タスク:PracticeとRLで"伸びる"が性質が違う)

*Evidence 2*
- 条件:
  - Practice(training-free GRPO): DAPO-Math-17Kから100問、3epoch、group size 5。AIME 2024/2025をMean\@32で評価
  - Agent RL(重み更新あり): Qwen2.5-7B-Instructをend-to-end RL、step 500時点でAIME24/25をbefore/after比較
- 結論:
  - Practice: AIME24 80.0→82.7(+2.7), AIME25 67.9→73.3(+5.4)
  - RL: AIME24 0.10→0.45(+0.35), AIME25 0.09→0.31(+0.22)
- 意味:
  - Practiceは少数サンプル＆重み更新なしで改善が出るのが売り(ただし改善幅は控えめ)
  - RLは改善が大きめに見える一方、計算資源・報酬設計・安定化が前提

== D-1: Gaps(AI for Scienceでrewardを安定に作れるか)

*Gap 1*
- *Applicability Gap*: Practiceは大量のreward相当の比較/評価を回す必要がある。AI for Scienceでは正解がない・実験が高コスト・遅いので、「数学ベンチでは回る」≠「科学タスクで回る」
- *Evidence status*: 評価は主にAIME等(短期・即時採点可能)で、遅延報酬/高コスト評価でスケールできる根拠は薄い
- *Minimal test*: 2〜3問の小さな科学ミニタスクで意図的にoverfitさせ、経験メモリが手順・ツール使用・検証ステップをどこまで表現できるか確認

== D-2: Gaps(LLM-as-a-Judgeの安定性)& Next Step

*Gap 2*
- *Applicability Gap*: LLM-as-a-Judgeで"良い軌跡"を選ぶ設計は、評価者の温度・モデル差・プロンプト差で順位が変わりやすく、学習が不安定に。AI for Scienceでは「どれが良いか」の基準自体が曖昧なので不安定性が増幅しそう
- *Evidence status*: 改善例は示すが、evaluatorのブレ耐性(seed/モデル/温度/rubric変更)を系統的に示していない
- *Minimal test*: 同一ロールアウト集合に対してevaluatorを変えて順位相関(Kendall/Spearman)を測る。頻繁に入れ替わるならノイズ駆動リスク

*Next step*: (i) 2〜3問overfitで表現力チェック → (ii) evaluatorのブレ定量化 → クリアできたらAI for Science向けに遅延・高コスト評価の近似設計(proxy reward/段階評価/人手混在)

// ========================================
// Appendix
// ========================================
= Appendix

== A: Glossary

- *SAE*: Sparse Auto Encoder の略で複雑なモデルを sparse な要素に分解することでモデルの解釈性を高める手法 (LLM に使って解釈性をあげる研究で見る。去年の NeurIPS での評価が高い論文の中に入っていた)
- *GRPO*: Group Relative Policy Optimization の略で、複数の試行結果を比較して良いものを強化学習的に学習する手法 (DeepSeekMath で提案、2025 年にバズった)
- *Gemma*: Google が出している大規模言語モデルシリーズの一つ (https://ai.google.dev/gemma/docs/core?hl=ja) で、Gemini series と違ってオープンソースで提供されている。最近のはそこそこ賢い。

== B: Q&A

*Q1 (Gemma Scope 2): 一般ユーザーの私たちでrejectとかに関してできることあるの?*
- A: 基本的にはopen weightのモデルに限定されるが、意図しないrejectだったり、逆にシステムを悪用されないためにもpromptを工夫するなどできることはある。alignmentするときでもどういうデータが必要なのか、どれを指標として見ればいいか、などを知るためにもSAEなどを用いたexplainabilityは重要。

*Q2 (FrontierScience): 評価が低かった回答ってどういうもの?*
- A: 私が動かして後で共有します。今週中には共有したい。(TODO)

*Q3 (全体): AI4Sではpromptとweightのどっちを最適化するのが主流か*
- A: Google AI co-scientist、Sakana AI Scientistでも基本的にはpromptとtool、agent workflowの最適化で、weightをいじらないことが多い。データが少ない、SoTAモデルのweightを調整するのは時間とお金がかかる、自然言語ほど直感的にフィードバックできないなどが理由。ただし、GPT-5-Codex, DeepSeek-Coderなど、数学/Coding系はデータが多く回答を評価しやすいので特化モデルは多い。
