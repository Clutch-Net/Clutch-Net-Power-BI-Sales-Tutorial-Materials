// Customer + 20 years for Clutch.Net Tutorial & Demo - Tom Sampson © Clutch.Net 2023
// free to use under the MIT License. See project LICENSE for more details.
let
    Source = Excel.Workbook(File.Contents("E:\Diabolical Test.xlsx"), null, true),
    Customers_Sheet = Source{[Item="Customers",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Customers_Sheet, [PromoteAllScalars=true]),
    #"Adjusted BirthDate" = Table.TransformColumns(#"Promoted Headers", {"BirthDate", each Date.AddYears(_, 20)}),
    #"Adjusted DateFirstPurchase" = Table.TransformColumns(#"Adjusted BirthDate", {"DateFirstPurchase", each Date.AddYears(_, 20)}),
    #"Changed Type" = Table.TransformColumnTypes(#"Adjusted DateFirstPurchase", {
        {"CustomerKey", Int64.Type}, {"AltCustomerKey", Int64.Type}, {"FirstName", type text}, 
        {"LastName", type text}, {"BirthDate", type date}, {"MaritalStatus", type text}, 
        {"Gender", type text}, {"EmailAddress", type text}, {"YearlyIncome", Int64.Type}, 
        {"TotalChildren", Int64.Type}, {"EnglishEducation", type text}, {"EnglishOccupation", type text}, 
        {"HouseOwnerFlag", Int64.Type}, {"NumberCarsOwned", Int64.Type}, {"AddressLine1", type text}, 
        {"DateFirstPurchase", type date}, {"CommuteDistance", type text}
    }),
    #"Trimmed Text" = Table.TransformColumns(#"Changed Type", {
        {"MaritalStatus", Text.Trim, type text}, {"Gender", Text.Trim, type text}, 
        {"EmailAddress", Text.Trim, type text}, {"EnglishEducation", Text.Trim, type text}, 
        {"EnglishOccupation", Text.Trim, type text}, {"AddressLine1", Text.Trim, type text}, 
        {"CommuteDistance", Text.Trim, type text}
    }),
    #"Renamed Columns" = Table.RenameColumns(#"Trimmed Text", {
        {"EnglishEducation", "Education"}, {"EnglishOccupation", "Occupation"}, {"CustomerKey", "CustomerKey_orig"}
    }),
    #"Added Custom" = Table.AddColumn(#"Renamed Columns", "CustomerKey", each 
        if [CustomerKey_orig] < [AltCustomerKey] then [CustomerKey_orig] else [AltCustomerKey]
    ),
    #"Changed Type Final" = Table.TransformColumnTypes(#"Added Custom", {{"CustomerKey", Int64.Type}}),
    #"Removed Columns" = Table.RemoveColumns(#"Changed Type Final",{"AltCustomerKey", "CustomerKey_orig"})
in
    #"Removed Columns"