//
//  CoreDataFeedImage+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Miguel Duran on 04-06-20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData


extension CoreDataFeedImage {

    @nonobjc internal class func createFetchRequest() -> NSFetchRequest<CoreDataFeedImage> {
        return NSFetchRequest<CoreDataFeedImage>(entityName: "CoreDataFeedImage")
    }

    @NSManaged internal var feedDescription: String?
    @NSManaged internal var id: UUID
    @NSManaged internal var location: String?
    @NSManaged internal var url: URL
    @NSManaged internal var cache: Cache

}
