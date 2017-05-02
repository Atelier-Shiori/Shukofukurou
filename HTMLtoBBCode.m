//
//  HTMLtoBBCode.m
//  MAL Library
//
//  Created by 桐間紗路 on 2017/05/01.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import "HTMLtoBBCode.h"
#import "ESCssParser.h"
#import <CocoaOniguruma/OnigRegexp.h>
#import <CocoaOniguruma/OnigRegexpUtility.h>

@implementation HTMLtoBBCode
+ (NSString *)convertHTMLStringtoBBCode:(NSString *)text {
    HTMLtoBBCode *parser = [HTMLtoBBCode new];
    // Pharse
    text = [parser extractBody:text];
    text = [parser convertFormatting:text];
    text = [parser convertLinks:text];
    return text;
}
- (NSString *)extractBody:(NSString *)html{
    NSScanner *scanner = [NSScanner scannerWithString:html];
    NSString *bodytext;
    while (![scanner isAtEnd]){
        [scanner scanUpToString:@"<body>" intoString:NULL];
        [scanner scanString:@"<body>" intoString:NULL];
        [scanner scanUpToString:@"</body>" intoString:&bodytext];
    }
    NSLog(@"%@",bodytext);
    NSDictionary *styles = [self csstoStyleDictionary:html];
    // Cleanup
    OnigRegexp *regex = [OnigRegexp compile:@"<span class=\"Apple-converted-space\">" ignorecase:YES multiline:YES extended:NO];
    OnigResult *match;
    while ((match = [regex search:bodytext])) {
        bodytext = [bodytext replaceByRegexp:regex with:@""];
    }
    bodytext = [self applyBBCodeFormatting:bodytext formatting:styles];
    regex = [OnigRegexp compile:@"</span>" ignorecase:YES multiline:YES extended:NO];
    while ((match = [regex search:bodytext])) {
        bodytext = [bodytext replaceByRegexp:regex with:@""];
    }
    regex = [OnigRegexp compile:@"<p class=\"p\\d+\">" ignorecase:YES multiline:YES extended:NO];
    while ((match = [regex search:bodytext])) {
        bodytext = [bodytext replaceByRegexp:regex with:@""];
    }
    regex = [OnigRegexp compile:@"</p>" ignorecase:YES multiline:YES extended:NO];
    while ((match = [regex search:bodytext])) {
        bodytext = [bodytext replaceByRegexp:regex with:@""];
    }
    regex = [OnigRegexp compile:@"<br>" ignorecase:YES multiline:YES extended:NO];
    while ((match = [regex search:bodytext])) {
        bodytext = [bodytext replaceByRegexp:regex with:@"\n"];
    }
    return bodytext;
}
- (NSString *)convertFormatting:(NSString *)html{
    // Bold
    html = [html stringByReplacingOccurrencesOfString:@"<b>" withString:@"[b]"];
    html = [html stringByReplacingOccurrencesOfString:@"</b>" withString:@"[/b]"];
    // Underline
    html = [html stringByReplacingOccurrencesOfString:@"<u>" withString:@"[u]"];
    html = [html stringByReplacingOccurrencesOfString:@"</u>" withString:@"[/u]"];
    // Italic
    html = [html stringByReplacingOccurrencesOfString:@"<i>" withString:@"[i]"];
    html = [html stringByReplacingOccurrencesOfString:@"</i>" withString:@"[/i]"];
    // Center
    html = [html stringByReplacingOccurrencesOfString:@"<center>" withString:@"[center]"];
    html = [html stringByReplacingOccurrencesOfString:@"</center>" withString:@"[/center]"];
    // Right
    html = [html stringByReplacingOccurrencesOfString:@"<right>" withString:@"[right]"];
    html = [html stringByReplacingOccurrencesOfString:@"</right>" withString:@"[/right]"];
    // finish
    return html;
}
- (NSString *)convertLinks:(NSString *)html {
    // URL
    html = [html stringByReplacingOccurrencesOfString:@"<a href=\"" withString:@"[url="];
    html = [html stringByReplacingOccurrencesOfString:@"</a>" withString:@"[/url]"];
    html = [html stringByReplacingOccurrencesOfString:@">" withString:@"]"];
    return html;
}
- (NSDictionary *)csstoStyleDictionary:(NSString *)html {
    NSScanner *scanner = [NSScanner scannerWithString:html];
    NSString *css;
    while (![scanner isAtEnd]){
        [scanner scanUpToString:@"<style type=\"text/css\">" intoString:NULL];
        [scanner scanString:@"<style type=\"text/css\">" intoString:NULL];
        [scanner scanUpToString:@"</style>" intoString:&css];
    }
    NSMutableDictionary *styles = [NSMutableDictionary new];
    NSDictionary *cssparsed = [[ESCssParser new] parseText:css];
    if (cssparsed.count > 0) {
        for (NSString *s in cssparsed.allKeys) {
            OnigRegexp *regex = [OnigRegexp compile:@"p.p\\d+"];
            if ([regex match:s]){
                NSDictionary *d = cssparsed[s];
                [styles setObject:[self parseCSS:d] forKey:s];
            }
            regex = [OnigRegexp compile:@"span.s\\d+"];
            if ([regex match:s]) {
                NSDictionary *d = cssparsed[s];
                if (d[@"text-decoration"]) {
                    if ([(NSString *)d[@"text-decoration"] isEqualToString:@"underline"]){
                        [styles setObject:@{@"textdecoration":@"underline"} forKey:s];
                    }
                }
            }
        }
    }
    return styles;
}

