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

    //dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
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
    
    let deleteAction: (_ task: THTask) -> Void
    
    init(_ section: SectionedFetchResults<String, THTask>.Element, deleteAction: @escaping (_ task: THTask) -> Void) {
        self.section = section
        self.deleteAction = deleteAction
    }
    
    var sectionTitle: String {
        let id = section.id
        guard id != "none" else { return "No Deadline" }
        let year = Int(id.substring(start: 0, end: 4))!
        
        let currentYear = Calendar.current.component(.year, from: .now)
        
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
            ForEach(section) { task in
                TaskRowView(task: task)
                    .swipeActions(edge: .trailing) {
                        Button() {
                            deleteAction(task)
                        } label: {
                            Label("delete", systemImage: "trash")
                        }
                        .tint(Color.red)
                    }
                    .disabled(editMode?.wrappedValue == .active)
                    .id(task.id)
                    .tag(task.objectID)
            }
        } header: {
            Text(sectionTitle)
        }
    }
}

//struct TaskListSectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        TaskListSectionView()
//    }
//}
