//
//  TaskListSectionView.swift
//  teha
//
//  Created by Matteo Ludwig on 22.01.23.
//

import SwiftUI

fileprivate func formatWeekOfYear(year: Int, weekOfYear: Int) -> String {
    let now: Date = .now
    let currentYear = Calendar.current.component(.year, from: now)

    let weekString = "CW \(weekOfYear)"
    
    if year == currentYear {
        let currentWeek = Calendar.current.component(.weekOfYear, from: now)
        
        if weekOfYear == currentWeek - 1 {
            return "Last Week"
        } else if weekOfYear == currentWeek {
            return "This Week"
        } else if weekOfYear == currentWeek + 1 {
            return "Next Week"
        }
        
        return weekString
    }
    
    return "\(weekString), \(year)"
}

fileprivate let yearMonthParseFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM"
    return dateFormatter
}()

fileprivate let yearMonthDayParseFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter
}()


fileprivate let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    dateFormatter.doesRelativeDateFormatting = true
    return dateFormatter
}()



struct TaskListSectionView: View {
    @Environment(\.editMode) var editMode
    
    let section: SectionedFetchResults<String, THTask>.Element
    
    let now: Date
    
    let deleteAction: (_ task: THTask) -> Void
    
    @State private var collapsed: Bool = false
    
    init(_ section: SectionedFetchResults<String, THTask>.Element, now: Date, deleteAction: @escaping (_ task: THTask) -> Void) {
        self.section = section
        self.now = now
        self.deleteAction = deleteAction
    }
    
    var sectionTitle: String {
        let id = section.id
        guard id != "none" else { return "No Deadline" }
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
            if section.id == "none" {
                Button {
                    withAnimation {
                        collapsed.toggle()
                    }
                } label: {
                    HStack {
                        Text("\(section.count) Tasks without Deadline")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(Angle(degrees:collapsed ? 0 : 90))
                    }
                }.disabled((editMode?.wrappedValue.isEditing ?? false) && !collapsed)
            }
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
