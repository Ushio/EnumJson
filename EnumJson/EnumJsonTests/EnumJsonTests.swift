//
//  EnumJsonTests.swift
//  EnumJsonTests
//
//  Created by Ushio on 2015/02/01.
//  Copyright (c) 2015年 Ushio. All rights reserved.
//

import UIKit
import XCTest


struct User {
    let number: Double
    let name: String
    let imageurl: String
    
//    static func construct(number: Double)(name: String)(imageurl: String) -> User{
//        return User(number: number, name: name, imageurl: imageurl)
//    }
//    static func fromJson(json: Json) -> User? {
//        return construct <*> json["number"]?.asNumber <*> json["user" ~> "name"]?.asString <*> json["user" ~> "profile_image_url"]?.asString
//    }
}
class EnumJsonTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasic() {
        let json: Json = [
            "string" : "string_value",
            "number_double" : 10.5,
            "number_int" : 15,
            "boolean" : true,
            "null" : nil,
            "array" : ["red", "green", "blue"],
            "object" : [
                "one" : 1,
                "two" : 2,
                "three" : 3
            ]
        ]
        
        XCTAssert(json["string"] != nil)
        XCTAssert(json["string"]!.asString == "string_value")
        XCTAssert(json["number_double"] != nil)
        XCTAssert(json["number_double"]!.asNumber == 10.5)
        XCTAssert(json["number_int"] != nil)
        XCTAssert(json["number_int"]!.asNumber == 15)
        XCTAssert(json["boolean"] != nil)
        XCTAssert(json["boolean"]!.asBoolean == true)
        XCTAssert(json["null"] != nil)
        XCTAssert(json["null"]!.isNull == true)
        
        XCTAssert(json["array" ~> 0] != nil)
        XCTAssert(json["array" ~> 0]!.asString == "red")
        XCTAssert(json["array" ~> 1] != nil)
        XCTAssert(json["array" ~> 1]!.asString == "green")
        XCTAssert(json["array" ~> 2] != nil)
        XCTAssert(json["array" ~> 2]!.asString == "blue")
        
        XCTAssert(json["array" ~> -1] == nil)
        XCTAssert(json["array" ~> 9999] == nil)
        
        XCTAssert(json["arraay" ~> 1] == nil)
        XCTAssert(json["arraay"] == nil)
        
        XCTAssert(json["object" ~> "one"] != nil)
        XCTAssert(json["object" ~> "one"]!.asNumber == 1)
        XCTAssert(json["object" ~> "two"] != nil)
        XCTAssert(json["object" ~> "two"]!.asNumber == 2)
        XCTAssert(json["object" ~> "three"] != nil)
        XCTAssert(json["object" ~> "three"]!.asNumber == 3)
        
