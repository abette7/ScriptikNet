//
//  AppDelegate.m
//  ScriptikNet
//
//  Created by Adam Betterton on 11/5/17.
//  Copyright © 2017 Adam Betterton. All rights reserved.
//

#import "AppDelegate.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"

#define WELCOME_MSG  0
#define ECHO_MSG     1
#define WARNING_MSG  2
#define SCRIPT_MSG   3
#define FILE_MSG     4
#define READ_TIMEOUT 15.0
#define READ_TIMEOUT_EXTENSION 10.0

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]

NSString *host = @"";
int port = 0;

GCDAsyncSocket *asyncSocket;
@interface AppDelegate () <GCDAsyncSocketDelegate>
@property (nonatomic, retain) NSTimer * theTimer;
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSWindow *ConfigWindow;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (assign, nonatomic) BOOL darkModeOn;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    _statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    
    NSImage *icon = [NSImage imageNamed:@"ScriptikNet.png"];
    icon.template = YES;
    
    _statusItem.button.image = icon;
    
    [self createStatusBarItem];
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
   // NSString *host = @"127.0.0.1";
   // uint16_t port = 8081;
    
    
  //  NSLog(@"Connecting to \"%@\" on port %hu...", host, port);
    
    NSError *error = nil;
    if ([asyncSocket connectToHost:host onPort:port error:&error])
    {
        [_currStatus setStringValue:@"not connected."];
        [_currScript setStringValue:@""];
        [_currFile setStringValue:@""];
    }
    [self initSystem];
    [self initConfig];
    [self startTimers];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Connected");
    
    
    
   // [sock writeData:myNetData withTimeout:-1 tag:ECHO_MSG];
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
  
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
   // NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
   //NSLog(@"we wrote some data");

   if (tag == ECHO_MSG){
       [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:1];
   }
    
    if (tag == SCRIPT_MSG){
        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:3];
    }
    
    if (tag == FILE_MSG){
        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:4];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
    NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    NSString *getMSG = msg;
    //NSLog(@"%@, did read data",getMSG);
   // NSLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
    //NSLog(@"%ld",tag);
    if (tag == ECHO_MSG)
    {
    [_currStatus setStringValue:getMSG];
    }
    if (tag == SCRIPT_MSG)
    {
        [_currScript setStringValue:getMSG];
        }
    if (tag == FILE_MSG)
    {
        [_currFile setStringValue:getMSG];
    }
   // NSLog(getMSG);

}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
   NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
}

- (void) startTimers
{
    // [self.theTimer invalidate];
    self.theTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    NSLog(@"Start");
    
    
}

- (void) stopTimers
{
    NSLog(@"Stop");
    [self.theTimer invalidate];

    
}

- (void) timerFired:(NSTimer*)theTimer{
    

   // NSString *host = @"127.0.0.1";
   // uint16_t port = 8081;
    
    NSString *isStopped = [_currStatus stringValue];
    if ([isStopped isEqualToString:@"stopped."]){
        NSImage *icon = [NSImage imageNamed:@"ScriptikNetStopped.png"];
        icon.template = YES;
        
        _statusItem.button.image = icon;
      
    }
    
    if (![isStopped isEqualToString:@"stopped."]){
        NSImage *icon = [NSImage imageNamed:@"ScriptikNet.png"];
        icon.template = YES;
        
        _statusItem.button.image = icon;
        
    }
    
  //  NSLog(@"Connecting to \"%@\" on port %hu...", host, port);
    
    NSError *error = nil;
    if ([asyncSocket connectToHost:host onPort:port error:&error])
    {
        [_currStatus setStringValue:@"not connected."];
        [_currScript setStringValue:@""];
        [_currFile setStringValue:@""];
        NSImage *icon = [NSImage imageNamed:@"ScriptikNetNotConnected.png"];
        icon.template = YES;
        
        _statusItem.button.image = icon;
    }
    
    NSString *myGetCommand = @"get";
    NSString *myNetString = [NSString stringWithFormat: @"%@\r\n",myGetCommand];
    NSData *myNetData = [myNetString dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket writeData:myNetData withTimeout:-1 tag:ECHO_MSG];
   // [asyncSocket readDataWithTimeout:READ_TIMEOUT tag:ECHO_MSG];
    
    NSString *myGetScriptCommand = @"getScript";
    NSString *myGetScriptString = [NSString stringWithFormat: @"%@\r\n",myGetScriptCommand];
    NSData *myGetScriptData = [myGetScriptString dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket writeData:myGetScriptData withTimeout:-1 tag:SCRIPT_MSG];
  //  [asyncSocket readDataWithTimeout:READ_TIMEOUT tag:SCRIPT_MSG];
    
    NSString *myGetFileCommand = @"getFile";
    NSString *myGetFileString = [NSString stringWithFormat: @"%@\r\n",myGetFileCommand];
    NSData *myGetFileData = [myGetFileString dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket writeData:myGetFileData withTimeout:-1 tag:FILE_MSG];
   // [asyncSocket readDataWithTimeout:READ_TIMEOUT tag:FILE_MSG];
    
}

- (void)createStatusBarItem {
    // ...
    _statusItem.menu = [self createStatusBarMenu];
}

