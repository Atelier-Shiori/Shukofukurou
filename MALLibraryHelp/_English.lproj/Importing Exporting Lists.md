---
title: Importing and Exporting Lists
description: About the Import and Export features in Shukofukurou.
keywords: importing, kitsu, exporting, backup lists, syncing lists, anidb
---
In Shukofukurou, you can import lists from other services to the current service.

Here are the formats that Shukofukurou supports:
* MyAnimeList XML Format (generated from the website or export done in Shukofukurou)
* AniDB XML (full) Lists.
* Kitsu (Anime only for now).
* AniList (Anime only for now).

**Note: Manga importing for Kitsu and AniList lists will come at a later date**

If there are titles that could not be imported, it will show them after the import is complete. You can save the list to a JSON file for inspection.

## Import Compatibility

**Fields** |**MyAnimeList XML**|**AniDB XML**|**Kitsu**|**AniList**
:-----:|:-----:|:-----:|:-----:|:-----:
Watched Episodes|Y|Y|Y|Y
Watched Status|Y|-*|Y|Y
Score|Y|N|Y|Y
Tags|Y|N|N|N
Custom Lists|N|N|N|N

(*) Only completed, plan to watch and watching status. The XML does not contain state/watch status information nor score.

Note: You cannot import Kitsu/Anilist lists if your current service is the same as the list you are importing.

## How to export lists from other sites and import them

### MyAnimeList
Note: Manga list importing is only available for App Store users.
1. In the library view on MyAnimeList, click "Export" option.
2. Select what list you want to export and click "Export My List." It will prompt you if you want to export your list. Click OK.
3. Download your list. Rename the downloaded file to add the ".gz" extension. Then, extract the list.
4. In Shukofukurou, click on Tools > Import List > Import MyAnimeList XML  from the menubar.. Select your list to import.
Note: To overwrite entries, click "Options" and check "Replace entries if exist"
5. Click Open and it will import the list to your library. If there is any titles that couldn't be imported, it will show a list.

### AniDB
1. Click Export under "My Stuff" on AniDB.
2. Choose XML from the template selector and click Request Export. You will have to wait until the export is ready.
3. Download the export and extract it.
4. In Shukofukurou, Click on Tools > Import List > Import AniDB XML from the menubar.
5. Go to the extracted folder and select file "mylist.xml." 
Note: To overwrite entries, click "Options" and check "Replace entries if exist"
6. Click open to start the import. If there is any titles that couldn't be imported, it will show a list.

### Kitsu and AniList
1. In Shukofukurou, click on Tools > Import List > Import from Kitsu or Import from AniList from the menubar.
2. Specify your username that you want to import your library from.
Note: To overwrite entries, check "Replace existing entries"
6. Click import to start the import. If there is any titles that couldn't be imported, it will show a list.

## Export
You can export lists for backup or use on other services.

### MyAnimeList XML Export (MyAnimeList only)
You can export your list to MyAnimeList XML compatible format. Note that some information that is not exposed by the API **will not** exported. However, your progress, status, personal tags and scores will be exported.

### Other Formats (Donors only)
You can export your lists to JSON or CSV format. Note that you cannot import these formats yet. They are meant as a backup or use in other third party applications.

* JSON (JavaScript Object Notation File) - JSON format allows you to use lists in other third party applications. 
* CSV (Comma Delimited File) - CSV format allows you to view your lists in Spreadsheet applications such as Microsoft Excel or Apple's Numbers.

**Note:** Fields like custom lists, tags (MyAnimeList), and privacy settings are not exported with CSV format. Scores/Ratings are converted to a 0-100 scale.

### Export Converted Lists
You can export converted MyAnimeList XML Anime or Manga lists from AniList or Kitsu with this option. Note that not all titles will be exported if the title does not exist on MyAnimeList.

Note that scores will be converted to a 1-10 scale and privacy settings will not apply.
