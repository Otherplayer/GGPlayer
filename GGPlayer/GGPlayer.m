//
//  GGPlayer.m
//  GGPlayer
//
//  Created by __无邪_ on 15/4/25.
//  Copyright (c) 2015年 __无邪_. All rights reserved.
//

#import "GGPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "TTRangeSlider.h"

const CGFloat ContainerViewHeight = 44.0f;
const CGFloat PauseButtonWidth = 44.0f;

typedef NS_ENUM(NSInteger, GGControlViewState){
    GGControlViewState_IsHidden,
    GGControlViewState_IsShow,
};

@interface GGPlayer ()<TTRangeSliderDelegate>
@property (nonatomic, strong)MPMoviePlayerController *moviePlayer;

@property (nonatomic, strong)UIView *bottomContainerView;
@property (nonatomic, strong)UIView *topContainerView;
@property (nonatomic, strong)UIView *centerControlView;
@property (nonatomic, unsafe_unretained)GGControlViewState controlViewState;
@property (nonatomic, strong)NSTimer *autoHiddenControlTimer;
@property (nonatomic, strong)NSTimer *shouldAutoStartTimer;
@property (nonatomic, strong)UIButton *pauseButton;
@property (nonatomic, strong)TTRangeSlider *progressView;
@property (nonatomic, unsafe_unretained)BOOL isPlaying;

@end
@implementation GGPlayer



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initializeVideoPlayer];
        [self initializePlayerControl];
        [self installGesture];
        [self registerNotification];
        
        [self setControlViewState:GGControlViewState_IsShow];
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializeVideoPlayer];
        [self initializePlayerControl];
        [self installGesture];
        [self registerNotification];
        
        [self setControlViewState:GGControlViewState_IsShow];
    }
    return self;
}

#pragma mark - Public
- (void)play{
    NSLog(@"%d",self.moviePlayer.isPreparedToPlay);
    self.isPlaying = NO;
    [self.moviePlayer play];
//    if (self.moviePlayer.isPreparedToPlay) {
//        [self.progressView setMinValue:0];
//        [self.progressView setMaxValue:self.moviePlayer.playableDuration];
//    }
//    else{
//    }
}
- (void)stop{
    [self.moviePlayer stop];
}
- (void)pause{
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self.moviePlayer pause];
    }
    else{
        [self play];
    }
}

#pragma mark - Init

- (void)initializeVideoPlayer{
    // Video file
    NSString *filePathStr = [[NSBundle mainBundle] pathForResource:@"example" ofType:@"mp4"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePathStr];
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:fileURL];
    self.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    [self.moviePlayer setShouldAutoplay:NO];
    [self.moviePlayer prepareToPlay];
    [self.moviePlayer.view setBackgroundColor:[UIColor colorWithRed:0.502 green:0.000 blue:0.000 alpha:1.000]];
    [self.moviePlayer.view setFrame:CGRectMake(0, 0, VideoWidth, VideoHeight)];
    [self addSubview:self.moviePlayer.view];
    
    
}

- (void)initializePlayerControl{
    
    self.topContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VideoWidth, ContainerViewHeight)];
    self.bottomContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, VideoHeight - ContainerViewHeight, VideoWidth, ContainerViewHeight)];
    self.centerControlView = [[UIView alloc] initWithFrame:CGRectMake(0, ContainerViewHeight, VideoWidth, VideoHeight - 2 * ContainerViewHeight)];
    [self addSubview:self.centerControlView];
    [self addSubview:self.topContainerView];
    [self addSubview:self.bottomContainerView];
    
    [self.topContainerView setUserInteractionEnabled:NO];
//    [self.bottomContainerView setUserInteractionEnabled:NO];
    [self.centerControlView setUserInteractionEnabled:YES];
    
    [self.topContainerView setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.3500]];
    [self.bottomContainerView setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.3500]];
    [self.centerControlView setBackgroundColor:[UIColor clearColor]];
    
    
    self.pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(VideoWidth - PauseButtonWidth * 1.5, VideoHeight - 2 * ContainerViewHeight - PauseButtonWidth - 5, PauseButtonWidth, PauseButtonWidth)];
    [self.pauseButton setBackgroundColor:[UIColor colorWithWhite:1.000 alpha:0.3500]];
    [self.centerControlView addSubview:self.pauseButton];
    [self.pauseButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.progressView = [[TTRangeSlider alloc] initWithFrame:CGRectMake(10, 0, VideoWidth - 150, ContainerViewHeight)];
    [self.bottomContainerView addSubview:self.progressView];
    [self.progressView setUserInteractionEnabled:YES];
    [self.progressView setDelegate:self];
    [self.progressView setMinValue:0];
    [self.progressView setSelectedMinimum:0];
    [self.progressView setMinLabelColour:[UIColor groupTableViewBackgroundColor]];
    
}

- (void)installGesture{
    [self setUserInteractionEnabled:YES];
    UITapGestureRecognizer *controlTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controlViewAction)];
    [self.centerControlView addGestureRecognizer:controlTapGesture];
}


