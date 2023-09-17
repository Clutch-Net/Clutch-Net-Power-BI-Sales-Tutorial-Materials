// CustomerProductBridge for Clutch.Net Tutorial & Demo - Tom Sampson © Clutch.Net 2023
// free to use under the MIT License. See project LICENSE for more details.

let
    // Load data from the Excel file
    Source = Excel.Workbook(
        File.Contents("D:\GitHub\BI Projects\Clutch Net Power BI Sales Tutorial Materials\Clutch-Net-Power-BI-Sales-Tutorial-Materials\Sample Company Data.xlsx"), 
        null, 
        true
    ),
    
    // Select the 'Sales' sheet
    Sales_Sheet = Source{[Item="Sales",Kind="Sheet"]}[Data],
    
    // Promote the first row as headers
    PromotedHeaders = Table.PromoteHeaders(Sales_Sheet, [PromoteAllScalars=true]),
    
    // Only select the columns we need
    SelectedColumns = Table.SelectColumns(PromotedHeaders,{"CustomerKey", "ProductKey"}),
    
    // Transform types of the columns to integer
    ChangedTypes = Table.TransformColumnTypes(SelectedColumns, {{"CustomerKey", Int64.Type}, {"ProductKey", Int64.Type}}),
    
    // Remove duplicate rows to get distinct combinations of CustomerKey and ProductKey
    RemovedDuplicates = Table.Distinct(ChangedTypes)
    
in
    RemovedDuplicates