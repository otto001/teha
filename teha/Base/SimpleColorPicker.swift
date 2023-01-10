//
//  SimpleColorPicker.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//

import SwiftUI

enum ColorChoice: String, CaseIterable, Hashable, Identifiable {
    case red = "red"
    case orange = "orange"
    case yellow = "yellow"
    case green = "green"
    case blue = "blue"
    case purple = "purple"
    case pink = "pink"
    case brown = "brown"
    
    var id: ColorChoice { self }
    
    var name: LocalizedStringKey {
        let key = "color-\(rawValue)"
        return LocalizedStringKey(key)
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
        }
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
    
    init(routing: SimpleColorPicker.Routing, back: @escaping () -> Void) {
        self.title = routing.title
        self._color = routing.color
        self.back = back
    }
    
    private func colorRow(_ choice: ColorChoice) -> some View {
        HStack {
            Text(choice.name)
            Spacer()
            Circle().frame(height: 20).foregroundColor(choice.color)
        }
        .contentShape(Rectangle())
    }
    
    var body: some View {
        List {
            ForEach(ColorChoice.allCases) { choice in
                colorRow(choice)
                    .onTapGesture {
                        color = choice
                        back()
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
