//
//  THWAppDelegate.m
//  BoomSNUSP
//
//  Created by Josh Hoffman on 12/5/12.
//  Copyright (c) 2012 Josh Hoffman. All rights reserved.
//

#import "THWAppDelegate.h"

@implementation dataPos
- (id)init
{
    self = [super init];
    if(self != nil)
    {
        CallStack = [[NSMutableArray alloc] init];
        stackSize = 0;
        ipx = 0;
        ipy = 0;
        dpx = 0;
        dpy = 0;
        quoteMode = NO;
        dataIndex = 0;
        inputStream = STD_INPUT;
        outputStream = STD_OUTPUT;
        direction = RIGHT;
    }
    return self;
}
@end

@implementation THWAppDelegate

@synthesize codeView;
@synthesize outputField;
@synthesize threads;
@synthesize output;
@synthesize executeThread;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self ResetData];
    [codeView setFont:[NSFont fontWithName:@"Courier" size:12]];
    
    threads = [[NSMutableArray alloc] init];
    srand(CFAbsoluteTimeGetCurrent());
    output = [[NSMutableString alloc]initWithString:@""];
    executeThread = nil;
    stringStack = [[NSString alloc] init];
    //NSRange resetArea = NSMakeRange(0, [[codeView textStorage] length]);
}

- (void)PushToStack:(dataPos*)posData;
{
    dataPos *newData = [[dataPos alloc] init];
    newData->ipx = posData->ipx;
    newData->ipy = posData->ipy;
    newData->dpx = posData->dpx;
    newData->dpy = posData->dpy;
    newData->direction = posData->direction;
    posData->stackSize++;
    [posData->CallStack addObject:newData];
}

- (void)PopFromStack:(dataPos*)posData
{
    dataPos *lastItem = [posData->CallStack lastObject];
    [posData->CallStack removeLastObject];
    posData->ipx = lastItem->ipx;
    posData->ipy = lastItem->ipy;
    posData->dpx = lastItem->dpx;
    posData->dpy = lastItem->dpy;
    posData->stackSize--;
    posData->direction = lastItem->direction;
}

- (void)ExecuteThread
{
    int num = 0;
    int codePos = 0;
    BOOL checking = YES;
    NSMutableArray *executed = [[NSMutableArray alloc] init];
    //[self ExecuteCode];
    while([executeThread isCancelled] ==NO &&
          (codePos = [self ExecuteCode:[threads objectAtIndex:num]]) > -1)
    {
        NSRange area = NSMakeRange(codePos, 1);
        //add new coloring
        switch (num % 3) {
            case 0:
                [[codeView textStorage] addAttribute:NSForegroundColorAttributeName
                                               value:[NSColor redColor]
                                               range:area];
                break;
                
            case 1:
                [[codeView textStorage] addAttribute:NSForegroundColorAttributeName
                                               value:[NSColor orangeColor]
                
                                               range:area];
                break;
                
            case 2:
                [[codeView textStorage] addAttribute:NSForegroundColorAttributeName
                                               value:[NSColor blueColor]
                                               range:area];
                break;
                
            default:
                [[codeView textStorage] addAttribute:NSForegroundColorAttributeName
                                               value:[NSColor redColor]
                                               range:area];
                break;
        }
        if([[self DelayCheck] state] == NSOnState)
            usleep(500000);
        else
            usleep(10000);
        
        checking = YES;
        
        while(checking)
        {
            checking = NO;
            num = rand() % [threads count];
            for(NSNumber *test in executed)
            {
                if([test intValue] == num)
                {
                    checking = YES;
                    break;
                }
            }
            
            if(checking == NO)
                [executed addObject:[NSNumber numberWithInt:num]];
            NSLog(@"count %ul %ul num %d", [executed count], [threads count], num);
            
            if([executed count] == [threads count])
            {
                [executed removeAllObjects];
                if([[self ClearCheck] state] == NSOnState)
                {
                    NSRange resetArea = NSMakeRange(0, [[codeView textStorage] length]);
                    
                    //remove existing coloring
                    [[codeView textStorage] removeAttribute:NSForegroundColorAttributeName
                                                      range:resetArea];
                }
            }
        }
    }
    return;
}

