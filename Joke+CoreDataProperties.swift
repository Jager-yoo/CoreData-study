//
//  Joke+CoreDataProperties.swift
//  CoreDataCRUDPractice
//
//  Created by 유재호 on 2022/01/24.
//
//

import Foundation
import CoreData


extension Joke {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Joke> {
        return NSFetchRequest<Joke>(entityName: "Joke")
    }

    @NSManaged public var body: String?
    @NSManaged public var category: String?
    @NSManaged public var id: UUID?

}

extension Joke : Identifiable {

}
