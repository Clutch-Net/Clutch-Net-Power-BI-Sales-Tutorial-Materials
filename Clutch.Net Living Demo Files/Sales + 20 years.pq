// Sales + 20 years for Clutch.Net Tutorial & Demo - Tom Sampson © Clutch.Net 2023
// free to use under the MIT License. See project LICENSE for more details.
let
    // Load the Sales data from the Excel file
    Source = Excel.Workbook(File.Contents("D:\GitHub\BI Projects\Clutch Net Power BI Sales Tutorial Materials\Clutch-Net-Power-BI-Sales-Tutorial-Materials\Data\Sample Company Data.xlsx"), null, true),
    SalesData = Source{[Item="Sales",Kind="Sheet"]}[Data],

    // Promote headers
    PromotedHeaders = Table.PromoteHeaders(SalesData, [PromoteAllScalars=true]),

    // Split SalesOrderNumber column based on position
    SplitOrderNumber = Table.SplitColumn(PromotedHeaders, "SalesOrderNumber", Splitter.SplitTextByPositions({0, 2}, false), {"OrderPrefix", "OrderKey"}),
    RemovedOrderPrefix = Table.RemoveColumns(SplitOrderNumber, {"OrderPrefix"}),

    // Add CustomerOrderKey column by concatenating CustomerKey and OrderKey
    AddedCustomerOrderKey = Table.AddColumn(RemovedOrderPrefix, "CustomerOrderKey", each Text.From([CustomerKey]) & Text.From([OrderKey])),

    // Set column types for specified columns
    TypedColumns = Table.TransformColumnTypes(AddedCustomerOrderKey, {
        {"OrderKey", Int64.Type},
        {"ProductKey", Int64.Type},
        {"SalesTerritoryKey", Int64.Type},
        {"SalesOrderLineNumber", Int64.Type},
        {"OrderQuantity", Int64.Type},
        {"DiscountAmount", Int64.Type},
        {"OrderDate", type date},
        {"CustomerKey", Int64.Type},
        {"ProductStandardCost", type number},
        {"SalesAmount", type number}
    }),

    // Add 20 years to OrderDate
    ExtendedDate = Table.TransformColumns(TypedColumns, {"OrderDate", each Date.AddYears(_, 20)}),

    // Filter rows where OrderDate <= today's date
    FilteredRows = Table.SelectRows(ExtendedDate, each [OrderDate] <= DateTime.Date(DateTime.LocalNow())),

    // Add DateKey column based on the OrderDate
    DateKey = Table.AddColumn(FilteredRows, "DateKey", each Text.From(Date.Year([OrderDate])) & Text.End(Text.PadStart(Text.From(Date.Month([OrderDate]), "en-US"), 2, "0"), 2) & Text.End(Text.PadStart(Text.From(Date.Day([OrderDate]), "en-US"), 2, "0"), 2)),
    TypedDateKey = Table.TransformColumnTypes(DateKey, {{"DateKey", Int64.Type}}),

    // Add CustomerDateKey column by concatenating CustomerKey and OrderDateKey
    CustomerDateKey = Table.AddColumn(TypedDateKey, "CustomerDateKey", each Text.From([CustomerKey]) & Text.From([DateKey])),
    
    // Ensure CustomerOrderKey is a text column for concatenation
    TextCustomerOrderKey = Table.TransformColumnTypes(CustomerDateKey, {{"CustomerOrderKey", type text}, {"CustomerDateKey", type text}}),

    // Concatenate "1" to the end of CustomerOrderKey and CustomerDateKey
    ConcatenateKeys = Table.TransformColumns(TextCustomerOrderKey, {
        {"CustomerOrderKey", each _ & "1", type text},
        {"CustomerDateKey", each _ & "1", type text}
    }),

    // Convert the concatenated columns back to whole numbers
    NumericKeys = Table.TransformColumnTypes(ConcatenateKeys, {
        {"CustomerOrderKey", Int64.Type},
        {"CustomerDateKey", Int64.Type}
    }),

    // Rename columns for better readability
    RenamedColumns = Table.RenameColumns(NumericKeys,{{"Territories.Region", "Region"}, {"Territories.Country", "Country"}, {"Territories.Continent", "Continent"}})
in
    RenamedColumns