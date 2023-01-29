//
//  RepeatIntervalPicker.swift
//  teha
//
//  Created by Matteo Ludwig on 29.01.23.
//

import SwiftUI

struct RepeatIntervalPicker: View {
    let titleKey: LocalizedStringKey
    @Binding var selection: RepeatInterval?
    
    init(_ titleKey: LocalizedStringKey, selection: Binding<RepeatInterval?>) {
        self.titleKey = titleKey
        self._selection = selection
    }
    
    var body: some View {
        Picker(titleKey, selection: $selection) {
            Text("never").tag(Optional<RepeatInterval>.none)
            
            Divider()
            
            ForEach(RepeatInterval.allCases) { option in
                Text(option.name).tag(Optional(option))
            }
        }
    }
}

struct RepeatIntervalPicker_Previews: PreviewProvider {
    
    struct RepeatIntervalPickerPreview: View {
        @State var selection: RepeatInterval? = nil
        var body: some View {
            RepeatIntervalPicker("repeat", selection: $selection)
        }
    }
    
    
    static var previews: some View {
        Form {
            RepeatIntervalPickerPreview()
        }
    }
}
