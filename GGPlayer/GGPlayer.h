//
//  GGPlayer.h
//  GGPlayer
//
//  Created by __无邪_ on 15/4/25.
//  Copyright (c) 2015年 __无邪_. All rights reserved.
//

#import <UIKit/UIKit.h>

#define VideoWidth [[UIScreen mainScreen] bounds].size.width
#define VideoHeight (VideoWidth * 9 / 16.0)
@interface GGPlayer : UIView


- (void)play;
- (void)stop;
- (void)pause;


@end