- (void)controlViewAction{
    if (self.controlViewState == GGControlViewState_IsShow) {
        [self hideControlView];
    }
    else{
        [self showControlView];
    }
}
- (void)showControlView{
    [UIView animateWithDuration:0.25 animations:^{
        [self.bottomContainerView setFrame:CGRectMake(0, VideoHeight - ContainerViewHeight, VideoWidth, ContainerViewHeight)];
        [self.topContainerView setFrame:CGRectMake(0, 0, VideoWidth, ContainerViewHeight)];
        [self.pauseButton setFrame:CGRectMake(VideoWidth - PauseButtonWidth * 1.5, VideoHeight - 2 * ContainerViewHeight - PauseButtonWidth - 5, PauseButtonWidth, PauseButtonWidth)];
        [self.progressView setAlpha:1];
    } completion:^(BOOL finished) {
        [self setControlViewState:GGControlViewState_IsShow];
        [self autoHiddenControlTimer];
    }];
}
- (void)hideControlView{
    [UIView animateWithDuration:0.25 animations:^{
        [self.bottomContainerView setFrame:CGRectMake(0, VideoHeight, VideoWidth, 0)];
        [self.topContainerView setFrame:CGRectMake(0, 0, VideoWidth, 0)];
        [self.pauseButton setFrame:CGRectMake(VideoWidth - PauseButtonWidth * 1.5, VideoHeight - 2 * ContainerViewHeight - PauseButtonWidth - 5, PauseButtonWidth, 0)];
        [self.progressView setAlpha:0];
    } completion:^(BOOL finished) {
        [self setControlViewState:GGControlViewState_IsHidden];
        [self killAutoHiddenTimer];
    }];
}




- (void)registerNotification{
    // Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationWillChange:)
                                                 name:UIApplicationWillChangeStatusBarFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterFullscreen:)
                                                 name:MPMoviePlayerWillEnterFullscreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterFullscreen:)
                                                 name:MPMoviePlayerDidEnterFullscreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willExitFullscreen:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieLoadStateChange:)
                                                 name:MPMoviePlayerReadyForDisplayDidChangeNotification
                                               object:nil];
    

}

#pragma mark - Action

#pragma mark - Delegate

-(void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum{
    
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        self.isPlaying = YES;
    }
    [self killAutoHiddenTimer];
    [self.moviePlayer pause];
    [self.moviePlayer setCurrentPlaybackTime:selectedMinimum];
    if (self.isPlaying) {
        [self shouldAutoStartTimer];
    }
    
    NSLog(@"%f",selectedMinimum);
}

#pragma mark - Notifications

- (void)playbackStateDidChange:(NSNotification *)notification{
    switch (self.moviePlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:{
            [self autoHiddenControlTimer];
        }
            break;
        case MPMoviePlaybackStateStopped:
            break;
        case MPMoviePlaybackStatePaused:{
            [self killAutoHiddenTimer];
        }
            break;
        case MPMoviePlaybackStateInterrupted:
            break;
        case MPMoviePlaybackStateSeekingForward:
            break;
        case MPMoviePlaybackStateSeekingBackward:
            break;
        default:
            break;
    }
    
NSLog(@"--%s--%lu",__func__,self.moviePlayer.playbackState);
}
- (void)playbackDidFinish:(NSNotification *)notification{
NSLog(@"--%s--",__func__);
}
- (void)orientationWillChange:(NSNotification *)notification{
NSLog(@"--%s--",__func__);
}
- (void)orientationDidChange:(NSNotification *)notification{
NSLog(@"--%s--",__func__);
}
- (void)willEnterFullscreen:(NSNotification *)notification{
NSLog(@"--%s--",__func__);
}
- (void)didEnterFullscreen:(NSNotification *)notification{
NSLog(@"--%s--",__func__);
}
- (void)willExitFullscreen:(NSNotification *)notification{
NSLog(@"--%s--",__func__);
}
-(void)movieLoadStateChange:(NSNotification *)notification{
NSLog(@"--%s--",__func__);
    [self.progressView setMaxValue:self.moviePlayer.playableDuration - 2];
    [self.progressView setSelectedMaximum:self.moviePlayer.playableDuration];
}


#pragma mark - Others

-(NSTimer *)autoHiddenControlTimer{
    if (!_autoHiddenControlTimer) {
        _autoHiddenControlTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideControlView) userInfo:nil repeats:NO];
    }
    return _autoHiddenControlTimer;
}

- (void)killAutoHiddenTimer{
    if (self.autoHiddenControlTimer) {
        [self.autoHiddenControlTimer invalidate];
        self.autoHiddenControlTimer = nil;
    }
}

-(NSTimer *)shouldAutoStartTimer{
    if (_shouldAutoStartTimer) {
        [_shouldAutoStartTimer invalidate];
        _shouldAutoStartTimer = nil;
    }
    _shouldAutoStartTimer = [NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(play) userInfo:nil repeats:NO];
    return _shouldAutoStartTimer;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
