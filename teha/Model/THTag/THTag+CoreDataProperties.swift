//
//  THTag+CoreDataProperties.swift
//  teha
//
//  Created by Matteo Ludwig on 15.06.24.
//
//

import Foundation
import CoreData


extension THTag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<THTag> {
        return NSFetchRequest<THTag>(entityName: "THTag")
    }

    @NSManaged public var name: String?
    @NSManaged public var taskDescriptions: Set<THTaskDescription>

}


extension THTag : Identifiable {

}
