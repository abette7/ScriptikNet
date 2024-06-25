//
//  AppDelegate.h
//  ScriptikNet
//
//  Created by Adam Betterton on 11/5/17.
//  Copyright © 2017 Adam Betterton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CocoaAsyncSocket.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSTextField *currStatus;
@property (weak) IBOutlet NSTextField *currScript;
@property (weak) IBOutlet NSTextField *currFile;

@property (weak) IBOutlet NSTextField *ipAddressField;
@property (weak) IBOutlet NSTextField *portField;
@property (weak) IBOutlet NSButton *cancelConfigButton;
@property (weak) IBOutlet NSButton *configConnectButton;
- (void) startTimers;
- (void) initSystem;
- (void) connectButton;
@end

