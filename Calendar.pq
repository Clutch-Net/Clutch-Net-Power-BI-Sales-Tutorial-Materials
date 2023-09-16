// Generic Power BI Calendar with selective start date - Tom Sampson © Clutch.Net 2023
// free to use under the MIT License. See project LICENSE for more details.
// v 1.1 - Added MonthYear text version, in your model use the date version to sort
let
    Source = YourSourceTable, // Change to desired source
    MinDate = Date.From(Date.StartOfYear(List.Min(Source[YourDateColumn]))), // Change this to date that will determine the start of your calendar
    EndDate = Date.From(List.Max(Source[YourDateColumn])), // ...and end date year, so you will get the remaining dates in the year of the final record
    AllDates = List.Dates(MinDate, Duration.Days(EndDate - MinDate) + 1, #duration(1, 0, 0, 0)),
    
    InitialTable = Table.FromList(AllDates, Splitter.SplitByNothing()),
    RenamedTable = Table.RenameColumns(InitialTable,{{"Column1", "CalendarDate"}}),
    
    AddYear = Table.AddColumn(RenamedTable, "Year", each Date.Year([CalendarDate]), Int64.Type),
    AddQuarter = Table.AddColumn(AddYear, "Quarter", each Date.QuarterOfYear([CalendarDate]), Int64.Type),
    AddMonth = Table.AddColumn(AddQuarter, "Month", each Date.Month([CalendarDate]), Int64.Type),
    AddDay = Table.AddColumn(AddMonth, "Day", each Date.Day([CalendarDate]), Int64.Type),
    AddWeekNumber = Table.AddColumn(AddDay, "WeekNumber", each Date.WeekOfYear([CalendarDate]), Int64.Type),
    AddWeekDay = Table.AddColumn(AddWeekNumber, "WeekDay", each Date.DayOfWeek([CalendarDate]) + 1, Int64.Type),
    AddMonthName = Table.AddColumn(AddWeekDay, "MonthName", each Date.ToText([CalendarDate], "MMMM"), Text.Type),
    AddDayName = Table.AddColumn(AddMonthName, "DayName", each Date.ToText([CalendarDate], "dddd"), Text.Type),
    AddDayOfYear = Table.AddColumn(AddDayName, "DayOfYear", each Date.DayOfYear([CalendarDate]), Int64.Type),
    AddIsWeekend = Table.AddColumn(AddDayOfYear, "IsWeekend", each if Date.DayOfWeek([CalendarDate], Day.Monday) >= 5 then "Weekend" else "Weekday", Text.Type),
    AddRelativeDate = Table.AddColumn(AddIsWeekend, "RelativeDate", each Duration.Days([CalendarDate] - EndDate), Int64.Type),
    AddRelativePeriod = Table.AddColumn(AddRelativeDate, "RelativePeriod", each -(Date.Year([CalendarDate])*12 + Date.Month([CalendarDate]) - (Date.Year(EndDate)*12 + Date.Month(EndDate)) ) * -1, Int64.Type),
    AddDateKey = Table.AddColumn(AddRelativePeriod, "DateKey", each [Year]*10000 + [Month]*100 + [Day], Int64.Type),
    AddFiscalPYDate = Table.AddColumn(AddDateKey, "FiscalPYDate", each Date.AddYears([CalendarDate], -1), Date.Type),
    AddFiscalYearNumber = Table.AddColumn(AddFiscalPYDate, "FiscalYearNumber", each [Year], Int64.Type),
    AddFiscalQuarterNumber = Table.AddColumn(AddFiscalYearNumber, "FiscalQuarterNumber", each [Quarter], Int64.Type),
    AddFiscalPeriodNumber = Table.AddColumn(AddFiscalQuarterNumber, "FiscalPeriodNumber", each [Month], Int64.Type),
    AddPeriodNum = Table.AddColumn(AddFiscalPeriodNumber, "PeriodNum", each [Month], Int64.Type),
    AddFiscalPPDate = Table.AddColumn(AddPeriodNum, "FiscalPPDate", each Date.AddMonths([CalendarDate], -1), Date.Type),
    AddFiscalPQDate = Table.AddColumn(AddFiscalPPDate, "FiscalPQDate", each Date.AddQuarters([CalendarDate], -1), Date.Type),
    AddFiscalPriorPeriodYearNumber = Table.AddColumn(AddFiscalPQDate, "FiscalPriorPeriodYearNumber", each Date.Year([FiscalPPDate]), Int64.Type),
    AddMonthYear = Table.AddColumn(AddFiscalPriorPeriodYearNumber, "MonthYear", each Text.Start(Date.MonthName([CalendarDate]),3) & " " & Text.End(Text.From(Date.Year([CalendarDate])),2)),
    AddYearQuarter = Table.AddColumn(AddMonthYear, "YearQuarter", each Text.From(Date.Year([CalendarDate])) & " Q" & Text.From(Date.QuarterOfYear([CalendarDate]))),
    AddMonthYearDate = Table.AddColumn(AddYearQuarter, "MonthYearDate", each #date(Date.Year([CalendarDate]), Date.Month([CalendarDate]), 1)),
    
    FinalTable = Table.TransformColumnTypes(AddMonthYearDate,{{"CalendarDate", type date}, {"MonthYearDate", type date}})
    
in
    FinalTable
