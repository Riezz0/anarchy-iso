import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: quranText

    property int currentSurah: 0
    property bool showTranslation: true
    property int selectedTranslation: 20
    property var verses: []
    property bool loading: false
    property string error: ""

    property var translations: [
        { id: 20,  name: "Saheeh International",     lang: "English" },
        { id: 19,  name: "M. Pickthall",             lang: "English" },
        { id: 22,  name: "A. Yusuf Ali",             lang: "English" },
        { id: 85,  name: "M.A.S. Abdel Haleem",      lang: "English" },
        { id: 203, name: "Al-Hilali & Khan",          lang: "English" },
        { id: 57,  name: "Transliteration",           lang: "English" },
        { id: 31,  name: "M. Hamidullah",             lang: "French" },
        { id: 77,  name: "Diyanet",                   lang: "Turkish" },
        { id: 33,  name: "Indonesian Ministry",       lang: "Indonesian" },
        { id: 54,  name: "M. Junagarhi",              lang: "Urdu" },
        { id: 210, name: "Dar Al-Salam",              lang: "Turkish" },
        { id: 140, name: "Montada Islamic Foundation", lang: "Spanish" },
        { id: 27,  name: "Bubenheim & Nadeem",        lang: "German" },
        { id: 35,  name: "Ryoichi Mita",              lang: "Japanese" }
    ]

    property var _cache: ({})

    Process {
        id: fetchProcess
        running: false
        stdout: SplitParser {
            onRead: line => {
                try {
                    var resp = JSON.parse(line)
                    if (resp.verses) {
                        var result = []
                        for (var i = 0; i < resp.verses.length; i++) {
                            var v = resp.verses[i]
                            var arabic = v.text_uthmani || ""
                            var trans = ""
                            if (v.translations && v.translations.length > 0)
                                trans = v.translations[0].text || ""
                            result.push({ n: v.verse_number, key: v.verse_key, arabic: arabic, translation: trans })
                        }
                        quranText._cache[quranText.currentSurah + "_" + quranText.selectedTranslation] = result
                        quranText.verses = result
                        quranText.loading = false
                        quranText.error = ""
                    }
                } catch (e) {
                    quranText.loading = false
                    quranText.error = "Parse error"
                }
            }
        }
    }

    Process {
        id: fetchPage2
        running: false
        stdout: SplitParser {
            onRead: line => {
                try {
                    var resp = JSON.parse(line)
                    if (resp.verses) {
                        var existing = quranText.verses.slice()
                        for (var i = 0; i < resp.verses.length; i++) {
                            var v = resp.verses[i]
                            var arabic = v.text_uthmani || ""
                            var trans = ""
                            if (v.translations && v.translations.length > 0)
                                trans = v.translations[0].text || ""
                            existing.push({ n: v.verse_number, key: v.verse_key, arabic: arabic, translation: trans })
                        }
                        var cacheKey = quranText.currentSurah + "_" + quranText.selectedTranslation
                        quranText._cache[cacheKey] = existing
                        quranText.verses = existing
                        quranText.loading = false
                    }
                } catch (e) {
                    quranText.loading = false
                }
            }
        }
    }

    function loadSurah(n) {
        if (n < 1 || n > 114) return
        var cacheKey = n + "_" + selectedTranslation
        if (_cache[cacheKey]) {
            verses = _cache[cacheKey]
            currentSurah = n
            return
        }
        currentSurah = n
        loading = true
        error = ""
        var url = "https://api.quran.com/api/v4/verses/by_chapter/" + n
            + "?language=en&translations=" + selectedTranslation
            + "&per_page=50&fields=text_uthmani"
        fetchProcess.command = ["sh", "-c", "curl -s '" + url + "'"]
        fetchProcess.running = true
    }

    function loadSurahIfNeeded(n) {
        if (n === currentSurah && verses.length > 0) return
        loadSurah(n)
    }

    function changeTranslation(id) {
        selectedTranslation = id
        if (currentSurah > 0) loadSurah(currentSurah)
    }

    function translationName() {
        for (var i = 0; i < translations.length; i++) {
            if (translations[i].id === selectedTranslation)
                return translations[i].name
        }
        return ""
    }

    function translationLang() {
        for (var i = 0; i < translations.length; i++) {
            if (translations[i].id === selectedTranslation)
                return translations[i].lang
        }
        return ""
    }
}
