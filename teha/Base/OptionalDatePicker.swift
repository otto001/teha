//
//  OptionalDatePicker.swift
//  teha
//
//  Created by Matteo Ludwig on 28.12.22.
//

import SwiftUI

struct OptionalDatePicker: View {
    let title: String
    @Binding var selection: Date?
    @State private var defaultValue: Date = .now
    
    init(_ title: String, selection: Binding<Date?>) {
        self.title = title
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
                DatePicker(title, selection: dateBinding)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            selection = nil
                        } label: {
                            Label("Remove", systemImage: "minus.circle")
                        }
                    }
                
            } else {
                Button {
                    selection = defaultValue
                } label: {
                    Label("Add \(title)", systemImage: "plus.circle")
                }
                
            }
        }
    }
}

struct OptionalDatePicker_Previews: PreviewProvider {
    struct OptionalDatePickerPreview: View {
        @State var date: Date?
        var body: some View {
            OptionalDatePicker("Deadline", selection: $date)
        }
    }
    static var previews: some View {
        Form {
            OptionalDatePickerPreview(date: .now)
            OptionalDatePickerPreview(date: nil)
        }
    }
}
