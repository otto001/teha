//
//  SimpleColorPicker.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//

import SwiftUI

enum ColorChoice: Hashable, Identifiable, RawRepresentable {
    typealias RawValue = String
    
    static var baseColors: [ColorChoice] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink, .brown
    ]
    
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
    
    var rawValue: RawValue {
        switch self {
        case .red:
            return "red"
        case .orange:
            return "orange"
        case .yellow:
            return "yellow"
        case .green:
            return "green"
        case .blue:
            return "blue"
        case .purple:
            return "purple"
        case .pink:
            return "pink"
        case .brown:
            return "brown"
        case .custom(let color):
            return color.hex ?? "green"
        }
    }

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
    
    var localizedName: LocalizedStringKey {
        switch self {
        case .custom:
            return "custom"
        default:
            let key = "color-\(rawValue)"
            return LocalizedStringKey(key)
        }
    }
    
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
    
    var isCustom: Bool {
        if case .custom = self {
            return true
        }
        return false
    }
}

struct SimpleColorPicker: View {
    struct Routing: Hashable {
        let id: UUID
        let title: String
        let color: Binding<ColorChoice>
        
        static func == (lhs: SimpleColorPicker.Routing, rhs: SimpleColorPicker.Routing) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    let title: String
    @Binding var color: ColorChoice
    @State private var id: UUID = UUID()
    
    init(title: String, color: Binding<ColorChoice>) {
        self.title = title
        self._color = color
    }
    
    var routing: Routing {
        Routing(id: id, title: title, color: $color)
    }
    
    var body: some View {
        NavigationLink(value: routing) {
            HStack {
                Text(title)
                Spacer()
                Circle().frame(height: 20).foregroundColor(color.color)
            }
            .contentShape(Rectangle())
        }
    }
}

fileprivate struct SimpleColorPickerRoutingDestination: View {
    let title: String
    @Binding var color: ColorChoice
    let back: () -> Void
    @State private var customColor: CGColor = .init(red: 0, green: 0, blue: 1, alpha: 1)
    
    @ViewBuilder
    private var selectedBackground: some View {
        Color.gray.opacity(0.3).padding(.all, -20)
    }
    
    init(routing: SimpleColorPicker.Routing, back: @escaping () -> Void) {
        self.title = routing.title
        self._color = routing.color
        self.back = back
    }
    
    private func colorRow(name: LocalizedStringKey, color: Color) -> some View {
        HStack {
            Text(name).fontWeight(name == self.color.localizedName ? .semibold : .regular)
            Spacer()
            Circle()
                .frame(height: 20)
                .padding(.trailing, 4)
                .foregroundColor(color)
        }
        .contentShape(Rectangle())
        .background {
            if name == self.color.localizedName {
                selectedBackground
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(ColorChoice.baseColors) { choice in
                colorRow(name: choice.localizedName, color: choice.color)
                    .onTapGesture {
                        color = choice
                        back()
                    }
            }
            ColorPicker(selection: $customColor, supportsOpacity: false) {
                Text(LocalizedStringKey("custom"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWeight(self.color.isCustom ? .semibold : .regular)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        color = .custom(customColor)
                        back()
                    }
            }
            .background {
                if self.color.isCustom {
                    selectedBackground
                }
            }
            .onChange(of: customColor) { newValue in
                color = .custom(newValue)
            }
            .onAppear {
                if case .custom(let cGColor) = color {
                    customColor = cGColor
                }
            }
                
        }
        .listStyle(.insetGrouped)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension Form {
    func registerSimpleColorPicker(back: @escaping () -> Void) -> some View {
        return navigationDestination(for: SimpleColorPicker.Routing.self) { routing in
            SimpleColorPickerRoutingDestination(routing: routing, back: back)
        }
    }
}


struct SimpleColorPicker_Previews: PreviewProvider {
    
    struct SimpleColorPickerPreview: View {
        @EnvironmentObject var router: Router
        @State var color: ColorChoice = .pink
        var body: some View {
            SimpleColorPicker(title: "Color", color: $color)
        }
    }
    
    static var previews: some View {
        RoutedNavigation { router in
            Form {
                SimpleColorPickerPreview()
            }.registerSimpleColorPicker {
                router.pop()
            }
        }
    }
}
