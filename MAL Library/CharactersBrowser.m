//
//  CharactersBrowser.m
//  Shukofukurou
//
//  Created by 桐間紗路 on 2017/07/26.
//  Copyright © 2017年 MAL Updater OS X Group. All rights reserved.
//

#import "CharactersBrowser.h"
#import "CharacterView.h"
#import "listservice.h"
#import <CocoaOniguruma/OnigRegexp.h>
#import <CocoaOniguruma/OnigRegexpUtility.h>
#import "Utility.h"

@interface CharactersBrowser ()
@property (strong) NSDictionary *castdict;
@property (strong) IBOutlet NSVisualEffectView *noselectionview;
@property (weak) IBOutlet NSProgressIndicator *progresswheel;
@property (strong) CharacterView *characterviewcontroller;
@property (strong) IBOutlet NSView *mainview;
@property (strong) IBOutlet NSToolbarItem *toolbarviewonmal;
@property (strong) IBOutlet NSToolbarItem *toolbarshare;
@property (strong) IBOutlet NSTextField *noselectionheader;
@end

@implementation CharactersBrowser

- (instancetype)init {
    self = [super initWithWindowNibName:@"CharactersBrowser"];
    if (!self)
        return nil;
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.;
    
    self.window.titleVisibility = NSWindowTitleHidden;
    
    // Fix window size
    NSRect frame = (self.window).frame;
    if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_11){
        frame.size.height = frame.size.height - 44;
    }
    else{
        frame.size.height = frame.size.height - 22;
    }
    [self.window setFrame:frame display:NO];
    
    [_mainview addSubview:[NSView new]];
    _characterviewcontroller = [CharacterView new];
    _characterviewcontroller.cb = self;
    // Set Resizing masks
    _noselectionview.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    _characterviewcontroller.view.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    [self setDefaultView];
    [self enabletoolbaritems:NO];
    [self setAppearance];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(recieveNotification:) name:@"AppAppearenceChanged" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(recieveNotification:) name:@"ServiceChanged" object:nil];
}

- (void)recieveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"AppAppearenceChanged"]) {
        [self setAppearance];
    }
    else if ([notification.name isEqualToString:@"ServiceChanged"]) {
        [self.window close];
    }
}

- (void)windowWillClose:(NSNotification *)notification {
    // Cleanup
    _castdict = nil;
    [_characterviewcontroller cleanup];
    _selectedtitle = nil;
    [self setDefaultView];
}

#pragma mark -
#pragma mark Main View functions
- (void)setDefaultView {
    [self replaceMainViewSubViewWithView:_noselectionview];
}

- (void)replaceMainViewSubViewWithView:(NSView *)view {
    NSRect mainviewframe = _mainview.frame;
    NSPoint origin = NSMakePoint(0, 0);
    [_mainview replaceSubview:(_mainview.subviews)[0] with:view];
    view.frame = mainviewframe;
    [view setFrameOrigin:origin];
}

- (void)enabletoolbaritems:(bool)enable {
    _toolbarshare.enabled = enable;
    _toolbarviewonmal.enabled = enable;
}

- (void)startstopanimation:(bool)enable {
    if (enable) {
        _noselectionheader.hidden = true;
        _progresswheel.hidden = false;
        [_progresswheel startAnimation:self];
    }
    else {
        _noselectionheader.hidden = false;
        _progresswheel.hidden = true;
        [_progresswheel stopAnimation:self];
    }
}

#pragma mark Other Methods

- (void)loadPerson:(int)personid personType:(int)persontype {
    switch (persontype) {
        case 0:
            [self retrievestaffinformation:personid];
            break;
        case 1:
            [self retrievecharacterinformation:personid];
            break;
    }
}

