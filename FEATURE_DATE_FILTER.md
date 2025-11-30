# Date Range Filter for Waste History

## Quick Implementation

Add a filter button to AppBar that opens a date range picker. Filter waste entries by selected date range.

### Steps:
1. Add filter icon button to AppBar
2. Show date range picker dialog
3. Filter entries by date range
4. Display active filter indicator

### Code changes needed:
- Add `startDate` and `endDate` to state or use local state
- Filter entries list based on date range
- Add clear filter option

This is a simple implementation using Flutter's built-in `showDateRangePicker`.
