// SalesPivot + 20 years for Clutch.Net tutorial and demo - Tom Sampson © Clutch.Net 2023
// free to use under the MIT License. See project LICENSE for more details.

let
    // Load the Sales data from the Excel file
    Source = Excel.Workbook(File.Contents("D:\GitHub\BI Projects\Clutch Net Power BI Sales Tutorial Materials\Clutch-Net-Power-BI-Sales-Tutorial-Materials\Data\Sample Company Data.xlsx"), null, true),
    
    SalesData = Source{[Item="Sales",Kind="Sheet"]}[Data],

    // Promote headers
    PromotedHeaders = Table.PromoteHeaders(SalesData, [PromoteAllScalars=true]),

    // Adjust the OrderDate by adding 20 years
    AdjustedDate = Table.TransformColumns(PromotedHeaders, {"OrderDate", each Date.AddYears(_, 20)}),

    // Add DateKey column based on the Adjusted OrderDate. This is an integer version of the date
    DateKey = Table.AddColumn(
        AdjustedDate, 
        "DateKey", 
        each Text.From(Date.Year([OrderDate])) & Text.End(Text.PadStart(Text.From(Date.Month([OrderDate]), "en-US"), 2, "0"), 2) & Text.End(Text.PadStart(Text.From(Date.Day([OrderDate]), "en-US"), 2, "0"), 2)
    ),

    // Ensure CustomerKey and DateKey are in text format for concatenation
    TextCustomerOrderKey = Table.TransformColumnTypes(
        DateKey, 
        {{"CustomerKey", type text}, {"DateKey", type text}}
    ),

    // Add CustomerDateKey column by concatenating CustomerKey and DateKey
    CustomerDateKey = Table.AddColumn(
        TextCustomerOrderKey, 
        "CustomerDateKey", 
        each Text.From([CustomerKey]) & Text.From([DateKey])
    ),

    // Convert the concatenated columns to whole numbers and the OrderDate to Date
    NumericKeys = Table.TransformColumnTypes(
        CustomerDateKey, {
            {"CustomerKey", Int64.Type},
            {"DateKey", Int64.Type},
            {"OrderDate", type date}
        }
    ),

    // Remove unnecessary columns
    #"Removed Columns" = Table.RemoveColumns(
        NumericKeys,
        {"ProductKey", "SalesTerritoryKey", "SalesOrderNumber", "SalesOrderLineNumber", "OrderQuantity", "DiscountAmount", "ProductStandardCost", "SalesAmount", "Territories.Region", "Territories.Country", "Territories.Continent"}
    ),

    // Keep only a distinct set of rows and sort them
    #"Removed Duplicates" = Table.Distinct(#"Removed Columns"),
    #"Sorted Rows" = Table.Sort(#"Removed Duplicates",{{"CustomerKey", Order.Ascending}, {"DateKey", Order.Ascending}}),

    // Reorder columns
    #"Reordered Columns" = Table.ReorderColumns(#"Sorted Rows",{"CustomerKey", "OrderDate", "CustomerDateKey"})
    
in
    #"Reordered Columns"