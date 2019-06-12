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
**Note: This setting is disabled on macOS 10.14 or later as Shukofukurou will use the current appearence**
* Clear Image Cache - Clears the poster image cache.
* Stream Region - Sets the stream version for aviliable legal steams for a given title from Because.moe. Stream information is only
* Reset Title ID Mappings - Allows you to reset the Title ID Mappings used for importing titles and switching services. Use this if the you having issues with Title ID conversion used by service switching and list importing.
* Cache Title Information - When enabled, Shukofukurou will cache title information so it can be loaded quickly. This enables offline viewing of title information, provided that you loaded it previously.
* Show 18+ Content (Non-Mac App Store version) - Enables the viewing of 18+ content. Note that for Kitsu, you need to enable viewing of mature content before Shukofukurou can view this kind of content. On the Mac App Store, this option is always disabled due to rating restrictions. However, you will still be able to manage 18+ on your animelist.
* Send Crash Data/Statistics - Allows you to opt in/opt out of crash data and statistics collection. Free users cannot opt out, only people who donated, is an active patron or downloaded the app from the Mac App Store can.

### Export
* Set Update on Import: You can chose which status you want to set the Update on Import value to enabled. If checked, it will change the update_on_import value to 1. This means that when you import the MyAnimeList XML, the entry will be imported.

## Accounts
Allows you to login or log out of your account. Credentials are saved in the login Keychain. MyAnimeList Credentials are checked every 24 hours to make sure they are valid. If they become invalid, you will be required to log out and login again.

For Kitsu and AniList, no user credentials are saved. Instead, OAuth is used to retrieve a token, which works the same as a username and password. For AniList, you will be taken to the website to authorize the application.

### Note
* If you are having trouble logging into Kitsu, use your profile name instead.

## Air Notifications
See "About Airing Notifications."

## Software Updates (Non-Appstore Version)
This section manages how updates are checked and installed.

* Automatically Check for Updates - Shukofukurou will check for new updates automatically
* Send anonymous system profile - Sends system information (CPU, memory, macOS version) and the version of Shukofukurou when you update. No personal information is sent.
* Automatically download new updates - Shukofukurou will download new updates automatically. When you quit Shukofukurou, it will install the new version.
