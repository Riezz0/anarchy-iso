// ═══════════════════════════════════════════════════════════════════════════════
// Calendar Module - Date Navigation Helpers
// ═══════════════════════════════════════════════════════════════════════════════
// Provides calendar date navigation and helper functions for the calendar popup.
//
// Usage in shell.qml:
//   Calendar { id: calendar }
//   calendar.calendarDate       // Current selected date
//   calendar.calendarMonthName() // "June 2026"
//   calendar.prevMonth()        // Navigate to previous month
//   calendar.nextMonth()        // Navigate to next month
//   calendar.goToToday()        // Jump to today
//   calendar.daysInMonth(y, m)  // Days in given month
//   calendar.firstDayOfMonth(y, m) // Day-of-week of first day
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick

Item {
    id: calendarRoot

    // ═══════════════════════════════════════════════════════════════════════════
    // Properties
    // ═══════════════════════════════════════════════════════════════════════════

    property var calendarDate: new Date()

    // ═══════════════════════════════════════════════════════════════════════════
    // Functions
    // ═══════════════════════════════════════════════════════════════════════════

    /// Returns the number of days in the given month (0-indexed)
    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }

    /// Returns the day-of-week (0=Sunday) for the first day of the given month
    function firstDayOfMonth(year, month) {
        return new Date(year, month, 1).getDay()
    }

    /// Returns the month and year as a display string (e.g. "June 2026")
    function calendarMonthName() {
        const months = ["January", "February", "March", "April", "May", "June",
                        "July", "August", "September", "October", "November", "December"]
        return months[calendarDate.getMonth()] + " " + calendarDate.getFullYear()
    }

    /// Navigate to the previous month
    function prevMonth() {
        var d = new Date(calendarDate)
        d.setMonth(d.getMonth() - 1)
        calendarDate = d
    }

    /// Navigate to the next month
    function nextMonth() {
        var d = new Date(calendarDate)
        d.setMonth(d.getMonth() + 1)
        calendarDate = d
    }

    /// Jump to today's date
    function goToToday() {
        calendarDate = new Date()
    }
}