//
//  RepeatIntervalInput.swift
//  teha
//
//  Created by Matteo Ludwig on 29.01.23.
//

import SwiftUI

/// Create a default repeating enddate that is 4 weeks from the current date
fileprivate var initialDefaultEndDate: Date {
    var result = Date.now + TimeInterval.week * 4
    return result
}

/// The View for the User Input of the Repeat Interval
struct RepeatIntervalInput: View {

    let titleKey: LocalizedStringKey
    // The Binding for the RepeatInterval, currently: Daily or weekly
    @Binding var interval: RepeatInterval?
    // The Binding for the EndDate, where the repeating tasks should stop
    @Binding var endDate: Date?

    // Get the default endDate
    @State var defaultEndDate: Date = initialDefaultEndDate

    // Initializer for the RepeatIntervalInput
    init(_ titleKey: LocalizedStringKey, interval: Binding<RepeatInterval?>, endDate: Binding<Date?>) {
        self.titleKey = titleKey
        self._interval = interval
        self._endDate = endDate
    }

    // Creating the get and set functions for the RepeatInterval Binding
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

    // Creating the get and set functions for the EndDate Binding
    var datePickerBinding: Binding<Date> {
        Binding {
            endDate!
        } set: { newValue in
            endDate = newValue
        }
    }

    // The Body for the RepeatInterval Picker
    var body: some View {
        Section {
            // Create a pciker for all different repeat Interval cases
            Picker(titleKey, selection: intervalPickerBinding) {
                Text("never").tag(Optional<RepeatInterval>.none)
                
                Divider()
                
                ForEach(RepeatInterval.allCases) { option in
                    Text(option.name).tag(Optional(option))
                }
            }
            // Only show the DatePicker for teh EndDate if the Interval has been set
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
