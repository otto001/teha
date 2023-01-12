//
//  PriorityPicker.swift
//  teha
//
//  Created by Denis Ukehaxhaj on 12.01.23.
//

import SwiftUI

struct PriorityPicker: View {
    
    @Binding var selection: PriorityTag
    let hasNoneOption: Bool
    
    init(selection: Binding<Priority?>) {
        self._selection = Binding {
            return PriorityTag(selection.wrappedValue)
        } set: { newValue in
            selection.wrappedValue = newValue.priority
            
        }
        self.hasNoneOption = true
    }
    
    init(selection: Binding<Priority>) {
        self._selection = Binding {
            return PriorityTag.some(selection.wrappedValue)
        } set: { newValue in
            selection.wrappedValue = newValue.priority ?? .normal
        }
        self.hasNoneOption = false
    }
    
    var body: some View {
        Picker(LocalizedStringKey("priority"), selection: $selection) {
            if hasNoneOption {
                Text("none").tag(PriorityTag.none)
            }
            Section {
                ForEach(Priority.allCases.reversed()) { priority in
                    Text(priority.name).tag(PriorityTag.some(priority))
                }
            }
        }
    }
}

extension PriorityPicker {
    enum PriorityTag: Hashable {
        case none
        case some(Priority)
        
        init(_ priority: Priority?) {
            if let priority = priority {
                self = .some(priority)
            } else {
                self = .none
            }
        }
        
        var priority: Priority? {
            switch self {
            case .none:
                return nil
            case .some(let priority):
                return priority
            }
        }
    }
}

struct PriorityPicker_Previews: PreviewProvider {
    
    struct PriorityPickerPreview: View {
        @State var priority: Priority? = .normal
        
        var body: some View {
            PriorityPicker(selection: $priority)
        }
    }
    
    static var previews: some View {
        PriorityPickerPreview()
    }
}
