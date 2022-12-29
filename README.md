# teha

teha is an app for freelancers, employees, students, and everyone else whose time is precious.
teha allows you to keep track of your projects and todos, while stopping you from taking up too many tasks at once.


## Views

### Projects
- List/Table like of all projects
- Default sorting: priority
  - Use Sections to divide projects based on priority
- Show project title & color
- Mark projects as complete (hidden per default)
  - reduces overcrowidng of table/list 
  - implement as priority? (completed as lowest priority)
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

#### Project detail
- Detailed Information on a single project
- Shows title, priority, color
- Shows some basic statisitcs (e.g., number of tasks/completed tasks/progress/hours left to do/hours completed)
- Includes a list of tasks, possibly multiple categories (todo, completed, etc...)
- Tapping on a task navigates to task details
- Edit button (trailing navigation)
  - Presents sheet like project add (reuse code!!)   

### Tasks
- Landing tab
- List/Table based
- Shows pendings tasks sorted by priority and approaching deadline & earliest start date
- Top: Segmented control
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
  
#### Add Task Sheet
- Form Sheet
- Fields for: Title, Notes, Dates, Project
  
#### Task Detail view
- Show title/notes/dates
- Edit button
  - Edit in place or as sheet (decide later) 
- Buttons for:
  - Started (with setting date to past option, i.e., "I started yesterday at 15:30")
    - Time optional (?)
  - Completed (with setting date to past option)
    - Time optional (?)
    
    
### Settings
- Color schemes
- Langauge (preferably not in in-app settins but in system settings)


## Work division
(WIP)
- Everyone has their own views for which they are responsible


## Rules
- Always use translation strings!
- No force pushing (unless explicitly discussed)

