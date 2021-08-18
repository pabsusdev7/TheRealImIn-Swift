# TheRealImIn-iOS
ImIn App - The Attendance Tracking App

DESCRIPTION:

The ImIn App is a solution to track individuals required attendance to their organization’s events utilizing mobile technology. Features like distance/duration calculation to an event's location, make this app a great alternative to the regular ID card or QR code scanners. This app allows the user to check in/out of an event just by pressing a button on their mobile device. Many organizations (e.g. universities) currently depend on several computers and laser scanners to track, for instance, required attendance for residential students. Crowded bottlenecks could be avoided, and resources efficiently utilized with an app like ImIn.

INTENDED USER:
Any group of individuals that are required to attend to one or more events hosted by their organization, for example:
- Students
- Employees
- Event Attendees

FEATURES:
- Records User Attendance to events by allowing check in/out events
- Provides a report of attendance for the user
- Persists data in Cloud-based Firebase collections
- Utilizes Distance Matrix APIs to calculate distance/time to get to an event's location
- Provides the user an overview of attended, ongoing and missed events
- Implements FirebaseUI authentication

STEPS TO BUILD:
1. Clone the TheRealImIn-iOS git repo or download as ZIP
2. Go to the download dir and open TheRealImIn.xcworkspace
3. XCode should start up and start indexing the project files
4. Run the project as usual (Build may take a bit due to some Pods libs)
5. The app should start right after that
6. Log in w/ a Google account and later you will be taken to the main screen where you can select an event and check in/out as needed.
7. All features above should be available for testing

OTHER PLATFORMS:
- Android: https://github.com/pabsusdev7/TheRealImIn-Android
