//
//  THTag+CoreDataClass.swift
//  teha
//
//  Created by Matteo Ludwig on 15.01.23.
//
//

import Foundation
import CoreData

@objc(THTag)
public class THTag: NSManagedObject {

}


//MARK: FetchRequests
extension THTag {
    
    static var all: NSFetchRequest<THTag> {
        let request = THTag.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        return request
    }
}
