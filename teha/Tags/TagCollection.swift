//
//  TagCollection.swift
//  teha
//
//  Created by Matteo Ludwig on 16.01.23.
//

import SwiftUI

struct TagCollection<LabelContent: View>: View {
    let tags: Set<THTag>
    let label: () -> LabelContent
    
    let inlineLabel: Bool
    
    private var sortedTags: [THTag] {
        Array(tags).sorted { a, b in
            a.name ?? "" < b.name ?? ""
        }
    }
    
    init(tags: Set<THTag>, inlineLabel: Bool = false, @ViewBuilder label: @escaping () -> LabelContent) {
        self.tags = tags
        self.label = label
        self.inlineLabel = inlineLabel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if !inlineLabel {
                HStack {
                    label()
                }
            }
            FlexHStack {
                if inlineLabel {
                    label()
                }
                ForEach(sortedTags) { tag in
                    Text(tag.name ?? "")
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.secondarySystemFill)
                        .cornerRadius(6)
                }
            }
        }
    }
}

extension TagCollection where LabelContent == Text {
    init(_ titleKey: LocalizedStringKey, tags: Set<THTag>) {
        self.init(tags: tags) {
            Text(titleKey)
        }
    }
}

struct TagCollection_Previews: PreviewProvider {
    static var previews: some View {
        TagCollection("tags", tags: .init())
    }
}
