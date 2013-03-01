//
//  THWAppDelegate.h
//  BoomSNUSP
//
//  Created by Josh Hoffman on 12/5/12.
//  Copyright (c) 2012 Josh Hoffman. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define CODE_SIZE       200
#define RIGHT           1
#define LEFT            3
#define DOWN            2
#define UP              4

#define DIR_LEFT        -1      // /
#define DIR_RIGHT       1       // \\d
#define MAX_PROC_COUNT  10

#define STD_INPUT       0
#define STD_OUTPUT      0

#define MAX_STREAMS   100;
#define MAX_STREAM_SIZE 1000;

@interface dataPos : NSObject
{
@public
    int ipx;
    int ipy;
    int dpx;
    int dpy;
    int direction;
    int inputStream;
    int outputStream;
    int stackSize;
    int dataIndex;
    BOOL quoteMode;
    NSMutableArray *CallStack;
}
@end

@interface THWAppDelegate : NSObject <NSApplicationDelegate>
{
    char code[CODE_SIZE][CODE_SIZE];
    char data[MAX_PROC_COUNT][CODE_SIZE][CODE_SIZE];
    int readPos;
    int startIPX;
    int startIPY;
    NSString *stringStack;
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
@property (strong,nonatomic) IBOutlet NSTextView *codeView;
@property (strong,nonatomic) IBOutlet NSTextField *outputField;
@property (strong,nonatomic) IBOutlet NSButton *DelayCheck;
@property (strong,nonatomic) IBOutlet NSTextField *InputField;
@property (strong,nonatomic) IBOutlet NSButton *ClearCheck;
@property (strong, nonatomic) NSMutableString *output;
@property (strong, nonatomic) NSMutableArray *threads;
@property (strong, nonatomic) NSThread *executeThread;

@end