//
//  RepeatIntervalInput.swift
//  teha
//
//  Created by Matteo Ludwig on 29.01.23.
//

import SwiftUI


fileprivate var initialDefaultEndDate: Date {
    var result = Date.now + TimeInterval.week * 4
    return result
}

struct RepeatIntervalInput: View {
    let titleKey: LocalizedStringKey
    @Binding var interval: RepeatInterval?
    @Binding var endDate: Date?
    
    @State var defaultEndDate: Date = initialDefaultEndDate
    
    init(_ titleKey: LocalizedStringKey, interval: Binding<RepeatInterval?>, endDate: Binding<Date?>) {
        self.titleKey = titleKey
        self._interval = interval
        self._endDate = endDate
    }
    
    var intervalPickerBinding: Binding<RepeatInterval?> {
        Binding {
            interval
        } set: { newValue in
            if interval == nil && newValue != nil {
                endDate = defaultEndDate
            }
            interval = newValue
        }
    }
    
    var datePickerBinding: Binding<Date> {
        Binding {
            endDate!
        } set: { newValue in
            endDate = newValue
        }
    }
    
    var body: some View {
        Section {
            Picker(titleKey, selection: intervalPickerBinding) {
                Text("never").tag(Optional<RepeatInterval>.none)
                
                Divider()
                
                ForEach(RepeatInterval.allCases) { option in
                    Text(option.name).tag(Optional(option))
                }
            }
            
            if interval != nil {
                DatePicker("repeating-end-date", selection: datePickerBinding, displayedComponents: .date)
            }
        }
    }
}

struct RepeatIntervalInput_Previews: PreviewProvider {
    
    struct RepeatIntervalInputPreview: View {
        @State var interval: RepeatInterval? = nil
        @State var endDate: Date? = nil
        var body: some View {
            RepeatIntervalInput("repeat", interval: $interval, endDate: $endDate)
        }
    }
    
    
    static var previews: some View {
        Form {
            RepeatIntervalInputPreview()
        }
    }
}
