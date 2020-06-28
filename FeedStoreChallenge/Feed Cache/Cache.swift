//
//  Cache.swift
//  FeedStoreChallenge
//
//  Created by Miguel Duran on 28-06-20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

@objc(Cache)
internal class Cache: NSManagedObject {
    @nonobjc internal class func createFetchRequest() -> NSFetchRequest<Cache> {
        return NSFetchRequest<Cache>(entityName: "Cache")
    }
    
    internal static func delete(in context: NSManagedObjectContext) throws {
        let request = createFetchRequest()
        let caches = try context.fetch(request)
        caches.forEach(context.delete)
    }

    @NSManaged internal var timestamp: Date
    @NSManaged internal var feed: NSOrderedSet
    
    convenience init(context moc: NSManagedObjectContext, feed: [CoreDataFeedImage], timestamp: Date) {
        let name = String(describing: type(of: self))
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: moc) else {
            fatalError("There is no entity with name \(name)")
        }
        self.init(entity: entity, insertInto: moc)
        self.timestamp = timestamp
        self.feed = NSOrderedSet(array: feed)
    }
    
    var localFeed: [LocalFeedImage] {
        let images = self.feed.array as? [CoreDataFeedImage] ?? []
        return images.map { $0.local }
    }
}
