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

struct User {
    let name: String
    let imageurl: String
    
    static func fromJson(json: Json) -> User? {
        if
            let name = json["name"]?.string,
            let imageurl = json["profile_image_url"]?.string
        {
            return User(name: name, imageurl: imageurl)
        }
        return nil
    }
}
struct Tweet {
    let text: String
    let user: User

    static func fromJson(json: Json) -> Tweet? {
        if
            let text = json["text"]?.string,
            let juser = json["user"],
            let user = User.fromJson(juser)
        {
            return Tweet(text: text, user: user)
        }
        return nil
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
                self.accounts = self.accountStore.accountsWithAccountType(accountType) as! [ACAccount]
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableviewAccounts {
            return self.accounts.count
        }
        return self.tweets.count
    }
    
    func cachedImage(url: String, completion: (UIImage?) -> ()) {
        if let url = NSURL(string: url) {
            let request = NSURLRequest(URL:url)
            
            if let cache = urlCache.cachedResponseForRequest(request) {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    completion(UIImage(data: cache.data))
                }
            } else {
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue() ) { (response, data, error) -> Void in
                    if let data = data, image = UIImage(data: data) {
                        let cached = NSCachedURLResponse(response: response, data: data)
                        self.urlCache.storeCachedResponse(cached, forRequest: request)
                        
                        completion(image)
                    } else {
                        completion(nil)
                    }
                }
            }
        } else {
            completion(nil)
        }
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
                
                cachedImage(tweet.user.imageurl) { image in
                    if let currentIndex = self.tableviewTweet.indexPathForCell(cell) {
                        if currentIndex == indexPath {
                            cell.imageviewUserThumbnail.image = image
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
            let tweets = Json(data: data)?.toArray(Tweet.fromJson) ?? []
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.tweets = tweets
            }
        }
    }
}


