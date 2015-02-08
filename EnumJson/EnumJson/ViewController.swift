//
//  ViewController.swift
//  EnumJson
//
//  Created by Ushio on 2015/02/01.
//  Copyright (c) 2015年 Ushio. All rights reserved.
//

import UIKit
import Accounts
import Social

// mapped object
struct User {
    var name = ""
    var imageurl = ""
}
struct Media {
    var url = ""
    var type = ""
}
struct Tweet {
    var text = ""
    var user = User()
    var medias: [Media]? = []
}

// conform protocol
extension User : EJsonObjectMapping {
    mutating func mapping() {
        self.name => "name"
        self.imageurl => "profile_image_url"
    }
}

extension Media : EJsonObjectMapping {
    mutating func mapping() {
        self.url => "url"
        self.type => "type"
    }
}
extension Tweet : EJsonObjectMapping {
    mutating func mapping() {
        self.text => "text"
        self.user => "user"
        self.medias => "entities" ~> "media"
    }
}

class TweetTableViewCell : UITableViewCell {
    @IBOutlet weak var imageviewUserThumbnail: UIImageView!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelContents: UILabel!
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let urlCache = NSURLCache.sharedURLCache()
    
    // binding
    @IBOutlet weak var tableviewAccounts: UITableView!
    @IBOutlet weak var tableviewTweet: UITableView!
    
    // variables
    let accountStore = ACAccountStore()
    var accounts: [ACAccount] = [] {
        didSet {
            self.tableviewAccounts.reloadData()
        }
    }
    var tweets: [Tweet] = [] {
        didSet {
            self.tableviewTweet.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableviewAccounts.delegate = self
        self.tableviewAccounts.dataSource = self
        self.tableviewTweet.delegate = self
        self.tableviewTweet.dataSource = self
        
        self.tableviewTweet.estimatedRowHeight = 100
        self.tableviewTweet.rowHeight = UITableViewAutomaticDimension
        
        let accountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        self.accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted, error) -> Void in
            if granted == false{
                println("denied")
                return
            }
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.accounts = self.accountStore.accountsWithAccountType(accountType) as [ACAccount]
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableviewAccounts {
            return self.accounts.count
        }
        return self.tweets.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.tableviewAccounts {
            if let cell = self.tableviewAccounts.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell {
                cell.textLabel?.text = "@" + self.accounts[indexPath.row].username
                return cell
            }
        } else if tableView == self.tableviewTweet {
            if let cell = self.tableviewTweet.dequeueReusableCellWithIdentifier("Cell") as? TweetTableViewCell {
                let tweet = self.tweets[indexPath.row]
                cell.labelUsername.text = tweet.user.name
                cell.labelContents.text = tweet.text
                cell.imageviewUserThumbnail.image = nil
                
                if let request = NSURL(string: tweet.user.imageurl) >>> { NSURLRequest(URL:$0) } {
                    if let cache = urlCache.cachedResponseForRequest(request) {
                        cell.imageviewUserThumbnail.image = UIImage(data: cache.data)
                    } else {
                        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue() ) { (response, data, error) -> Void in
                            if let image = data >>> { data in UIImage(data: data) } {
                                
                                let cached = NSCachedURLResponse(response: response, data: data)
                                self.urlCache.storeCachedResponse(cached, forRequest: request)
                                
                                if let currentIndex = self.tableviewTweet.indexPathForCell(cell) {
                                    if currentIndex == indexPath {
                                        UIView.transitionWithView(
                                            cell.imageviewUserThumbnail,
                                            duration: 0.2,
                                            options: UIViewAnimationOptions.TransitionCrossDissolve,
                                            animations: { () -> Void in
                                                cell.imageviewUserThumbnail.image = image
                                        }, completion: { (completed) -> Void in })
                                    }
                                }
                            }
                        }
                    }
                }
                return cell
            }
        }
        assert(false, "")
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView != self.tableviewAccounts {
            return
        }
        
        let account = self.accounts[indexPath.row]
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: url, parameters: ["count" : "50"])
        request.account = account
        request.performRequestWithHandler { (data, response, error) -> Void in
            let tweets: [Tweet] = EJson(data: data)?.asMappedObject() ?? []
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.tweets = tweets
            }
        }
    }
}

