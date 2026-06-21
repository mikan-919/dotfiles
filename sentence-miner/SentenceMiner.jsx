import React, { useState } from "react";

// Sentence Miner — claude.ai アーティファクト版
// 日本語話者の英語学習者向け、AIネイティブなセンテンスマイニング（用例つき単語カード生成）ツール。
// AI抽出はアーティファクト内の window.claude.complete() を使用（APIキー不要）。
// localStorage/sessionStorage は使わない（アーティファクト制約）。

const LEVELS = [
  { value: "A2", label: "A2 / TOEIC 〜450（基礎）" },
  { value: "B1", label: "B1 / TOEIC 〜600（中級）" },
  { value: "B2", label: "B2 / TOEIC 〜800（中上級）" },
  { value: "C1", label: "C1 / TOEIC 860+（上級）" },
];

function escapeHtml(s) {
  return (s || "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));
}

// 語の先頭一致で文中を軽くハイライト（活用差があっても目印になる）
function highlight(sentence, word) {
  const head = (word || "").split(/\s+/)[0].replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const esc = escapeHtml(sentence);
  if (!head) return esc;
  try {
    const re = new RegExp("\\b(" + head + "\\w*)\\b", "i");
    return esc.replace(re, '<mark style="background:#fde68a;padding:0 .12em;border-radius:3px">$1</mark>');
  } catch {
    return esc;
  }
}

function csvField(s) {
  return '"' + String(s ?? "").replace(/"/g, '""') + '"';
}

function buildPrompt({ text, level, known, maxCards }) {
  return `あなたは日本語話者の英語学習を助けるセンテンスマイニングのアシスタントです。
与えられた英文から、学習者が覚える価値のある語・熟語（コロケーションや句動詞を含む）を選び、用例つきの単語カードを作ります。

選定ルール:
- 学習者のレベルは CEFR ${level} 相当。これより明確に易しい基礎語（中学レベルの超頻出語など）は選ばない。
- 文中に実際に出てくる語だけを対象にする。活用形でも、その文脈での意味を正しく捉える。
- 固有名詞・数字・記号は除外する。
${known ? `- 次の『既知語リスト』に含まれる語、およびその活用形・派生語は除外する: ${known}` : ""}
- カードは最大 ${maxCards} 件。価値の高い順に選ぶ。覚える価値のある語がなければ空配列を返す。

出力は次の形の JSON だけを返すこと（前後に説明文やコードフェンスを付けない）:
{"cards":[{"word":"見出し語(基本形/lemma、句動詞や熟語ならそのまとまり)","sentence":"その語を含む元テキストの実際の一文","meaning_ja":"その文脈に即した自然な日本語の意味","example_en":"その語を使った元文とは別の自然な新しい例文","example_ja":"example_en の自然な日本語訳","cefr":"A1〜C2 のいずれか"}]}

対象の英文:
---
${text}`;
}

// window.claude.complete の戻りは文字列。説明やコードフェンスが混ざっても拾えるよう防御的にパース。
function parseCards(raw) {
  let s = (raw || "").trim();
  const fence = s.match(/```(?:json)?\s*([\s\S]*?)```/i);
  if (fence) s = fence[1].trim();
  const start = s.indexOf("{");
  const end = s.lastIndexOf("}");
  if (start !== -1 && end !== -1) s = s.slice(start, end + 1);
  const data = JSON.parse(s);
  return Array.isArray(data.cards) ? data.cards : [];
}

export default function SentenceMiner() {
  const [tab, setTab] = useState("paste");
  const [sourceText, setSourceText] = useState("");
  const [sourceUrl, setSourceUrl] = useState("");
  const [level, setLevel] = useState("B1");
  const [knownWords, setKnownWords] = useState("");
  const [maxCards, setMaxCards] = useState(12);
  const [wordOnly, setWordOnly] = useState(false);
  const [cards, setCards] = useState([]);
  const [loading, setLoading] = useState(false);
  const [status, setStatus] = useState({ msg: "", err: false });

  const setMsg = (msg, err = false) => setStatus({ msg, err });

  async function fetchArticle(url) {
    const res = await fetch("https://r.jina.ai/" + url);
    if (!res.ok) throw new Error("記事の取得に失敗しました (" + res.status + ")");
    const t = await res.text();
    return t.slice(0, 12000);
  }

  async function generate() {
    let text = "";
    try {
      if (tab === "url") {
        if (!sourceUrl.trim()) return setMsg("記事URLを入力してください。", true);
        setMsg("記事を取得中…");
        text = await fetchArticle(sourceUrl.trim());
      } else {
        text = sourceText.trim();
      }
    } catch (e) {
      return setMsg(e.message, true);
    }
    if (!text) return setMsg("英文を入力してください。", true);

    const cap = Math.min(50, Math.max(1, parseInt(maxCards) || 12));
    const known = knownWords.trim().replace(/\s+/g, " ");

    setLoading(true);
    setMsg("AIが語を抽出中…（10〜30秒ほど）");
    try {
      const raw = await window.claude.complete(buildPrompt({ text, level, known, maxCards: cap }));
      const parsed = parseCards(raw).map((c) => ({ ...c, wordOnly }));
      setCards(parsed);
      setMsg(parsed.length ? `${parsed.length} 件のカードを生成しました。` : "覚える価値のある語が見つかりませんでした。");
    } catch (e) {
      setMsg("生成に失敗しました: " + (e?.message || e), true);
    } finally {
      setLoading(false);
    }
  }

  function removeCard(i) {
    setCards((cs) => cs.filter((_, idx) => idx !== i));
  }

  function exportCsv() {
    if (!cards.length) return;
    const lines = ["#separator:Comma", "#html:true", "#columns:Front,Back"];
    for (const c of cards) {
      const front = c.wordOnly ? `<b>${escapeHtml(c.word)}</b>` : highlight(c.sentence, c.word);
      const back = [
        `<b>${escapeHtml(c.word)}</b>（${escapeHtml(c.cefr)}）`,
        escapeHtml(c.meaning_ja),
        `<br><i>${escapeHtml(c.example_en)}</i>`,
        escapeHtml(c.example_ja),
      ].join("<br>");
      lines.push(csvField(front) + "," + csvField(back));
    }
    const blob = new Blob([lines.join("\n")], { type: "text/csv;charset=utf-8" });
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = "sentence-miner-" + new Date().toISOString().slice(0, 10) + ".csv";
    a.click();
    URL.revokeObjectURL(a.href);
  }

  const tabBtn = (id, label) => (
    <button
      onClick={() => setTab(id)}
      className={`px-3 py-1.5 rounded-md text-sm ${tab === id ? "bg-slate-800 text-white" : "bg-slate-100 text-slate-600"}`}
    >
      {label}
    </button>
  );

  return (
    <div className="min-h-screen bg-slate-50 text-slate-800" style={{ fontFeatureSettings: '"palt"' }}>
      <header className="border-b border-slate-200 bg-white">
        <div className="max-w-5xl mx-auto px-5 py-4">
          <h1 className="text-xl font-bold tracking-tight">Sentence Miner</h1>
          <p className="text-sm text-slate-500">英文を貼る → レベルに合う語をAIが抽出 → 用例つきカード → Anki用CSVで書き出し</p>
        </div>
      </header>

      <main className="max-w-5xl mx-auto px-5 py-6 grid gap-6 lg:grid-cols-[380px_1fr]">
        {/* 入力パネル */}
        <section>
          <div className="bg-white rounded-xl border border-slate-200 p-4 space-y-4">
            <div>
              <label className="block text-sm font-semibold mb-1.5">ソース</label>
              <div className="flex gap-1 mb-2">
                {tabBtn("paste", "テキスト貼り付け")}
                {tabBtn("url", "記事URL")}
              </div>
              {tab === "paste" ? (
                <textarea
                  rows={9}
                  value={sourceText}
                  onChange={(e) => setSourceText(e.target.value)}
                  className="w-full rounded-lg border border-slate-300 p-3 text-sm focus:outline-none focus:ring-2 focus:ring-slate-400"
                  placeholder="英語のテキストをここに貼り付け（記事・本の一節・ドラマの字幕など）"
                />
              ) : (
                <div className="space-y-2">
                  <input
                    type="url"
                    value={sourceUrl}
                    onChange={(e) => setSourceUrl(e.target.value)}
                    className="w-full rounded-lg border border-slate-300 p-3 text-sm focus:outline-none focus:ring-2 focus:ring-slate-400"
                    placeholder="https://example.com/article"
                  />
                  <p className="text-xs text-slate-500">記事本文を取得してから抽出します（取得には数秒。環境によっては取得できない場合があります）。</p>
                </div>
              )}
            </div>

            <div>
              <label className="block text-sm font-semibold mb-1.5">あなたのレベル</label>
              <select
                value={level}
                onChange={(e) => setLevel(e.target.value)}
                className="w-full rounded-lg border border-slate-300 p-2.5 text-sm bg-white"
              >
                {LEVELS.map((l) => (
                  <option key={l.value} value={l.value}>{l.label}</option>
                ))}
              </select>
              <p className="text-xs text-slate-500 mt-1">これより易しい語は除外して、覚える価値のある語だけを選びます。</p>
            </div>

            <div>
              <label className="block text-sm font-semibold mb-1.5">もう知っている単語（重複除外）</label>
              <textarea
                rows={3}
                value={knownWords}
                onChange={(e) => setKnownWords(e.target.value)}
                className="w-full rounded-lg border border-slate-300 p-3 text-sm focus:outline-none focus:ring-2 focus:ring-slate-400"
                placeholder="カンマ・改行区切りで入力（例: although, nevertheless, robust）"
              />
            </div>

            <div className="flex items-center justify-between gap-3">
              <label className="text-sm font-semibold">最大カード数</label>
              <input
                type="number"
                min={1}
                max={50}
                value={maxCards}
                onChange={(e) => setMaxCards(e.target.value)}
                className="w-20 rounded-lg border border-slate-300 p-2 text-sm text-center"
              />
            </div>

            <label className="flex items-center gap-2 text-sm">
              <input type="checkbox" checked={wordOnly} onChange={(e) => setWordOnly(e.target.checked)} className="rounded border-slate-300" />
              <span>単語単体カードも作る（既定は文ごとカード）</span>
            </label>

            <button
              onClick={generate}
              disabled={loading}
              className="w-full rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white font-semibold py-3 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? "生成中…" : "カードを生成"}
            </button>
            <p className={`text-sm text-center min-h-[1.25rem] ${status.err ? "text-red-600" : "text-slate-500"}`}>{status.msg}</p>
          </div>
        </section>

        {/* 結果パネル */}
        <section>
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-base font-semibold">
              カード {cards.length > 0 && <span className="text-slate-400 font-normal">({cards.length})</span>}
            </h2>
            <button
              onClick={exportCsv}
              disabled={!cards.length}
              className="text-sm rounded-lg border border-slate-300 bg-white px-3 py-1.5 hover:bg-slate-100 disabled:opacity-40"
            >
              Anki用CSVで書き出し
            </button>
          </div>

          {cards.length === 0 ? (
            <div className="text-center text-slate-400 border-2 border-dashed border-slate-200 rounded-xl py-20">
              まだカードはありません。左側で英文を貼って「カードを生成」を押してください。
            </div>
          ) : (
            <div className="space-y-3">
              {cards.map((c, i) => (
                <div key={i} className="bg-white rounded-xl border border-slate-200 p-4">
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex items-center gap-2">
                      <span className="font-semibold text-emerald-700">{c.word}</span>
                      <span className="text-xs px-1.5 py-0.5 rounded bg-slate-100 text-slate-500">{c.cefr}</span>
                    </div>
                    <button onClick={() => removeCard(i)} className="text-slate-300 hover:text-red-500 text-sm" title="削除">✕</button>
                  </div>
                  <p
                    className="mt-2 leading-relaxed"
                    style={{ fontSize: "1.05rem" }}
                    dangerouslySetInnerHTML={{ __html: c.wordOnly ? escapeHtml(c.word) : highlight(c.sentence, c.word) }}
                  />
                  <div className="mt-3 grid gap-2 text-sm border-t border-slate-100 pt-3">
                    <div><span className="text-slate-400">意味</span> {c.meaning_ja}</div>
                    <div><span className="text-slate-400">例文</span> {c.example_en}</div>
                    <div><span className="text-slate-400">訳</span> {c.example_ja}</div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </section>
      </main>
    </div>
  );
}
