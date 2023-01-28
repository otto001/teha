//
//  PriorityPicker.swift
//  teha
//
//  Created by Denis Ukehaxhaj on 12.01.23.
//

import SwiftUI


/// A Picker input that allows the user to select a prioritiy. Support both optional and non-optional modes.
struct PriorityPicker<PickerLabel: View>: View {
    @Binding var selection: Priority?
    @ViewBuilder let label: () -> PickerLabel
    
    /// The label text for the "none" option, defaults to "none"
    let noneText: LocalizedStringKey

    /// True if the picker should show a "none" option
    private let hasNoneOption: Bool

    init(selection: Binding<Priority?>, noneText: LocalizedStringKey = "none", @ViewBuilder label: @escaping () -> PickerLabel) {
        self._selection = selection
        self.hasNoneOption = true
        self.noneText = noneText
        self.label = label
    }
    
    init(selection: Binding<Priority>, noneText: LocalizedStringKey = "none", @ViewBuilder label: @escaping () -> PickerLabel) {
        
        // In order to support a non-optional binding, we create a binding that always returns a value, even if it is technically an optional binding.
        // As a result, we can safely use our internal (technically optional) binding, without causing crashes
        self._selection = Binding {
            return selection.wrappedValue
        } set: { newValue in
            selection.wrappedValue = newValue ?? .normal
        }
        
        self.hasNoneOption = false
        self.noneText = noneText
        self.label = label
    }
    
    var body: some View {
        HStack {
            // Custom label
            label()
            Spacer()
            
            // The actual picker
            Picker(LocalizedStringKey(""), selection: $selection) {
                // Only show none option if needed
                if hasNoneOption {
                    Text(noneText)
                        .tag(Optional<Priority>.none)
                        .foregroundColor(.secondaryLabel)
                    Divider()
                }

                ForEach(Priority.allCases.reversed()) { priority in
                    Text(priority.name)
                        .tag(Optional<Priority>.some(priority))
                        .foregroundColor(.secondaryLabel)

                }
                
            }
            .pickerStyle(.automatic)
        }
    }
}

// MARK: Convenience
extension PriorityPicker where PickerLabel == Text {
    // "Convenience" initializers that allow for a simple text label
    
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


// MARK: Preview

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

