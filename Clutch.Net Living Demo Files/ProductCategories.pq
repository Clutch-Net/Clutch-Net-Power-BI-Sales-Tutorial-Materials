// ProductCategories for Clutch.Net Tutorial & Demo - Tom Sampson © Clutch.Net 2023
// Free to use under the MIT License. See project LICENSE for more details.

let
    // Load data from the Excel file
    Source = Excel.Workbook(File.Contents("D:\GitHub\BI Projects\Clutch Net Power BI Sales Tutorial Materials\Clutch-Net-Power-BI-Sales-Tutorial-Materials\Data\Sample Company Data.xlsx"), null, true),
    
    // Select the 'ProductCategories' sheet
    ProductCategories_Sheet = Source{[Item="ProductCategories",Kind="Sheet"]}[Data],
    
    // Initially set data types for the loaded columns
    ChangedType = Table.TransformColumnTypes(
        ProductCategories_Sheet,
        {
            {"Column1", type text},
            {"Column2", type text}
        }
    ),
    
    // Promote the first row as headers
    PromotedHeaders = Table.PromoteHeaders(ChangedType, [PromoteAllScalars=true]),
    
    // Correctly set the data types of the newly promoted headers
    ChangedType1 = Table.TransformColumnTypes(
        PromotedHeaders,
        {
            {"Subcategory", type text},
            {"Category", type text}
        }
    )
    
in
    ChangedType1