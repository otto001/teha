//
//  OptionalDatePicker.swift
//  teha
//
//  Created by Matteo Ludwig on 28.12.22.
//

import SwiftUI

struct OptionalDatePicker: View {
    let title: LocalizedStringKey
    let addText: LocalizedStringKey
    let removeText: LocalizedStringKey
    
    @Binding var selection: Date?
    @State private var defaultValue: Date = .now
    
    init(_ title: LocalizedStringKey, addText: LocalizedStringKey, removeText: LocalizedStringKey = "remove", selection: Binding<Date?>) {
        self.title = title
        self.addText = addText
        self.removeText = removeText
        self._selection = selection
    }
    
    private var dateBinding: Binding<Date>? {
        guard let date = selection else { return nil }
        return .init {
            return date
        } set: { newValue in
            selection = newValue
            defaultValue = newValue
        }
        
    }
    
    var body: some View {
        ZStack {
            if let dateBinding = dateBinding {
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
                Button {
                    selection = defaultValue
                } label: {
                    Label(addText, systemImage: "plus.circle")
                }
            }
        }
    }
}

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