- (IBAction)vieonmal:(id)sender {
    switch ([listservice getCurrentServiceID]) {
        case 1: {
            if (_characterviewcontroller.persontype == PersonCharacter) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/character/%i",_characterviewcontroller.selectedid]]];
            }
            else {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/people/%i",_characterviewcontroller.selectedid]]];
            }
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            if (_characterviewcontroller.persontype == PersonCharacter) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/character/%i",_characterviewcontroller.selectedid]]];
            }
            else {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/staff/%i",_characterviewcontroller.selectedid]]];
            }
            break;
        }
        default:
            break;
    }
            
}

- (IBAction)share:(id)sender {
    //Generate Items to Share
    NSArray *shareItems = @[];
    switch ([listservice getCurrentServiceID]) {
        case 1: {
            if (_characterviewcontroller.persontype == PersonCharacter) {
                shareItems = @[[NSString stringWithFormat:@"Check out %@ out on MyAnimeList ", [Utility convertNameFormat:_characterviewcontroller.charactername.stringValue]], [NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/character/%i", _characterviewcontroller.selectedid]]];
            }
            else {
                shareItems = @[[NSString stringWithFormat:@"Check out %@ out on MyAnimeList ", [Utility convertNameFormat:_characterviewcontroller.charactername.stringValue]], [NSURL URLWithString:[NSString stringWithFormat:@"https://myanimelist.net/people/%i", _characterviewcontroller.selectedid]]];
            }
            break;
        }
        case 3: {
            if (_characterviewcontroller.persontype == PersonCharacter) {
                shareItems = @[[NSString stringWithFormat:@"Check out %@ out on AniList ", [Utility convertNameFormat:_characterviewcontroller.charactername.stringValue]], [NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/character/%i", _characterviewcontroller.selectedid]]];
            }
            else {
                shareItems = @[[NSString stringWithFormat:@"Check out %@ out on AniList ", [Utility convertNameFormat:_characterviewcontroller.charactername.stringValue]], [NSURL URLWithString:[NSString stringWithFormat:@"https://anilist.co/staff/%i", _characterviewcontroller.selectedid]]];
            }
            break;
        }
    }
    //Get Share Picker
    NSSharingServicePicker *sharePicker = [[NSSharingServicePicker alloc] initWithItems:shareItems];
    sharePicker.delegate = nil;
    NSButton * btn = (NSButton *)sender;
    // Show Share Box
    [sharePicker showRelativeToRect:btn.bounds ofView:btn preferredEdge:NSMinYEdge];
}

- (void)retrievecharacterinformation:(int)idnum {
    [self replaceMainViewSubViewWithView:_noselectionview];
    [self startstopanimation:true];
    [AniList retrieveCharacterDetails:idnum completion:^(id responseObject) {
        [self startstopanimation:false];
        [_characterviewcontroller populateStaffInformation:responseObject];
        [self replaceMainViewSubViewWithView:_characterviewcontroller.view];
    } error:^(NSError *error) {
        [self startstopanimation:false];
    }];
}

- (void)retrievestaffinformation:(int)idnum {
    [self replaceMainViewSubViewWithView:_noselectionview];
    [self startstopanimation:true];
    [listservice retrievePersonDetails:idnum completion:^(id responseObject){
        [self startstopanimation:false];
        [_characterviewcontroller populateStaffInformation:responseObject];
        [self replaceMainViewSubViewWithView:_characterviewcontroller.view];
    }error:^(NSError *error) {
        [self startstopanimation:false];
    }];
}

- (void)setAppearance {
    if (@available(macOS 10.14, *)) {
        // Do not set appearence on macOS Versions >= 10.14
        return;
    }
    else {
        NSString * appearence = [[NSUserDefaults standardUserDefaults] valueForKey:@"appearance"];
        NSString *appearancename;
        if ([appearence isEqualToString:@"Light"]){
            appearancename = NSAppearanceNameVibrantLight;
            self.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
        }
        else{
            appearancename = NSAppearanceNameVibrantDark;
            self.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
        }
        _noselectionview.appearance = [NSAppearance appearanceNamed:appearancename];
        _characterviewcontroller.view.appearance = [NSAppearance appearanceNamed:appearancename];
        [self.window setFrame:self.window.frame display:false];
    }
}

@end
