# 15171.info
#### now whats it all about
it's a simple... eine einfache logbuch app, die eingaben in 9 frei definierbare textfelder erlaubt, diese in einem log view chronologisch abwärts sortiert auflistet und in einem search view die einträge nach regulären ausdrücken filtert. es können einträge aus einer externen sqlite datenbank importiert werden (9 textfelder named field1-9, 1 datetime feld named timestamp, 1 id feld named id) und auch alle vorhergehenden einträge der datenbank gelöscht werden. die app wird standardmäßig in iCloud über alle angemeldeten iOS geräte synchronisiert.

#### todo
- frei definierbare anzahl felder (derzeit 9)
- erstellung weiterer logbücher in der datenbank
- field label anzeige im log view
- cluster abbildung der suchergebnisse
- sample log datenbank as entry situation

#### help bites

1.    if you want to customize (you dont have to, but you probably want to have your own field names instead of the default) the field labels (which is the names of the input fields displayed in the input view), stick to the placeholder scheme which is showing if you open the \<configure field labels> view. 
that means you must insert your field names as a comma separated string i.e. all fieldnames, separated by comma, into the change-label input mask. no blankspace / whitespace / tab between the commata. just the labels like `label1,label2,label3,label4,label5,label6,label7,label8,label9`. as you will have 9 input fields in your log input view you better insert 9 labels accordingly, else a missing label (if you would insert 7 instead of 9 commaseparated labels) will get a default name.   
2. in the search view you will be querying you log with **regular expressions**. thats a common but powerful method of searching text. you can not use just a comma if you want to query for multiple expressions (words) like you would with ggooggle. instead you would to find log entries containing the words **temperature** or **wind** use a query like `temperature|wind` where the dash functions as an OR operator. if you want to find entries containing both expressions it's more complicated, but with regex nearly all is possible. see [here e.g.](https://regexr.com) for a complete regex review on how to use it for queries. (i assume this is definitely an issue so i will break up the regex search into readymade queries in a future build.)

#### features
one wonderful thing is, that in the logview all words that you inserted as a #hashtag will appear blue. that took me bit to realise but i find it very beautiful in the log view...