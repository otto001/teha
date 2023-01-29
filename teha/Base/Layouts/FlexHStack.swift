//
//  FlexVStack.swift
//  teha
//
//  Created by Matteo Ludwig on 15.01.23.
//

import SwiftUI

/// A Layout container that, just like HStack, lays out its subviews horizontally.
/// However, when its width is not sufficient for displaying all subviews next to eachother, it starts a new row below the previous items.
/// Therefore, it does not grow in size horizontally, but vertically.
struct FlexHStack: Layout {
    
    /// A helper struct containing a LayoutSubview and its frame. The struct also provides a cache for the LayoutSubview's ViewDimensions.
    struct SubviewWithFrame {
        let subview: LayoutSubview
        var frame: CGRect
        let dimensions: ViewDimensions
        
        init(subview: LayoutSubview, proposal: ProposedViewSize) {
            self.subview = subview
            
            // The frames origin will be set later, therefore init with .zero
            self.frame = CGRect(origin: .zero, size: subview.sizeThatFits(proposal))
            
            // Cache the subviews dimensions for later use
            self.dimensions = subview.dimensions(in: ProposedViewSize(self.frame.size))
        }
    }
    
    /// A helper struct containing all subviews that will be displayed in one row.
    /// Can determine its own size and frame based on the subviews it contains.
    /// Impletements the Collection Protocol for easy access to the subviews.
    struct Row: Collection {
        // Members
        private var subviews: [SubviewWithFrame] = []
        private(set) var frame: CGRect = .zero
        
        // Collection Protocol
        var startIndex: Int { subviews.startIndex }
        var endIndex: Int { subviews.endIndex }
        
        func index(after i: Int) -> Int {
            return subviews.index(after: i)
        }
        
        subscript(position: Int) -> SubviewWithFrame {
            return subviews[position]
        }
        
        func makeIterator() -> IndexingIterator<[SubviewWithFrame]> {
            return subviews.makeIterator()
        }
        
        /// Method for adding a subview to the row.
        /// Will update the width of the rows frame, which is important to later check if a row is full.
        /// In order to finalize the rows layout (respecting alignment guides), please call .finalizeLayout
        /// - Parameter subview: The subview to add to the row.
        /// - Parameter spacing: The horizontal spacing between the subviews of the row.
        mutating func add(subview: SubviewWithFrame, spacing: CGFloat) {
            // Add width of subview to total row width, respecting spacing when more than one element will be in row
            frame.size.width += subview.frame.size.width + (subviews.isEmpty ? 0 : spacing)
            subviews.append(subview)
        }
        
        /// Finalizes the frames of the row and its subviews, repsecting the vertical alignment of its subviews.
        /// Also updates the frame of the row to be a bounding box surrounding all of the rows subviews.
        /// - Parameter origin: The top left corner of the row and its subviews.
        /// - Parameter alignment: The vertical alignment of the subviews of the row.
        /// - Parameter spacing: The horizontal spacing between the subviews of the row.
        mutating func finalizeLayout(origin: CGPoint, alignment: VerticalAlignment, spacing: CGFloat) {
            guard !subviews.isEmpty else { return }
            
            // Define cursor that starts in the topLeft corner
            var cursor = origin
            
            // Calculate the maximum dimension of the rows chosen vertical alignment, used later to calculate each subview's vertical offset
            let verticalMax = subviews.map { $0.dimensions[alignment] }.max() ?? 0
            
            // Update position (origin) of each subview
            for i in subviews.indices {
                // Calculate verticalOffset of subview based on its vertical alignmentGuide value
                let verticalOffset = verticalMax - subviews[i].dimensions[alignment]
                
                // Update the origin of each of the subviews frame while respecting the subviews vertical alignment guides
                subviews[i].frame.origin = CGPoint(x: cursor.x,
                                                   y: cursor.y + verticalOffset)
                // Move cursor to the right for next view
                cursor.x += subviews[i].frame.size.width + spacing
            }
            
            // Update the row's frame to be a bounding box surrounding all of the rows subviews
            frame = subviews.first!.frame
            for subview in subviews[1...] {
                frame = .bounding(a: frame, b: subview.frame)
            }
        }
    }
    
    /// A helper struct containing all rows that make up the FlexHStack.
    /// Can determine its own size and frame based on the rows it contains.
    /// Impletements the Collection Protocol for easy access to the rows.
    struct Rows: Collection {
        // Members
        private var rows: [Row] = [Row()]
        private(set) var frame: CGRect = .zero
        
        // To calculate the number of rows correctly, the collection must know the width it has avaliable
        init(avaliableWidth: CGFloat) {
            self.frame = CGRect(x: 0, y: 0, width: avaliableWidth, height: 0)
        }
        
        // Collection Protocol
        var startIndex: Int { rows.startIndex }
        var endIndex: Int { rows.endIndex }
        
        func index(after i: Int) -> Int {
            return rows.index(after: i)
        }
        
