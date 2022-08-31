//
//  FeedLoader.swift
//  RouteMap
//
//  Created by Анна Яцун on 31.08.2022.
//

import Foundation
enum FeedLoadResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func execute(completion: @escaping(FeedLoadResult) -> ())
}
