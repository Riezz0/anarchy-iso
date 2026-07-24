import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: quranPlayer

    property int currentSurah: 0
    property bool playing: false
    property bool loaded: false
    property bool minimized: false
    property bool autoNext: barSettings.autoNext
    property real position: 0
    property real duration: 0
    property real lastPosition: 0
    property int positionStallCount: 0

    readonly property string ipcSocket: "/tmp/quran-mpv-socket"

    property var reciters: [
        { name: "Mishary Alafasi",                    style: "Hafs",    server: "https://server8.mp3quran.net/afs/" },
        { name: "Abdulrahman Alsudaes",                style: "Hafs",    server: "https://server11.mp3quran.net/sds/" },
        { name: "Saud Al-Shuraim",                     style: "Hafs",    server: "https://server7.mp3quran.net/shur/" },
        { name: "Abdulbasit Abdulsamad",               style: "Hafs",    server: "https://server7.mp3quran.net/basit/" },
        { name: "Ahmad Al-Ajmy",                       style: "Hafs",    server: "https://server10.mp3quran.net/ajm/" },
        { name: "Saad Al-Ghamdi",                      style: "Hafs",    server: "https://server7.mp3quran.net/s_gmd/" },
        { name: "Yasser Salamah",                      style: "Hafs",    server: "https://server12.mp3quran.net/salamah/Rewayat-Hafs-A-n-Assem/" },
        { name: "Mohammed Jibreel",                    style: "Hafs",    server: "https://server8.mp3quran.net/jbrl/" },
        { name: "Nasser Alqatami",                     style: "Hafs",    server: "https://server6.mp3quran.net/qtm/" },
        { name: "Mohammed Ayyub",                      style: "Hafs",    server: "https://server16.mp3quran.net/ayyoub2/Rewayat-Hafs-A-n-Assem/" },
        { name: "Khalid Al-Jileel",                    style: "Hafs",    server: "https://server10.mp3quran.net/jleel/" },
        { name: "Khaled Al-Qahtani",                   style: "Hafs",    server: "https://server10.mp3quran.net/qht/" },
        { name: "Abdulmohsen Al-Qasim",                style: "Hafs",    server: "https://server8.mp3quran.net/qasm/" },
        { name: "Adel Al-Khalbany",                    style: "Hafs",    server: "https://server8.mp3quran.net/a_klb/" },
        { name: "Hatem Fareed Alwaer",                 style: "Hafs",    server: "https://server11.mp3quran.net/hatem/" },
        { name: "Maher Al Meaqli",                     style: "Mujawwad", server: "https://server12.mp3quran.net/maher/Almusshaf-Al-Mojawwad/" },
        { name: "Mohammed Siddiq Al-Minshawi",         style: "Mujawwad", server: "https://server10.mp3quran.net/minsh/Almusshaf-Al-Mo-lim/" },
        { name: "Mustafa Ismail",                      style: "Mujawwad", server: "https://server8.mp3quran.net/mustafa/Almusshaf-Al-Mojawwad/" },
        { name: "Mahmoud Khalil Al-Hussary",           style: "Qalon",   server: "https://server13.mp3quran.net/husr/Rewayat-Qalon-A-n-Nafi/" },
        { name: "Ahmad Deban",                         style: "Warsh",   server: "https://server16.mp3quran.net/deban/Rewayat-Warsh-A-n-Nafi-Men-Tariq-Alazraq/" }
    ]

    property var surahs: [
        { n: 1,   name: "Al-Fatihah",              verses: 7 },
        { n: 2,   name: "Al-Baqarah",             verses: 286 },
        { n: 3,   name: "Ali-Imran",               verses: 200 },
        { n: 4,   name: "An-Nisa",                verses: 176 },
        { n: 5,   name: "Al-Ma'idah",             verses: 120 },
        { n: 6,   name: "Al-An'am",               verses: 165 },
        { n: 7,   name: "Al-A'raf",               verses: 206 },
        { n: 8,   name: "Al-Anfal",                verses: 75 },
        { n: 9,   name: "At-Tawbah",              verses: 129 },
        { n: 10,  name: "Yunus",                   verses: 109 },
        { n: 11,  name: "Hud",                     verses: 123 },
        { n: 12,  name: "Yusuf",                   verses: 111 },
        { n: 13,  name: "Ar-Ra'd",                 verses: 43 },
        { n: 14,  name: "Ibrahim",                 verses: 52 },
        { n: 15,  name: "Al-Hijr",                 verses: 99 },
        { n: 16,  name: "An-Nahl",                 verses: 128 },
        { n: 17,  name: "Al-Isra",                 verses: 111 },
        { n: 18,  name: "Al-Kahf",                 verses: 110 },
        { n: 19,  name: "Maryam",                   verses: 98 },
        { n: 20,  name: "Taha",                     verses: 135 },
        { n: 21,  name: "Al-Anbiya",               verses: 112 },
        { n: 22,  name: "Al-Hajj",                  verses: 78 },
        { n: 23,  name: "Al-Mu'minun",              verses: 118 },
        { n: 24,  name: "An-Nur",                   verses: 64 },
        { n: 25,  name: "Al-Furqan",                verses: 77 },
        { n: 26,  name: "Ash-Shu'ara",             verses: 227 },
        { n: 27,  name: "An-Naml",                  verses: 93 },
        { n: 28,  name: "Al-Qasas",                 verses: 88 },
        { n: 29,  name: "Al-Ankabut",               verses: 69 },
        { n: 30,  name: "Ar-Rum",                   verses: 60 },
        { n: 31,  name: "Luqman",                   verses: 34 },
        { n: 32,  name: "As-Sajdah",                verses: 30 },
        { n: 33,  name: "Al-Ahzab",                 verses: 73 },
        { n: 34,  name: "Saba",                     verses: 54 },
        { n: 35,  name: "Fatir",                    verses: 45 },
        { n: 36,  name: "Ya-Sin",                   verses: 83 },
        { n: 37,  name: "As-Saffat",                verses: 182 },
        { n: 38,  name: "Sad",                      verses: 88 },
        { n: 39,  name: "Az-Zumar",                 verses: 75 },
        { n: 40,  name: "Ghafir",                   verses: 85 },
        { n: 41,  name: "Fussilat",                 verses: 54 },
        { n: 42,  name: "Ash-Shura",                verses: 53 },
        { n: 43,  name: "Az-Zukhruf",               verses: 89 },
        { n: 44,  name: "Ad-Dukhan",                verses: 59 },
        { n: 45,  name: "Al-Jathiyah",              verses: 37 },
        { n: 46,  name: "Al-Ahqaf",                 verses: 35 },
        { n: 47,  name: "Muhammad",                 verses: 38 },
        { n: 48,  name: "Al-Fath",                  verses: 29 },
        { n: 49,  name: "Al-Hujurat",               verses: 18 },
        { n: 50,  name: "Qaf",                      verses: 45 },
        { n: 51,  name: "Adh-Dhariyat",             verses: 60 },
        { n: 52,  name: "At-Tur",                   verses: 49 },
        { n: 53,  name: "An-Najm",                  verses: 62 },
        { n: 54,  name: "Al-Qamar",                 verses: 55 },
        { n: 55,  name: "Ar-Rahman",                verses: 78 },
        { n: 56,  name: "Al-Waqi'ah",              verses: 96 },
        { n: 57,  name: "Al-Hadid",                 verses: 29 },
        { n: 58,  name: "Al-Mujadilah",             verses: 22 },
        { n: 59,  name: "Al-Hashr",                 verses: 24 },
        { n: 60,  name: "Al-Mumtahanah",            verses: 13 },
        { n: 61,  name: "As-Saff",                  verses: 14 },
        { n: 62,  name: "Al-Jumu'ah",               verses: 11 },
        { n: 63,  name: "Al-Munafiqun",             verses: 11 },
        { n: 64,  name: "At-Taghabun",              verses: 18 },
        { n: 65,  name: "At-Talaq",                 verses: 12 },
        { n: 66,  name: "At-Tahrim",                verses: 12 },
        { n: 67,  name: "Al-Mulk",                  verses: 30 },
        { n: 68,  name: "Al-Qalam",                 verses: 52 },
        { n: 69,  name: "Al-Haqqah",                verses: 52 },
        { n: 70,  name: "Al-Ma'arij",               verses: 44 },
        { n: 71,  name: "Nuh",                      verses: 28 },
        { n: 72,  name: "Al-Jinn",                  verses: 28 },
        { n: 73,  name: "Al-Muzzammil",             verses: 20 },
        { n: 74,  name: "Al-Muddaththir",           verses: 56 },
        { n: 75,  name: "Al-Qiyamah",               verses: 40 },
        { n: 76,  name: "Al-Insan",                 verses: 31 },
        { n: 77,  name: "Al-Mursalat",              verses: 50 },
        { n: 78,  name: "An-Naba",                  verses: 40 },
        { n: 79,  name: "An-Nazi'at",               verses: 46 },
        { n: 80,  name: "Abasa",                    verses: 42 },
        { n: 81,  name: "At-Takwir",                verses: 29 },
        { n: 82,  name: "Al-Infitar",               verses: 19 },
        { n: 83,  name: "Al-Mutaffifin",            verses: 36 },
        { n: 84,  name: "Al-Inshiqaq",              verses: 25 },
        { n: 85,  name: "Al-Buruj",                 verses: 22 },
        { n: 86,  name: "At-Tariq",                 verses: 17 },
        { n: 87,  name: "Al-A'la",                  verses: 19 },
        { n: 88,  name: "Al-Ghashiyah",             verses: 26 },
        { n: 89,  name: "Al-Fajr",                  verses: 30 },
        { n: 90,  name: "Al-Balad",                 verses: 20 },
        { n: 91,  name: "Ash-Shams",                verses: 15 },
        { n: 92,  name: "Al-Layl",                  verses: 21 },
        { n: 93,  name: "Ad-Duha",                  verses: 11 },
        { n: 94,  name: "Ash-Sharh",                verses: 8 },
        { n: 95,  name: "At-Tin",                   verses: 8 },
        { n: 96,  name: "Al-Alaq",                  verses: 19 },
        { n: 97,  name: "Al-Qadr",                  verses: 5 },
        { n: 98,  name: "Al-Bayyinah",              verses: 8 },
        { n: 99,  name: "Az-Zalzalah",              verses: 8 },
        { n: 100, name: "Al-Adiyat",                verses: 11 },
        { n: 101, name: "Al-Qari'ah",               verses: 11 },
        { n: 102, name: "At-Takathur",              verses: 8 },
        { n: 103, name: "Al-Asr",                   verses: 3 },
        { n: 104, name: "Al-Humazah",               verses: 9 },
        { n: 105, name: "Al-Fil",                   verses: 5 },
        { n: 106, name: "Quraysh",                  verses: 4 },
        { n: 107, name: "Al-Ma'un",                 verses: 7 },
        { n: 108, name: "Al-Kawthar",               verses: 3 },
        { n: 109, name: "Al-Kafirun",               verses: 6 },
        { n: 110, name: "An-Nasr",                  verses: 3 },
        { n: 111, name: "Al-Masad",                 verses: 5 },
        { n: 112, name: "Al-Ikhlas",                verses: 4 },
        { n: 113, name: "Al-Falaq",                 verses: 5 },
        { n: 114, name: "An-Nas",                   verses: 6 }
    ]

    Process { id: mpvProcess; running: false }

    Process {
        id: mpvCmd1
        running: false
        stdout: SplitParser {
            onRead: line => {
                try {
                    var msg = JSON.parse(line)
                    if (msg.request_id === 1 && msg.data !== undefined)
                        quranPlayer.duration = msg.data
                    if (msg.request_id === 2 && msg.data !== undefined)
                        quranPlayer.position = msg.data
                    if (msg.event === "end-file") {
                        var curForNext = quranPlayer.currentSurah
                        var shouldAutoNext = quranPlayer.autoNext && curForNext > 0 && curForNext < 114
                        quranPlayer.playing = false
                        quranPlayer.position = 0
                        quranPlayer.loaded = false
                        quranPlayer.currentSurah = 0
                        if (shouldAutoNext) {
                            for (var i = 0; i < quranPlayer.surahs.length; i++) {
                                if (quranPlayer.surahs[i].n === curForNext) {
                                    quranPlayer.playSurah(quranPlayer.surahs[(i + 1) % quranPlayer.surahs.length].n)
                                    break
                                }
                            }
                        }
                    }
                } catch (e) {}
            }
        }
    }

    Process {
        id: mpvCmd2
        running: false
        stdout: SplitParser {
            onRead: line => {
                try {
                    var msg = JSON.parse(line)
                    if (msg.request_id === 1 && msg.data !== undefined)
                        quranPlayer.duration = msg.data
                    if (msg.request_id === 2 && msg.data !== undefined)
                        quranPlayer.position = msg.data
                } catch (e) {}
            }
        }
    }

    Timer {
        id: posPoll
        interval: 1000
        running: quranPlayer.playing && quranPlayer.loaded
        repeat: true
        onTriggered: {
            queryPosition()
            if (Math.abs(quranPlayer.position - quranPlayer.lastPosition) < 0.5 && quranPlayer.position > 1) {
                quranPlayer.positionStallCount++
            } else {
                quranPlayer.positionStallCount = 0
            }
            quranPlayer.lastPosition = quranPlayer.position
            if (quranPlayer.positionStallCount >= 3) {
                quranPlayer.positionStallCount = 0
                var curForNext = quranPlayer.currentSurah
                var shouldAutoNext = quranPlayer.autoNext && curForNext > 0 && curForNext < 114
                quranPlayer.playing = false
                quranPlayer.position = 0
                quranPlayer.loaded = false
                quranPlayer.currentSurah = 0
                if (shouldAutoNext) {
                    for (var i = 0; i < quranPlayer.surahs.length; i++) {
                        if (quranPlayer.surahs[i].n === curForNext) {
                            quranPlayer.playSurah(quranPlayer.surahs[(i + 1) % quranPlayer.surahs.length].n)
                            break
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: durationTimer
        interval: 1500
        onTriggered: queryDuration()
    }

    function surahName(n) {
        for (var i = 0; i < surahs.length; i++) {
            if (surahs[i].n === n) return surahs[i].name
        }
        return ""
    }

    function formatTime(s) {
        var m = Math.floor(s / 60)
        var sec = Math.floor(s % 60)
        return m + ":" + (sec < 10 ? "0" : "") + sec
    }

    function ipcCommand(cmd) {
        var proc = mpvCmd1.running ? mpvCmd2 : mpvCmd1
        proc.command = ["sh", "-c",
            "echo '" + JSON.stringify(cmd) + "' | timeout 2 nc -w 1 -U " + ipcSocket]
        proc.running = true
    }

    function queryDuration() { ipcCommand({"command":["get_property","duration"],"request_id":1}) }
    function queryPosition() { ipcCommand({"command":["get_property","time-pos"],"request_id":2}) }

    function seekTo(seconds) {
        ipcCommand({"command":["seek", seconds, "absolute"]})
        position = seconds
    }

    function reciterName() {
        if (barSettings.selectedReciter >= 0 && barSettings.selectedReciter < reciters.length)
            return reciters[barSettings.selectedReciter].name
        return ""
    }

    function playSurah(n) {
        stop()
        currentSurah = n
        playing = true
        var padded = String(n).padStart(3, '0')
        var baseUrl = reciters[barSettings.selectedReciter].server
        mpvProcess.command = ["mpv",
            "--no-video", "--really-quiet", "--no-terminal",
            "--keep-open=no", "--force-window=no", "--ytdl=no",
            "--cache=yes", "--demuxer-max-bytes=5MiB",
            "--input-ipc-server=" + ipcSocket,
            baseUrl + padded + ".mp3"]
        mpvProcess.running = true
        loaded = true
        durationTimer.start()
    }

    function togglePause() {
        if (!loaded) return
        ipcCommand({"command":["cycle","pause"]})
        playing = !playing
    }

    function stop() {
        mpvProcess.running = false
        playing = false
        loaded = false
        position = 0
        duration = 0
        positionStallCount = 0
        lastPosition = 0
        root.runCommand("rm -f " + ipcSocket)
    }

    function next() {
        for (var i = 0; i < surahs.length; i++) {
            if (surahs[i].n === currentSurah) {
                playSurah(surahs[(i + 1) % surahs.length].n)
                return
            }
        }
        playSurah(1)
    }

    function prev() {
        for (var i = 0; i < surahs.length; i++) {
            if (surahs[i].n === currentSurah) {
                playSurah(surahs[(i - 1 + surahs.length) % surahs.length].n)
                return
            }
        }
        playSurah(114)
    }

    function seekForward() {
        if (!loaded) return
        ipcCommand({"command":["seek",10,"relative"]})
        if (duration > 0) position = Math.min(position + 10, duration)
    }

    function seekBackward() {
        if (!loaded) return
        ipcCommand({"command":["seek",-10,"relative"]})
        position = Math.max(position - 10, 0)
    }

    function toggleMinimize() { minimized = !minimized }

    function selectReciter(index) {
        if (index === barSettings.selectedReciter) return
        var wasPlaying = playing
        var curSurah = currentSurah
        stop()
        barSettings.selectedReciter = index
        if (wasPlaying && curSurah > 0) playSurah(curSurah)
    }
}
