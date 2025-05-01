# 15171.info
#### now whats it all about
it's a simple... eine einfache logbuch app, die eingaben in 9 frei definierbare textfelder erlaubt, diese in einem log view chronologisch abwärts sortiert auflistet und in einem search view die einträge nach regulären ausdrücken filtert. es können einträge aus einer externen sqlite datenbank importiert werden (9 textfelder named field1-9, 1 datetime feld named timestamp, 1 id feld named id) und auch alle vorhergehenden einträge der datenbank gelöscht werden. die app wird standardmäßig in iCloud über alle angemeldeten iOS geräte synchronisiert.

#### pourquoi?
c'est simplement qc j'aimerais bien d'avoir. donc, il y a.

#### general
as tester please check de temps en temps for available update builds in your TestFlight app as i am not sending out messages if a new version/build is available.   
und: natürlich ist es müszig, darauf hinzuweisen, dasz kein log view möglich ist, solange keine einträge in der datenbank sind, dh. da noch keine sample datenbank integriert ist seht ihr auch nicht, was so geht und müsst eben fröhlich posten, damit überhaupt was sichtbar wird...


#### todo
- frei definierbare anzahl felder (derzeit 9)
- erstellung weiterer logbücher in der datenbank
- field label anzeige im log view
- cluster abbildung der suchergebnisse
- sample log datenbank as entree situation
- display links as clickable elements in log view
- make content of log view selectable (able to copy from view)
- filter search after fields
- export log (csv, sqlite, text/pdf)
- !preserve uncommitted field input during session if change view while input i.e. restore input if change from input to log view and back

#### help bites

1.    if you want to customize (you dont have to, but you probably want to have your own field names instead of the default) the field labels (which is the names of the input fields displayed in the input view), stick to the placeholder scheme which is showing if you open the \<configure field labels> view. 
that means you must insert your field names as a comma separated string i.e. all fieldnames, separated by comma, into the change-label input mask. no blankspace / whitespace / tab between the commata. just the labels like `label1,label2,label3,label4,label5,label6,label7,label8,label9`. as you will have 9 input fields in your log input view you better insert 9 labels accordingly, else a missing label (if you would insert 7 instead of 9 commaseparated labels) will get a default name.   
2. in the search view you will be querying your log with **regular expressions**. thats a common but powerful method of searching text. you can't use just a comma/+ if you want to query for multiple expressions (words) like you would with ggooggle. instead you would to find log entries containing the words **temperature** or **wind** use a query like `temperature|wind` where the dash functions as an OR operator. if you want to find entries containing both expressions it's more complicated, but with regex nearly all is possible. see [here e.g.](https://regexr.com) for a short regex reference & cheatsheet on how to use it for queries. (i assume this is definitely an issue so i will break up the regex search into readymade queries in a future build.)

#### features
1 fine thing is, that in the logview all words that you inserted as a #hashtag will appear blue. that took me bit to realise but i find it very beautiful in the log view...

#### development history
**1.0.1 first (internal test) build:** input/display/search log.   
**0.0.2 first beta (external test) build:** settings screen wt import db, customise labels, flush db options.   
**1.0.2 beta (adapted version number):** included this about page with help bites.  
**1.0.2(4):** included app version display and app update check.  
**1.0.2(6):** improved search view to not display entries if search pattern is empty.   
**1.0.2(8):** added little helper to *edit field label view*. improved input view: now you can while editing input also switch to another view without losing already input text.

-----