- (int)ExecuteCode:(dataPos*)posData
{
    if(posData == nil)
        return -1;
    
    if(posData->ipx < 0 || posData->ipy < 0 || posData->dpx < 0 || posData->dpy < 0 ||
       posData->ipx == CODE_SIZE || posData->ipy == CODE_SIZE ||
       posData->dpx == CODE_SIZE || posData->dpy == CODE_SIZE ||
       code[posData->ipy][posData->ipx] == '\0' ||
       (code[posData->ipy][posData->ipx] == '#' && posData->stackSize == 0))
    {
        return -1;
    }
    //[[codeView textStorage] removeAttribute:NSForegroundColorAttributeName
    //                                  range:resetArea];
    if(posData->quoteMode && code[posData->ipy][posData->ipx] != '"')
    {
        data[posData->dataIndex][posData->dpy][posData->dpx++] = code[posData->ipy][posData->ipx];
    }
    else
    {
        switch (code[posData->ipy][posData->ipx]) {
            case '+':
                data[posData->dataIndex][posData->dpy][posData->dpx]++;
                break;
            case '-':
                data[posData->dataIndex][posData->dpy][posData->dpx]--;
                break;
            case '>':
                posData->dpx++;
                break;
            case '<':
                posData->dpx--;
                break;
            case '.':
                [output appendString:[NSString stringWithFormat:@"%c",
                                      data[posData->dataIndex][posData->dpy][posData->dpx]]];
                break;
            case '\\':
                [self ChangeDirection:posData direction:DIR_RIGHT];
                break;
            case '/':
                [self ChangeDirection:posData direction:DIR_LEFT];
                break;
            case '@':
                [self PushToStack:posData];
                break;
            case '#':
                [self PopFromStack:posData];
                [self MoveCodePos:posData];
                break;
            case '!':
                [self MoveCodePos:posData];
                break;
            case '?':
                if(data[posData->dataIndex][posData->dpy][posData->dpx] == 0)
                    [self MoveCodePos:posData];
                break;
            case ',':
                [self ReadDataAtPos:posData];
                break;
            case ':':
                posData->dpy--;
                break;
            case ';':
                posData->dpy++;
                break;
            case '%':
                if(data[posData->dpy][posData->dpx] > 0)
                {
                    data[posData->dataIndex][posData->dpy][posData->dpx] = rand() %
                    data[posData->dataIndex][posData->dpy][posData->dpx];
                }
                break;
            case '&':
                // threading
                [self CreateNewThread:posData];
                break;
            case '^':
                data[posData->dataIndex][posData->dpy][posData->dpx] =
                data[posData->dataIndex][posData->dpy][posData->dpx] * data[posData->dataIndex][posData->dpy][posData->dpx];
                break;
            case '"':
                if(posData->quoteMode == YES)
                    posData->quoteMode = NO;
                else
                    posData->quoteMode = YES;
                break;
            case 'Y':
                // fork you!
                // So, this creates a new thread with its own data field
                // Sets the current value of the current cell in the parent
                // to 0, and to 1 in the child.
                // The data in the child is a COPY of the main memory,
                // but still separate.
                // Also creates a pipe.. The output '.' of the parent is the
                // input ',' of the child
                // Also no need to increment the instruction pointer an additional time
                // Just let it go!
                break;
            default:
                break;
        }
    }
    NSLog(@"%c %d %d %d", code[posData->ipy][posData->ipx],
          data[posData->dataIndex][posData->dpy][posData->dpx], posData->ipy, posData->ipx);
    [self MoveCodePos:posData];
    [[self outputField]setStringValue:output];
    NSLog(@"%@", output);
    return [self GetCodePos:posData];
}

- (void)CreateNewThread:(dataPos *)posData
{
    dataPos *new = [[dataPos alloc] init];
    new->ipx = posData->ipx;
    new->ipy = posData->ipy;
    new->dpx = posData->dpx;
    new->dpy = posData->dpy;
    new->direction = posData->direction;
    [self MoveCodePos:new];
    [self MoveCodePos:posData];
    [threads addObject:new];
}

