//
//  TLHMViewController.h
//  HelloMyo
//
//  Copyright (c) 2013 Thalmic Labs. All rights reserved.
//  Distributed under the Myo SDK license agreement. See LICENSE.txt.
//

#import <UIKit/UIKit.h>
@class GTMOAuth2Authentication;

@interface TLHMViewController : UIViewController
@property (nonatomic, assign) BOOL startRecording;
@property (nonatomic, assign) BOOL recentPoseIsSqueeze;
- (IBAction)signinpressed:(id)sender;
@property (nonatomic, strong) GTMOAuth2Authentication*authorizer;
@property (nonatomic, strong) TLHMViewController* myocontroller;

@end
