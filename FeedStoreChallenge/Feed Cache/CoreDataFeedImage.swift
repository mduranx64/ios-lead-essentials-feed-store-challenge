//
//  CoreDataFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Miguel Duran on 28-06-20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

@objc(CoreDataFeedImage)
internal class CoreDataFeedImage: NSManagedObject {

    @NSManaged internal var feedDescription: String?
    @NSManaged internal var id: UUID
    @NSManaged internal var location: String?
    @NSManaged internal var url: URL
    @NSManaged internal var cache: Cache
    
    convenience init(context moc: NSManagedObjectContext, image: LocalFeedImage) {
        let name = String(describing: type(of: self))
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: moc) else {
            fatalError("There is no entity with name \(name)")
        }
        self.init(entity: entity, insertInto: moc)
        self.id = image.id
        self.location = image.location
        self.feedDescription = image.description
        self.url = image.url
    }
    
    var local: LocalFeedImage {
        return LocalFeedImage(
            id: id,
            description: feedDescription,
            location: location,
            url: url
        )
    }
}
