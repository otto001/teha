//
//  ProjectPicker.swift
//  teha
//
//  Created by Matteo Ludwig on 10.01.23.
//

import SwiftUI

/// A Picker like View allowing the user to select a THProject. The input is optional, meaning that the user does have a "None" option avaliable.
/// Since the SwiftUI Picker has some unexpected/buggy behaviour when it comes to Labels with colors, a Menu is used to emulate a Picker.
struct ProjectPicker: View {
    @Binding var selection: THProject?
    @FetchRequest(fetchRequest: THProject.all) private var projects: FetchedResults<THProject>
    
    init(selection: Binding<THProject?>) {
        self._selection = selection
    }
    
    /// Returns a Label/Text for a THProject to be used in the Menu content.
    @ViewBuilder
    func label(for project: THProject?) -> some View {
        if let project = project {
            Label {
                Text(project.name ?? "")
            } icon: {
                Image(systemName: "circle.fill")
                    .foregroundStyle(project.color.color, .gray)
            }
        } else {
            Text("None")
        }
    }
    
    var body: some View {
        HStack {
            // Input Label
            Text(LocalizedStringKey("project"))
            Spacer()
            Menu {
                
                // None Option
                Button {
                    selection = nil
                } label: {
                    label(for: nil)
                }
                
                // Section for projects
                Section {
                    // add Button for each project
                    ForEach(projects) { project in
                        Button {
                            selection = project
                        } label: {
                            label(for: project)
                        }
                    }
                }
            } label: {
                HStack(spacing: 1) {
                    if let selection = selection {
                        ProjectLabel(project: selection).foregroundColor(.secondaryLabel)
                        
                    } else {
                        Text("None").foregroundColor(.secondaryLabel)
                    }
                    // Add the chevrons to emulate the look of the SwiftUI Picker
                    Image(systemName: "chevron.up.chevron.down")
                        .scaleEffect(0.8)
                        .offset(x: 1)
                        .foregroundColor(.secondaryLabel)
                }
            }
            .transaction { t in
                // We disable the animation of all transactions, as otherwise the label of the menu plays some sketchy animation everytime the user changes their selection
                t.animation = nil
            }
        }
    }
}

struct ProjectPicker_Previews: PreviewProvider {
    
    struct ProjectPickerPreview: View {
        @State var project: THProject? = nil
        
        var body: some View {
            ProjectPicker(selection: $project)
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
