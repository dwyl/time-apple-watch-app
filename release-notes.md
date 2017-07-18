# release-notes

We'll be updating this document along with each update that is merged into master.

We are now on Testflight :tada:, please forward us an email at hello@dwyl.io to request beta access

## Version 1.1 (Build 17) _Current_

- Added Modular Small and Module Large Complications, When a timer is running, it will show the live time on the watch face as long as you have the complications showing. Below is a screenshot of how it will look.

| **Timer not running** | **Timer running** |
| --- | --- |
| ![watch-no-timer](https://user-images.githubusercontent.com/2305591/28313863-4ae4472a-6bb0-11e7-9bbf-062e36ee2a5c.png) | ![watch-timer](https://user-images.githubusercontent.com/2305591/28313876-5879ea16-6bb0-11e7-8644-297cb66041b1.png) |

## Version 1.1 (Build 16)

- updated name of the app to `dwyl`
- updated the text input issue where the first letter was not auto capitalized, described in  [issue 50](https://github.com/dwyl/time-apple-watch-app/issues/50)
- also updated the flow of the add view so that the user does not have to click done and then save. If the user clicks done, it will return user to the table view automatically.


## Version 1.1 (Build 15)

- updated the way the watch was being synced.
    - If the watch returns from the background we are now fetching the latest information from the iPhone and then displaying a live timer accordingly
- Also fixed issue When the timer is stopped on the watch and the user is in the project details view.


## Version 1.1 (Build 14)

- Syncing timer both ways. Users can now see the timer running on the watch if they've started it on the Phone.

## Version 1.1 (Build 13)

- Timer state is reloaded if the user force quits the app and rejoins. :tada:


## Version 1.1 (Build 11)

**Additions**
- If a user tries to start a new timer whilst another one is running then they will be prompted with an alert

| **iPhone Home** |
| --- |
| ![phone-logo-v2](https://cloud.githubusercontent.com/assets/2305591/26006188/67a9ce9a-3733-11e7-8434-e479d9da1085.png) |

**Code Change**
- iPhone now has a singleton timer
- refactored and removed all the other timers that were running in multiple view controllers

**Bug Fixes**
- Updated UI on phone so that the live timers now show hours minutes and seconds.

| **iPhone Home** | **iPhone Project Detail** |
| --- | --- |
| ![phone-logo-v2](https://cloud.githubusercontent.com/assets/2305591/25908757/ef359782-35a2-11e7-84fd-d2941f8f3bfb.png) | ![watch-logo-v3](https://cloud.githubusercontent.com/assets/2305591/25908758/ef36ae7e-35a2-11e7-9181-d3ddde4f7295.png) |

## Version 1.1 (Build 10)

**Bug Fixes**
- [Issue 61](https://github.com/dwyl/time-apple-watch-app/issues/61) Fixed issue where the user was unable to start the timer.

**General**
- Updated Logo for the app

| **iPhone** | **Watch** |
| --- | --- |
| ![phone-logo-v2](https://cloud.githubusercontent.com/assets/2305591/25895607/7e73ebc2-3578-11e7-869d-360dd6cf2dea.png) | ![watch-logo-v3](https://cloud.githubusercontent.com/assets/2305591/25895608/7e8bbd7e-3578-11e7-961b-c871d2bbd1f0.png) |

## Version 1.1 (Build 9) _Failed_

- Apple watch icons contained an alpha channel hence the build was failed on iTunes Connect

## Version 1.1 (Build 8)

**Bug Fixes**
- [Issue 54](https://github.com/dwyl/time-apple-watch-app/issues/54) Fixed issue where the timer was not aligned correctly for a screen size bigger than iPhone 5.

**General**
- Downgraded the version with which this app is compatible at. Hopefully @iteles will not have to upgrade the OS on the watch to run this build :fingers_crossed: :tada:


## Version 1.1 (Build 7)

**Bug Fixes**
- [Issue 53](https://github.com/dwyl/time-apple-watch-app/issues/53) user can now add a project and not lose track of the timer on the apple watch. They can also delete a task without losing track of the timer on the watch.

## Version 1.1 (Build 6)

**Bug Fixes**
- [Issue 54](https://github.com/dwyl/time-apple-watch-app/issues/54) display issues have now been fixed for users of iPhone 5.

## Version 1.1 (Build 5)

**Debugging**
- Added [Crashlytics](https://fabric.io/kits/ios/crashlytics/summary) for the app.

**iPhone**
- Live Timer shows on the Home screen if running.

| **iPhone Home** | **iPhone + Watch** |
| --- | --- |
| ![](https://cloud.githubusercontent.com/assets/2305591/25747783/a7c2ff26-31a0-11e7-9837-28a784bff199.png) | ![](https://cloud.githubusercontent.com/assets/2305591/25747712/5413b4f6-31a0-11e7-960b-ba57f1b65251.png) |


## Version 1.0.(Build 1)

**iPhone**
- Users can view a list of projects
- User can add a new project
- User can start a new timer for a given project
- Timers started on the watch can be stopped on the phone

**Apple Watch**
- User can view a list of projects that have been created on the Watch
- User can start a timer for a given project

| **iPhone Home** | **iPhone project detail** | **iPhone add task** |
| --- | --- | --- |
| ![](https://cloud.githubusercontent.com/assets/2305591/25430592/1ebb4d32-2a75-11e7-80d7-f2b4d8124c85.png) | ![screen shot 2016-11-01 at 11 51 41](https://cloud.githubusercontent.com/assets/2305591/25430591/1eb99438-2a75-11e7-9295-43e5c6e07641.png) | ![screen shot 2016-11-01 at 11 51 41](https://cloud.githubusercontent.com/assets/2305591/25430593/1ebb8d92-2a75-11e7-8c5d-d852a7c23755.png) |

| **Watch Home** | **Watch Timer** |
| --- | --- |
| ![](https://cloud.githubusercontent.com/assets/2305591/25430590/1eb96882-2a75-11e7-8e3b-33a0750c903e.png) | ![screen shot 2016-11-01 at 11 51 41](https://cloud.githubusercontent.com/assets/2305591/25430589/1eb84218-2a75-11e7-8787-85b7704f0ebb.png) |
