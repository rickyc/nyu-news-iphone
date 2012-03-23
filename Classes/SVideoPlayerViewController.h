//
//  SVideoPlayerViewController.h
//  NYUWSN
//
//  Created by Ricky Cheng on 8/4/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SVideoPlayerViewController : UIViewController {
	MPMoviePlayerController *moviePlayer;
}

@property(readwrite, retain) MPMoviePlayerController *moviePlayer;

- (void)initAndPlayMovie:(NSURL *)movieURL;
- (void)setMoviePlayerUserSettings;
- (void)playVideo:(NSString *)videoPath;

@end