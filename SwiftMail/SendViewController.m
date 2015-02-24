//
//  SendViewController.m
//  SwiftMail
//
//  Created by Griffin Koontz on 2/21/15.
//  Copyright (c) 2015 Anna Wang. All rights reserved.
//

#import "SendViewController.h"
#import "AppDelegate.h"
#import "GTLGmail.h"
#import "GTMOAuth2Authentication.h"
#import "GTLBase64.h"
#import "MCOMessageBuilder.h"
#import "MCOAddress.h"
#import "MCOMessageHeader.h"
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEAcousticModel.h>
#import "SendViewController.h"

@interface SendViewController ()

@end

@implementation SendViewController
@synthesize currRecording;
@synthesize currView;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    currView = 0;
    
    //ADD OBSERVER
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(recordingCallback:)
                                                 name: @"recordNotification"
                                               object: nil];
    
    
    // LOAD DICTIONARY
    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    
    NSArray *words = [NSArray arrayWithObjects:@"HELLO", @"Lunch plans",
                      @"GOODBYE", @"Let's get lunch at coho",
                      @"LETS GRAB LUNCH", @"JHCOHEN@STANFORD.EDU", @"cohenjosh10@gmail.com", @"IM AT YOUR DOOR", @"I MISS YOU", @"CHECK OUT MY PARTY PANTS",
                      @"ID LOVE TO SEE THOSE PHOTOS FROM YOUR TRIP", @"YOUR NEW HAIRCUT IS GREAT", @"BABY PLEASE COME BACK", @"CHECK OUT MY PARTY PANTS",
                      @"DISCOTHEQUE", @"ALEX BERTRAND", @"TREEHACKS WAS GREAT", @"NO SLEEP", @"LET'S CATCH UP", @"LET'S HANGOUT THIS WEEKEND", @"DID YOU SLEEP AT ALL", @"YAY WEARABLES", @"HEY", @"WHERE ARE YOU", @"CATCH YOU LATER", @"HELLO", @"YOU'RE GREAT", nil];
    NSString *name = @"NameIWantForMyLanguageModelFiles";
    NSError *err = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
    
    // initialize instance variables
    self.lmPath = nil;
    self.dicPath = nil;
    self.listening = NO;    // are we currently listening for words
    self.engineStarted = NO; // has recognition engine started
    
    // create language model
    if(err == nil) {
        self.lmPath = [lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"NameIWantForMyLanguageModelFiles"];
        self.dicPath = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"NameIWantForMyLanguageModelFiles"];
        
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
    
    // INSTANTIATE EVENTS OBSERVER
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) buildAndSendEmail{
    
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc]init];
    MCOAddress *from = [MCOAddress addressWithDisplayName:@"Anna Wang" mailbox:@"annawangx@gmail.com"];
    MCOAddress *to = [MCOAddress addressWithMailbox:@"annaxw@stanford.edu"];
    [builder.header setFrom:from];
    [builder.header setTo: @[to]];
    [builder.header setSubject:@"Let's Get Lunch"];
    [builder setHTMLBody:@"Treehacks was awesome!"];
    NSData* d = [builder data];
    GTLServiceGmail *service = [[GTLServiceGmail alloc] init];
    service.APIKey = @"AIzaSyB4gkYqj0FqiMGfml7JA1IG7PzQnTiMfaU";
    service.authorizer = self.auth;
    GTLGmailMessage* message = [[GTLGmailMessage alloc] init];
    NSMutableString* email = [NSMutableString new];
    [email appendString:@"Date: Fri, 14 Nov 2003 14:00:01 -0500<CRLF>"];
    [email appendString:@"Message-ID: <AauNjVuMhvq0000007c@elsewhere.com><CRLF>"];
    [email appendString:@"From: \"Mr. PostMaster\" <annawangx@gmail.com><CRLF>"];
    [email appendString:@"Reply-To: \"My Reply Account\" <postmaster_reply@elsewhere.com><CRLF>"];
    [email appendString:@"To: \"Mrs. Someone\" <annawangx@gmail.com><CRLF>"];
    [email appendString:@"To: \"Anna Wang\" <annaxw@stanford.edu><CRLF>"];
    [email appendString:@"Subject: Failure Notice<CRLF>"];
    [email appendString:@"<CRLF> Hi, This is Anna <CRLF> <CRLF"];
    NSData* nsdata = [email dataUsingEncoding:NSUTF8StringEncoding];
    message.raw = GTLEncodeWebSafeBase64(d);
    GTLQueryGmail *query = [GTLQueryGmail queryForUsersMessagesSendWithUploadParameters: nil];
    query.message = message;
    query.userId = @"annawangx@gmail.com";
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        NSLog(@"complete");
        [self performSegueWithIdentifier:@"proofOfConcept" sender:self];

    }];
}
- (IBAction)send:(id)sender {
    [self buildAndSendEmail];
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    if (self.currView == 0) {
        [self.toField setText:[@"Recipient: " stringByAppendingString:hypothesis]];
        self.currView = self.currView + 1;
        self.sentButton.text = @"Drafting0";
    } else if (self.currView == 1) {
        [self.fromField setText:[@"Subject: " stringByAppendingString:hypothesis]];
        self.currView = self.currView + 1;
        self.sentButton.text = @"Drafting1";
    } else if (self.currView == 2) {
        [self.mainTextField setText:[@"Email: " stringByAppendingString:hypothesis]];
        self.currView = self.currView + 1;
        self.sentButton.text = @"Drafting2";
    }
}


