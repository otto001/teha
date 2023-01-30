//
//  TaskListSectionView.swift
//  teha
//
//  Created by Matteo Ludwig on 22.01.23.
//

import SwiftUI

/// Returns the week as a formatted string in the  way CW-week, except for this-week, last-week, next-week
fileprivate func formatWeekOfYear(year: Int, weekOfYear: Int) -> String {
    let now: Date = .now
    let currentYear = Calendar.current.component(.year, from: now)

    let weekString = String(format: NSLocalizedString("CW-%@", comment: ""), "\(weekOfYear)")
    
    if year == currentYear {
        let currentWeek = Calendar.current.component(.weekOfYear, from: now)
        
        if weekOfYear == currentWeek - 1 {
            return String(localized: "last-week")
        } else if weekOfYear == currentWeek {
            return String(localized: "this-week")
        } else if weekOfYear == currentWeek + 1 {
            return String(localized: "next-week")
        }
        
        return weekString
    }
    
    return "\(weekString), \(year)"
}

// DateFormatter to only get year and months
fileprivate let yearMonthParseFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM"
    return dateFormatter
}()

// DateFormatter to get year, month and day
fileprivate let yearMonthDayParseFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter
}()

// dateFormatter for relative date formatting, in 2 weeks, yesterday ...
fileprivate let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    dateFormatter.doesRelativeDateFormatting = true
    return dateFormatter
}()


/// The view containing all tasksections
struct TaskListSectionView: View {
    @Environment(\.editMode) var editMode
    
    let section: SectionedFetchResults<String, THTask>.Element
    
    let now: Date
    
    let deleteAction: (_ task: THTask) -> Void

    // The Boolean if the collapsed section is collapsed, needed because some tasks have no deadline and cant be
    // represented in the satndard way
    @State private var collapsed: Bool = false
    
    init(_ section: SectionedFetchResults<String, THTask>.Element, now: Date, deleteAction: @escaping (_ task: THTask) -> Void) {
        self.section = section
        self.now = now
        self.deleteAction = deleteAction
    }

    // The section title based on the section ID and deadline
    var sectionTitle: String {
        let id = section.id
        guard id != "none" else { return String(localized: "deadline-no") }
        let year = Int(id.substring(start: 0, end: 4))!
        
        if id.count >= 8 && id.substring(start: 4, end: 7) == "-CW" {
            // id is of format [year]-CW[weekOfYear]
            let weekOfYear = Int(id.suffix(from: id.index(offsetFromStart: 7)))!
            return formatWeekOfYear(year: year, weekOfYear: weekOfYear)
        } else if id.count == 7 {
            // id is of format [year]-[month]
            let month = Int(id.suffix(from: id.index(offsetFromStart: 5)))!
            return "\(dateFormatter.monthSymbols[month-1]), \(year)"
        } else if id.count == 10, let date = yearMonthDayParseFormatter.date(from: id) {
            // id is of format [year]-[month]-[day]
            return dateFormatter.string(from: date)
        }
        
        // fallback: return year
        return "\(year)"
    }
    
    var body: some View {
        Section {
            // section for all tasks without deadline, can be shown by pushing the button
            if section.id == "none" {
                Button {
                    withAnimation {
                        collapsed.toggle()
                    }
                } label: {
                    HStack {
                        // shows the amount of tasks without a deadline
                        Text(String(format: NSLocalizedString("%@-tasks-without-deadline", comment: ""), "\(section.count)"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(Angle(degrees:collapsed ? 0 : 90))
                    }
                }.disabled((editMode?.wrappedValue.isEditing ?? false) && !collapsed)
            }
            // create a section for all section ids that are not none
            if section.id != "none" || !collapsed {
                ForEach(section) { task in
                    TaskListRowView(task: task, now: now)
                        .disabled(editMode?.wrappedValue == .active)
                        .id(task.id)
                        .tag(task.objectID)
                }
            }
            
        } header: {
            Text(sectionTitle)
        }
    }
}
