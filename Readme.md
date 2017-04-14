# MAL Library
![screenshot](https://malupdaterosx.ateliershiori.moe/assets/mallibrary.png)

MAL Library an open sourced and mostly native MyAnimeList library manager, a complete rewrite of MAL Client OSX written in Objective-C. Is in Alpha and may contain bugs.
 
Requires latest SDK (10.12), XCode 8 or later. The C#/Xamarin version is deprecated, but still aviliable in the c-sharp-old branch.

## Supporting this Project

Like this program and want to support the development of this program? [Become our Patreon](http://www.patreon.com/ateliershiori) or [Donate](https://malupdaterosx.ateliershiori.moe/donate/). By donating more than $5 or becoming a patron, you will recieve a donation key to remove the reminder message and unlock Manga support.

You can also donate cryptocurrencies to these addresses (send an email with the transaction ID and address to get a donation key as long the amount is equilivant to $5 USD or more):
* Bitcoin - Use the Bitpay form on the [donation page](https://malupdaterosx.ateliershiori.moe/donate/).
* Ethereum - 7DDfd7443d3D4A7ec76e25d481E68BE43533b509

## How to Compile

Warning: This won't work if you don't have a Developer ID installed. If you don't have one, obtain one by joining the Apple Developer Program or turn off code signing.

1. Get the Source
2. Type 'xcodebuild' to build

# About Donation Key restrictions
These restrictions only apply on officially distributed versions of MAL Library. To create an unofficial version without restrictions, build the App Store scheme. There is no software updates if you build your own as this is an unofficial copy. Do not create issues for self-built copies as they won't be supported. Also, you must use a different Atarashii-API server as the one specified in the application is only for official copies.

# Tests
Currently, there is a UI test that tests the basic UI functionality (search, adding/modifying/deleting titles, and viewing title information) and unit tests testing the search and list management functionality. Note that you should only run these tests on a test account so your entries won't get overwritten.

## Dependencies
All the frameworks are included. Just build! Here are the frameworks that are used in this app:

* Sparkle.framework
* MASPreferences.framework
* AFNetworking.framework
* PXSourceList.framework
 
Licenses for these frameworks and related classes can be seen [here](https://github.com/Atelier-Shiori/mallibrary/wiki/Credits).

## License
Unless stated, Source code is licensed under New BSD License
