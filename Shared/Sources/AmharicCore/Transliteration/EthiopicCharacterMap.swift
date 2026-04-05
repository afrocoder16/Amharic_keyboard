import Foundation

/// Complete mapping from Latin transliteration sequences to Ethiopic (Amharic) characters.
///
/// The Ethiopic syllabary has 7 vowel orders per consonant:
///   1st (e/ə): bare consonant  e.g. "le" = ለ
///   2nd (u):   consonant + u   e.g. "lu" = ሉ
///   3rd (i):   consonant + i   e.g. "li" = ሊ
///   4th (a):   consonant + a   e.g. "la" = ላ
///   5th (ie/E): consonant + ie e.g. "lie" = ሌ
///   6th (∅):   bare consonant (neutral/6th form) e.g. "l" = ል
///   7th (o):   consonant + o   e.g. "lo" = ሎ
///
/// Special multi-letter consonants (sh, ch, zh, ny, ts, kh, etc.) are listed with
/// their full vowel variants first so greedy matching prefers them.
public enum EthiopicCharacterMap {

    /// Sorted longest-first for greedy matching in TransliterationEngine.
    public static let sortedKeys: [String] = {
        map.keys.sorted { $0.count > $1.count }
    }()

    // MARK: - Master Map

    public static let map: [String: Character] = {
        var m: [String: Character] = [:]

        // ── ሀ row (h) ──────────────────────────────────────────────
        m["he"] = "ሀ"; m["hu"] = "ሁ"; m["hi"] = "ሂ"; m["ha"] = "ሃ"
        m["hie"] = "ሄ"; m["h"] = "ህ"; m["ho"] = "ሆ"

        // ── ለ row (l) ──────────────────────────────────────────────
        m["le"] = "ለ"; m["lu"] = "ሉ"; m["li"] = "ሊ"; m["la"] = "ላ"
        m["lie"] = "ሌ"; m["l"] = "ል"; m["lo"] = "ሎ"

        // ── ሐ row (H - second h, pharyngeal) ───────────────────────
        m["He"] = "ሐ"; m["Hu"] = "ሑ"; m["Hi"] = "ሒ"; m["Ha"] = "ሓ"
        m["Hie"] = "ሔ"; m["H"] = "ሕ"; m["Ho"] = "ሖ"

        // ── መ row (m) ──────────────────────────────────────────────
        m["me"] = "መ"; m["mu"] = "ሙ"; m["mi"] = "ሚ"; m["ma"] = "ማ"
        m["mie"] = "ሜ"; m["m"] = "ም"; m["mo"] = "ሞ"

        // ── ሠ row (S - archaic s) ──────────────────────────────────
        m["Se"] = "ሠ"; m["Su"] = "ሡ"; m["Si"] = "ሢ"; m["Sa"] = "ሣ"
        m["Sie"] = "ሤ"; m["S"] = "ሥ"; m["So"] = "ሦ"

        // ── ረ row (r) ──────────────────────────────────────────────
        m["re"] = "ረ"; m["ru"] = "ሩ"; m["ri"] = "ሪ"; m["ra"] = "ራ"
        m["rie"] = "ሬ"; m["r"] = "ር"; m["ro"] = "ሮ"

        // ── ሰ row (s) ──────────────────────────────────────────────
        m["se"] = "ሰ"; m["su"] = "ሱ"; m["si"] = "ሲ"; m["sa"] = "ሳ"
        m["sie"] = "ሴ"; m["s"] = "ስ"; m["so"] = "ሶ"

        // ── ሸ row (sh) ─────────────────────────────────────────────
        m["she"] = "ሸ"; m["shu"] = "ሹ"; m["shi"] = "ሺ"; m["sha"] = "ሻ"
        m["shie"] = "ሼ"; m["sh"] = "ሽ"; m["sho"] = "ሾ"

        // ── ቀ row (q) ──────────────────────────────────────────────
        m["qe"] = "ቀ"; m["qu"] = "ቁ"; m["qi"] = "ቂ"; m["qa"] = "ቃ"
        m["qie"] = "ቄ"; m["q"] = "ቅ"; m["qo"] = "ቆ"

        // ── በ row (b) ──────────────────────────────────────────────
        m["be"] = "በ"; m["bu"] = "ቡ"; m["bi"] = "ቢ"; m["ba"] = "ባ"
        m["bie"] = "ቤ"; m["b"] = "ብ"; m["bo"] = "ቦ"

        // ── ቨ row (v) ──────────────────────────────────────────────
        m["ve"] = "ቨ"; m["vu"] = "ቩ"; m["vi"] = "ቪ"; m["va"] = "ቫ"
        m["vie"] = "ቬ"; m["v"] = "ቭ"; m["vo"] = "ቮ"

        // ── ተ row (t) ──────────────────────────────────────────────
        m["te"] = "ተ"; m["tu"] = "ቱ"; m["ti"] = "ቲ"; m["ta"] = "ታ"
        m["tie"] = "ቴ"; m["t"] = "ት"; m["to"] = "ቶ"

        // ── ቸ row (ch) ─────────────────────────────────────────────
        m["che"] = "ቸ"; m["chu"] = "ቹ"; m["chi"] = "ቺ"; m["cha"] = "ቻ"
        m["chie"] = "ቼ"; m["ch"] = "ች"; m["cho"] = "ቾ"

        // ── ነ row (n) ──────────────────────────────────────────────
        m["ne"] = "ነ"; m["nu"] = "ኑ"; m["ni"] = "ኒ"; m["na"] = "ና"
        m["nie"] = "ኔ"; m["n"] = "ን"; m["no"] = "ኖ"

        // ── ኘ row (ny/gn) ──────────────────────────────────────────
        m["nye"] = "ኘ"; m["nyu"] = "ኙ"; m["nyi"] = "ኚ"; m["nya"] = "ኛ"
        m["nyie"] = "ኜ"; m["ny"] = "ኝ"; m["nyo"] = "ኞ"

        // ── አ row (standalone vowels / glottal stop) ───────────────
        m["ae"] = "አ"; m["au"] = "ኡ"; m["ai"] = "ኢ"; m["aa"] = "ኣ"
        m["aie"] = "ኤ"; m["ao"] = "ኦ"
        // Schwa / 6th order standalone
        m["ie"] = "ኤ"

        // ── ከ row (k) ──────────────────────────────────────────────
        m["ke"] = "ከ"; m["ku"] = "ኩ"; m["ki"] = "ኪ"; m["ka"] = "ካ"
        m["kie"] = "ኬ"; m["k"] = "ክ"; m["ko"] = "ኮ"

        // ── ኸ row (kh) ─────────────────────────────────────────────
        m["khe"] = "ኸ"; m["khu"] = "ኹ"; m["khi"] = "ኺ"; m["kha"] = "ኻ"
        m["khie"] = "ኼ"; m["kh"] = "ኽ"; m["kho"] = "ኾ"

        // ── ወ row (w) ──────────────────────────────────────────────
        m["we"] = "ወ"; m["wu"] = "ዉ"; m["wi"] = "ዊ"; m["wa"] = "ዋ"
        m["wie"] = "ዌ"; m["w"] = "ው"; m["wo"] = "ዎ"

        // ── ዐ row (A - pharyngeal ayin) ────────────────────────────
        m["Ae"] = "ዐ"; m["Au"] = "ዑ"; m["Ai"] = "ዒ"; m["Aa"] = "ዓ"
        m["Aie"] = "ዔ"; m["A"] = "ዕ"; m["Ao"] = "ዖ"

        // ── ዘ row (z) ──────────────────────────────────────────────
        m["ze"] = "ዘ"; m["zu"] = "ዙ"; m["zi"] = "ዚ"; m["za"] = "ዛ"
        m["zie"] = "ዜ"; m["z"] = "ዝ"; m["zo"] = "ዞ"

        // ── ዠ row (zh) ─────────────────────────────────────────────
        m["zhe"] = "ዠ"; m["zhu"] = "ዡ"; m["zhi"] = "ዢ"; m["zha"] = "ዣ"
        m["zhie"] = "ዤ"; m["zh"] = "ዥ"; m["zho"] = "ዦ"

        // ── የ row (y) ──────────────────────────────────────────────
        m["ye"] = "የ"; m["yu"] = "ዩ"; m["yi"] = "ዪ"; m["ya"] = "ያ"
        m["yie"] = "ዬ"; m["y"] = "ይ"; m["yo"] = "ዮ"

        // ── ደ row (d) ──────────────────────────────────────────────
        m["de"] = "ደ"; m["du"] = "ዱ"; m["di"] = "ዲ"; m["da"] = "ዳ"
        m["die"] = "ዴ"; m["d"] = "ድ"; m["do"] = "ዶ"

        // ── ዸ row (dh - emphatic d) ────────────────────────────────
        m["dhe"] = "ዸ"; m["dhu"] = "ዹ"; m["dhi"] = "ዺ"; m["dha"] = "ዻ"
        m["dhie"] = "ዼ"; m["dh"] = "ዽ"; m["dho"] = "ዾ"

        // ── ጀ row (j) ──────────────────────────────────────────────
        m["je"] = "ጀ"; m["ju"] = "ጁ"; m["ji"] = "ጂ"; m["ja"] = "ጃ"
        m["jie"] = "ጄ"; m["j"] = "ጅ"; m["jo"] = "ጆ"

        // ── ገ row (g) ──────────────────────────────────────────────
        m["ge"] = "ገ"; m["gu"] = "ጉ"; m["gi"] = "ጊ"; m["ga"] = "ጋ"
        m["gie"] = "ጌ"; m["g"] = "ግ"; m["go"] = "ጎ"

        // ── ጠ row (T - emphatic t) ─────────────────────────────────
        m["Te"] = "ጠ"; m["Tu"] = "ጡ"; m["Ti"] = "ጢ"; m["Ta"] = "ጣ"
        m["Tie"] = "ጤ"; m["T"] = "ጥ"; m["To"] = "ጦ"

        // ── ጨ row (Ch - emphatic ch) ───────────────────────────────
        m["Che"] = "ጨ"; m["Chu"] = "ጩ"; m["Chi"] = "ጪ"; m["Cha"] = "ጫ"
        m["Chie"] = "ጬ"; m["Ch"] = "ጭ"; m["Cho"] = "ጮ"

        // ── ጰ row (P - emphatic p) ─────────────────────────────────
        m["Pe"] = "ጰ"; m["Pu"] = "ጱ"; m["Pi"] = "ጲ"; m["Pa"] = "ጳ"
        m["Pie"] = "ጴ"; m["P"] = "ጵ"; m["Po"] = "ጶ"

        // ── ጸ row (ts - emphatic s/ts) ─────────────────────────────
        m["tse"] = "ጸ"; m["tsu"] = "ጹ"; m["tsi"] = "ጺ"; m["tsa"] = "ጻ"
        m["tsie"] = "ጼ"; m["ts"] = "ጽ"; m["tso"] = "ጾ"

        // ── ፀ row (Ts - alternate emphatic) ───────────────────────
        m["Tse"] = "ፀ"; m["Tsu"] = "ፁ"; m["Tsi"] = "ፂ"; m["Tsa"] = "ፃ"
        m["Tsie"] = "ፄ"; m["Ts"] = "ፅ"; m["Tso"] = "ፆ"

        // ── ፈ row (f) ──────────────────────────────────────────────
        m["fe"] = "ፈ"; m["fu"] = "ፉ"; m["fi"] = "ፊ"; m["fa"] = "ፋ"
        m["fie"] = "ፌ"; m["f"] = "ፍ"; m["fo"] = "ፎ"

        // ── ፐ row (p) ──────────────────────────────────────────────
        m["pe"] = "ፐ"; m["pu"] = "ፑ"; m["pi"] = "ፒ"; m["pa"] = "ፓ"
        m["pie"] = "ፔ"; m["p"] = "ፕ"; m["po"] = "ፖ"

        // ── Amharic punctuation ────────────────────────────────────
        m["::"] = "።"   // full stop (Ethiopic)
        m[":"] = "፡"    // word separator (Ethiopic)
        m["?"] = "?"
        m["!"] = "!"

        return m
    }()
}
