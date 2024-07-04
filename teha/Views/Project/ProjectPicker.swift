//
//  ProjectPicker.swift
//  teha
//
//  Created by Matteo Ludwig on 10.01.23.
//

import SwiftUI

/// A Picker like View allowing the user to select a THProject. The input is optional, meaning that the user does have a "None" option avaliable.
/// Since the SwiftUI Picker has some unexpected/buggy behaviour when it comes to Labels with colors, a Menu is used to emulate a Picker.
struct ProjectPicker<PickerLabel: View>: View {
    @Binding var selection: THProject?
    @ViewBuilder let label: () -> PickerLabel
    
    let noneText: LocalizedStringKey
    
    @FetchRequest(fetchRequest: THProject.all) private var projects: FetchedResults<THProject>
    
    init(selection: Binding<THProject?>, noneText: LocalizedStringKey = "none", @ViewBuilder label: @escaping () -> PickerLabel) {
        self._selection = selection
        self.noneText = noneText
        self.label = label
    }
    
    /// Returns a Label/Text for a THProject to be used in the Menu content.
    @ViewBuilder
    func label(for project: THProject?) -> some View {
        if let project = project {
            Label {
                Text(project.name ?? "")
            } icon: {
                Image(uiImage: colorSwatchImage(color: project.color.uiColor)).padding(.horizontal, 12)
            }
        } else {
            Text(noneText)
        }
    }
    
    private func colorSwatchImage(color: UIColor) -> UIImage {
        let size: CGFloat = 16
        let rect = CGRect(origin: .zero, size: CGSize(width: size+4, height: size))
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image(actions: { context in
            color.setFill()
            UIBezierPath(roundedRect: CGRect(origin: .zero, size: CGSize(width: size, height: size)), cornerRadius: size/2).fill()
        })
    }
    
    var body: some View {
        Picker(selection: $selection) {
            label(for: nil).tag(Optional<THProject>.none)
            Divider()
            // add Button for each project
            ForEach(projects) { project in

                label(for: project).tag(Optional(project))
                
            }
            
        } label: {
            label()
        }

    }
}

extension ProjectPicker where PickerLabel == Text{
    init(_ titleKey: LocalizedStringKey, noneText: LocalizedStringKey = "none", selection: Binding<THProject?>) {
        self._selection = selection
        self.noneText = noneText
        self.label = {
            Text(titleKey)
        }
    }
}


struct ProjectPicker_Previews: PreviewProvider {
    
    struct ProjectPickerPreview: View {
        @State var project: THProject? = nil
        @State var selection: String = ""
        
        var body: some View {
            ProjectPicker(selection: $project) {
                Label("projects", systemImage: "circle")
            }
            
//            ProjectPicker(selection: $project) {
//                Label("projects", systemImage: "circle")
//            }
            
            
            Picker(selection: $selection) {
                Text("A")
            } label: {
                Label("projects", systemImage: "circle")
            }
            
            Picker(selection: $selection) {
                Text("A")
            } label: {
                Label("projects", systemImage: "circle")
            }
//            
//            Menu {
//                Text("A")
//            } label: {
//                Label("projects", systemImage: "circle")
//                Spacer()
//                Text("A")
//            }
//            
            ProjectPicker(selection: $project) {
                Label("projects", systemImage: "circle")
            }
        }
    }
    
    static var previews: some View {
        ZStack {
            Form {
                ProjectPickerPreview().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
        }
    }
}