- (NSMenu *)createStatusBarMenu {
    NSMenu *menu = [[NSMenu alloc] init];
    
    NSMenuItem *status =
    [[NSMenuItem alloc] initWithTitle:@"Status Window"
                               action:@selector(myStatus)
                        keyEquivalent:@""];
   // [online setTarget:self];
    [menu addItem:status];
    
    NSMenuItem *config =
    [[NSMenuItem alloc] initWithTitle:@"Configuration"
                               action:@selector(myConfig)
                        keyEquivalent:@""];
    // [online setTarget:self];
    [menu addItem:config];
    
    NSMenuItem *quit =
    [[NSMenuItem alloc] initWithTitle:@"Quit"
                               action:@selector(myQuit)
                        keyEquivalent:@""];
   // [away setTarget:self];
    [menu addItem:quit];
    
    return menu;
}

- (void)myStatus {
    [_window makeKeyAndOrderFront:nil];
}

- (void)myConfig {
    [_ConfigWindow makeKeyAndOrderFront:self];
}

- (void)myQuit {
    [NSApp terminate:self];
}

- (void)initSystem {
    
    NSString *pathToFile = @"~/.ScriptikNet";
    NSString *expandedPathToFile = [pathToFile stringByExpandingTildeInPath];
    BOOL isDir = NO;
    BOOL isFile = [[NSFileManager defaultManager] fileExistsAtPath:expandedPathToFile isDirectory:&isDir];
    
    if(isFile)
    {
        
    }
    else
    {
        NSError * error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath: expandedPathToFile
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:&error];
        if (!success){
            NSLog(@"Error");
        }
        else{
            NSLog(@"Success");;
        }
    }
    
    
    NSString *configPathToFile = @"~/.ScriptikNet/config.xml";
    NSString *expandedConfigPathToFile = [configPathToFile stringByExpandingTildeInPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:expandedConfigPathToFile]){
        
    }
    else{
        
        
        NSXMLElement *myroot = [NSXMLNode elementWithName:@"Config"];
        NSXMLDocument *myxmlDoc = [[NSXMLDocument alloc] initWithRootElement:myroot];
        
        NSData *mydata = [myxmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
        [[NSFileManager defaultManager] createFileAtPath:expandedConfigPathToFile
                                                contents:mydata
                                              attributes:nil];
        
        
        
    }
}

- (IBAction)configCancelButton:(id)sender {
    [_ConfigWindow orderOut:self];
}

- (IBAction)configConnectButton:(id)sender {
    NSString *ipAddress = [_ipAddressField stringValue];
    NSString *port      = [_portField stringValue];
    NSString *mypathname = [@"~/.ScriptikNet/config.xml" stringByExpandingTildeInPath];
    NSURL *myurl = [NSURL fileURLWithPath:mypathname];
    
    
    NSXMLElement *myroot = [NSXMLNode elementWithName:@"Config"];
    NSXMLDocument *myxmlDoc = [[NSXMLDocument alloc] initWithRootElement:myroot];
    id myIPAddress = [NSXMLNode elementWithName:@"ipAddress" stringValue:ipAddress ];
    id myPort = [NSXMLNode elementWithName:@"port" stringValue:port ];
    
    [myroot insertChild:myIPAddress atIndex:0];
    [myroot insertChild:myPort atIndex:1];
   
    NSData *mydata = [myxmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
    [mydata writeToURL:myurl atomically:YES];
    
    
    [_ConfigWindow orderOut:self];
    [self initConfig];
    [self stopTimers];
    [self startTimers];
}

- (void) initConfig{
    NSString *xmlPath = @"~/.ScriptikNet/config.xml";
    NSString *expandedXMLPath = [xmlPath stringByExpandingTildeInPath];
    NSError         *error=nil;
    NSXMLDocument   *xmlDOC=[[NSXMLDocument alloc]
                             initWithContentsOfURL:[NSURL fileURLWithPath:expandedXMLPath]
                             options:NSXMLNodeOptionsNone
                             error:&error
                             ];
    
    if(!xmlDOC)
    {
        NSLog(@"Error reading '%@': %@",xmlPath,error);
        
        return;
    }
    
    NSXMLElement    *rootElement=[xmlDOC rootElement];
    NSArray         *theIPAddress=[rootElement nodesForXPath:@"ipAddress" error:&error];
    NSXMLNode *theIPAddressValue = (NSXMLNode *) [[theIPAddress objectAtIndex:0]stringValue];
    NSString *myIPAddressValue = (NSString *) theIPAddressValue;
    
    NSArray         *thePort=[rootElement nodesForXPath:@"port" error:&error];
    NSXMLNode *thePortValue = (NSXMLNode *) [[thePort objectAtIndex:0]stringValue];
    NSString *myPortValue = (NSString *) thePortValue;
    

    

    if (![myIPAddressValue isEqualToString:@""]){
        [_ipAddressField setStringValue:myIPAddressValue];
        host = (NSString *) theIPAddressValue;
        
    }
    else{
        host = @"127.0.0.1";
    }
   // [_ipAddressField setStringValue:myIPAddressValue];
    if (![myPortValue isEqualToString:@""]){
        [_portField setStringValue:myPortValue];
        NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
        port = (int)[[formatter numberFromString:myPortValue] intValue];
        
        
    }
    else{
        port = 8081;
    }
   // [_portField setStringValue:myPortValue];
    
}
- (void)connectButton{
    return;
}



@end
