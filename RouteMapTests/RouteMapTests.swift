//
//  RouteMapTests.swift
//  RouteMapTests
//
//  Created by Анна Яцун on 01.08.2022.
//

import XCTest
@testable import RouteMap

class RouteMapTests: XCTestCase {
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
        execute(sut: sut, toCompliteWithResult: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complite(error: clientError)
        }
    }
    
    func test_load_deliversErrprOn200HTTPResponce() {
        let (sut, client) = mekeSUT()
        [199, 201, 300, 400, 500].enumerated().forEach { index, code in
            execute(sut: sut, toCompliteWithResult: .failure(.invalidate)) {
                let json = makesItemJSON(items: [])
                client.complite(withStatusCode: code, data: json, index: index)
            }
        }
    }
    
    func test_deliverErrorOn200HTTPResponceWithInvalidJSON() {
        let (sut, client) = mekeSUT()
        execute(sut: sut, toCompliteWithResult: .failure(.invalidate)) {
            let invalidJSON = Data(bytes: "Invalid JSOn".utf8)
            client.complite(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_deliverNotItem200HTTPResponceWithEmptySON() {
        let (sut, client) = mekeSUT()
        execute(sut: sut, toCompliteWithResult: .succes([])) {
            let emptyJSON = Data(bytes: "{\"items\": []}".utf8)
            client.complite(withStatusCode: 200, data: emptyJSON)
        }
    }
    
    func test_deliverNotItem200HTTPResponceWithSONItems() {
        let (sut, client) = mekeSUT()
        
        let item = makeItems(
            id: UUID(),
            imageUrl: URL(string: "https://a-url.com")!)
        
        let item2 = makeItems(
            id: UUID(),
            description: "a description",
            locaton: "a loication",
            imageUrl: URL(string: "https://a-url.com")!)
        
        let items = [item.model, item2.model]
        execute(sut: sut, toCompliteWithResult: .succes(items)){
            let json = makesItemJSON(items: [item.json, item2.json])
            client.complite(withStatusCode: 200, data: json)
        }
    }
    // MARK: Helper
    
    private func mekeSUT(url: URL = URL(string: "http://a-given-url.com")!) -> (sut: RemoteFeedLoad, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoad(url: url, client: client)
        return (sut, client)
    }
    
    private func execute(sut: RemoteFeedLoad, toCompliteWithResult result: RemoteFeedLoad.Result, file: StaticString = #file, line: UInt = #line, action: () ->()) {
        var captureResult = [RemoteFeedLoad.Result?]()
        sut.load { captureResult.append($0) }
        action()
        XCTAssertEqual(captureResult, [result], file: file, line: line)
        
    }
    
    private func makeItems(id: UUID, description: String? = nil, locaton: String? = nil, imageUrl: URL) -> (model: FeedItem, json: [String: Any]){
        let item = FeedItem(id: id, description: description, location: locaton, imageUrl: imageUrl)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": locaton,
            "image": imageUrl.absoluteString
        ].reduce(into: [String: Any]()) { (acc, e) in
            if let value = e.value {
                acc[e.key] = value
            }
        }
        
        return (item, json)
    }
    private func makesItemJSON(items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
        
    }
    private class HTTPClientSpy: HTTPClient {
        var requestURL: [URL] {
            return masseges.map {
                $0.url
            }
        }
        var masseges = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            masseges.append((url, completion))
        }
        
        func complite(error: Error, index: Int = 0) {
            masseges[index].completion(.failure(error))
        }
        
        func complite(withStatusCode code: Int, data: Data, index: Int = 0) {
            let responce = HTTPURLResponse(
                url: requestURL[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            masseges[index].completion(.succes(data, responce))
        }
    }
}

public enum HTTPClientResult {
    case succes(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(url: URL, completion: @escaping (HTTPClientResult) -> ())
}

public final class RemoteFeedLoad {
    private let client: HTTPClient
    private let url: URL

    public enum Error: Swift.Error {
        case connectivity
        case invalidate
    }

    public enum Result: Equatable {
        case succes([FeedItem])
        case failure(Error)
    }
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }

    public func load(completion: @escaping (RemoteFeedLoad.Result) -> ()) {
        client.get(url: url) { rerult in
            switch rerult {
            case let .succes(data, responce):
                if responce.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.succes(root.items))
                } else {
                    completion(.failure(.invalidate))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
struct Root: Decodable {
    let items: [FeedItem]
}
