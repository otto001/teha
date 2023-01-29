//
//  TextFieldMultiline.swift
//  teha
//
//  Created by Matteo Ludwig on 06.01.23.
//

import SwiftUI

/// A Textfield that looks like a normal SwiftUI TextField but supports linebreaks.
struct TextFieldMultiline: View {
    var title: String
    @Binding var text: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        // In this view we use some weird padding, which has been fine-tuned to emulate the look of the SwiftUI.TextField input
        ZStack(alignment: .topLeading) {
            // Using a TextEditor to support multile text
            TextEditor(text: $text)
                .frame(minHeight: 72)
                .padding(.horizontal, -5)
            
            if text.isEmpty {
                // The title made to look like a normal TextField label
                Text(title)
                    .foregroundColor(Color(uiColor: .tertiaryLabel))
                    .padding(.top, 8)
            }
        }
    }
}

// MARK: Preview

struct TextFieldMultiline_Previews: PreviewProvider {
    
    /// A Preview wrapper that allows for stateful previews
    struct TextFieldMultilinePreview: View {
        @State var text: String = ""
        let title = "Notes"
        
        var body: some View {
            TextFieldMultiline(title, text: $text)
        }
    }
    
    static var previews: some View {
        Form {
            TextFieldMultilinePreview()
        }
    }
}
