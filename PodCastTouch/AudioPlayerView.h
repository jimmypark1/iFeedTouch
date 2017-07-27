//
//  AudioPlayerView.h
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 16..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKAudioPlayer.h"

@class AudioPlayerView;


@interface AudioPlayerView : UIView<STKAudioPlayerDelegate>

@property (readwrite, retain) STKAudioPlayer* audioPlayer;

@end