        subscript(position: Int) -> Row {
            return rows[position]
        }
        
        func makeIterator() -> IndexingIterator<[Row]> {
            return rows.makeIterator()
        }
        
        /// Add a row to the collection. Does not update the frame.
        /// - Parameter row: The row to add to the collection.
        mutating func add(row: Row) {
            rows.append(row)
        }
        
        /// Add a subview to the last row of the collection. Does not update the frame.
        /// - Parameter subview: The subview to add to the last row of the collection.
        /// - Parameter horizontalSpacing: The horizontal spacing between the subviews of each row.
        mutating func add(subview: SubviewWithFrame, horizontalSpacing: CGFloat) {
            if !rows.last!.isEmpty && rows.last!.frame.width + subview.frame.width > frame.width {
                rows.append(Row())
            }
            rows[rows.count-1].add(subview: subview, spacing: horizontalSpacing)
        }
        
        /// Finalizes the frames of the row and its subviews, repsecting the vertical alignment of its subviews.
        /// Also updates the frame of the row to be a bounding box surrounding all of the rows subviews.
        /// - Parameter origin: The top left corner of the row and its subviews.
        /// - Parameter alignment: The vertical alignment of the subviews of the row.
        /// - Parameter horizontalSpacing: The horizontal spacing between the subviews of each row.
        /// - Parameter verticalSpacing: The vertical spacing between each of the rows.
        mutating func finalizeLayout(origin: CGPoint, alignment: VerticalAlignment, horizontalSpacing: CGFloat, verticalSpacing: CGFloat) {
            guard !rows.isEmpty else { return }
            
            // Define cursor that starts in the topLeft corner
            var cursor = origin
            
            // Finalize the layout of each indivdual row
            for i in rows.indices {
                rows[i].finalizeLayout(origin: cursor, alignment: alignment, spacing: horizontalSpacing)
                
                // Add the final height of the row to the cursor to place the next row underneath
                cursor.y += rows[i].frame.size.height + verticalSpacing
            }
            
            // Update the frame to be a bounding box surrounding all of the rows subviews
            frame = rows.first!.frame
            for subview in rows[1...] {
                frame = .bounding(a: frame, b: subview.frame)
            }
        }
    }
    
    // A helper struct containing the entire layout data for the FlexHStack.
    struct LayoutData {
        private var rows: Rows
        
        /// A bounding box  containing all subviews.
        var bounds: CGRect {
            return rows.frame
        }
        
        init(proposal: ProposedViewSize, subviews: Subviews, alignment: VerticalAlignment, horizontalSpacing: CGFloat, verticalSpacing: CGFloat) {
            
            // Init rows collection with avaliable width gathered from the container's size proposal, or infinity if no size was proposed
            var rows = Rows(avaliableWidth: proposal.width ?? .infinity)
            
            // Add all subviews to the rows collection
            for subview in subviews {
                let subviewWithFrame = SubviewWithFrame(subview: subview, proposal: proposal)
                rows.add(subview: subviewWithFrame, horizontalSpacing: horizontalSpacing)
            }
            
            // Finalize the layout of the rows
            rows.finalizeLayout(origin: .zero, alignment: alignment, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing)
            
            self.rows = rows
        }
        
        /// Applies the layout to all subviews by placing them. Calls .place(at:, proposal:) for each subview once.
        /// - Parameter bounds: The bounds in which the subviews shall be placed. The width and height of the bounds may be ignored.
        func apply(bounds: CGRect) {
            for row in rows {
                for subview in row {
                    let position = CGPoint(x: subview.frame.origin.x + bounds.origin.x,
                                           y: subview.frame.origin.y + bounds.origin.y)
                    subview.subview.place(at: position, proposal: ProposedViewSize(subview.frame.size))
                }
            }
        }
    }
    
    let alignment: VerticalAlignment
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    
    init(alignment: VerticalAlignment = .center, horizontalSpacing: CGFloat = 6, verticalSpacing: CGFloat = 6) {
        self.alignment = alignment
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        // Use the LayoutData helper struct to determine size of Layout
        let layout = LayoutData(proposal: proposal, subviews: subviews, alignment: alignment, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing)
        
        return layout.bounds.size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        // Use the LayoutData helper struct to generate frames for each subview and the apply them.
        let layout = LayoutData(proposal: proposal, subviews: subviews, alignment: alignment, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing)
        
        layout.apply(bounds: bounds)
    }
}

struct FlexHStack_Previews: PreviewProvider {
    static var previews: some View {
        FlexHStack(alignment: .center) {
            Text("1")
                .frame(width: 150, height: 60)
                .background(Color.gray)
            Text("2")
                .frame(width: 150, height: 40)
                .background(Color.gray)
            Text("3")
                .frame(width: 150, height: 20)
                .background(Color.gray)
        }
        .frame(width: 350, height: 400)
        .background(Color.red)
    }
}
