# Shukofukurou
![screenshot](https://malupdaterosx.moe/wp-content/uploads/2018/04/mallibrary.png)

Formerly known as MAL Library

Shukofukurou an open sourced and native [MyAnimeList](https://myanimelist.net), [Kitsu](https://kitsu.io/), and [AniList](https://anilist.co) library manager, a complete rewrite of MAL Client OSX written in Objective-C.

This app is named after the owl, Shuko from Sora no Woto.

Requires latest SDK (10.13), XCode 9 or later. The C#/Xamarin version is deprecated, but still aviliable in the c-sharp-old branch.

## Supporting this Project

You can also support the project by buying the full version from the Mac App Store for $4.99. All future updates are free for 2.x.

[![macappstore](https://malupdaterosx.moe/wp-content/uploads/2018/04/downloadmacappstore.png)](https://itunes.apple.com/us/app/mal-library/id1226620085?ls=1&mt=12)

Note that for 3.0, binaries are only available as a freenimum application with Donor/Pro features like manga list management, list syncing, profile browser and character browser locked.

For existing users who downloaded from the App Store, the upgrade fee planned to be $1.99 to help cover the cost of development. People who downloaded MAL Library after March 1, 2018 before the release of 3.0 will recieve a free upgrade.. More details coming soon.

## How to Compile

Warning: This won't work if you don't have a Developer ID installed. If you don't have one, obtain one by joining the Apple Developer Program or turn off code signing.

1. Get the Source
2. Type 'xcodebuild' to build

# About Self-Built Copies
These restrictions only apply on officially distributed versions of MAL Library. To create an unofficial version without restrictions, build the App Store scheme. There is no software updates if you build your own as this is an unofficial copy. Do not create issues for self-built copies as they won't be supported. Also, you must use a different Atarashii-API server as the one specified in the application is only for official copies.

There will be a community scheme to allow users to build unofficial copies. However, you must enter your own client keys.

# Tests
Currently, there is a UI test that tests the basic UI functionality (search, adding/modifying/deleting titles, and viewing title information) and unit tests testing the search and list management functionality. Note that you should only run these tests on a test account so your entries won't get overwritten.

## Dependencies
All the frameworks are included. Just build! Here are the frameworks that are used in this app:

* Sparkle.framework
* MASPreferences.framework
* AFNetworking.framework
* PXSourceList.framework
* CocoaOniguruma.framework

Licenses for these frameworks and related classes can be seen [here](https://github.com/Atelier-Shiori/mallibrary/wiki/Credits).

Icons provided by [icons8](https://icons8.com/)

## License
Unless stated, Source code is licensed under New BSD License
