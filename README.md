# SwiftMailFinal (TreeHacks 2015 Submission)
*The Gmail You Love - Hands Free*

##### Inspiration/Use Case
```
Our team wanted to leverage Myo's functionality to allow the classic multitasker to send emails on-to-go. 
An ideal use case would be someone about to hop into their car for a long drive, but needs to send some 
time-sensitive messages. 
```

##### Functionality
```
- Upon launching the app, users sync the Myo to the iOS application and then log into Gmail.
- At this point, the experience becomes completely hands-free.
- Users clench their first to start/stop our voice recognition system to populate the 
"To", "Subject", and "Body".
- A final clench fires off the email.
```

##### APIs Used
```
* Gmail API
  * Google does not provide adequate documentation or references for Objective-C. To generate the 
  necessary OAuth2.0 access token, we implemented many wrapper classes and downloaded Google's source files
* OpenEars API
 * This API provided support for voice recognition. It works off a local dictionary of words that speeds up 
 the experience, but does pay for it with some accuracy
* Myo API
  * Myo commands were necessary to sync the device with our application
```