        let rebuild = Json(data: json.jsonData)
        XCTAssert(rebuild != nil)
        XCTAssert(json == rebuild!)
    }
    func testPath() {
        XCTAssert((1 ~> "one") ~> "hoge" == 1 ~> ("one" ~> "hoge"))
        
        let path_a: JsonPath = "object"
        let path_b: JsonPath = 1
        let path_c: JsonPath = JsonPath.End
        
        XCTAssert(path_a.isKey)
        XCTAssert(path_b.isIndex)
        XCTAssert(path_c.isEnd)
        
        XCTAssert(("object" ~> 1 ~> "hoge").description == "\"object\" ~> 1 ~> \"hoge\" ~> @")
        
        XCTAssert(("object" ~> 1 ~> "hoge") != ("object" ~> 2 ~> "hoge"))
        XCTAssert(("object" ~> 1 ~> "hoge") != ("object" ~> 1 ~> "hogee"))
    }
    func testRemove() {
        let json_a: Json = [
            "string" : "string_value",
            "number_double" : 10.5,
            "number_int" : 15,
            "boolean" : true,
            "null" : nil,
            "array" : ["red", "green", "blue", "blue"],
            "object" : [
                "one" : 1,
                "two" : 2,
                "three" : 3
            ]
        ]
        let json_b = json_a.remove("number_int").remove("array" ~> 1).remove("object" ~> "one")
        XCTAssert(json_b == [
            "string" : "string_value",
            "number_double" : 10.5,
            "boolean" : true,
            "null" : nil,
            "array" : ["red", "blue", "blue"],
            "object" : [
                "two" : 2,
                "three" : 3
            ]
        ])
        
        XCTAssert(json_a == json_a.remove("aaaaaa"))
        XCTAssert(json_a == json_a.remove(0))
        XCTAssert(json_a == json_a.remove(0 ~> 0))
    }
    func testReplace() {
        let json_a: Json = [
            "string" : "string_value",
            "number_double" : 10.5,
            "number_int" : 15,
            "boolean" : true,
            "null" : nil,
            "array" : ["red", "green", "blue", "blue"],
            "object" : [
                "one" : 1,
                "two" : 2,
                "three" : 3
            ]
        ]
        let json_b = json_a
            .replace(100, jsonPath: "number_double")
            .replace("head", jsonPath: "array" ~> 0)
            .replace("aaaaa", jsonPath: "aaa")
            .replace(["four" : 4], jsonPath: "object")
        
        XCTAssert(json_b == [
            "string" : "string_value",
            "number_double" : 100,
            "number_int" : 15,
            "boolean" : true,
            "null" : nil,
            "array" : ["head", "green", "blue", "blue"],
            "object" : ["four" : 4]
            ])
    }
    func testAppend() {
        var json: Json = [:]
        XCTAssert(json == [:])
        
        json = json.append("string", jsonPath: "string_key")
        XCTAssert(json == ["string_key" : "string"])
        
        json = json.append(true, jsonPath: "key1" ~> "key2")
        XCTAssert(json == [
            "string_key" : "string",
            "key1" : ["key2" : true]
        ])
        
        json = json.append("a", jsonPath: "key3")
        XCTAssert(json == [
            "string_key" : "string",
            "key1" : ["key2" : true],
            "key3" : "a"
        ])
        
        json = json.append("c", jsonPath: "key3")
        XCTAssert(json == [
            "string_key" : "string",
            "key1" : ["key2" : true],
            "key3" : ["a", "c"]
        ])
        
        json = "a"
        json = json.append("b", jsonPath: JsonPath.End)
        json = json.append("c", jsonPath: JsonPath.End)
        XCTAssert(json == ["a", "b", "c"])
    }
    
    func testJsonImport() {
        let json = NSBundle(forClass: self.dynamicType).pathForResource("JsonExample1.txt", ofType: "") >>> { path in
            NSData(contentsOfFile: path)
        } >>> { data in
            Json(data: data)
        }
        
        XCTAssert(json != nil, "")
        if let json = json {
            let coordinates = json["coordinates"]
            XCTAssert(coordinates != nil, "")
            XCTAssert(coordinates!.isNull, "")
            
            let favorited = json["favorited"]
            XCTAssert(favorited != nil, "")
            XCTAssert(favorited!.isBoolean, "")
            XCTAssert(favorited!.asBoolean != nil, "")
            XCTAssert(favorited!.asBoolean! == false, "")
            
            let url = json["entities" ~> "urls" ~> 0 ~> "expanded_url"]
            XCTAssert(url != nil, "")
            XCTAssert(url! == "https://dev.twitter.com/terms/display-guidelines", "")
            
            let index = json["entities" ~> "urls" ~> 0 ~> "indices" ~> 1]
            XCTAssert(index != nil, "")
            XCTAssert(index! == 97, "")
        }
    }
    

    func testObjectMapping() {
//        let users = NSBundle(forClass: self.dynamicType).pathForResource("JsonExample2.txt", ofType: "") >>> { path in
//            NSData(contentsOfFile: path)
//        } >>> { data in
//            Json(data: data)?.toArray(User.fromJson)
//        }
//        
//        XCTAssert(users != nil, "")
//        if let users = users {
//            XCTAssert(users.count == 2, "")
//            XCTAssert(users[0].number == 102, "")
//            XCTAssert(users[1].name == "Ken", "")
//            XCTAssert(users[1].imageurl == "http://dummy2.jpeg", "")
//        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
