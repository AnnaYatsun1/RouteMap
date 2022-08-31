//
//  ViewController.swift
//  RouteMap
//
//  Created by Анна Яцун on 01.08.2022.
//

import UIKit

// LogginModule

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        APIClient.instance.login() { user in
            
        }
    }
}

struct LoggedInUser {}

extension APIClient {
    func login(completion: (LoggedInUser) -> ()) {
        
    }
}

// FeedModule
class FeedController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        APIClient.instance.loadFeed() { feedItem in
            
        }
    }
}


extension APIClient {
    func loadFeed(completion: ([FeedItem]) -> ()) {
        
    }
}


// Singeltone
class APIClient {
    
    static let instance = APIClient()
    
    private init() { }
    
    func execute(_ : URLSession, completion: (Data) -> ()) {
        
    }
}
