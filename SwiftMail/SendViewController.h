//
//  SendViewController.h
//  SwiftMail
//
//  Created by Griffin Koontz on 2/21/15.
//  Copyright (c) 2015 Anna Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/OEEventsObserver.h>
#import "TLHMViewController.h"
@class GTMOAuth2Authentication;

@interface SendViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *toField;
@property (strong, nonatomic) IBOutlet UITextField *fromField;
@property (strong, nonatomic) IBOutlet UITextView *mainTextField;


/*@property (weak, nonatomic) IBOutlet UITextField *toField;
@property (weak, nonatomic) IBOutlet UITextField *fromField;
@property (weak, nonatomic) IBOutlet UITextView *mainTextField;*/
- (IBAction)send:(id)sender;
@property (strong, nonatomic) TLHMViewController* myocontroller;

- (void) realToggleRecording;
@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;
@property (strong, nonatomic) NSString *lmPath;
@property (strong, nonatomic) NSString *dicPath;
@property (nonatomic) BOOL engineStarted;
- (IBAction)toggleRecording:(id)sender;
@property (nonatomic, getter=isListening) BOOL listening;
@property (weak, nonatomic) IBOutlet UIButton *button;
//@property (weak, nonatomic) IBOutlet UITextView *spokenWords;
- (void) recordingCallback:(NSNotification *) notification;

@property (strong, nonatomic) IBOutlet UILabel *recordingStatus;

@property (nonatomic, assign) BOOL currRecording;
@property (nonatomic, assign) int currView;
@property (strong, nonatomic) IBOutlet UILabel *sentButton;

@property (strong, nonatomic) NSString* accessToken;
@property (strong, nonatomic) GTMOAuth2Authentication *auth;

@end