- (void)ReadDataAtPos:(dataPos*)posData
{
    NSString *inp = [[self InputField] stringValue];
    if(readPos < [inp length])
    {
        data[posData->dataIndex][posData->dpy][posData->dpx] = [inp characterAtIndex:readPos];
        readPos++;
    }
}

- (int)GetCodePos:(dataPos*)posData
{
    int ret = 0;
    int newlineCount = 0;
    char cur;
    int i;
    NSString *test = [[codeView textStorage] string];
    // so the number of new line characters to pass is in ipy
    // then offset from that is in ipx
    for(i = 0; i < [test length]; i++)
    {
        cur = [test characterAtIndex:i];
        if(newlineCount == posData->ipy)
            break;
        if(cur == '\n')
            newlineCount++;
    }
    if(i == [test length])
    {
        return i-1;
    }
    
    ret = i+posData->ipx;
    while(ret >= ([test length]))
          ret--;
    return ret;
}

- (void)ChangeDirection:(dataPos*) posData direction:(int)newDir
{
    /*posData->direction += newDir;
    if(posData->direction == 0)
        posData->direction = UP;
    else if(posData->direction == 5)
        posData->direction = RIGHT;*/
    if(posData->direction == RIGHT)
    {
        if(newDir != DIR_LEFT)
        {
            posData->direction = DOWN;
        }
        else
        {
            posData->direction = UP;
        }
    }
    else if(posData->direction == LEFT)
    {
        if(newDir != DIR_LEFT)
        {
            posData->direction = UP;
        }
        else
        {
            posData->direction = DOWN;
        }
    }
    else if(posData->direction == DOWN)
    {
        if(newDir != DIR_LEFT)
        {
            posData->direction = RIGHT;
        }
        else
        {
            posData->direction = LEFT;
        }
    }
    else if(posData->direction == UP)
    {
        if(newDir != DIR_LEFT)
        {
            posData->direction = LEFT;
        }
        else
        {
            posData->direction = RIGHT;
        }
    }
}

- (void)MoveCodePos:(dataPos*)posData
{
    switch (posData->direction) {
        case RIGHT:
            posData->ipx++;
            break;
        case LEFT:
            posData->ipx--;
            break;
        case UP:
            posData->ipy--;
            break;
        case DOWN:
            posData->ipy++;
            break;
            
        default:
            break;
    }
}

- (void)ResetData
{
    for(int i = 0; i < CODE_SIZE; i++)
    {
        for(int j = 0; j < CODE_SIZE; j++)
        {
            for(int k = 0; k < MAX_PROC_COUNT; k++)
            {
                data[k][i][j] = 0;
            }
            code[i][j] = 0;
        }
    }
    [threads removeAllObjects];
    //data[0][0] = 65;
    readPos = 0;
    startIPX = 0;
    startIPY = 0;
    output = [NSMutableString stringWithString:@""];
}

- (void)Parse
{
    NSString *test = [[codeView textStorage] string];
    int linePos = 0;
    int rowPos = 0;
    char cur;
    int ipx = 0;
    int ipy = 0;
    
    for(int i = 0; i < [test length]; i++)
    {
        cur = [test characterAtIndex:i];
        if(cur == '\n')
        {
            linePos++;
            rowPos = 0;
            continue;
        }
        if(cur == '$' && ipx == 0 && ipy == 0)
        {
            ipy = linePos;
            ipx = rowPos;
        }
        code[linePos][rowPos] = cur;
        rowPos++;
    }
    dataPos *new = [[dataPos alloc] init];
    new->direction = RIGHT;
    new->ipx = ipx;
    new->ipy = ipy;
    new->dpx = 0;
    new->dpy = 0;
    [threads addObject:new];
    startIPX = ipx;
    startIPY = ipy;
}

- (IBAction)Run:(id)sender {
    [self ResetData];
    [self Parse];
    if(executeThread != nil)
    {
        [executeThread cancel];
        executeThread = nil;
    }
    executeThread = [[NSThread alloc] initWithTarget:self
                                            selector:@selector(ExecuteThread)
                                              object:nil];
    [executeThread start];
}
@end
