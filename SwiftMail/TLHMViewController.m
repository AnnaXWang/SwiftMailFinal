//
//  TLHMViewController.m
//  HelloMyo
//
//  Copyright (c) 2013 Thalmic Labs. All rights reserved.
//  Distributed under the Myo SDK license agreement. See LICENSE.txt.
//
#import "TLHMViewController.h"
#import <MyoKit/MyoKit.h>
#import "SendViewController.h"

#import "AppDelegate.h"
#import "SendViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"

@interface TLHMViewController ()

//Our properties
- (IBAction)connectMyo:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *connectionLabel;
@property (strong, nonatomic) IBOutlet UILabel *stepArmsyncLabel;
@property (strong, nonatomic) IBOutlet UILabel *armSyncedLabel;
@property (strong, nonatomic) IBOutlet UILabel *stepUnlockLabel;
@property (strong, nonatomic) IBOutlet UILabel *lockedLabel;
@property (strong, nonatomic) IBOutlet UILabel *stepGoToSignin;


//Important info about pose
@property (strong, nonatomic) TLMPose *currentPose;


@end
@implementation TLHMViewController
@synthesize startRecording;
@synthesize recentPoseIsSqueeze;


#pragma mark - View Lifecycle

- (id)init {
    // Initialize our view controller with a nib (see TLHMViewController.xib).
    self = [super initWithNibName:@"TLHMViewController" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *notificationName = @"recordNotification";
    [[NSNotificationCenter defaultCenter] postNotificationName: notificationName
                                                        object: self];
    
    // Data notifications are received through NSNotificationCenter.
    // Posted whenever a TLMMyo connects
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnectDevice:)
                                                 name:TLMHubDidConnectDeviceNotification
                                               object:nil];
    // Posted whenever a TLMMyo disconnects.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDisconnectDevice:)
                                                 name:TLMHubDidDisconnectDeviceNotification
                                               object:nil];
    // Posted whenever the user does a successful Sync Gesture.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSyncArm:)
                                                 name:TLMMyoDidReceiveArmSyncEventNotification
                                               object:nil];
    // Posted whenever Myo loses sync with an arm (when Myo is taken off, or moved enough on the user's arm).
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUnsyncArm:)
                                                 name:TLMMyoDidReceiveArmUnsyncEventNotification
                                               object:nil];
    // Posted whenever Myo is unlocked and the application uses TLMLockingPolicyStandard.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUnlockDevice:)
                                                 name:TLMMyoDidReceiveUnlockEventNotification
                                               object:nil];
    // Posted whenever Myo is locked and the application uses TLMLockingPolicyStandard.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLockDevice:)
                                                 name:TLMMyoDidReceiveLockEventNotification
                                               object:nil];
    // Posted when a new orientation event is available from a TLMMyo. Notifications are posted at a rate of 50 Hz.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveOrientationEvent:)
                                                 name:TLMMyoDidReceiveOrientationEventNotification
                                               object:nil];
    // Posted when a new accelerometer event is available from a TLMMyo. Notifications are posted at a rate of 50 Hz.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveAccelerometerEvent:)
                                                 name:TLMMyoDidReceiveAccelerometerEventNotification
                                               object:nil];
    // Posted when a new pose is available from a TLMMyo.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePoseChange:)
                                                 name:TLMMyoDidReceivePoseChangedNotification
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotificationCenter Methods
//
// Connection Method
//
- (IBAction)connectMyo:(id)sender {
    UINavigationController *controller = [TLMSettingsViewController settingsInNavigationController];
    // Present the settings view controller modally.
    [self presentViewController:controller animated:YES completion:nil];
}


- (void)didConnectDevice:(NSNotification *)notification {
    NSLog(@"Connection Status: Connected");
    self.connectionLabel.textColor = [UIColor greenColor];
    self.connectionLabel.text = @"Connection Status: Connected";
}

- (void)didDisconnectDevice:(NSNotification *)notification {
    NSLog(@"Connection Status: Not Connected");
    self.connectionLabel.textColor = [UIColor redColor];
    self.connectionLabel.text = @"Connection Status: Not Connected";
}



- (void)didSyncArm:(NSNotification *)notification {
    NSLog(@"Armsync Status: Synced");
    self.armSyncedLabel.textColor = [UIColor greenColor];
    self.armSyncedLabel.text = @"Armsync Status: Synced";
}

- (void)didUnsyncArm:(NSNotification *)notification {
    NSLog(@"Armsync Status: Not Synced");
    self.armSyncedLabel.textColor = [UIColor redColor];
    self.armSyncedLabel.text = @"Armsync Status: Not Synced";
}

