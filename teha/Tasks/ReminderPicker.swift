//
//  ReminderPicker.swift
//  teha
//
//  Created by Jette on 17.01.23.
//

import SwiftUI

struct ReminderPicker: View {
    @Binding var internalSelection: ReminderOffsetTag
    
    init(selection: Binding<ReminderOffset?>) {

        self._internalSelection = Binding {
            return ReminderOffsetTag(selection.wrappedValue)
        } set: { reminderOffsetTag in
            selection.wrappedValue = reminderOffsetTag.value
        }
    }
    
    var body: some View {
        Picker("reminder-add", selection: $internalSelection) {
            Text("none").tag(ReminderOffsetTag(nil))
            
            ForEach(ReminderOffset.allCases) { reminderOffset in
                Text(reminderOffset.name).tag(ReminderOffsetTag(reminderOffset))
            }
        }
    }
}

extension ReminderPicker {
    struct ReminderOffsetTag: Hashable {
        let value: ReminderOffset?
        
        init(_ value: ReminderOffset?) {
            self.value = value
        }
    }
}

struct ReminderPicker_Previews: PreviewProvider {
    
    struct ReminderPickerPreview: View {
        @State var selection: ReminderOffset? = nil

        var body: some View {
            ReminderPicker(selection: $selection)
        }
    }
    
    static var previews: some View {
        Form {
            ReminderPickerPreview()
        }
    }
}
