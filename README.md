# teha

teha is an app for freelancers, employees, students, and everyone else whose time is precious.
teha allows you to keep track of your projects and todos, while recommending you with what to continue so you meet the deadline.
The app is completly written in SwiftUi.

# repository structure 

```
teha/
├─ Onboarding/
├─ Localization/
├─ Model/
├─ Base/
├─ Utils/
├─ Project/
├─ Tasks/
├─ Suggestions/
├─ Tags/
├─ Settings/
├─ Preview Content/
├─ Assets.xcassets
├─ tehaApp.swift
├─ Persistence.swift
├─ ContentView.swift
├─ teha.entitlements
tehaTests/
├─SuggestionsGeneratorTests.swift
README.md 
```


# implementation

## Onboarding
### structure
```
├─ Onboarding/
  ├─ OnboardingView.swift // controller of multiple onboarding views
  ├─ OnboardingPageView.swift // a single onboarding page
  ```
### functionality

Multiple OnboardingPageViews, which are controlled by the OnboardingView.swift to create a shot onboarding experience.

### Dependencies

- SwiftUI

## Localization

### structure
```
├─Localization/
  ├─Localizable/ //stringfiles
    ├─localizable (German)
    ├─localizable (English)
  ├─Localizabke/ //stringdicts
    ├─localizable (German)
    ├─localizable (English)
 ```
### functionality
teha supports german and english translation. These files contain the translations of all texts and its pluralization rules.

    
## Model
### structure
```
├─ Model/
  ├─ teha.xcdatamodeld
  ├─ THProject+CoreDataClass.swift
  ├─ THTask+CoreDataClass.swift
  ├─ THTag+CoreDataClass.swift
 ``` 
### functionality

`THProject+CoreDataClass.swift` is a Swift class that represents a project managed by Core Data. It has properties like priority, color, and completion status, and provides methods for fetching projects from Core Data (e.g. all, all with a specific priority).

`THTask+CoreDataClass.swift` is a Swift class that represents a task managed by Core Data. It has properties like priority, estimated worktime, and reminder offsets, and provides methods for managing the task's completion status and notifications.

`THTag+CoreDataClass.swift` is a Swift class that represents a tag managed by Core Data. It provides fetchrequest ??????????

### Dependencies
- SwiftUI
- CoreData
- Fondation

## Base
### structure
```
├─ Base/
  ├─ Types/
    ├─ ReminderOffset.swift
    ├─ Priority.swift
    ├─ Worktime.swift
  ├─Layouts/
    ├─ FlexHStack.swift
  ├─Modifiers/
    ├─ RefreshModifier.swift
    ├─ FormSheetNavigationBar.swift
  ├─Inputs/
    ├─ WorktimeField.swift
    ├─ ReminderPicker.swift
    ├─ OptionalDatePicker.swift
    ├─ PriorityPicker.swift
    ├─ SimpleColorPicker.swift
    ├─ TextFieldMultiline.swift
  ├─LocalNotification.swift
 ``` 
### functionality

`ReminderOffset.swift`:  ReminderOffset is an enum that represents different time offsets that can be used to set a reminder given a deadline.

`Priority.swift`: Priority is an enum that defines the priority levels of tasks or reminders. The four cases are low, normal, high, and urgent.

`Worktime.swift`: The Worktime struct wraps around a number of minutes and supports basic arithmetic and comparison operations. It provides a formatted and localized string representation of the work time in hours and minutes. Additionally, it can be converted to a TimeInterval or a RawValue.

`FlexHStack.swift`: A Layout container that, just like HStack, lays out its subviews horizontally. However, when its width is not sufficient for displaying all subviews next to eachother, it starts a new row below the previous items. Therefore, it does not grow in size horizontally, but vertically.


`RefreshModifier.swift`: The AutoRefreshModifier is a SwiftUI view modifier that updates a bound Date value once per minute to the current date rounded to the current minute. It does this by using a timer to check once per second if the time has changed and updating the bound Date value accordingly.

`FormSheetNavigationBar.swift`: The FormSheetNavigationBar is a view modifier in SwiftUI that configures the navigation bar for a form in a sheet. It adds a navigation title, a leading cancel button, and a trailing done/add button that are either labeled as "Done" or "Add" and disabled when invalid.

`WorktimeField.swift`: A view used by the WorktimeField to allow the user to input a value.

`ReminderPicker.swift`: A view that allows users to select a reminder offset from a list of options.

`OptionalDatePicker.swift`: The "OptionalDatePicker" struct in SwiftUI provides an input for a form that allows a user to select an optional date and time or remove their selection. 

`PriorityPicker.swift`: A Picker input that allows the user to select a prioritiy. Support both optional and non-optional modes.

`SimpleColorPicker.swift`: A enum representing a user-picked color. Supports both built-in standard colors (e.g., red, blue, ...) and custom 8-bit colors.

`TextFieldMultiline.swift`: A Textfield that looks like a normal SwiftUI TextField but supports linebreaks.

`LocalNotification`: The object for managing notification-related activities such as scheduling reminder.

### Dependencies:
- SwiftUI
- Foundation
- Usernotification

  
## SwiftUI bugs, that we can't fix