// has started listening
- (void) pocketsphinxDidStartListening {
    NSLog(@"Pocketsphinx is now listening.");
    [self.mainTextField setText:@"Listening now"];
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
    //[self.mainTextField setText:@"Finished speech"];
}

- (void) pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinx has stopped listening.");
    self.currView = self.currView + 1;
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) testRecognitionCompleted {
    NSLog(@"A test file that was submitted for recognition is now complete.");
}


// button action method
- (void) realToggleRecording {
    NSLog(@"realToggleRecording Called");
    if (!self.engineStarted) { // we only want to start the listening engine once
        NSLog(@"Starting engine");
        // START ENGINE
        [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.lmPath dictionaryAtPath:self.dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
        //[self.button setTitle:@"Stop Listening" forState:UIControlStateNormal];
        //[self.button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.listening = YES;
        self.engineStarted = YES;
    } else {
        if (!self.isListening) {
            NSLog(@"Resuming listening");
            [self.mainTextField setText:@"Resuming Listening"];
            [[OEPocketsphinxController sharedInstance] resumeRecognition]; // resume listening
            //[self.button setTitle:@"Stop Listening" forState:UIControlStateNormal];
            //[self.button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            self.listening = YES;
        } else {
            NSLog(@"Suspending listening");
            [self.mainTextField setText:@"Suspending Listening"];
            [[OEPocketsphinxController sharedInstance] suspendRecognition]; // suspend listening
            //[self.button setTitle:@"Start Listening" forState:UIControlStateNormal];
            //[self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            self.listening = NO;
        }
        
    }
}

- (IBAction)toggleRecording:(id)sender {
    if (!self.engineStarted) { // we only want to start the listening engine once
        NSLog(@"Starting engine");
        // START ENGINE
        [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.lmPath dictionaryAtPath:self.dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
        [self.button setTitle:@"Stop Listening" forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.listening = YES;
        self.engineStarted = YES;
    } else {
        if (!self.isListening) {
            NSLog(@"Resuming listening");
            //[self.mainTextField setText:@"Resuming Listening"];
            [[OEPocketsphinxController sharedInstance] resumeRecognition]; // resume listening
            //[self.button setTitle:@"Stop Listening" forState:UIControlStateNormal];
            //[self.button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            self.listening = YES;
        } else {
            NSLog(@"Suspending listening");
            //[self.mainTextField setText:@"Suspending Listening"];
            [[OEPocketsphinxController sharedInstance] suspendRecognition]; // suspend listening
            //[self.button setTitle:@"Start Listening" forState:UIControlStateNormal];
            //[self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            self.listening = NO;
        }
        
    }
}


- (void)recordingCallback:(NSNotification *)notification {
    NSLog(@"Callback received");
    if (self.currView == 3) {
        //Call send
        [self buildAndSendEmail];
        self.currView = 4;
        
    } else if (self.currView < 3) {
        if (currRecording == false) {
            NSLog(@"Turning recording on");
            currRecording = true;
            self.recordingStatus.textColor = [UIColor redColor];
            [self realToggleRecording];
        } else {
            NSLog(@"Turning recording off");
            currRecording = false;
            self.recordingStatus.textColor = [UIColor blackColor];
            [self realToggleRecording];
        }
    }
}

@end
