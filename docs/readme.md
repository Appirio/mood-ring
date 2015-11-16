My username is seriyvolk83
The fork of the project repository is https://github.com/seriyvolk83/mood-ring
The Deployment Guide is provided in docs/Deployment Guide
The sample Salesforce credentials provided in docs/TEST_CREDENTIALS
The sample video - https://youtu.be/RIObGwFff-M

Notes:
- If you will need a verification code for authentication on Salesforce, then please login on gmail.com with common.moodring.user@gmail.com/moodring and check emails from Salesforce.
- As in initial project there is a problem with running the app on a real device related to the Salesforce static libraries.
The Salesforce libraries are obtained from the official repository
https://github.com/forcedotcom/SalesforceMobileSDK-iOS but they are not working in Xcode 7.0+. You can try the provided sample projects in the SalesforceMobileSDK.xcworkspace from the repository. These projects are also cannot be launched due to linker error related to architecture. Hence, please use iOS simulator to verify the app for this prototype.
- The server does not support required fields for User object. The issue is fixed with sample data that is added in DemoMoodRingApi class. See how sample icons are added and avgAllProjectsRating property is set.
- If you have rated a ProjectUser you will be not able to rate it again. For verification I have added an option that allows to rate users without the limitation. Change
OPTION_ENABLE_MULTIPLE_RATINGS_FROM_ONE_PERSON in ProjectDetailsViewController.swift to true to enable.
- UI is prepared for custom login screen. All UI can be shown if OPTION_USE_CUSTOM_LOGIN_SCREEN option in LoginViewController.swift is on (true). However, as it was discussed in the forum it not yet implemented due to some Salesforce SDK limitations.

If you will encounter problems with using provided sample credentials you will need to register and generate new Salesforce credentials:
1. Register on Salesforce website - https://developer.salesforce.com/signup
2. Create a connected app and select OAuth while creating it.
Copy and configure API key and callback in the app.
3. Create new or use you main user to authenticate in the app.
For more information refer to Salesforce iOS SDK documentation.
Also you will need to follow the DG from 2nd challenge to setup unmanaged package and add some users, projects, etc. to fill the app screens with data.
As you see it’s better to use provided credentials. If you will have problems with them, for example a verification code will be required, then please ask a question in the forum.

### Bowerman deployment Notes (11/16/2015)
1.  In order to build I needed to set SWIFT_OPTIMIZATION_LEVEL to none in order to compile.
2. The SwiftyJSON in external git repo so to add this you need to do the following in the root dir
```
git submodules init
git submodule update
```
