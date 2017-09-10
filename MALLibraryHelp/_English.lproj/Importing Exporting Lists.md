---
title: Importing and Exporting Lists
description: About the Import and Export features in MAL Library.
keywords: importing, kitsu, exporting, backip lists, syncing lists, anidb
---
In MAL Library 2.1, you can import lists from other services.

Here are the formats that MAL Library supports:
* MyAnimeList XML Format (generated from the website or export done in MAL Library)
* AniDB XML (full) Lists.(1)
* Kitsu (Anime only for now).(1)
* AniList (Anime only for now).(1)

(1) These import options requires a donation key or an App Store version.

If there are titles that could not be imported, it will show them after the import is complete. You can save the list to a JSON file for inspection.

## Import Compatibility

**Fields** |**MyAnimeList XML**|**AniDB XML**|**Kitsu**|**AniList**
:-----:|:-----:|:-----:|:-----:|:-----:
Watched Episodes|Y|Y|Y|Y
Watched Status|Y|-*|Y|Y
Score|Y|N|Y|Y

(*) Only completed, plan to watch and watching status. The XML does not contain state/watch status information nor score.

## How to export lists from other sites and import them

### MyAnimeList
1. In the library view on MyAnimeList, click "Export" option.
2. Select what list you want to export and click "Export My List." It will prompt you if you want to export your list. Click OK.
3. Download your list. Rename the downloaded file to add the ".gz" extension. Then, extract the list.
4. In MAL Library, click on MyAnimeList > Import List > Import MyAnimeList XML  from the menubar.. Select your list to importe 
Note: To overwrite entries, click "Options" and check "Replace entries if exist"
5. Click Open and it will import the list to your library. If there is any titles that couldn't be imported, it will show a list.

### AniDB
This option requires a donation key entered or an App Store version.
1. Click Export under "My Stuff" on AniDB.
2. Choose XML from the template selector and click Request Export. You will have to wait until the export is ready.
3. Download the export and extract it.
4. In MAL Library, Click on MyAnimeList > Import List > Import AniDB XML from the menubar.
5. Go to the extracted folder and select file "mylist.xml." 
Note: To overwrite entries, click "Options" and check "Replace entries if exist"
6. Click open to start the import. If there is any titles that couldn't be imported, it will show a list.

### Kitsu and AniList
This option requires a donation key entered or an App Store version.
1. In MAL Library, click on MyAnimeList > Import List > Import from Kitsu or Import from AniList from the menubar.
2. Specify your username that you want to import your library from.
Note: To overwrite entries, check "Replace existing entries"
6. Click import to start the import. If there is any titles that couldn't be imported, it will show a list.

## Export
You can export your list to MyAnimeList XML compatible format. Note that some information that is not exposed by the API will get exported. However, your progress, status, personal tags and scores will get exported.
