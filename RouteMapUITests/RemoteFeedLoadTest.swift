//
//  RemoteFeedLoadTest.swift
//  RouteMapUITests
//
//  Created by Анна Яцун on 31.08.2022.
//

import XCTest
import RouteMap


public protocol HTTPClient {
    func get(url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> ())
}

public final class RemoteFeedLoad {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidate
    }
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (RemoteFeedLoad.Error) -> ()) {
        client.get(url: url) { error, responce in
            if responce != nil {
                completion(.invalidate)
            } else {
                completion(.connectivity)
            }
        }
    }
}

class RemoteFeedLoadTest: XCTestCase {

    func test_init_dosNotRequestDataFromUrl() {
        let (_, client) = mekeSUT()
        XCTAssertTrue(client.requestURL.isEmpty)
    }

    func test_load_requestDataFromUrl() {
        let url = URL(string: "http://given-url.com")!
        let (sut, client) = mekeSUT(url: url)
        sut.load { _ in }
        XCTAssertEqual(client.requestURL, [url])
    }
    
    func test_load_deliversErrprOnClientError() {
        let (sut, client) = mekeSUT()

        var captureError = [RemoteFeedLoad.Error?]()
        sut.load { captureError.append($0) }
        let clientError = NSError(domain: "Test", code: 0)
        client.complite(error: clientError)
        XCTAssertEqual(captureError, [.connectivity])
    }
    
    func test_load_deliversErrprOn200HTTPResponce() {
        let (sut, client) = mekeSUT()
        
        [199, 201, 300, 400, 500].enumerated().forEach { index, code in
            var captureError = [RemoteFeedLoad.Error?]()
            sut.load { captureError.append($0) }
            client.complite(withStatusCode: code, index: index)
            XCTAssertEqual(captureError, [.invalidate])
        }
    }
    
    private func mekeSUT(url: URL = URL(string: "http://a-given-url.com")!) -> (sut: RemoteFeedLoad, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoad(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestURL: [URL] {
            return masseges.map {
                $0.url
            }
        }
        var masseges = [(url: URL, completion: (Error?, HTTPURLResponse?) -> ())]()
        
        func get(url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> ()) {
            masseges.append((url, completion))
        }
        
        func complite(error: Error, index: Int = 0) {
            masseges[index].completion(error, nil)
        }
        
        func complite(withStatusCode code: Int, index: Int = 0) {
            let responce = HTTPURLResponse(
                url: requestURL[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)
            masseges[index].completion(nil, responce)
        }
    }
}
