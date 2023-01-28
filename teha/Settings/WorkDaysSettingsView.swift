//
//  WorkDaysSettingsView.swift
//  teha
//
//  Created by Matteo Ludwig on 27.01.23.
//

import SwiftUI


fileprivate let dateFormatter = DateFormatter()

fileprivate struct WorkDaysSettingInput: View {
    
    @State var activeDays: Set<Int> = Set<Int>([1, 2, 3, 4, 5])
    
    @ViewBuilder func dayButton(for day: Int) -> some View {
        let isSelected = activeDays.contains(day)
        
        Text(dateFormatter.veryShortStandaloneWeekdaySymbols[day])
            .font(.system(size: 15))
            .frame(width: 30, height: 30)
            //.padding(.all, 8)
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
                Text("Workdays")
                
                HStack(spacing: 0) {
                    ForEach(0..<7) { day in
                        dayButton(for: day).frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        } footer: {
            Text("Select all weekdays on which you have time to complete Tasks.")
        }
        
    }
}

fileprivate struct WorktimePerDayInput: View {
    
    // 0:30 to 10h per day
    let options = Array(1..<20).map { Worktime(totalMinutes: $0*30) }
    
    @State var worktime: Worktime = .init(hours: 4, minutes: 0)
    
    var body: some View {
        Picker("Worktime per Workday", selection: $worktime) {
            ForEach(options, id: \.totalMinutes) { option in
                Text(option.formattedShort!).tag(option)
            }
        }
    }
}

fileprivate struct StartOfWorkdayInput: View {
    
    @State var startOfDay: Date = .now
    
    var body: some View {
        DatePicker("Start of Day", selection: $startOfDay, displayedComponents: .hourAndMinute)
    }
    
}

struct WorkDaysSettingsView: View {
    var body: some View {
        WorkDaysSettingInput()
        StartOfWorkdayInput()
        WorktimePerDayInput()
    }
}

struct WorkDaysSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            WorkDaysSettingsView()
        }
    }
}
