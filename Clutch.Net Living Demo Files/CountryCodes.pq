// CountryCodes for Clutch.Net Tutorial & Demo - Tom Sampson © Clutch.Net 2023
// free to use under the MIT License. See project LICENSE for more details.

let
    Source = #table({"Country", "Code"}, 
    {
        {"Australia", "AU"},
        {"Canada", "CA"},
        {"France", "FR"},
        {"Germany", "DE"},
        {"United Kingdom", "GB"},
        {"United States", "US"}
    }),
    #"Added FlagIconURL" = Table.AddColumn(Source, "FlagIconURL", each "https://clutch.net/flags/icons/" & [Code] & ".png"),
    #"Added FlagSmallURL" = Table.AddColumn(#"Added FlagIconURL", "FlagSmallURL", each "https://clutch.net/flags/small/" & [Code] & ".png")
in
    #"Added FlagSmallURL"