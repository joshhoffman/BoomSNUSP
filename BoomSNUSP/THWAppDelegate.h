//
//  THWAppDelegate.h
//  BoomSNUSP
//
//  Created by Josh Hoffman on 12/5/12.
//  Copyright (c) 2012 Josh Hoffman. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define CODE_SIZE       100
#define RIGHT           1
#define LEFT            3
#define DOWN            2
#define UP              4

#define DIR_LEFT        -1      // /
#define DIR_RIGHT       1       // \\d

@interface dataPos : NSObject
{
@public
    int ipx;
    int ipy;
    int dpx;
    int dpy;
    int direction;
    int stackSize;
    NSMutableArray *CallStack;
}
@end

@interface THWAppDelegate : NSObject <NSApplicationDelegate>
{
    char code[CODE_SIZE][CODE_SIZE];
    char data[CODE_SIZE][CODE_SIZE];
    int readPos;
    NSThread *executeThread;
    NSMutableArray *threads;
    int startIPX;
    int startIPY;
    NSMutableString *output;
}

@property (assign) IBOutlet NSWindow *window;
- (IBAction)Run:(id)sender;
- (void)Parse;
- (int)ExecuteCode:(dataPos*)posData;
- (void)MoveCodePos:(dataPos*)posData;
- (void)ResetData;
- (void)ChangeDirection:(dataPos*) posData direction:(int)newDir;
- (void)PushToStack:(dataPos*)posData;
- (void)PopFromStack:(dataPos*)posData;
- (int)GetCodePos:(dataPos*)posData;
- (void)ReadDataAtPos:(dataPos*)posData;
- (void)CreateNewThread:(dataPos*)posData;
- (void)ExecuteThread;
@property (strong) IBOutlet NSTextView *codeView;
@property (strong) IBOutlet NSTextField *outputField;
@property (strong) IBOutlet NSButton *DelayCheck;
@property (strong) IBOutlet NSTextField *InputField;
@property (strong) IBOutlet NSButton *ClearCheck;

@end