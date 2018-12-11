# Compiling and Running Commnunity Version

The community version of Shukofukurou is meant for advanced users. It does not have any restrictions. However, there is **no support** and you have to provide your own OAuth keys. The community version will also lack any closed source optional features as well. Also, you have to compile each update (following the steps for obtaining the source code and compling) as the App Cast will only download the official release. Do not create any issues if you are using the Community Version. They will be ignored.

The community version does not contain closed source features.

For regular users, it's highly recommended to use the official binaries or the Mac App Store version.

## What do you need
* [Xcode 10](https://developer.apple.com/xcode/)
* Jekyll (To compile the help file)
* OAuth keys for Kitsu and AniList
* A Mac running macOS 10.14 Mojave.

If you haven't installed XCode, install it first and run it. You need the XCode Command Line tools to complete this process.

## Install Jekyll
Jekyll is required to compile the help files used by Shukofukurou. You can install Jekyll by running the following terminal command
```sudo gem install jekyll ```

## Getting the source code and Compling
To download the source code, open the terminal app and run the following command.

```git clone https://github.com/Atelier-Shiori/Shukofukurou.git ```

Afterwards, the whole respository should download. Then change to the repo directory. The easy way to change the directory is typing "cd Shukofukurou".

In the repo folder, rename ClientConstants-sample.m to ClientConstants.m. For Kitsu and AniList, you need to obtain a Consumer Key and Secret. You can do this by going to [https://kitsu.docs.apiary.io](https://kitsu.docs.apiary.io ) for Kitsu and [https://anilist.co/settings/developer](https://anilist.co/settings/developer) for AniList. For Anilist, create a v2 client. Version 1 API Client keys for AniList will not work.

To compile type the following to compile:

```xcodebuild -target "Shukofukurou (Open Source)" -configuration "release" ```

The release will be in the "build/release" folder.

To obtain the latest copy, run the following command
```git pull```

**Do not ask questions about how to set up the community version in the Kitsu Group or AniList thread or Github issues. They will be deleted. Make sure you follow the instructions if you have any issues.**
