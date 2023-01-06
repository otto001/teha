//
//  TextFieldMultiline.swift
//  teha
//
//  Created by Matteo Ludwig on 06.01.23.
//

import SwiftUI

struct TextFieldMultiline: View {
    var title: String
    @Binding var text: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .frame(minHeight: 72)
                .padding(.horizontal, -5)
            if text.isEmpty {
                Text(title)
                    .foregroundColor(Color(uiColor: .tertiaryLabel))
                    .padding(.top, 8)
            }
        }
    }
}

struct TextFieldMultiline_Previews: PreviewProvider {
    
    struct TextFieldMultilinePreview: View {
        @State var text: String = ""
        let title = "Notes"
        
        var body: some View {
            TextField(title, text: $text)
            TextFieldMultiline(title, text: $text)
        }
    }
    static var previews: some View {
        ZStack {
            Form {
                
                TextFieldMultilinePreview()
            }
            Rectangle()
                .frame(width: 1)
                .offset(x: -155)
        }
    }
}
