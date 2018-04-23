---
title: Preferences
description: About Preferences.
keywords: settings, preferences, software updates, login, account login, general settings, api settings, advanced settings
---
The Preferences window allows you to change various settings

## General
These options affect the main functionality of the application.

### List Options
* Double Click Action - Specifies the action when an item is double clicked in the library view. The possible actions are Do Nothing, View Info and Modify Title.
* Refresh List on start - Shukofukurou will refresh your list when Shukofukurou is launched.
* Refresh List Automatically - This allows Shukofukurou to refresh your list periodically.

### General
* Appearance - Sets the appearance of the main window. Possible options are light or dark.
* Clear Image Cache - Clears the poster image cache.
* Stream Region - Sets the stream version for aviliable legal steams for a given title from Because.moe. Stream information is only
* Reset Title ID Mappings - Allows you to reset the Title ID Mappings used for importing titles and switching services. Use this if the you having issues with Title ID conversion used by service switching and list importing.
* Show 18+ Content (Non-Mac App Store version) - Enables the viewing of 18+ content. Note that for Kitsu, you need to enable viewing of mature content before Shukofukurou can view this kind of content. On the Mac App Store, this option is always disabled due to rating restrictions. However, you will still be able to manage 18+ on your animelist.

## Login
Allows you to login or log out of your account. Credentials are saved in the login Keychain. MyAnimeList Credentials are checked every 24 hours to make sure they are valid. If they become invalid, you will be required to log out and login again.

For Kitsu and AniList, no user credentials are saved. Instead, OAuth is used to retrieve a token, which works the same as a username and password. For AniList, you will be taken to the website to authorize the application.

### Note
* If you are having trouble logging into Kitsu, use your profile name instead.

## Software Updates (Non-Appstore Version)
This section manages how updates are checked and installed.

* Automatically Check for Updates - Shukofukurou will check for new updates automatically
* Send anonymous system profile - Sends system information (CPU, memory, macOS version) and the version of Shukofukurou when you update. No personal information is sent.
* Automatically download new updates - Shukofukurou will download new updates automatically. When you quit Shukofukurou, it will install the new version.

## Advanced
These options are for advanced users only.

### API Settings
Allows you to specify a MAL API server to use.
* API URL - The URL to the Atarashii-API server
* Reset API URL - Resets the API URL to the defaults
* Test API - Tests the API to see if it works or not.
