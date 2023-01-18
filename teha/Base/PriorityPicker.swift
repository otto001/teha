//
//  PriorityPicker.swift
//  teha
//
//  Created by Denis Ukehaxhaj on 12.01.23.
//

import SwiftUI

struct PriorityPicker<PickerLabel: View>: View {
    @Binding var selection: PriorityTag
    @ViewBuilder let label: () -> PickerLabel
    let noneText: LocalizedStringKey
    
    
    let hasNoneOption: Bool

    
    init(selection: Binding<Priority?>, noneText: LocalizedStringKey = "none", @ViewBuilder label: @escaping () -> PickerLabel) {
        self._selection = Binding {
            return PriorityTag(selection.wrappedValue)
        } set: { newValue in
            selection.wrappedValue = newValue.priority
        }
        self.hasNoneOption = true
        self.noneText = noneText
        self.label = label
    }
    
    init(selection: Binding<Priority>, noneText: LocalizedStringKey = "none", @ViewBuilder label: @escaping () -> PickerLabel) {
        self._selection = Binding {
            return PriorityTag.some(selection.wrappedValue)
        } set: { newValue in
            selection.wrappedValue = newValue.priority ?? .normal
        }
        self.hasNoneOption = false
        self.noneText = noneText
        self.label = label
    }
    
    var body: some View {
        HStack {
            label()
            Spacer()
            Picker(LocalizedStringKey(""), selection: $selection) {
                if hasNoneOption {
                    Text(noneText).tag(PriorityTag.none).foregroundColor(.secondaryLabel)
                }
                Section {
                    ForEach(Priority.allCases.reversed()) { priority in
                        Text(priority.name).tag(PriorityTag.some(priority)).foregroundColor(.secondaryLabel)

                    }
                }
            }.pickerStyle(.automatic)

        }
    }
}

extension PriorityPicker where PickerLabel == Text {
    init(_ titleKey: LocalizedStringKey, noneText: LocalizedStringKey = "none", selection: Binding<Priority?>) {
        self.init(selection: selection, noneText: noneText) {
            Text(titleKey)
        }
    }

    init(_ titleKey: LocalizedStringKey, noneText: LocalizedStringKey = "none", selection: Binding<Priority>) {
        self.init(selection: selection, noneText: noneText) {
            Text(titleKey)
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
            PriorityPicker(selection: $priority) {
                Label("priority", systemImage: "tag")
            }
        }
    }
    
    static var previews: some View {
        PriorityPickerPreview()
    }
}

