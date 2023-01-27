//
//  DurationPicker.swift
//  teha
//
//  Created by Matteo Ludwig on 27.01.23.
//

import SwiftUI

// MARK: EstimatedWorktimeFieldComponent

/// A view used by the EstimatedWorktimeField to allow the user to input a value
fileprivate struct EstimatedWorktimeFieldComponent: View {
    @Binding var value: Int
    let label: String
    
    /// We use the lastValue state to keep track of the last value this field set in order to avoid setting the same value multiple times
    @State private var lastValue: Int
    
    /// True if the input text field should be empty
    @State private var isEmpty: Bool = false
    
    /// Keeping track of the focus state of the TextField
    @FocusState private var isFocused
    
    init(value: Binding<Int>, label: String) {
        self._value = value
        self.label = label
        // initializing last value with current value
        self.lastValue = value.wrappedValue
    }
    
    var textFieldBinding: Binding<String> {
        Binding {
            // if isEmpty is true and the input is focussed, return an empty string.
            // This (in combination with properly setting isEmpty) ensures that the user does not end up inputting "10" by just pressing "1", just because there already was a "0" in the textfield.
            isEmpty && isFocused ? "" : "\(value)"
        } set: { text in
            // ignore everything that isnt a digit
            let cleanedText = text.filter { $0.isNumber }
            
            // If the user input an empty string, set isEmpty = true, otherwise false
            isEmpty = cleanedText.isEmpty
            if isEmpty {
                // An empty string is a 0 numerically
                value = 0
            } else if let newValue = Int(cleanedText), newValue != lastValue {
                // Update value and lastValue, but only if the new value differs from lastValue
                // If we do not check that the values differ, we start some unfortunate event ping-pong, which can lead to some unexpected behaviour.
                value = newValue
                lastValue = newValue
            }
            
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            TextField("", text: textFieldBinding)
                .focused($isFocused)
                .keyboardType(.numberPad)
                .autocorrectionDisabled()
                .multilineTextAlignment(.trailing)
                .monospacedDigit()
                .padding(.vertical, 3)
                .padding(.horizontal, 10)
                .fixedSize()
                .frame(minWidth: 42)
                .background {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.secondarySystemFill)
                }
                .onChange(of: isFocused) { isFocused in
                    if isFocused && value == 0 {
                        isEmpty = true
                    }
                }
            Text(label)
        }
        .onTapGesture {
            // No matter where on the field the user taps, they probably wanted to focus the input.
            // However, since the input is bigger than the text field, that does not always happen by default, so we help out by manually setting the focus state to true on tap.
            isFocused = true
        }
    }
}

// MARK: EstimatedWorktimeField

/// An Input field to be used in a Form that allows the user to pick an hours and a minutes value
struct EstimatedWorktimeField: View {
    /// The binding value of the field
    @Binding var value: EstimatedWorktime
    
    /// The binding for the minutes field
    private var minuteFieldBinding: Binding<Int> {
        Binding {
            value.minutes
        } set: { newMinutes, _ in
            value = .init(hours: value.hours, minutes: newMinutes)
        }
    }
    
    /// The binding for the hours field
    private var hourFieldBinding: Binding<Int> {
        Binding {
            value.hours
        } set: { newHours, _ in
            value = .init(hours: newHours, minutes: value.minutes)
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            // The label of the input
            Text("estimated-worktime")
            Spacer()
            // The hour and minute field
            EstimatedWorktimeFieldComponent(value: hourFieldBinding, label: "h")
            EstimatedWorktimeFieldComponent(value: minuteFieldBinding, label: "min")
        }
    }
}

// MARK: Preview
struct DurationPicker_Previews: PreviewProvider {
    struct EstimatedWorktimeFieldPreview: View {
        
        @State var value: EstimatedWorktime = .init(totalMinutes: 135)
        var body: some View {
            EstimatedWorktimeField(value: $value)
        }
    }
    
    static var previews: some View {
        Form {
            EstimatedWorktimeFieldPreview()
        }
    }
}
