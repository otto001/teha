//
//  WorkDaysSettingsView.swift
//  teha
//
//  Created by Matteo Ludwig on 27.01.23.
//

import SwiftUI


fileprivate let dateFormatter = DateFormatter()

/// Extension to Set to make an Int Set RawRepresentable. This is used to save the workdays inside the AppStorage
extension Set: RawRepresentable where Element == Int {
    public var rawValue: String {
        return self.map {String($0)}.joined(separator: ",")
    }
    
    public init?(rawValue: String) {
        self.init(rawValue.split(separator: ",").compactMap { Int($0) })
    }
}

/// The View for inputting the workdays of every week
fileprivate struct WorkDaysSettingInput: View {
    // Setting the workdays variable for the first time in the AppStorage
    @AppStorage(SettingsAppStorageKey.workDays.rawValue) var activeDays: Set<Int> = Set<Int>([1, 2, 3, 4, 5])

    /// Creates a useable button to select or deselect a day of the week
    @ViewBuilder func dayButton(for day: Int) -> some View {
        let isSelected = activeDays.contains(day)
        
        Text(dateFormatter.veryShortStandaloneWeekdaySymbols[day])
            .font(.system(size: 15))
            .frame(width: 30, height: 30)
            .background {
                
                Circle()
                    .foregroundColor(isSelected ? Color.tertiaryLabel : Color.secondarySystemFill)
            }
            // Removes or inserts the current day from the active workdays
            .onTapGesture {
                if isSelected {
                    activeDays.remove(day)
                } else {
                    activeDays.insert(day)
                }
            }
    }
    
    var body: some View {
        // Create a Button for each day of the week
        Section {
            VStack(alignment: .leading) {
                Text("workdays")
                
                HStack(spacing: 0) {
                    let firstWeekDay = Calendar.current.firstWeekday
                    ForEach(firstWeekDay ..< (firstWeekDay + 7)) { day in
                        dayButton(for: (day - 1) % 7).frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        } footer: {
            // Check if the workdays are empty. If they are empty a foote is presented with an error message
            if activeDays.isEmpty {
                Text("settings-no-workdays-selected-error")
                    .foregroundColor(.red)
            } else {
                Text("workdays-select-footer")
            }
            
        }
        
    }
}

/// The View for inputting the start of workday and the end of workday
fileprivate struct WorktimeInput: View {
    // Setting the startOfWorkDay variable for the first time in the AppStorage
    @AppStorage(SettingsAppStorageKey.startOfWorkDay.rawValue) var startOfWorkDay: Worktime = .init(hours: 8, minutes: 0)
    // Setting the endOfWorkDay variable for the first time in the AppStorage
    @AppStorage(SettingsAppStorageKey.endOfWorkDay.rawValue) var endOfWorkDay: Worktime = .init(hours: 16, minutes: 0)

    // Create a base date as the current day at 0:00
    let baseDate: Date = Calendar.current.startOfDay(for: .now)

    // Create a Binding for the startOfWorkDay to be used for setting the startOfWorkDay value later
    var startOfWorkDayBinding: Binding<Date> {
        Binding {
            // The get method for the Binding. It gets set to the current baseDate with the totalMinutes of startOfWorkDay added
            Calendar.current.date(byAdding: .minute, value: startOfWorkDay.totalMinutes, to: baseDate)!
        } set: { newValue in
            // Use the newValue to set the startOfWorkDay variable
            startOfWorkDay = .init(extractFrom: newValue)
        }
    }

    // Create a Binding for the endOfWorkDay to be used for setting the endOfWorkDay value later
    var endOfWorkDayBinding: Binding<Date> {
        Binding {
            // The get method for the Binding. It gets set to the current baseDate with the totalMinutes of endOfWorkDay added
            Calendar.current.date(byAdding: .minute, value: endOfWorkDay.totalMinutes, to: baseDate)!
        } set: { newValue in
            // Use the newValue to set the endOfWorkDay variable
            endOfWorkDay = .init(extractFrom: newValue)
        }
    }

    // An Error message that only gets created if the startOfWorkDay is bigger than the endOfWorkDay
    var errorMessage: LocalizedStringKey? {
        if startOfWorkDay >= endOfWorkDay {
            return "settings-worktime-error"
        }
        return nil
    }
    
    var body: some View {
        Section {
            // Create a Datepicker for startOfWorkDay and endOfWorkDay with both bindings as the selections
            DatePicker("workday-start", selection: startOfWorkDayBinding, displayedComponents: .hourAndMinute)
            DatePicker("workday-end", selection: endOfWorkDayBinding, displayedComponents: .hourAndMinute)
        } footer: {
            // Display the errorMessage if it exists
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
    }
}


/// Combines the two created views
struct WorkDaysSettingsView: View {
    
    var body: some View {
        WorkDaysSettingInput()
        WorktimeInput()
    }
}

struct WorkDaysSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            WorkDaysSettingsView()
        }
    }
}
