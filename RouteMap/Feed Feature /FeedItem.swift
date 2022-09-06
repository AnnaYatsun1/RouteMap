//
//  FeedItem.swift
//  RouteMap
//
//  Created by Анна Яцун on 31.08.2022.
//

import Foundation
import UIKit

//public struct FeedItem: Equatable {
//    public let id: UUID
//    public let description: String?
//    public let location: String?
//    public let imageUrl: URL
//    
//    
////    private enum CodingKeys: String, CodingKey {
////        case id
////        case description
////        case location
////        case imageURL = "image"
////    }
////    public init(id: UUID,
////                description: String?,
////                location: String?,
////                imageUrl: URL) {
////        self.id = id
////        self.description = description
////        self.location = location
////        self.imageUrl = imageUrl
////    }
//}

struct FeedItem: Decodable, Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageUrl: URL
    private enum CodingKeys: String, CodingKey {
        case id
        case imageUrl = "image"
        case description
        case location
    }
        public init(id: UUID,
                    description: String?,
                    location: String?,
                    imageUrl: URL) {
            self.id = id
            self.description = description
            self.location = location
            self.imageUrl = imageUrl
        }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        description = try? values.decode(String.self, forKey: .description)
        location = try? values.decode(String.self, forKey: .location)
        imageUrl = try values.decode(URL.self, forKey: .imageUrl)
    }
}

