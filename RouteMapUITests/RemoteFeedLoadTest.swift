//
//  RemoteFeedLoadTest.swift
//  RouteMapUITests
//
//  Created by Анна Яцун on 31.08.2022.
//

import XCTest

class RemoteFeedLoad {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    func load() {
        client.get(url: url)
    }
}

protocol HTTPClient {
    func get(url: URL)
}

class RemoteFeedLoadTest: XCTestCase {

    func test_init_dosNotRequestDataFromUrl() {
        let (_, client) = mekeSUT()
        XCTAssertNil(client.requestURL)
    }

    func test_load_requestDataFromUrl() {
        let url = URL(string: "http://given-url.com")!
        let (sut, client) = mekeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestURL, url)
    }
    
    private func mekeSUT(url: URL = URL(string: "http://a-given-url.com")!) -> (sut: RemoteFeedLoad, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoad(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestURL: URL?
        
        func get(url: URL) {
            requestURL = url
        }
    }
}
