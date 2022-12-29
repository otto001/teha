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
    
    var name: String {
        return self.rawValue.localizedCapitalized
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
    struct RoutingId: Hashable {}
    
    let title: String
    @Binding var color: ColorChoice
    @EnvironmentObject var router: Router
    
    private func colorRow(_ choice: ColorChoice) -> some View {
        HStack {
            Text(choice.name)
            Spacer()
            Circle().frame(height: 20).foregroundColor(choice.color)
        }
        .contentShape(Rectangle())
    }
    
    var body: some View {
        NavigationLink(value: RoutingId()) {
            HStack {
                Text(title)
                Spacer()
                Circle().frame(height: 20).foregroundColor(color.color)
            }
            .contentShape(Rectangle())
        }
        .navigationDestination(for: RoutingId.self) { _ in
            List {
                ForEach(ColorChoice.allCases) { choice in
                    colorRow(choice)
                        .onTapGesture {
                            color = choice
                            router.pop()
                        }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SimpleColorPicker_Previews: PreviewProvider {
    
    struct SimpleColorPickerPreview: View {
        @State var color: ColorChoice = .pink
        var body: some View {
            SimpleColorPicker(title: "Color", color: $color)
        }
        
    }
    
    static var previews: some View {
        RoutedNavigation {
            Form {
                SimpleColorPickerPreview()
            }
        }
    }
}
