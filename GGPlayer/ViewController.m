//
//  ViewController.m
//  GGPlayer
//
//  Created by __无邪_ on 15/4/25.
//  Copyright (c) 2015年 __无邪_. All rights reserved.
//

#import "ViewController.h"
#import "GGPlayer.h"

@interface ViewController ()
@property (nonatomic, strong)GGPlayer *moviePlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.moviePlayer = [[GGPlayer alloc] initWithFrame:CGRectMake(0, 64, VideoWidth, VideoHeight)];
    [self.view addSubview:self.moviePlayer];
    
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self.moviePlayer play];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
