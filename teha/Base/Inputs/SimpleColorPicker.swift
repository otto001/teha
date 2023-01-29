//
//  SimpleColorPicker.swift
//  teha
//
//  Created by Matteo Ludwig and Andreas Romann on 23.12.22.
//

import SwiftUI


/// A enum representing a user-picked color. Supports both built-in standard colors (e.g., red, blue, ...) and custom 8-bit colors.
enum ColorChoice: Hashable, Identifiable, RawRepresentable {
    typealias RawValue = String
    
    /// All color choices (besides custom colors)
    static var baseColors: [ColorChoice] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink, .brown
    ]
    
    // Besides supporting custom colors, we also support some of the built-in colors of SwiftUI.Color
    // While these could, in theory, also be represented by custom colors / hex color codes, we explictly use the built in colors as these  can be expected to have better support for accesibility features (e.g. color blindness adjustment)
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case pink
    case brown
    case custom(CGColor)
    
    var id: ColorChoice { self }
    
    /// The string representation of the color choice. For standard colors, the color name is used. Custom colors are encoded as a hex color code.
    var rawValue: RawValue {
        switch self {
        case .red: return "red"
        case .orange: return "orange"
        case .yellow: return "yellow"
        case .green: return "green"
        case .blue: return "blue"
        case .purple: return "purple"
        case .pink: return "pink"
        case .brown: return "brown"
        case .custom(let color):
            return color.hex ?? "green"
        }
    }

    /// Init a color choice by a string that is either the name of a color (for standard colors) or a hex color code (for custom colors).
    init?(rawValue: RawValue) {
        switch rawValue {
        case "red":
            self = .red
        case "orange":
            self = .orange
        case "yellow":
            self = .yellow
        case "green":
            self = .green
        case "blue":
            self = .blue
        case "purple":
            self = .purple
        case "pink":
            self = .pink
        case "brown":
            self = .brown
        default:
            guard let cgColor = CGColor.fromHex(rawValue) else { return nil }
            self = .custom(cgColor)
        }
    }
    
    /// The localized name of the color. Custom colors are simply named "custom", all other colors have their appropriate name.
    var localizedName: LocalizedStringKey {
        switch self {
        case .custom:
            return "custom"
        default:
            let key = "color-\(rawValue)"
            return LocalizedStringKey(key)
        }
    }
    
    /// The SwiftUI Color corresponding to the color choice.
    var color: Color {
        switch self {
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .blue:
            return .blue
        case .purple:
            return .purple
        case .pink:
            return .pink
        case .brown:
            return .brown
        case .custom(let color):
            return Color(cgColor: color)
        }
    }
    
    /// The name of the AppIcon themed in this color
    var appIconName: String? {
        if case .custom = self {
            return nil
        }
        
        return "AppIcon-\(self)"
    }
    
    /// Whether the colorChoice is a custom color.
    /// - Returns: True when the color is a custom color.
    var isCustom: Bool {
        if case .custom = self {
            return true
        }
        return false
    }
}

/// A Form input view that allows a user to pick a color using the ColorChoice enum.
struct SimpleColorPicker: View {
    let title: LocalizedStringKey
    @Binding var selection: ColorChoice
    
    /// True when the detail page (which is the actual input) is pushed.
    @State private var pageIsPushed: Bool = false
    
    init(title: LocalizedStringKey, selection: Binding<ColorChoice>) {
        self.title = title
        self._selection = selection
    }
    
    var body: some View {
        
        // The "label" of the SimpleColorPicker is simply a button, that pushes the actual input onto the navigation stack if pressed.
        Button {
            pageIsPushed = true
        } label: {
            HStack {
                Text(title)
                Spacer()
                Circle().frame(height: 20).foregroundColor(selection.color)
            }
            // Setting content shape to allow for hit detection even in the transparent parts of the label
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .navigationDestination(isPresented: $pageIsPushed) {
            // The actual input
            SimpleColorPickerPage(title: title, selection: $selection) {
                // This closure is called when the page wants to dissmiss
                pageIsPushed = false
            }
        }
        //.contentShape(Rectangle())
        
    }
}


/// The detail page of SimpleColorPicker which allows the user to pick a color out of a list of options or define a custom one.
fileprivate struct SimpleColorPickerPage: View {
    let title: LocalizedStringKey
    @Binding var selection: ColorChoice
    let back: () -> Void
    
    /// The custom color the user picked
    @State private var customColor: CGColor = .init(red: 0, green: 0, blue: 1, alpha: 1)
    
    /// The background that gets placed behind the selected element
    @ViewBuilder private var selectedBackground: some View {
        Color.gray.opacity(0.3).padding(.all, -20)
    }
    
    /// Creates a row for a color with a name. Also sets up a tap gesture so that the user can select the row.
    private func colorRow(_ choice: ColorChoice) -> some View {
        HStack {
            Text(choice.localizedName)
                .fontWeight(choice == selection ? .semibold : .regular)
            Spacer()
            Circle()
                .frame(height: 20)
                .padding(.trailing, 4)
                .foregroundColor(choice.color)
        }
        .contentShape(Rectangle())
        .background {
            // If row is selected, show that by displaying the selectedBackground
            if choice == selection {
                selectedBackground
            }
        }
        .onTapGesture {
            selection = choice
            // navigate back on select
            back()
        }
    }
    
    var body: some View {
        List {
            ForEach(ColorChoice.baseColors) { choice in
                colorRow(choice)
            }
            ColorPicker(selection: $customColor, supportsOpacity: false) {
                // label for the custom color picker that visually matches the other rows
                Text("custom")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWeight(selection.isCustom ? .semibold : .regular)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selection = .custom(customColor)
                        // navigate back on select
                        back()
                    }
            }
            .background {
                if selection.isCustom {
                    selectedBackground
                }
            }
            .onChange(of: customColor) { newValue in
                // If the custom color picker by the user changes, we update the selection accordingly
                selection = .custom(newValue)
            }
            .onAppear {
                // On first appear, when the selection is a custom color, we set the color we bind to the ColorPicker above to the selected custom color to preserve the users previous input
                if case .custom(let cGColor) = selection {
                    customColor = cGColor
                }
            }
                
        }
        .listStyle(.insetGrouped)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SimpleColorPicker_Previews: PreviewProvider {
    
    /// Preview wrapper to add state to the preview
    struct SimpleColorPickerPreview: View {
        @State private var color: ColorChoice = .pink
        var body: some View {
            NavigationStack {
                Form {
                    SimpleColorPicker(title: "Color", selection: $color)
                }
            }
        }
    }
    
    static var previews: some View {
        SimpleColorPickerPreview()
    }
}
