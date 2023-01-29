//
//  WorkDaysSettingsView.swift
//  teha
//
//  Created by Matteo Ludwig on 27.01.23.
//

import SwiftUI


fileprivate let dateFormatter = DateFormatter()

extension Set: RawRepresentable where Element == Int {
    public var rawValue: String {
        return self.map {String($0)}.joined(separator: ",")
    }
    
    public init?(rawValue: String) {
        self.init(rawValue.split(separator: ",").compactMap { Int($0) })
    }
}

fileprivate struct WorkDaysSettingInput: View {
    @AppStorage(SettingsAppStorageKey.workDays.rawValue) var activeDays: Set<Int> = Set<Int>([1, 2, 3, 4, 5])
    
    @ViewBuilder func dayButton(for day: Int) -> some View {
        let isSelected = activeDays.contains(day)
        
        Text(dateFormatter.veryShortStandaloneWeekdaySymbols[day])
            .font(.system(size: 15))
            .frame(width: 30, height: 30)
            .background {
                
                Circle()
                    .foregroundColor(isSelected ? Color.tertiaryLabel : Color.secondarySystemFill)
            }
            .onTapGesture {
                if isSelected {
                    activeDays.remove(day)
                } else {
                    activeDays.insert(day)
                }
            }
    }
    
    var body: some View {
        
        Section {
            VStack(alignment: .leading) {
                Text("workdays")
                
                HStack(spacing: 0) {
                    ForEach(0..<7) { day in
                        dayButton(for: day).frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        } footer: {
            if activeDays.isEmpty {
                Text("settings-no-workdays-selected-error")
                    .foregroundColor(.red)
            } else {
                Text("workdays-select-footer")
            }
            
        }
        
    }
}


fileprivate struct WorktimeInput: View {
    @AppStorage(SettingsAppStorageKey.startOfWorkDay.rawValue) var startOfWorkDay: Worktime = .init(hours: 8, minutes: 0)
    
    @AppStorage(SettingsAppStorageKey.endOfWorkDay.rawValue) var endOfWorkDay: Worktime = .init(hours: 16, minutes: 0)
    
    let baseDate: Date = Calendar.current.startOfDay(for: .now)
    
    var startOfWorkDayBinding: Binding<Date> {
        Binding {
            Calendar.current.date(byAdding: .minute, value: startOfWorkDay.totalMinutes, to: baseDate)!
        } set: { newValue in
            startOfWorkDay = .init(extractFrom: newValue)
        }
    }
    
    var endOfWorkDayBinding: Binding<Date> {
        Binding {
            Calendar.current.date(byAdding: .minute, value: endOfWorkDay.totalMinutes, to: baseDate)!
        } set: { newValue in
            endOfWorkDay = .init(extractFrom: newValue)
        }
    }
    
    var errorMessage: LocalizedStringKey? {
        if startOfWorkDay >= endOfWorkDay {
            return "settings-worktime-error"
        }
        return nil
    }
    
    var body: some View {
        Section {
            DatePicker("workday-start", selection: startOfWorkDayBinding, displayedComponents: .hourAndMinute)
            DatePicker("workday-end", selection: endOfWorkDayBinding, displayedComponents: .hourAndMinute)
        } footer: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
    }
}



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