- (NSDictionary *)parseCSS:(NSDictionary *)css {
    NSNumber *fontsize;
    NSString *align;
    OnigRegexp *regex = [OnigRegexp compile:@".*px" options:OnigOptionIgnorecase];
    OnigResult *match = [regex search:css[@"font"]];
    // Get font size
    NSString *tmpstr = match.strings[0];
    regex = [OnigRegexp compile:@"\\d+.\\d+px"];
    match = [regex search:tmpstr];
    tmpstr = [match stringAt:0];
    tmpstr = [tmpstr replaceByRegexp:[OnigRegexp compile:@".\\d+px"] with:@""];
    fontsize = @(tmpstr.intValue);
    // Get alignment
    regex = [OnigRegexp compile:@"(center|right)" options:OnigOptionIgnorecase];
    if (css[@"text-align"]) {
        match = [regex search:css[@"text-align"]];
        if (match) {
            tmpstr = [match stringAt:0];
            align = tmpstr;
        }
    }
    if (align && fontsize.intValue != 12) {
        return @{@"fontsize":fontsize, @"align":align};
    }
    else if (align && fontsize.intValue == 12) {
        return @{@"align":align};
    }
    else if (!align && fontsize.intValue != 12) {
        return @{@"fontsize":fontsize};
    }
    return @{};
}
- (NSString *)applyBBCodeFormatting:(NSString *)html formatting:(NSDictionary *)formatdict {
    for (NSString *key in [formatdict.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]) {
        NSDictionary *formatinfo = formatdict[key];
        NSMutableString * beforetags = [[NSMutableString alloc] initWithString:@""];
        NSMutableString * endtags = [[NSMutableString alloc] initWithString:@""];
        if ([[OnigRegexp compile:@"p.p\\d+"] match:key]) {
            if (formatinfo[@"fontsize"]) {
                [beforetags appendFormat:@"[size=%@]",formatinfo[@"fontsize"]];
                [endtags appendString:@"[/size]"];
            }
            if (formatinfo[@"align"]) {
                [beforetags appendFormat:@"[%@]",formatinfo[@"align"]];
                [endtags insertString:[NSString stringWithFormat:@"[/%@]",formatinfo[@"align"]] atIndex:0];
            }
            NSString *paragraphtext = [self getParagraph:html paragraph:[key stringByReplacingOccurrencesOfString:@"p." withString:@""]];
            NSString *parsedstring = [NSString stringWithFormat:@"%@%@%@",beforetags,paragraphtext,endtags];
            html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<p class=\"%@\">%@</p>",[key stringByReplacingOccurrencesOfString:@"p." withString:@""],paragraphtext] withString:parsedstring];
            
        }
        else if ([[OnigRegexp compile:@"span.s\\d+"] match:key]) {
            if (formatinfo[@"textdecoration"]) {
                [beforetags appendString:@"[u]"];
                [endtags appendString:@"[/u]"];
            }
            NSString *spantext = [self getSpan:html span:[key stringByReplacingOccurrencesOfString:@"span." withString:@""]];
            NSString *parsedstring = [NSString stringWithFormat:@"%@%@%@",beforetags,spantext,endtags];
            html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<span class=\"%@\">%@</span>",[key stringByReplacingOccurrencesOfString:@"span." withString:@""],spantext] withString:parsedstring];
        }
    }
    return html;
}
- (NSString *)getParagraph:(NSString *)html paragraph:(NSString *)paragraph {
    NSScanner *scanner = [NSScanner scannerWithString:html];
    NSString *theParagraph;
    NSString *paragraphtag = [NSString stringWithFormat:@"<p class=\"%@\">",paragraph];
    while (![scanner isAtEnd]){
        [scanner scanUpToString:paragraphtag intoString:NULL];
        [scanner scanString:paragraphtag intoString:NULL];
        [scanner scanUpToString:@"</p>" intoString:&theParagraph];
    }
    return theParagraph;
}

- (NSString *)getSpan:(NSString *)html span:(NSString *)span {
    NSScanner *scanner = [NSScanner scannerWithString:html];
    NSString *theParagraph;
    NSString *spantag = [NSString stringWithFormat:@"<span class=\"%@\">",span];
    while (![scanner isAtEnd]){
        [scanner scanUpToString:spantag intoString:NULL];
        [scanner scanString:spantag intoString:NULL];
        [scanner scanUpToString:@"</span>" intoString:&theParagraph];
    }
    return theParagraph;
}

@end
