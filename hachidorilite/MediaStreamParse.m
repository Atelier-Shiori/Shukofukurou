//
//  MediaStreamParse.m
//  detectstream
//
//  Created by 高町なのは on 2015/02/09.
//  Copyright 2014-2020 Atelier Shiori, James Moy. All rights reserved. Code licensed under MIT License.
//

#import "MediaStreamParse.h"
#import "ezregex.h"
#import "NSString+HTML.h"

@implementation MediaStreamParse
+ (NSArray *)parse:(NSArray *)pages {
     NSMutableArray * final = [[NSMutableArray alloc] init];
    ezregex * ez = [[ezregex alloc] init];
    //Perform Regex and sanitize
    if (pages.count > 0) {
        for (NSDictionary *m in pages) {
            NSString * regextitle = [NSString stringWithFormat:@"%@",m[@"title"]];
            NSString * url = [NSString stringWithFormat:@"%@", m[@"url"]];
            NSString * site = [NSString stringWithFormat:@"%@", m[@"site"]];
            NSString * title = @"";
            NSString * tmpepisode = @"";
            NSString * tmpseason = @"";
            bool isManga = false;
            if ([site isEqualToString:@"crunchyroll"]) {
                if ([url containsString:@"beta"]) {
                    if ([ez checkMatch:url pattern:@"\\/watch\\/.+\\/.+"]) {
                        // Crunchyroll Beta Watch Page
                        // Requires Javascript Scraping
                        NSString *DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                        NSString *metastring = [ez findMatch:DOM pattern:@"E\\d+ - .+<\\/h2>" rangeatindex:0];
                        metastring = [metastring stringByReplacingOccurrencesOfString:@"</h2>" withString:@""];
                        tmpepisode = [ez findMatch:DOM pattern:@"E\\d+" rangeatindex:0];
                        tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"E" withString:@""];
                        NSString *tmpeptitle = [ez findMatch:metastring pattern:@"- .+" rangeatindex:0];
                        tmpeptitle = [tmpeptitle stringByReplacingOccurrencesOfString:@"- " withString:@""];
                        regextitle = [regextitle stringByReplacingOccurrencesOfString:@" - Watch on Crunchyroll" withString:@""];
                        regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpeptitle withString:@""];
                        title = regextitle;
                    }
                    else if ([url containsString:@"history"]) {
                        // Crunchyroll Beta History Page
                        // Requires Javascript Scraping
                        NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                        NSArray *history = [self generateBetaCrunchyrollHistoryQueue:DOM];
                        if (history.count > 0) {
                            NSDictionary *historyobject = history[0];
                            title = historyobject[@"title"];
                            tmpepisode = historyobject[@"episode"];
                            tmpseason = historyobject[@"season"];
                        }
                        else {
                            continue;
                        }
                    }
                }
                else {
                    //Add Regex Arguments Here
                    if ([ez checkMatch:url pattern:@"\\/home\\/history"]) {
                        // Scrobble from viewing history
                        //Get the Document Object Model
                        NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                        NSArray *history = [self generateCrunchyrollHistoryQueue:DOM];
                        if (history.count > 0) {
                            NSDictionary *historyobject = history[0];
                            title = historyobject[@"title"];
                            tmpepisode = historyobject[@"episode"];
                        }
                        else {
                            continue;
                        }
                    }
                    else if ([ez checkMatch:url pattern:@"[^/]+\\/episode-[0-9]+.*-[0-9]+"]||[ez checkMatch:url pattern:@"[^/]+\\/.*-movie-[0-9]+"]||[ez checkMatch:url pattern:@"[^/]+\\/.*-\\d+"]) {
                        //Perform Sanitation
                          regextitle = [ez findMatch:regextitle pattern:@".* (Episode \\d+|\\(Movie\\))" rangeatindex:0];
                        tmpepisode = [ez findMatch:regextitle pattern:@"\\sEpisode (\\d+)" rangeatindex:0];
                        regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpepisode withString:@""];
                        tmpepisode = [ez searchreplace:tmpepisode pattern:@"\\sEpisode"];
                        regextitle = [regextitle stringByReplacingOccurrencesOfString:@"(Movie)" withString:@""];
                        title = regextitle;
                        if ([ez checkMatch:title pattern:@"Crunchyroll"]) {
                            continue;
                        }
                    }
                    else if ([ez checkMatch:url pattern:@"\\/comics_read\\/manga\\?volume_id=\\d+&chapter_num=\\d+"]) {
                        isManga = true;
                        NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                        regextitle = [ez findMatch:DOM pattern:@"<span itemprop=\"title\">.+</span>" rangeatindex:0];
                        regextitle = [regextitle stringByReplacingOccurrencesOfString:@"<span itemprop=\"title\">" withString:@""];
                        regextitle = [regextitle stringByReplacingOccurrencesOfString:@"</span>" withString:@""];
                        tmpepisode = [ez findMatch:url pattern:@"chapter_num=\\d+" rangeatindex:0];
                        tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"chapter_num=" withString:@""];
                        title = regextitle;
                        if (title.length == 0) {
                            continue;
                        }
                    }
                    else {
                        continue;
                    }
                }
            }
            // Following came from Taiga - https://github.com/erengy/taiga/ //
            else if ([site isEqualToString:@"animelab"]) {
                if ([ez checkMatch:url pattern:@"(\\/player\\/)"]) {
                    regextitle = [ez searchreplace:regextitle pattern:@"AnimeLab\\s-\\s"];
                    
                    regextitle = [ez searchreplace:regextitle pattern:@"-\\sEpisode\\s"];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\s-\\s.*"];
                    tmpepisode = [ez findMatch:regextitle pattern:@"(\\d+)" rangeatindex:0];
                    title = [ez findMatch:regextitle pattern:@"\\b.*\\D" rangeatindex:0];
                    title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    tmpepisode = [tmpepisode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    tmpseason = @"0"; //not supported
                }
                else {
                    continue; // Invalid address
                }
            }
            else if ([site isEqualToString:@"animenewsnetwork"]) {
                if ([ez checkMatch:url pattern:@"video\\/[0-9]+"]) {
                    regextitle = [ez searchreplace:regextitle pattern:@"\\b\\s-\\sAnime News Network$"];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\s\\((s|d)\\)\\s"];
                    regextitle = [ez searchreplace:regextitle pattern:@"ep\\."];
                    tmpepisode = [ez findMatch:regextitle pattern:@"(\\d+)" rangeatindex:0];
                    title = [ez findMatch:regextitle pattern:@"\\b.*\\D" rangeatindex:0];
                }
                else {
                    continue; // Invalid address
                }
            }
            else if ([site isEqualToString:@"viz"]) {
                if ([ez checkMatch:url pattern:@"watch\\/streaming\\/[^/]+-episode-[0-9]+\\/"]||[ez checkMatch:url pattern:@"watch\\/streaming\\/[^/]+-movie\\/"]) {
                    tmpepisode = [ez findMatch:regextitle pattern:@"(\\d+)" rangeatindex:0];
                    regextitle = [ez searchreplace:regextitle pattern:@"#\\d+\\s*.*\\/\\/\\sVIZ"];
                    regextitle = [ez searchreplace:regextitle pattern:@"#\\d+\\s\\w+"];
                    title = [ez findMatch:regextitle pattern:@"\\b.*\\s" rangeatindex:0];
                }
                else {
                    continue; // Invalid address
                }
            }
            else if ([site isEqualToString:@"funimation"]) {
                if ([ez checkMatch:url pattern:@"shows\\/.*\\/.*\\/.*"]) {
	                regextitle = [regextitle stringByReplacingOccurrencesOfString:@"Watch " withString:@""];
	                regextitle = [ez findMatch:regextitle pattern:@".* Season \\d+ Episode \\d+" rangeatindex:0];
	                tmpepisode = [ez findMatch:regextitle pattern:@"Episode \\d+" rangeatindex:0];
	                tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"Episode " withString:@""];
	                tmpseason = [ez findMatch:regextitle pattern:@"Season \\d+" rangeatindex:0];
	                tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"Season "  withString:@""];
	                title = [ez searchreplace:regextitle pattern:@"Season \\d+ Episode \\d+"];
                }
                else if ([url.lowercaseString containsString:@"/account/"]) {
	                NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
	                regextitle = [ez findMatch:DOM pattern:@"<a href=\"\\/shows\\/.*\\/.*\\/?qid=\">.*<\\/a>" rangeatindex:0];
					regextitle = [ez searchreplace:regextitle pattern:@"<a href=\"\\/shows\\/.*\\/.*\\/?qid=\">"];
					regextitle = [ez searchreplace:regextitle pattern:@"<\\/a>"];
					tmpepisode = [ez findMatch:DOM pattern:@"Episode \\d+" rangeatindex:0];
					tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"Episode " withString:@""];
					tmpseason = [ez findMatch:DOM pattern:@"Season \\d+" rangeatindex:0];
					tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"Season "  withString:@""];
					title = regextitle;
                }
                else {
                    continue; // Invalid address
                }
            }
            else if ([site isEqualToString:@"netflix"]){
                if([ez checkMatch:url pattern:@"WiPlayer"]){
                    //Get the Document Object Model
                    NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                    //Get the Episode Movie ID
                    NSArray * matches = [ez findMatches:url pattern:@"\\b(EpisodeMovieId|episodeId)=\\d+"];
                    NSString * videoid;
                    if (matches.count > 0) {
                        videoid = [NSString stringWithFormat:@"%@", [[ez findMatches:url pattern:@"\\b(EpisodeMovieId|episodeId)=\\d+"] lastObject]];
                        videoid = [ez searchreplace:videoid pattern:@"(EpisodeMovieId|episodeId)="];
                    }
                    NSData * jsonData;
                    if ([ez checkMatch:DOM pattern:@"\"video\":*.*\\]\\}\\}"]){
                        // HTML5 Player
                        if (videoid.length == 0) {
                            //Get Video ID
                            videoid = [ez findMatch:[NSString stringWithFormat:@"%@", m[@"DOM"]] pattern:@"\"videoId\":\\d+" rangeatindex:0];
                            videoid = [videoid stringByReplacingOccurrencesOfString:@"\"videoId\":" withString:@""];
                        }
                        DOM = [NSString stringWithFormat:@"{%@",[ez findMatch:DOM pattern:@"\"video\":*.*\\]\\}\\}" rangeatindex:0]];
                        jsonData = [DOM dataUsingEncoding:NSUTF8StringEncoding];
                    }
                    else{
                        if (videoid.length == 0) {
                            //Get Video ID
                            videoid = [ez findMatch:[NSString stringWithFormat:@"%@",m[@"DOM"]] pattern:@"EpisodeMovieId=\\d+" rangeatindex:0];
                            videoid = [videoid stringByReplacingOccurrencesOfString:@"EpisodeMovieId=" withString:@""];
                        }
                        // Silverlight Player
                        // Parse the DOM to get the JSON Data
                        DOM = [ez findMatch:DOM pattern:@"\"metadata\":\"*.*\",\"initParams\"" rangeatindex:0];
                        DOM = [DOM stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        DOM = [DOM stringByReplacingOccurrencesOfString:@"metadata:" withString:@""];
                        DOM = [DOM stringByReplacingOccurrencesOfString:@",initParams" withString:@""];
                        jsonData = [[NSData alloc] initWithBase64Encoding:DOM];
                    }
                    NSError* error;
                    // Parse JSON Data
                    NSDictionary *metadata = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
                    NSDictionary *videodata = metadata[@"video"];
                    // Set Title
                    title = videodata[@"title"];
                    // Search to get the right Episode Number
                    NSArray * seasondata = videodata[@"seasons"];
                    for (NSUInteger i = 0; i < [seasondata count]; i++) {
                        NSDictionary * season = seasondata[i];
                        NSArray *episodes = season[@"episodes"];
                        for (NSUInteger e = 0; e < [episodes count]; e++) {
                            NSDictionary * episode = episodes[e];
                            if (![videoid isEqualTo:[NSString stringWithFormat:@"%@", episode[@"id"]]]) {
                                continue;
                            }
                            else{
                                //Set Episode Number and Season
                                tmpepisode = [NSString stringWithFormat:@"%@", episode[@"seq"]];
                                tmpseason = [NSString stringWithFormat:@"%lu", (i + 1)];
                                break;
                            }
                        }
                    }
                }
                else {
                    continue;
                }
            }
            else if ([site isEqualToString:@"plex"]){
                if ([ez checkMatch:url pattern:@"web\\/app"]||[ez checkMatch:url pattern:@"web\\/index.html"]) {
                    // Check if there is a usable episode number
                    if (![regextitle isEqualToString:@"Plex"]) {
                        regextitle = [ez searchreplace:regextitle pattern:@"\\▶\\s"];
                        // Just return title, let Anitomy pharse the rest
                        title = regextitle;
                        tmpepisode = @"0";
                    }
                    else {
                        continue;
                    }
                }
                else {
                    continue;
                }
            }
            else if ([site isEqualToString:@"viewster"]) {
                if ([ez checkMatch:url pattern:@"\\/serie\\/\\d+-\\d+-\\d+\\/*.*\\/"]) {
                    //Get the Document Object Model
                    NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                    regextitle = [ez findMatch:DOM pattern:@".*\\sEpisode\\s\\d+:" rangeatindex:0];
                    tmpepisode = [ez findMatch:regextitle pattern:@"Episode\\s\\d+" rangeatindex:0];
                    title = [regextitle stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@:",tmpepisode] withString:@""];
					tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"Episode " withString:@""];
                }
                else {
                    continue; // Invalid address
                }
            }
            else if ([site isEqualToString:@"wakanim"]) {
                if ([ez checkMatch:url pattern:@"/[^/]+/v2/catalogue/episode/[^/]+/"]) {
                    NSArray *matches = [ez findMatches:regextitle pattern:@"(?:Episode (\\d+)|Film|Movie) - (?:ENGDUB - )?(.+)"];
                    if (matches.count > 2) {
                      regextitle = matches[1];
                      tmpepisode = matches[0];
                    }
                    else {
                      regextitle = matches[0];
                    }
                    title = regextitle;
                }
                else {
                    continue; // Invalid address
                }
            }
            else if ([site isEqualToString:@"myanimelist"]) {
                if ([ez checkMatch:url pattern:@"anime\\/\\d+\\/*.*\\/episode\\/\\d+"]) {
                    regextitle = [ez searchreplace:regextitle pattern:@"- MyAnimeList.net"];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\sEpisode"];
                    tmpepisode = [ez findMatch:regextitle pattern:@"(\\d+)" rangeatindex:0];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\D-\\s*.*$"];
                    title = [ez findMatch:regextitle pattern:@"\\b.*\\D" rangeatindex:0];
                }
                else {
                    continue; // Invalid address
                }
            }
            else if ([site isEqualToString:@"hidive"]) {
                //Add Regex Arguments for hidive
                if ([ez checkMatch:url pattern:@"(stream\\/*.*\\/s\\d+e\\d+|stream\\/*.*\\/\\d+)"]) {
                    // Clean title
                    regextitle = [ez searchreplace:regextitle pattern:@"(Stream |\\sof| on HIDIVE)"];
                    if ([ez checkMatch:regextitle pattern:@"Episode \\d+"]) {
                        // Regular TV series
                        tmpseason = [ez findMatch:regextitle pattern:@"Season \\d+" rangeatindex:0];
                        regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpseason withString:@""];
                        tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"Season " withString:@""];
                        tmpepisode = [ez findMatch:regextitle pattern:@"Episode \\d+" rangeatindex:0];
                        regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpepisode withString:@""];
                        tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"Episode " withString:@""];
                        title = [regextitle stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    }
                    else {
                        // Movie or OVA
                        tmpepisode = @"1";
                        tmpseason = @"1";
                        title = [ez searchreplace:regextitle pattern:@" - (OVA|Movie|Special)"];
                    }
                }
                else {
                    continue; // Invalid address
                }
            }
            else if ([site isEqualToString:@"vrv"]) {
                //Add Regex Arguments Here
                if ([ez checkMatch:url pattern:@"\\/watch\\/*.*\\/*.*"]) {
                    //Perform Sanitation
                    regextitle = [ez searchreplace:regextitle pattern:@" - Watch on VRV\\s"];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\s-\\sMovie\\s-\\sMovie"];
                    tmpepisode = [ez findMatch:regextitle pattern:@"\\s(Episode) (\\d+)" rangeatindex:0];
                    regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpepisode withString:@""];
                    tmpepisode = [ez searchreplace:tmpepisode pattern:@"\\s(Episode) "];
                tmpseason  = [ez findMatch:regextitle pattern:@"Season (\\d+)" rangeatindex:0];
                regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpseason withString:@""];
                tmpseason  = [ez searchreplace:tmpseason pattern:@"Season "];                    regextitle = [ez searchreplace:regextitle pattern:@"\\s-\\s*.*"];
                    title = regextitle;
                    if ([ez checkMatch:title pattern:@"VRV"]) {
                        continue;
                    }
                }
                else {
                    continue;
                }
            }
            else if ([site isEqualToString:@"amazon"]) {
                // Amazon Prime Video/Anime Strike
                if ([ez checkMatch:url pattern:@"(\\/gp\\/video\\/detail\\/*.*|\\/.+\\/dp\\/.*|\\/gp\\/product\\/.*?pf_rd_p=)"]) {
                    NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                    if ([DOM isEqualToString:@"(null) - (null)"]) {
                        // Silverlight Player not supported
                        continue;
                    }
                    regextitle = [ez findMatch:DOM pattern:@".* - " rangeatindex:0];
                    regextitle = [regextitle stringByReplacingOccurrencesOfString:@" - " withString:@""];
                    tmpepisode = [ez findMatch:DOM pattern:@"(Ep.|Episode|E) \\d+" rangeatindex:0];
                    tmpepisode = [ez searchreplace:tmpepisode pattern:@"(Ep.|Episode|E) "];
                    if ([ez checkMatch:DOM  pattern:@"Season \\d+"]) {
                        regextitle = [NSString stringWithFormat:@"%@ %@",regextitle, [ez findMatch:DOM pattern:@"Season \\d+" rangeatindex:0]];
                    }
                    title = regextitle;
                }
            }
            else if ([site isEqualToString:@"tubitv"]) {
                //Add Regex Arguments Here
                if ([ez checkMatch:url pattern:@"\\/*.+\\/\\d+\\/s\\d+_e\\d+"]) {
                    //Perform Sanitation
                    regextitle = [ez searchreplace:regextitle pattern:@"(Watch | - *.* \\| Tubi)"];
                    regextitle = [regextitle stringByReplacingOccurrencesOfString:@":" withString:@" "];
                    tmpseason = [ez findMatch:regextitle pattern:@"S\\d+" rangeatindex:0];
                    regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpseason withString:@""];
                    tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"S" withString:@""];
                    tmpepisode = [ez findMatch:regextitle pattern:@"E\\d+" rangeatindex:0];
                    regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpepisode withString:@""];
                    tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"E" withString:@""];
                    title = regextitle;
                }
                else {
                    continue;
                }
            }
            else if ([site isEqualToString:@"asiancrush"]) {
                if ([ez checkMatch:url pattern:@"(\\/video\\/*.+\\/\\d+v|\\/video\\/\\d+v)"]) {
                    regextitle = [ez searchreplace:regextitle pattern:@"(Subbed|Dubbed)"];
                    if ([ez checkMatch:regextitle pattern:@".* S\\d+E\\d+"]) {
                        regextitle = [ez findMatch:regextitle pattern:@".* S\\d+E\\d+" rangeatindex:0];
                        regextitle = [ez searchreplace:regextitle pattern:@"\\(.*\\)"];
                        tmpseason = [ez findMatch:regextitle pattern:@"S\\d+" rangeatindex:0];
                        tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"S" withString:@""];
                        tmpepisode = [ez findMatch:regextitle pattern:@"E\\d+" rangeatindex:0];
                        tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"E" withString:@""];
                        title = [ez searchreplace:regextitle pattern:@"S\\d+E\\d+"];
                    }
                    else {
                        regextitle = [ez searchreplace:regextitle pattern:@"(Subbed|Dubbed)"];
                        regextitle = [regextitle stringByReplacingOccurrencesOfString:@" | Watch Full Movie Free | AsianCrush" withString:@""];
                        title = regextitle;
                    }
                }
                else {
                   continue;
                }
            }
            else if ([site isEqualToString:@"animedigitalnetwork"]) {
                if ([ez checkMatch:url pattern:@"\\/video\\/.*\\/\\d+"]) {
                       regextitle = [ez searchreplace:regextitle pattern:@" - streaming -.* ADN"];
                       if ([ez checkMatch:regextitle pattern:@".*-.*\\d+"]) {
                          regextitle = [ez findMatch:regextitle pattern:@".*-.*\\d+" rangeatindex:0];
                          tmpepisode = [ez findMatch:regextitle pattern:@" -.*\\d+" rangeatindex:0];
                          regextitle = [ez searchreplace:regextitle pattern:@" -.*\\d+"];
                          tmpepisode = [ez findMatch:tmpepisode pattern:@"\\d+" rangeatindex:0];
                       }
                       title = regextitle;
                }
                else {
                      continue;
                }
            }
            else if ([site isEqualToString:@"sonycrackle"]) {
                      if ([ez checkMatch:regextitle pattern:@"Watch *.+ Online Free - Sony Crackle"]) {
                      regextitle = [ez searchreplace:regextitle pattern:@"(Watch |Online Free - Sony Crackle)"];
                      if ([ez findMatch:regextitle pattern:@", Episode \\d+" rangeatindex:0]) {
                                tmpepisode = [ez findMatch:regextitle pattern:@", Episode \\d+" rangeatindex:0];
                                regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpepisode withString:@""];
                                tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@", Episode " withString:@""];
                      }
                      if ([ez findMatch:regextitle pattern:@", Season \\d+" rangeatindex:0]) {
                                tmpseason = [ez findMatch:regextitle pattern:@", Season \\d+" rangeatindex:0];
                                regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpseason withString:@""];
                                tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@", Season " withString:@""];
                      }
                      title = regextitle;
            }
            else {
                     continue;
            }
            }
            else if ([site isEqualToString:@"adultswim"]) {
                 if ([ez checkMatch:url pattern:@"\\/videos\\/*.+\\/*.+\\/"]) {
                      NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                      // Parse title
                      regextitle = [regextitle stringByReplacingOccurrencesOfString:@" - Adult Swim Shows" withString:@""];
                      regextitle = [ez searchreplace:regextitle pattern:@".+ - "];
                      NSArray *seasons = [ez findMatches:DOM pattern:@"<div class=\"season__root show-content__season\">*.+<\\/div>"];
                      if (seasons.count > 0) {
                           for (NSString *season in seasons) {
                                  // Get Temp Season
                                  tmpseason = [ez findMatch:season pattern:@"Season \\d+" rangeatindex:0];
                                  tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"Season " withString:@""];
                                  NSString *currentepisodedomregex = @"<div class=\"episode__root episode__selected\">*.+Ep \\d+";
                                  if ([ez checkMatch:DOM pattern:currentepisodedomregex]) {
                                        NSString *epdom = [ez findMatch:DOM pattern:currentepisodedomregex rangeatindex:0];
                                        tmpepisode = [ez findMatch:epdom pattern:@"Ep \\d+" rangeatindex:0];
                                        tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"Ep " withString:@""];
                                        title = regextitle;
                                  }
                                  else {
                                        continue;
                                  }
                           }
                      }
                      else {
                           continue;
                      }
                 }
                 else {
                      continue;
                 }
            }
			else if ([site isEqualToString:@"hbomax"]) {
				if ([ez checkMatch:url pattern:@"https:\\/\\/play.hbomax.com\\/(episode|feature)\\/urn\\:hbo\\:(episode|feature):"]) {
					NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
					if ([url containsString:@"episode"]) {
						NSString *titlepattern = @"<span style=\"font-family: street2_bold; font-size: 12px; font-style: normal; text-decoration: none; text-transform: uppercase; line-height: 18px; letter-spacing: 0px; color: rgb\\(255, 255, 255\\);\">.*<\\/span><\\/span><\\/div><\\/a><div class=\"default\" style=\"width\\: 313px; top\\: (3[3-9]|4[0-9]|5[01])px;\">";
						if ([ez checkMatch:DOM pattern:titlepattern]) {
							regextitle = [ez findMatch:DOM pattern:titlepattern rangeatindex:0];
							regextitle = [ez searchreplace:regextitle pattern:@"<span style=\"font-family: street2_bold; font-size: 12px; font-style: normal; text-decoration: none; text-transform: uppercase; line-height: 18px; letter-spacing: 0px; color: rgb\\(255, 255, 255\\);\">"];
                        	regextitle = [ez searchreplace:regextitle pattern:@"<\\/span><\\/span><\\/div><\\/a><div class=\"default\" style=\"width\\: 313px; top\\: (3[3-9]|4[0-9]|5[01])px;\">"];
							tmpepisode = [ez findMatch:DOM pattern:@"Ep \\d+" rangeatindex:0];
							tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"Ep " withString:@""];
							tmpseason = [ez findMatch:DOM pattern:@"Sn \\d+" rangeatindex:0];
							tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"Sn " withString:@""];
							title = regextitle;
						}
						else {
							continue;
						}
					}
					else if ([url containsString:@"feature"]) {
                    NSString *titlepattern = @"<span style=\"font-family: street2_medium; font-size: 28px; font-style: normal; text-decoration: none; text-transform: none; line-height: 36px; letter-spacing: 0px; color: rgb\\(240, 240, 240\\);\">.*<\\/span><\\/span><\\/div><div class=\"default\" style=\"width: 313px; top: (5[1-9]|[6-9][0-9]|1[01][0-9]|12[0-3])px;\">";
						if ([ez checkMatch:DOM pattern:titlepattern]) {
							regextitle = [ez findMatch:DOM pattern:titlepattern rangeatindex:0];
							regextitle = [ez searchreplace:regextitle pattern:@"<span style=\"font-family: street2_medium; font-size: 28px; font-style: normal; text-decoration: none; text-transform: none; line-height: 36px; letter-spacing: 0px; color: rgb\\(240, 240, 240\\);\">"];
                        	regextitle = [ez searchreplace:regextitle pattern:@"<\\/span><\\/span><\\/div><div class=\"default\" style=\"width: 313px; top: (5[1-9]|[6-9][0-9]|1[01][0-9]|12[0-3])px;\">"];
                        	regextitle = [ez searchreplace:regextitle pattern:@"((G|PG-13|PG|R|TV-14|NC-17) \\| (2.0|Stereo|5.1) \\| (HD|SD).*|(G|PG-13|PG|R|TV-14|NC-17) \\| (HD|SD).*)"];
                        	regextitle = [ez searchreplace:regextitle pattern:@"<span style=\"*.*\">"];
							tmpepisode = @"1";
							tmpseason = @"1";
							title = regextitle;
						}
						else {
							continue;
						}
					}
				}
            }
            else if ([site isEqualToString:@"retrocrush"]) {
            	if ([ez checkMatch:url pattern:@"\\/video\\/.*\\/\\d+.*"]) {
            		NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
            		regextitle = [ez findMatch:DOM pattern:@"<a href=\"\\/series\\/.*\">.*<\\/a>" rangeatindex:0];
            		regextitle = [ez searchreplace:regextitle pattern:@"<a href=\"\\/series\\/.*\">"];
            		regextitle = [regextitle stringByReplacingOccurrencesOfString:@"</a>" withString:@""];
            		tmpepisode = [ez findMatch:DOM pattern:@"Episode \\d+" rangeatindex:0];
            		tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"Episode " withString:@""];
            		tmpseason = [ez findMatch:DOM pattern:@"Season \\d+" rangeatindex:0];
            		tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"Season " withString:@""];
            		title = regextitle;
            	}
			}
            else if ([site isEqualToString:@"hulu"]) {
	            if ([ez checkMatch:url pattern:@"\\/watch\\/.*"]) {
		            if (m[@"DOM"]) {
			            NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
			            regextitle = [ez findMatch:DOM pattern:@"<div class=\"ClampedText\" *.+><span>.*<\\/span>" rangeatindex:0];
			            regextitle = [ez searchreplace:regextitle pattern:@"<div class=\"ClampedText\" *.+><span>"];
			            regextitle = [regextitle stringByReplacingOccurrencesOfString:@"</span>" withString:@""];
			            tmpepisode = [ez findMatch:DOM pattern:@"E\\d+" rangeatindex:0];
			            tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"E" withString:@""];
			            tmpseason = [ez findMatch:DOM pattern:@"S\\d+" rangeatindex:0];
			            tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"S" withString:@""];
			            title = regextitle;
		            }
	            }
            }
            else {
                continue;
            }
        
            NSNumber * episode;
            NSNumber * season;
            // Populate Season
            if (tmpseason.length == 0 && !isManga) {
                // Parse Season from title
                NSDictionary * seasondata = [MediaStreamParse checkSeason:title];
                if (seasondata != nil) {
                    season = (NSNumber *)seasondata[@"season"];
                    title = seasondata[@"title"];
                }
                else{
                   season = @(1);
                }
            }
            else {
                season = [[[NSNumberFormatter alloc] init] numberFromString:tmpseason];
            }
            //Trim Whitespace
            title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            tmpepisode = [tmpepisode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            // Decode HTML
            title = [title kv_decodeHTMLCharacterEntities];
            // Final Checks
            if ([tmpepisode length] ==0){
                episode = @(0);
            }
            else{
                episode = [[[NSNumberFormatter alloc] init] numberFromString:tmpepisode];
            }
            if (title.length == 0) {
                continue;
            }
            // Add to Final Array
            NSDictionary * frecord;
            if (!isManga) {
                frecord = @{@"title" :title, @"episode" : episode, @"season" : season, @"browser" : m[@"browser"], @"site" : site, @"type" : @"anime" };
            }
            else {
                 frecord = @{@"title" :title, @"chapter" : episode, @"browser" : m[@"browser"], @"site" : site, @"type" : @"manga" };
            }
            [final addObject:frecord];
        }
    }
    return final;
}
+ (NSDictionary *)checkSeason:(NSString *) title {
    // Parses season
    ezregex * ez = [ezregex new];
    NSString * tmpseason;
    NSDictionary * result;
    NSString * pattern = @"(\\d+(st|nd|rd|th) season|season \\d+|s\\d+|season\\d+)";
    if ([ez checkMatch:title pattern:pattern]) {
        tmpseason = [ez findMatch:title pattern:pattern rangeatindex:0];
        title = [title stringByReplacingOccurrencesOfString:tmpseason withString:@""];
        tmpseason = [ez findMatch:tmpseason pattern:@"\\d+" rangeatindex:0];
        result = @{@"title": title, @"season": [[NSNumberFormatter alloc] numberFromString:tmpseason]};
        
    }
    pattern = @"(first|season|third|fourth|fifth) season";
    if ([ez checkMatch:title pattern:@"(first|season|third|fourth|fifth) season"] && tmpseason.length == 0) {
        tmpseason = [ez findMatch:title pattern:pattern rangeatindex:0];
        title = [title stringByReplacingOccurrencesOfString:tmpseason withString:@""];
        result = @{@"title": title, @"season": @([MediaStreamParse recognizeseason:tmpseason])};
    }
    return result;
}
+ (int)recognizeseason:(NSString *)season {
    if ([season caseInsensitiveCompare:@"second season"] == NSOrderedSame) {
        return 2;
    }
    else if ([season caseInsensitiveCompare:@"third season"] == NSOrderedSame) {
        return 3;
    }
    else if ([season caseInsensitiveCompare:@"fourth season"] == NSOrderedSame) {
        return 4;
    }
    else if ([season caseInsensitiveCompare:@"fifth season"] == NSOrderedSame) {
        return 5;
    }
    else {
        return 1;
    }
}
+ (NSArray *)generateCrunchyrollHistoryQueue:(NSString *)DOM {
    // Creates an array of titles and episodes from Crunchyroll history
    ezregex *regex = [ezregex new];
    NSString *tmpdom = [DOM stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSMutableArray *tmparray = [NSMutableArray new];
    NSArray *matches = [regex findMatches:tmpdom pattern:@"<li class=\"group-item hover-bubble\" id=\"media_group_\\d+\" group_id=\"media_group_\\d+\">(.*?)<\\/li>"];
    for (NSString *item in matches) {
        if ([regex checkMatch:item pattern:@"<span itemprop=\"name\" class=\"series-title block ellipsis\">(.*?)<\\/span>"]) {
            NSString *title = [regex findMatch:item pattern:@"<span itemprop=\"name\" class=\"series-title block ellipsis\">(.*?)<\\/span>" rangeatindex:0];
            title = [title stringByReplacingOccurrencesOfString:@"<span itemprop=\"name\" class=\"series-title block ellipsis\">" withString:@""];
            title = [title stringByReplacingOccurrencesOfString:@"</span>" withString:@""];
            NSString *episode = @"1";
            if ([regex checkMatch:item pattern:@"Episode \\d+"]) {
                episode = [regex findMatch:item pattern:@"Episode \\d+" rangeatindex:0];
                episode = [episode stringByReplacingOccurrencesOfString:@"Episode " withString:@""];
            }
            [tmparray addObject:@{@"title":title, @"episode":episode}];
        }
        else {
            continue;
        }
    }
    return tmparray;
    
}

+ (NSArray *)generateBetaCrunchyrollHistoryQueue:(NSString *)DOM {
    // Creates an array of titles and episodes from Crunchyroll history (Beta)
    ezregex *regex = [ezregex new];
    NSString *tmpdom = [DOM stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSMutableArray *tmparray = [NSMutableArray new];
    NSArray *matches = [regex findMatches:tmpdom pattern:@"<div class=\"erc-my-lists-item\">(.*?)<\\/svg><\\/div><\\/div><\\/div><\\/div><\\/div>"];
    for (NSString *item in matches) {
        if ([regex checkMatch:item pattern:@"<small class=\"c-text c-text--xs c-text--heavy c-playable-card__show-title\">(.*?)<\\/small>"]) {
            NSString *title = [regex findMatch:item pattern:@"<small class=\"c-text c-text--xs c-text--heavy c-playable-card__show-title\">(.*?)<\\/small>" rangeatindex:0];
            title = [title stringByReplacingOccurrencesOfString:@"<small class=\"c-text c-text--xs c-text--heavy c-playable-card__show-title\">" withString:@""];
            title = [title stringByReplacingOccurrencesOfString:@"</small>" withString:@""];
            NSString *episode = @"1";
            NSString *season = @"1";
            if ([regex checkMatch:item pattern:@"E\\d+"]) {
                episode = [regex findMatch:item pattern:@"E\\d+" rangeatindex:0];
                episode = [episode stringByReplacingOccurrencesOfString:@"E" withString:@""];
            }
            if ([regex checkMatch:item pattern:@"S\\d+"]) {
                season = [regex findMatch:item pattern:@"S\\d+" rangeatindex:0];
                season = [season stringByReplacingOccurrencesOfString:@"S" withString:@""];
            }
            [tmparray addObject:@{@"title":title, @"episode":episode, @"season":season}];
        }
        else {
            continue;
        }
    }
    return tmparray;
    
}
@end
