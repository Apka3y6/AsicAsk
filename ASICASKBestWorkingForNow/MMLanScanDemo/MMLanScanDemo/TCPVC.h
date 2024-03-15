//
//  TCPVC.h
//  MMLanScanDemo
//
//  Created by Dmitrii Vilgauk on 22.02.2024.
//  Copyright © 2024 Miksoft. All rights reserved.
//
///DEFAULT
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface TCPVC : UIViewController <UITextViewDelegate>
- (IBAction)DIssmissKeyboard:(id)sender;

@property (nonatomic, strong) NSString *selectedIpAddress;

@end

NS_ASSUME_NONNULL_END
///DEFAULT
