// Products + 20 years for Clutch.Net Tutorial & Demo - Tom Sampson © Clutch.Net 2023
// free to use under the MIT License. See project LICENSE for more details.

let
    // Load data from the Excel file
    Source = Excel.Workbook(
        File.Contents("D:\GitHub\BI Projects\Clutch Net Power BI Sales Tutorial Materials\Clutch-Net-Power-BI-Sales-Tutorial-Materials\Sample Company Data.xlsx"), 
        null, 
        true
    ),
    
    // Select the 'Products' sheet
    Products_Sheet = Source{[Item="Products",Kind="Sheet"]}[Data],
    
    // Promote the first row as headers
    #"Promoted Headers" = Table.PromoteHeaders(Products_Sheet, [PromoteAllScalars=true]),
    
    // Change column types
    #"Changed Type" = Table.TransformColumnTypes(
        #"Promoted Headers",
        {
            {"ProductKey", Int64.Type}, {"EnglishProductName", type text}, {"StandardCost", type number}, 
            {"FinishedGoodsFlag", type logical}, {"Color", type text}, {"ListPrice", type number}, 
            {"Size", type text}, {"ProductLine", type text}, {"DealerPrice", type number}, 
            {"Class", type text}, {"Style", type text}, {"ModelName", type text}, 
            {"StartDate", type datetime}, {"EndDate", type datetime}, {"Status", type text}, 
            {"Subcategory", type text}
        }
    ),
    
    // Reorder columns for better readability
    #"Reordered Columns" = Table.ReorderColumns(
        #"Changed Type",
        {"ProductKey", "Subcategory", "EnglishProductName", "StandardCost", "FinishedGoodsFlag", 
         "Color", "ListPrice", "Size", "ProductLine", "DealerPrice", "Class", "Style", 
         "ModelName", "StartDate", "EndDate", "Status"}
    ),
    
    // Trim text columns to remove unwanted spaces
    #"Trimmed Text" = Table.TransformColumns(
        #"Reordered Columns",
        {
            {"Size", Text.Trim, type text}, {"ProductLine", Text.Trim, type text}, 
            {"Class", Text.Trim, type text}, {"Style", Text.Trim, type text}, 
            {"ModelName", Text.Trim, type text}
        }
    ),
    
    // Convert 'StartDate' from datetime to date type
    #"Changed Type1" = Table.TransformColumnTypes(#"Trimmed Text",{{"StartDate", type date}}),
    
    // Extract only the date from 'EndDate'
    #"Extracted Date" = Table.TransformColumns(#"Changed Type1",{{"EndDate", DateTime.Date, type date}}),
    
    // Trim 'Status' column
    #"Trimmed Text1" = Table.TransformColumns(#"Extracted Date",{{"Status", Text.Trim, type text}}),
    
    // Rename the 'EnglishProductName' column
    #"Renamed Columns" = Table.RenameColumns(#"Trimmed Text1",{{"EnglishProductName", "ProductName"}}),
    
    // Rename original date columns for later adjustments
    #"Renamed Columns1" = Table.RenameColumns(#"Renamed Columns",{{"StartDate", "StartDate_orig"}, {"EndDate", "EndDate_orig"}}),
    
    // Add 20 years to the original 'StartDate'
    #"Added Custom" = Table.AddColumn(#"Renamed Columns1", "StartDate", each Date.AddYears([StartDate_orig], 20)),
    
    // Add 20 years to the original 'EndDate'
    #"Added Custom1" = Table.AddColumn(#"Added Custom", "EndDate", each Date.AddYears([EndDate_orig], 20)),
    
    // Remove original date columns
    #"Removed Columns" = Table.RemoveColumns(#"Added Custom1",{"StartDate_orig", "EndDate_orig"}),
    
    // Filter out products with future 'StartDate'
    #"Filtered Future Dates" = Table.SelectRows(#"Removed Columns", each [StartDate] <= Date.From(DateTime.LocalNow())),
    
    // Adjust 'StartDate' and 'EndDate' types
    #"Changed Type2" = Table.TransformColumnTypes(#"Filtered Future Dates",{{"StartDate", type date}, {"EndDate", type date}}),
    
    // Rename 'Status' column for status calculation
    #"Renamed Columns2" = Table.RenameColumns(#"Changed Type2",{{"Status", "Status_orig"}}),
    
    // Calculate 'Status' based on 'StartDate' and 'EndDate'
    #"Added Custom2" = Table.AddColumn(#"Renamed Columns2", "Status", each 
        if [StartDate] <= Date.From(DateTime.LocalNow()) and ([EndDate] = null or [EndDate] > Date.From(DateTime.LocalNow())) 
        then "Current" 
        else null
    ),
    
    // Convert 'Status' column to text
    #"Changed Type3" = Table.TransformColumnTypes(#"Added Custom2",{{"Status", type text}}),
    
    // Remove the original 'Status' column
    #"Removed Columns1" = Table.RemoveColumns(#"Changed Type3",{"Status_orig"})
in
    #"Removed Columns1"