- (void)didUnlockDevice:(NSNotification *)notification {
    NSLog(@"Lock Status: Unlocked");
    self.lockedLabel.textColor = [UIColor greenColor];
    self.lockedLabel.text = @"Lock Status: Unlocked";
    //This should permalock, but might not.
    TLMMyo *myo = [[[TLMHub sharedHub] myoDevices] objectAtIndex:0];
    [myo unlockWithType:TLMUnlockTypeHold];
}

- (void)didLockDevice:(NSNotification *)notification {
    NSLog(@"Lock Status: Locked");
    self.lockedLabel.textColor = [UIColor redColor];
    self.lockedLabel.text = @"Lock Status: Locked";
    
    //This should immediately unlock if it ever locks. should not be necessary.
    //TLMMyo *myo = [[[TLMHub sharedHub] myoDevices] objectAtIndex:0];
    //[myo unlockWithType:TLMUnlockTypeHold];
}


//
// Pose change callbacks!
//
- (void)didReceivePoseChange:(NSNotification *)notification {
    NSLog(@"Pose received");
    // Retrieve the pose from the NSNotification's userInfo with the kTLMKeyPose key.
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    self.currentPose = pose;
    
    switch (pose.type) {
        case TLMPoseTypeFist: {
            NSLog(@"Fkst pose");
            // Changes helloLabel's font to Noteworthy when the user is in a fist pose.
            NSNotification *notification = [NSNotification
                                            notificationWithName: @"recordNotification" object: self];
            [[NSNotificationCenter defaultCenter] postNotification: notification];
            break;
        } case TLMPoseTypeFingersSpread: {
            NSLog(@"Finger spread pose");
            //If we have a squeeze change state, send a notification saying that
            //the recording button has been pushed.
            /*if (!recentPoseIsSqueeze) {
                //NSLog(@"Recording Button Pressed");
                NSNotification *notification = [NSNotification
                                                notificationWithName: @"recordNotification" object: self];
                [[NSNotificationCenter defaultCenter] postNotification: notification];
                
                
                //self.recordingStatus.text = @"--Recording--";
                //self.recordingStatus.textColor = [UIColor redColor];
                recentPoseIsSqueeze = true;
                
            }*/
            break;
        } default: {
            NSLog(@"Oter pose");
            recentPoseIsSqueeze = false;
            //Do nothing: Only notify if we've squeezed
            
            /**NSLog(@"Not Recording");
             recordingBool = false;
             NSNotification *notification = [NSNotification
             notificationWithName: @"recordNotification" object: self];
             [[NSNotificationCenter defaultCenter] postNotification: notification];
             
             self.recordingStatus.text = @"--Not Recording--";
             self.recordingStatus.textColor = [UIColor blackColor];
             break; */
        }
    }
}


//
// Acceleration change callbacks!
//
- (void)didReceiveAccelerometerEvent:(NSNotification *)notification {
    /*TLMAccelerometerEvent *accelerometerEvent = notification.userInfo[kTLMKeyAccelerometerEvent];
    // Get the acceleration vector from the accelerometer event.
    TLMVector3 accelerationVector = accelerometerEvent.vector;
    // Calculate the magnitude of the acceleration vector.
    float magnitude = TLMVector3Length(accelerationVector);
    if (magnitude > 2) {
        NSNotification *notificationOne = [NSNotification
                                    notificationWithName: @"recordNotification" object: self];
        [[NSNotificationCenter defaultCenter] postNotification: notificationOne];
    } */
    //Do Nothing
}


//
// Orientation Callback!
//
- (void)didReceiveOrientationEvent:(NSNotification *)notification {
    //Do nothing
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showEmailPage"]) {
        SendViewController* view = segue.destinationViewController;
        view.auth = self.authorizer;
        view.myocontroller = self.myocontroller;
    }
}

- (IBAction)signinpressed:(id)sender {
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope: @"https://www.googleapis.com/auth/gmail.compose" clientID:@"299527735277-qsa1kafh00vps2j38u6shfib8qbu5de6.apps.googleusercontent.com" clientSecret:@"pt5FnxhfDPWWGiL8sRuSzOYr" keychainItemName:@"OAuth2 Sample: Gmail" completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
        if (error == nil){
            self.authorizer = auth;
            NSLog(@"success");
            [self dismissViewControllerAnimated:YES completion:^{
                [self
                 performSegueWithIdentifier:@"showEmailPage" sender:self];
            }];
            
        } else {
            NSLog(@"failed %@", error);
        }
    }];
    [self presentViewController:viewController animated:YES completion:^{
    }];

}
-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails{
    NSLog(@"%@", errorShortDescription);
    NSLog(@"%@", errorDetails);
}

-(void)errorInResponseWithBody:(NSString *)errorMessage{
    NSLog(@"%@", errorMessage);
}

-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData{
}

-(void)accessTokenWasRevoked{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Your access was revoked!"
                                                   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
    
}


@end
