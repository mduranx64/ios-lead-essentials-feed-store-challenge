//
//  Cache+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Miguel Duran on 04-06-20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData


extension Cache {

    @nonobjc internal class func createFetchRequest() -> NSFetchRequest<Cache> {
        return NSFetchRequest<Cache>(entityName: "Cache")
    }

    @NSManaged internal var timestamp: Date
    @NSManaged internal var feed: NSOrderedSet

}

// MARK: Generated accessors for feed
extension Cache {

    @objc(insertObject:inFeedAtIndex:)
    @NSManaged internal func insertIntoFeed(_ value: CoreDataFeedImage, at idx: Int)

    @objc(removeObjectFromFeedAtIndex:)
    @NSManaged internal func removeFromFeed(at idx: Int)

    @objc(insertFeed:atIndexes:)
    @NSManaged internal func insertIntoFeed(_ values: [CoreDataFeedImage], at indexes: NSIndexSet)

    @objc(removeFeedAtIndexes:)
    @NSManaged internal func removeFromFeed(at indexes: NSIndexSet)

    @objc(replaceObjectInFeedAtIndex:withObject:)
    @NSManaged internal func replaceFeed(at idx: Int, with value: CoreDataFeedImage)

    @objc(replaceFeedAtIndexes:withFeed:)
    @NSManaged internal func replaceFeed(at indexes: NSIndexSet, with values: [CoreDataFeedImage])

    @objc(addFeedObject:)
    @NSManaged internal func addToFeed(_ value: CoreDataFeedImage)

    @objc(removeFeedObject:)
    @NSManaged internal func removeFromFeed(_ value: CoreDataFeedImage)

    @objc(addFeed:)
    @NSManaged internal func addToFeed(_ values: NSOrderedSet)

    @objc(removeFeed:)
    @NSManaged internal func removeFromFeed(_ values: NSOrderedSet)

}

extension Cache {
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
