// Generic Power BI Calendar with selective start date - Tom Sampson © Clutch.Net 2023
// free to use under the MIT License. See project LICENSE for more details.
// v 1.1 - 20230910 - Tom S - Added MonthYear text version, in your model use the date version to sort
// v 1.2 - 20230917 - Tom S - Added configurable fiscal date choices
let
    Source = Sales, // Change this to your source
    MinDate = Date.From(Date.StartOfYear(List.Min(Source[OrderDate]))), // Change this to your source column, the calendar coverage will be based on this
    EndDate = Date.From(List.Max(Source[OrderDate])), // this column choice should match the one you made on the line above
    AllDates = List.Dates(MinDate, Duration.Days(EndDate - MinDate) + 1, #duration(1, 0, 0, 0)),
    // Add a parameter for the fiscal year start month.
    // Set this based on your choice:
    // 1 for January (most U.S. companies)
    // 4 for April (U.K. and Japan)
    // 7 for July (for countries like Australia and the start of the federal government's fiscal year in Canada)
    // 10 for October (In the U.S., the federal government's fiscal year starts on October 1st and ends on September 30th)
    FiscalStartMonth = 1, // change this based on your choice
    InitialTable = Table.FromList(AllDates, Splitter.SplitByNothing()),
    RenamedTable = Table.RenameColumns(InitialTable,{{"Column1", "CalendarDate"}}),
    AddYear = Table.AddColumn(RenamedTable, "Year", each Date.Year([CalendarDate]), Int64.Type),
    AddQuarter = Table.AddColumn(AddYear, "Quarter", each Date.QuarterOfYear([CalendarDate]), Int64.Type),
    AddMonth = Table.AddColumn(AddQuarter, "Month", each Date.Month([CalendarDate]), Int64.Type),
    AddPeriod = Table.AddColumn(AddMonth, "Period", each Date.Month([CalendarDate]), Int64.Type),
    AddDay = Table.AddColumn(AddPeriod, "Day", each Date.Day([CalendarDate]), Int64.Type),
    AddWeekNumber = Table.AddColumn(AddDay, "WeekNumber", each Date.WeekOfYear([CalendarDate]), Int64.Type),
    AddWeekDay = Table.AddColumn(AddWeekNumber, "WeekDay", each Date.DayOfWeek([CalendarDate]) + 1, Int64.Type),
    AddMonthName = Table.AddColumn(AddWeekDay, "MonthName", each Date.ToText([CalendarDate], "MMMM"), Text.Type),
    AddDayName = Table.AddColumn(AddMonthName, "DayName", each Date.ToText([CalendarDate], "dddd"), Text.Type),
    AddDayOfYear = Table.AddColumn(AddDayName, "DayOfYear", each Date.DayOfYear([CalendarDate]), Int64.Type),
    AddIsWeekend = Table.AddColumn(AddDayOfYear, "IsWeekend", each if Date.DayOfWeek([CalendarDate], Day.Monday) >= 5 then "Weekend" else "Weekday", Text.Type),
    AddRelativeDate = Table.AddColumn(AddIsWeekend, "RelativeDate", each Duration.Days([CalendarDate] - EndDate), Int64.Type),
    AddRelativePeriod = Table.AddColumn(AddRelativeDate, "RelativePeriod", each -(Date.Year([CalendarDate])*12 + Date.Month([CalendarDate]) - (Date.Year(EndDate)*12 + Date.Month(EndDate)) ) * -1, Int64.Type),
    AddDateKey = Table.AddColumn(AddRelativePeriod, "DateKey", each [Year]*10000 + [Month]*100 + [Day], Int64.Type),
    AddPPDate = Table.AddColumn(AddDateKey, "PPDate", each Date.AddMonths([CalendarDate], -1), Date.Type),
    AddPQDate = Table.AddColumn(AddPPDate, "PQDate", each Date.AddQuarters([CalendarDate], -1), Date.Type),
    AddPriorPeriodYear = Table.AddColumn(AddPQDate, "PriorPeriodYear", each Date.Year(Date.AddMonths([CalendarDate], -1)), Int64.Type),
    AddPYDate = Table.AddColumn(AddPriorPeriodYear, "PYDate", each Date.AddYears([CalendarDate], -1), Date.Type),
    AddMonthYear = Table.AddColumn(AddPYDate, "MonthYear", each Text.Start(Date.MonthName([CalendarDate]),3) & " " & Text.End(Text.From(Date.Year([CalendarDate])),2)),  
    IntermediateTable = Table.AddColumn(AddMonthYear, "MonthYearDate", each #date(Date.Year([CalendarDate]), Date.Month([CalendarDate]), 1)),
    AddMonthYearDate = Table.TransformColumnTypes(IntermediateTable,{{"MonthYearDate", type date}}),
    //Fiscal Dates
    AddFiscalDate = Table.AddColumn(AddMonthYearDate, "FiscalDate", each 
        if Date.Month([CalendarDate]) < FiscalStartMonth then Date.AddYears([CalendarDate], -1) else [CalendarDate], Date.Type),
    AddFiscalYear = Table.AddColumn(AddFiscalDate, "FiscalYear", each Date.Year([FiscalDate]), Int64.Type),
    AddFiscalQuarter = Table.AddColumn(AddFiscalYear, "FiscalQuarter", each 
        let 
            monthDiff = Date.Month([FiscalDate]) - FiscalStartMonth,
            adjustedMonthDiff = if monthDiff < 0 then monthDiff + 12 else monthDiff
        in 
            Number.RoundDown(adjustedMonthDiff / 3) + 1, Int64.Type),
    AddFiscalPeriod = Table.AddColumn(AddFiscalQuarter, "FiscalPeriod", each 
        let 
            monthDiff = Date.Month([FiscalDate]) - FiscalStartMonth,
            adjustedMonthDiff = if monthDiff < 0 then monthDiff + 12 else monthDiff
        in 
            adjustedMonthDiff + 1, Int64.Type),
    AddFiscalPPDate = Table.AddColumn(AddFiscalPeriod, "FiscalPPDate", each Date.AddMonths([FiscalDate], -1), Date.Type),
    AddFiscalPQDate = Table.AddColumn(AddFiscalPPDate, "FiscalPQDate", each Date.AddQuarters([FiscalDate], -1), Date.Type),
    AddFiscalPriorPeriodYear = Table.AddColumn(AddFiscalPQDate, "FiscalPriorPeriodYear", each Date.Year([FiscalPPDate]), Int64.Type),
    AddFiscalPYDate = Table.AddColumn(AddFiscalPriorPeriodYear, "FiscalPYDate", each 
        Date.AddYears([FiscalDate], -1), Date.Type),    
    FinalTable = Table.TransformColumnTypes(AddFiscalPYDate,{{"CalendarDate", type date}, {"FiscalPYDate", type date}})
in
    FinalTable