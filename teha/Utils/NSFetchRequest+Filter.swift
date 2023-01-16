//
//  NSFetchRequest+Filter.swift
//  teha
//
//  Created by Matteo Ludwig on 15.01.23.
//

import Foundation
import CoreData

extension NSFetchRequest {
    
    /// Concatenates the NSFetchRequest's  current predicate with the given predicate by an AND.
    /// When the NSFetchRequest currently does not have any predicate, the give predicate is set as the new predicate without the use of an AND.
    @objc func predicateAnd(with predicate: NSPredicate) {
        self.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [self.predicate, predicate].compactMap{ $0 })
    }
}


