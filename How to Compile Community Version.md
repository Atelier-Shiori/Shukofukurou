# Compiling and Running Commnunity Version

The community version of Shukofukurou is meant for advanced users. It does not have any restrictions. However, there is **no support** and you have to install your own Unofficial MAL API server and provide your own OAuth keys. The community version will also lack any closed source optional features as well. Also, you have to compile each update (following the steps for obtaining the source code and compling) as the App Cast will only download the official release. Do not create any issues if you are using the Community Version. They will be ignored.

The community version does not contain closed source features such as the Bittorent Browser.

## What do you need
* [Xcode](https://developer.apple.com/xcode/)
* Jekyll (To compile the help file)
* OAuth keys for Kitsu and AniList

If you haven't installed XCode, install it first and run it. You need the XCode Command Line tools to complete this process.

## Install Jekyll
Jekyll is required to compile the help files used by Shukofukurou. You can install Jekyll by running the following terminal command
```sudo gem install jekyll ```

## Getting the source code and Compling
To download the source code, open the terminal app and run the following command.

```git clone https://github.com/Atelier-Shiori/Shukofukurou.git ```

Afterwards, the whole respository should download. Then change to the repo directory. The easy way to change the directory is typing "cd Shukofukurou".

In the repo folder, rename ClientConstants-sample.m to ClientConstants.m. For Kitsu and AniList, you need to obtain a Consumer Key and Secret. You can do this by going to [https://kitsu.docs.apiary.io](https://kitsu.docs.apiary.io ) for Kitsu and [https://anilist.co/settings/developer](https://anilist.co/settings/developer) for AniList. For Anilist, create a v2 client. Version 1 API Client keys for AniList will not work

To compile type the following to compile:

```xcodebuild -target "Shukofukurou (Open Source)" -configuration "release" ```

The release will be in the "build/release" folder.

To obtain the latest copy, run the following command
```git pull```

## Installing Atarashii API
Download Atarashii API [here](https://bitbucket.org/animeneko/atarashii-api/downloads/?tab=branches) and then uncompress the zip file. Open the terminal to the directory containing the Atarashii API and run the following commands to install. The easy way to change the directory is typing "cd " and dragging the folder and pressing enter.

This will be deprecated in the future when the new Official MAL API is ready and suitable for production use.

```shell
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
```

After installing composer, run the folowing command to install Atarashii API
```shell
php composer.phar install
```

You need to set the parametrs. Just hit enter when you are prompted to input something.

Once the installation is done, you can bring up Atarashii-API by running the following command.

```shell
php app/console server:run
```

You need to bring up the server everytime you use Shukofukurou version. The community version will always default to the default php console url (http://localhost:8000).

**Do not ask questions about how to set up the community version in the MAL Club, Kitsu Group or AniList thread or Github issues. They will be deleted. Make sure you follow the instructions if you have any issues.**
