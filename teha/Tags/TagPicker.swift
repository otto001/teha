//
//  TagPicker.swift
//  teha
//
//  Created by Matteo Ludwig on 15.01.23.
//

import SwiftUI


fileprivate struct TagPickerSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(fetchRequest: THTag.all) private var tags: FetchedResults<THTag>
    
    @State private var text: String = ""
    @Binding var selection: Set<THTag>

    
    init(selection: Binding<Set<THTag>>) {
        self._selection = selection
    }
    
    private var tagSections: ([THTag], [THTag]) {
        var selected = [THTag]()
        var notSelected = [THTag]()
        
        for tag in tags {
            if selection.contains(tag) {
                selected.append(tag)
            } else {
                notSelected.append(tag)
            }
        }
        
        return (selected, notSelected)
    }
    
    private var suggestions: [THTag] {
        guard !text.isEmpty else {
            return Array(tags)
        }
        return tags.filter { tag in
            tag.name?.lowercased().contains(text.lowercased()) == true
        }
    }
    
    private func addNewTag(_ name: String) {
        let tag = THTag(context: viewContext)
        tag.name = name
        
        selection.insert(tag)
    }
    
    @ViewBuilder
    private func tagRow(_ tag: THTag) -> some View {
        Button {
            withAnimation {
                if selection.contains(tag) {
                    selection.remove(tag)
                } else {
                    selection.insert(tag)
                }
            }
        } label: {
            HStack {
                Image(systemName: "tag")
                Text(tag.name ?? "").foregroundColor(.label)
                Spacer()
                if selection.contains(tag) {
                    Image(systemName: "checkmark")
                }
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                selection.remove(tag)
                viewContext.delete(tag)
            } label: {
                Label("delete", systemImage: "minus.circle.fill")
            }
            .tint(Color.red)
        }
    }
    
    @ViewBuilder
    private var addNewTagButton: some View {
        Button {
            addNewTag(text)
            text = ""
        } label: {
            Label("add-\(text)-as-new-tag",
                  systemImage: "plus")
        }
    }
    
    @ViewBuilder
    private var filteredResultsSection: some View {
        Section {
            ForEach(suggestions) { tag in
                tagRow(tag)
            }
        }
    }
    
    @ViewBuilder
    private var selectionSections: some View {
        
        let (selected, notSelected) = tagSections
        
        if !selected.isEmpty {
            Section {
                ForEach(selected) { tag in
                    tagRow(tag)
                }
            } header: {
                Text("selected")
            }
        }
        
        if !notSelected.isEmpty {
            Section {
                ForEach(notSelected) { tag in
                    tagRow(tag)
                }
            } header: {
                Text("tags")
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if tags.isEmpty && text.isEmpty {
                    VStack {
                        Image(systemName: "tag.slash")
                            .font(.title)
                        Text("tags-none-yet")
                            .padding()
                            .foregroundColor(.secondaryLabel)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    List {
                        if !text.isEmpty {
                            addNewTagButton
                            filteredResultsSection
                        } else {
                            selectionSections
                        }
                        
                    }
                }
            }
            
            
            .navigationTitle("tags")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $text, prompt: "tags-search-or-add")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("done").fontWeight(.semibold)
                    }

                }
            }
        }
        .presentationDetents([.medium])        
    }
}

struct TagPicker: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(fetchRequest: THTag.all) private var tags: FetchedResults<THTag>
    @State private var sheet: Bool = false
    
    @Binding var selection: Set<THTag>
    
    let compact: Bool
    
    init(selection: Binding<Set<THTag>>, compact: Bool = false) {
        self._selection = selection
        self.compact = compact
    }

    var body: some View {
        TagCollection(tags: selection, inlineLabel: compact) {
            HStack {
                if !compact {
                    Text("tags")
                    Spacer()
                }
                
                Button {
                    sheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.bordered)
            }
        }
        .onTapGesture {
            sheet = true
        }
        .sheet(isPresented: $sheet) {
            TagPickerSheet(selection: $selection)
        }
    }
}

struct TagPicker_Previews: PreviewProvider {
    
    struct TagPickerPreview: View {
        @State private var selection = Set<THTag>()
        
        let compact: Bool
        var body: some View {
            TagPicker(selection: $selection, compact: compact)
        }
    }
    static var previews: some View {
        Form {
            Section {
                TagPickerPreview(compact: false)
            }
            
            Section {
                TagPickerPreview(compact: true)
            }
        }.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
