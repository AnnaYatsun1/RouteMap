//
//  FeedItem.swift
//  RouteMap
//
//  Created by Анна Яцун on 31.08.2022.
//

import Foundation

public struct FeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let image: String
}
