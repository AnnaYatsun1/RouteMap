//
//  RemoteFeedLoad.swift
//  RouteMap
//
//  Created by Анна Яцун on 31.08.2022.
//

import Foundation

public protocol HTTPClient {
    func get(url: URL)
}

public final class RemoteFeedLoad {
    private let client: HTTPClient
    private let url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(url: url)
    }
}
