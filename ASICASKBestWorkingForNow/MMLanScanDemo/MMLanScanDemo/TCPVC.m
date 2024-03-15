//
//  TCPVC.m
//  MMLanScanDemo
//
//  Created by Dmitrii Vilgauk on 22.02.2024.
//  Copyright © 2024 Miksoft. All rights reserved.
//
#import "TCPVC.h"

@interface TCPVC () <NSStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextView *receivedDataTextView;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatusLabel;
@property (weak, nonatomic) IBOutlet UITextField *currentHostAddress;

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, assign) BOOL isConnected;

@end

@implementation TCPVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isConnected = NO;
    self.receivedDataTextView.layer.borderColor = [UIColor grayColor].CGColor;
    self.receivedDataTextView.layer.borderWidth = 1.0;
    self.receivedDataTextView.layer.cornerRadius = 8.0;
    self.currentHostAddress.text = _selectedIpAddress;
}

- (IBAction)connectButtonPressed:(UIButton *)sender {
    if (self.isConnected) {
        [self disconnect];
    } else {
        [self connect];
    }
}

- (void)connect {
    NSString *hostInput = self.currentHostAddress.text; // Assuming you set the currentHostAddress property from MainVC
    NSString *portString = @"4028"; // Adjust port number as needed
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    [NSStream getStreamsToHostWithName:hostInput port:portString.intValue inputStream:&inputStream outputStream:&outputStream];
    
    self.inputStream = inputStream;
    self.outputStream = outputStream;
    
    self.inputStream.delegate = self;
    self.outputStream.delegate = self;
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.inputStream open];
    [self.outputStream open];
}

- (void)disconnect {
    [self.inputStream close];
    [self.outputStream close];
}

- (IBAction)sendStatsCommand:(UIButton *)sender {
    [self sendCommand:@"stats"];
}

- (IBAction)sendSummaryCommand:(UIButton *)sender {
    [self sendCommand:@"summary"];
}

- (IBAction)sendEdevsCommand:(UIButton *)sender {
    [self sendCommand:@"edevs"];
}

- (IBAction)sendPoolsCommand:(UIButton *)sender {
    [self sendCommand:@"ascset|0,reboot,0"];
}

- (void)sendCommand:(NSString *)command {
    NSData *data = [command dataUsingEncoding:NSUTF8StringEncoding];
    [self.outputStream write:data.bytes maxLength:data.length];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable: {
            NSMutableData *data = [NSMutableData data];
            uint8_t buffer[1024];
            NSInteger len;
            while ([self.inputStream hasBytesAvailable]) {
                len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
                if (len > 0) {
                    [data appendBytes:buffer length:len];
                }
            }
            NSString *receivedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Received message: %@", receivedString);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Append new text to the existing text
                NSString *existingText = self.receivedDataTextView.text;
                NSString *updatedText = [existingText stringByAppendingFormat:@"%@\n", receivedString];
                self.receivedDataTextView.text = updatedText;
                
                // Optionally, scroll to the bottom of the text view
                NSRange range = NSMakeRange(updatedText.length - 1, 1);
                [self.receivedDataTextView scrollRangeToVisible:range];
            });
            break;
        }
        case NSStreamEventErrorOccurred:
            NSLog(@"Error occurred");
            [self handleStreamError];
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"End encountered");
            [self handleStreamError];
            break;
        case NSStreamEventOpenCompleted:
            NSLog(@"Connection opened");
            [self handleStreamOpened];
            break;
        default:
            break;
    }
}

- (void)handleStreamError {
    self.isConnected = NO;
    self.connectionStatusLabel.text = @"Disconnected";
    self.connectionStatusLabel.textColor = [UIColor redColor];
}

- (void)handleStreamOpened {
    self.isConnected = YES;
    self.connectionStatusLabel.text = @"Connected";
    self.connectionStatusLabel.textColor = [UIColor greenColor];
}

- (IBAction)DIssmissKeyboard:(id)sender {
    [sender resignFirstResponder];
}
@end

