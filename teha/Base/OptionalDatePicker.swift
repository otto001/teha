//
//  OptionalDatePicker.swift
//  teha
//
//  Created by Matteo Ludwig on 28.12.22.
//

import SwiftUI

/// An input to be used in a Form that allows the user to select an optional date and time, meaning that the user can opt to select no value.
struct OptionalDatePicker: View {
    /// The label text of the input
    let title: LocalizedStringKey
    /// The label text of the input when no value is slected yet, prompting the user to add a value if they wish.
    let addText: LocalizedStringKey
    /// The label text allowing the user to remove their current selection.
    let removeText: LocalizedStringKey
    
    @Binding var selection: Date?
    @State private var defaultValue: Date = .now
    
    init(_ title: LocalizedStringKey,
         addText: LocalizedStringKey,
         removeText: LocalizedStringKey = "remove",
         selection: Binding<Date?>,
         defaultDate: Date = .now) {
        self.title = title
        self.addText = addText
        self.removeText = removeText
        self._selection = selection
        
        self._defaultValue = .init(initialValue: defaultDate)
    }
    
    private var dateBinding: Binding<Date>? {
        guard let date = selection else { return nil }
        return .init {
            return date
        } set: { newValue in
            selection = newValue
            
            // If the user changes their selected date, also adjust the set the default date.
            // Should the user accidentally press "remove", this allows their previous selection to be automatically restored once they press "add" again.
            defaultValue = newValue
        }
    }
    
    var body: some View {
        ZStack {
            if let dateBinding = dateBinding {
                // If the user has selected any date, show the date picker
                VStack(spacing: 10) {
                    DatePicker(title, selection: dateBinding)
                    
                    Button(role: .destructive) {
                        selection = nil
                    } label: {
                        Text(removeText)
                    }.frame(maxWidth: .infinity, alignment: .trailing)
                    
                }
                .padding(.all, 0)
            } else {
                // If the user has not selected any date (dateBinding == nil), show a button prompting the user to add a value
                Button {
                    // set selection to default value if the user chooses to add a value
                    selection = defaultValue
                } label: {
                    Label(addText, systemImage: "plus.circle")
                }
            }
        }
    }
}

// MARK: Preview
struct OptionalDatePicker_Previews: PreviewProvider {
    struct OptionalDatePickerPreview: View {
        @State var date: Date?
        var body: some View {
            OptionalDatePicker("Deadline", addText: "Add Deadline", removeText: "Remove Deadline", selection: $date)
        }
    }
    static var previews: some View {
        Form {
            OptionalDatePickerPreview(date: .now)
            OptionalDatePickerPreview(date: nil)
        }
    }
}
