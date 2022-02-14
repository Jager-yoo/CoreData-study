//
//  Joke+CoreDataClass.swift
//  CoreDataCRUDPractice
//
//  Created by 유재호 on 2022/02/15.
//
//

import CoreData

@objc(Joke)
public class Joke: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Joke> {
        return NSFetchRequest<Joke>(entityName: "Joke")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var body: String?
    @NSManaged public var category: String?
    
    enum Category: String {
        
        case buzzWord
        case dadJoke
    }
}

extension Joke : Identifiable {

}
