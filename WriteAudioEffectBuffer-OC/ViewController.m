//
//  ViewController.m
//  WriteAudioEffectBuffer-OC
//
//  Created by Bruce on 16/6/28.
//  Copyright © 2016年 Bruce. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (nonatomic, strong) AVAudioEngine *engine;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVAudioInputNode *intput = self.engine.inputNode;
    AVAudioOutputNode *output = self.engine.outputNode;
    
    AVAudioUnitReverb *reverb = [[AVAudioUnitReverb alloc] init];
    [reverb loadFactoryPreset:AVAudioUnitReverbPresetPlate];
    reverb.wetDryMix = 60;
    [self.engine attachNode:reverb];
    
    AVAudioUnitDelay *delay = [[AVAudioUnitDelay alloc] init];
    delay.delayTime = 0.5;
    [self.engine attachNode:delay];
    
    AVAudioMixerNode *mixer = [[AVAudioMixerNode alloc] init];
    mixer.volume = 80;
    [self.engine attachNode:mixer];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"audio.caf"];
    
    NSError *error;
    __block AVAudioFile *audioFile = [[AVAudioFile alloc] initForWriting:[NSURL fileURLWithPath:path] settings:@{} error:&error];
    [mixer installTapOnBus:0 bufferSize:8192 format:[intput inputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        NSError *error;
        [audioFile writeFromBuffer:buffer error:&error];
    }];
    
    [self.engine connect:intput to:reverb format:[intput inputFormatForBus:0]];
    [self.engine connect:reverb to:delay format:[intput inputFormatForBus:0]];
    [self.engine connect:delay to:mixer format:[intput inputFormatForBus:0]];
    [self.engine connect:mixer to:output format:[intput inputFormatForBus:0]];
    
    NSLog(@"%@",path);
}

- (void)start{
    
    NSError *error;
    [self.engine startAndReturnError:&error];
    if (error) {
        NSLog(@"%@",error.description);
    }
}

- (void)stop{
    
    [self.engine.inputNode removeTapOnBus:0];
    [self.engine stop];
}

- (IBAction)control:(id)sender {
    UIButton *button = sender;
    button.selected = button.selected!=YES ? YES:NO;
    button.selected==YES ? [self start]:[self stop];
}

- (AVAudioEngine *)engine{
    if (!_engine) {
        _engine = [[AVAudioEngine alloc] init];
    }
    return _engine;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
