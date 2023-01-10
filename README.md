# teha

teha is an app for freelancers, employees, students, and everyone else whose time is precious.
teha allows you to keep track of your projects and todos, while stopping you from taking up too many tasks at once.

## Views
There are 3 tabs: Projects, Tasks, Settings. Tasks is the "landing page" of the app.


### Projects
- List/Table like of all projects
- Default sorting: priority
  - Use Sections to divide projects based on priority
- Show project title & color
- Mark projects as complete (hidden per default)
  - reduces overcrowidng of table/list 
  - implemented as boolean property: otherwise, we'd need special handling for creation/edit UI
- Tap on project -> project detail view
- Button to open add project sheet
- Filter options (?)
- Edit button
  - Delete projects
- Swipe gesture for project delete
- Searchable (?)

#### Add Project Sheet
- Form Sheet
- Fields like: title, color, priority
- Add due date for project, use as default for project tasks

#### Project detail
- Detailed Information on a single project
- Shows title, priority, color
- Shows some basic statisitcs (e.g., number of tasks/completed tasks/progress/hours left to do/hours completed)
- Edit button (trailing navigation)
  - Presents sheet like project add (reuse code!!)   
- Navigation link to list of tasks of this project
  - Re-use list from tasks tab, but with project filter locked

### Tasks (Alternative Title: Overview?)
- Landing tab
- List/Table based
- Shows pendings tasks sorted by priority and approaching deadline & earliest start date
- Top: Segmented control (?)
  - EDIT: Segmented Control will overload (clutter) the view, find other solution
  - Choose between: group by Day/Week/Month
- Trailing navigation menu (show me more/systemImage: ellipsis.circle)
  - Toggable option: Group by projects
  - Filter button (opens filter sheet, see Photos app)
- Visual feedback for when filters are active (see Photos app for example)
- Searchable
  - Task title/notes
  - Project names
  - Tags
  - Advanced Feature:
    - If user inputs something that looks like a tag, suggest filtering by that tag
- Tap on task -> task detail view
- Add button -> Add Task Sheet (navigation leading)
- Edit button (navigation trailing)
  - Delete Tasks
  - Select multiple tasks
    - Mark as: completed, started, move to project, setting due date, etc...
- Swipe gestures:
  - Completed
  - Started
  - Delete (?)

#### Filter sheet
- See Photos app for inspo
- Options to filter by:
  - Project
  - Tag
  - Priority 
  - Repeating
  
#### Add Task Sheet
- Form Sheet
- Fields for: Title, Notes, Dates, Project
- Add reminder alerts
- Repeating tasks
  
#### Task Detail view
- Show title/notes/dates
- Edit button
  - Edit in place or as sheet (decide later) 
- Buttons for:
  - Started (with setting date to past option, i.e., "I started yesterday at 15:30")
    - Time optional (?)
  - Completed (with setting date to past option)
    - Time optional (?)
- Add reminder alerts
    
    
### Settings
- Color schemes
- Langauge (preferably not in in-app settins but in system settings)


## Misc
### Notifications

- Task reminder alerts
  - Approaching deadlines (default behaviour adjustable in setting)

## Implementation
### SwiftUI
We will attempt to use SwiftUI wherever possible. If SwiftUI starts acting up, we will replace the parts that act up with good ol' UIKit.

## Work division
- Matteo, Denis: Tasktabs & -views
- Andi: Settings
- Alex: Projects
- Jette: Notifications
- Nuri: Geofencing


## Rules
- Always use translation strings!
- No force pushing (unless explicitly discussed)

