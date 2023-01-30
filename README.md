# teha

teha is an app for freelancers, employees, students, and everyone else whose time is precious.
teha allows you to keep track of your projects and todos, while recommending you with what to continue so you meet the deadline.
The app is completly written in SwiftUi.

# repository structure 

```
teha/
├─ Onboarding/
├─ Location/
├─ Geofencing/
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

## Location
### structure
```
├─ Location/
  ├─ LocationPicker.swift // A button which opens a sheet and gives the opportunity to add a location
  ├─ LocationSearch.swift // AutoComplete service for the LocationPicker
  ```
### functionality

Sheet including an editbox, where you can put in an address and get suggestions. 

### Dependencies

- MapKit

## Geofencing
### structure
```
├─ Geofencing/
  ├─ Geomonitor.swift // handling the region monitoring for tasks
  ```
### functionality

Tasks can get monitored by giving their location to the Geomonitor. The Geomonitor will send out a notificiation if a task location is nearby.

### Dependencies

- MapKit
- CoreLocation

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

`ReminderOffset.swift`: ReminderOffset is an enum that represents different time offsets that can be used to set a reminder given a deadline.

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



## Base
### structure
```
├─ Utils/
  ├─ String+Substring.swift
  ├─ CGColor+Utils.swift
  ├─ Color+UIKitColors.swift
  ├─ NSFetchRequest+Filter.swift
  ├─ CGRect+Utils.swift
  ├─ TimeInterval+Values.swift
  ├─ Date+Utils.swift
 ``` 
### functionality
`String+Substring.swift`: This is an extension for the String class in Swift that adds two methods: index(offsetFromStart:) and substring(start:end:). The first method returns an index based on a given distance from the start of the string, while the second method returns a substring based on start and end indices.

`CGColor+Utils.swift`: This is an extension for the CGColor class in Swift that adds two methods: hex and fromHex(_:). The first method returns the color components as a hexadecimal string in P3 color space, while the second method creates a CGColor based on a given hexadecimal string.

`Color+UIKitColors.swift`: This is an extension for the SwiftUI Color class that adds a number of predefined color constants based on the UIColor system colors in UIKit.

`NSFetchRequest+Filter.swift`: This is an extension to the NSFetchRequest class in CoreData that adds a predicateAnd(with:) function.

`CGRect+Utils.swift`: This code extends the CGRect type with a static function called "bounding" which returns the smallest rectangle that includes two given rectangles as inputs.

`TimeInterval+Values.swift`: This extension adds static values for time intervals in seconds, such as a week, a day, an hour, or a minute.

`Date+Utils.swift`: This Swift code extends the Date class by adding the ability to add and subtract TimeInterval values to/from a Date instance, and returns the start date of the week for a given date.

### Dependencies:
- Foundation
- CoreGraphics
- SwiftUI
- CoreData

  
## Project
This is one of the main four tabs of the app, that provides all functionalities for managing projects.

### structure
```
├─ Projects/
  ├─ ProjectsTab.swift
  ├─ ProjectListView.swift
  ├─ ProjectEditView.swift
  ├─ ProjectLabel.swift
  ├─ ProjectDetailView.swift
  ├─ ProjectStatsView.swift
  ├─ ProjectPicker.swift
  ├─ NoProjectView.swift
 ``` 
### functionality
`ProjectsTabv`: The ProjectsTab struct is a SwiftUI View that displays a list of projects. It allows the user to add a new project, view details of an existing project, view task details of a task within a project, and search for projects.

`ProjectListView.swift`: ProjectsListView is a SwiftUI view that displays a list of projects in a grouped style. It uses the SectionedFetchRequest object to retrieve projects from Core Data and categorize them based on their completion status and priority. The view implements swipe actions to complete and delete projects, as well as a navigation link to view and edit each project's details.

`ProjectEditView.swift`: ProjectEditView allows a user to add or edit a project. The view contains form elements for inputting project name, priority, color, and deadline, and a done button to save changes.

`ProjectLabel.swift`: ProjectLabel is a SwiftUI view that displays the name and color of a project. 

`ProjectDetailView.swift`: ProjectDetailView is a SwiftUI view that displays detailed information about a THProject object. If the project has tasks, it displays ProjectStatsView, otherwise it displays a ProjectNoStatsView. 

`ProjectStatsView.swift`: It displays statistics for a THProject, including the count of all tasks, tasks due today, current tasks, and finished tasks. 

`ProjectPicker.swift`: The ProjectPicker is a SwiftUI View that emulates the Picker View but with a Menu View to handle Labels with colors. It allows the user to select a THProject and the input is optional, meaning that the user can choose "None" as an option.

`NoProjectView.swift`: NoProjectView dispalays that there are no projects, if the list is empty

### Dependencies:
- SwiftUI
- CoreData

## Tasks
This is one of the main four tabs of the app, that provides all functionalities for managing tasks.

### structure
```
├─ Tasks/
  ├─ Filter
    ├─ TaskFilterView.swift
    ├─ TaskFilterViewModel.swift
  ├─ ProgressBar
    ├─ TaskProgressBar.swift
    ├─ TaskProgressBarInteractive.swift
  ├─ List
    ├─ TaskListView.swift
    ├─ TaskListSectionView.swift
    ├─ TaskRowView.swift
    ├─ TaskListToolbarView.swift
  ├─ TasksTab.swift
  ├─ TaskDetailView.swift
  ├─ TaskEditView.swift
  ├─ NoTaskView.swift
  ├─ NoTaskFilterView.swift

 ``` 
### functionality

`TaskFilterView.swift`: TasksFilterView used for filtering tasks. The filter view consists of several components, including a completion picker, a tag filter, and an upcoming filter.

`TaskFilterViewModel.swift`: The class TasksFilterViewModel is an observable object that holds the filter parameters for a task list. The filter parameters include grouping, task state, project, priority, tag filter mode, tags, upcoming and deadline filter modes, and search string. The class also provides computed properties to determine if any or all filters are active and a fetch request to fetch tasks based on the filter parameters.

`TaskProgressBar.swift`: This code defines a TaskProgressBar view in SwiftUI which represents a task's progress in the form of a bar graph. 

`TaskProgressBarInteractive.swift`: The progress bar allows to interact with the completion status of a task, for example marking the task as started or completed.

`TaskListView.swift`: The TasksListView is a SwiftUI view that displays a list of tasks and allows the user to filter the tasks based on certain criteria, such as the deadline year, month, week or day. The FilteredTasksListView is a private struct that provides the actual view of the tasks list and allows users to edit, delete, and select tasks.

`TaskListSectionView.swift`: The TaskListSectionView is a view for a section of a task list. It creates based on the status, a "enabled" section for filter.

`TaskRowView.swift`: The TaskRowView is a SwiftUI view that displays information about a task, such as its title, project, completion status, deadline, and progress.

`TaskListToolbarView.swift`: TaskListToolBarView allows users to perform actions on selected tasks, such as changing the date, project, completion progress, or deleting the tasks.

`TasksTab.swift`: This provides the scafold of the tasks tab. It shows if filter are active, allows to apply filter and to group tasks

`TaskDetailView.swift`: TaskDetailView displays information about the task such as its name, progress, and completion status

`TaskEditView.swift`: TaskEditView allows to edit tasks.

`NoTaskView.swift`: NoTaskView dispalays that there are no tasks, if the list is empty

`NoTaskFilterView.swift`: NoTaskFilterView dispalays that there are no tasks, if the filters are active

### Dependencies:
- SwiftUI
- CoreData
- Foundation


## Suggestions
This is one of the main four tabs of the app, that provides all information for suggestions.

### structure
```
├─ Suggestions/
  ├─ Generator
    ├─ SuggestionsGenerator.swift
    ├─ SuggestionsGenerator+Structs.swift
    ├─ SuggestionsGeneratorError.swift
  ├─ SuggestionsViewModel.swift
  ├─ SuggestionsTab.swift
  ├─ SuggestionsListView.swift
 ``` 
### functionality

`SuggestionsGenerator.swift`: 

`SuggestionsGenerator+Structs.swift`: The "SuggestionsGenerator+Structs.swift" is an extension of the SuggestionsGenerator class that provides additional structs and classes to enhance the functionality of the SuggestionsGenerator. The extension provides a class "UnwrappedTask" that wraps around the THTask object, an struct "BinKey" that represents a moment in time, and a struct "Bin" that holds information about a task's time allocation.

`SuggestionsGeneratorError.swift`: The "SuggestionsGeneratorError.swift" contains the errors that may be thrown by the SuggestionsGenerator

`SuggestionsViewModel.swift`: The "SuggestionsViewModel.swift" istens to save notifications of the view context and updates the latest suggestions result and error using the SuggestionsGenerator. 

`SuggestionsTab.swift`:  This provides the scafold of the suggestions tab.

`SuggestionsListView.swift`: It creates a ListView of suggestions

### Dependencies:
- SwiftUI
- CoreData
- Foundation
- OSLog


## Tags

### structure
```
├─ Tags/
  ├─ TagPicker.swift
  ├─ TagCollection.swift
 ``` 
### functionality

`TagPicker.swift`:  The TagPicker is a SwiftUI View that enables the user to create labels and select them 

`TagCollection.swift`: This creates the view of created and stored tags

### Dependencies:
- SwiftUI

## Settings
This is one of the main four tabs of the app, that provides all settings of the app.
### structure
```
├─ Settings/
  ├─ SettingsTab.swift
  ├─ WorkDaysSettingsView.swift
 ``` 
### functionality

`SettingsTab.swift`:  This provides the scafold of the settings tab with settings that can be customized .  

`WorkDaysSettingsView.swift`: This creates the functionality to customize the WorkDay-settings. E.g. workhours or general workdays.

### Dependencies:
- SwiftUI

## SwiftUI bugs, that we can't fix





