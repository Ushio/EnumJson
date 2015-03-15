//
//  EnumJsonTests.swift
//  EnumJsonTests
//
//  Created by Ushio on 2015/02/01.
//  Copyright (c) 2015年 Ushio. All rights reserved.
//

import UIKit
import XCTest
import EnumJsonFramework


struct User {
    let number: Double
    let name: String
    let imageurl: String
    
    static func fromJson(json: Json) -> User? {
        if
            let number = json["number"]?.double,
            let name = json["user" ~> "name"]?.string,
            let imageurl = json["user" ~> "profile_image_url"]?.string
        {
            return User(number: number, name: name, imageurl: imageurl)
        }
        return nil
    }
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
        
        XCTAssert(json.isObject)
        XCTAssert(json["string"] != nil)
        XCTAssert(json["string"]!.isString)
        XCTAssert(json["string"]!.string == "string_value")
        XCTAssert(json["number_double"] != nil)
        XCTAssert(json["number_double"]!.isNumber)
        XCTAssert(json["number_double"]!.number == 10.5)
        XCTAssert(json["number_int"] != nil)
        XCTAssert(json["number_int"]!.number == 15)
        XCTAssert(json["boolean"] != nil)
        XCTAssert(json["boolean"]!.boolean == true)
        XCTAssert(json["null"] != nil)
        XCTAssert(json["null"]!.isNull == true)
        
        XCTAssert(json["array" ~> 0] != nil)
        XCTAssert(json["array" ~> 0]!.string == "red")
        XCTAssert(json["array" ~> 1] != nil)
        XCTAssert(json["array" ~> 1]!.string == "green")
        XCTAssert(json["array" ~> 2] != nil)
        XCTAssert(json["array" ~> 2]!.string == "blue")
        
        XCTAssert(json["array" ~> -1] == nil)
        XCTAssert(json["array" ~> 9999] == nil)
        
        XCTAssert(json["arraay" ~> 1] == nil)
        XCTAssert(json["arraay"] == nil)
        
        XCTAssert(json["object" ~> "one"] != nil)
        XCTAssert(json["object" ~> "one"]!.number == 1)
        XCTAssert(json["object" ~> "two"] != nil)
        XCTAssert(json["object" ~> "two"]!.number == 2)
        XCTAssert(json["object" ~> "three"] != nil)
        XCTAssert(json["object" ~> "three"]!.number == 3)
        
        if let data = json.jsonData, rebuild = Json(data: data) {
            XCTAssert(json == rebuild)
        } else {
            XCTAssert(false)
        }

    }
    func testPath() {
        XCTAssert((1 ~> "one") ~> "hoge" == 1 ~> ("one" ~> "hoge"))
        XCTAssert((1 ~> "one") ~> "hoge" == JsonPath(1) ~> JsonPath("one") ~> JsonPath("hoge"))
        
        let path_a: JsonPath = "object"
        let path_b: JsonPath = 1
        let path_c: JsonPath = JsonPath.Nil
        
        XCTAssert(("object" ~> 1 ~> "hoge").description == "\"object\" ~> 1 ~> \"hoge\" ~> @")
        
        let a0 = ("object" ~> 1 ~> "hoge")
        let b0 = ("object" ~> 2 ~> "hoge")
        XCTAssert(a0 != b0)
        
        let a1 = ("object" ~> 1 ~> "hoge")
        let b1 = ("object" ~> 1 ~> "hogee")
        XCTAssert(a1 != b1)
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
            .set(100, jsonPath: "number_double")
            .set("head", jsonPath: "array" ~> 0)
            .set("aaaaa", jsonPath: "aaa")
            .set(["four" : 4], jsonPath: "object")
        
        XCTAssert(json_b == [
            "aaa" : "aaaaa",
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
        
        json["string_key"] = "string"
        XCTAssert(json == ["string_key" : "string"])
        
        json["key1" ~> "key2"] = true
        XCTAssert(json == [
            "string_key" : "string",
            "key1" : ["key2" : true]
        ])
        
        json["key3"] = "a"
        XCTAssert(json == [
            "string_key" : "string",
            "key1" : ["key2" : true],
            "key3" : "a"
        ])
        
        json["key3"] = "c"
        XCTAssert(json == [
            "string_key" : "string",
            "key1" : ["key2" : true],
            "key3" : "c"
        ])
        json["key1"] = nil
        
        XCTAssert(json == [
            "string_key" : "string",
            "key3" : "c"])
    }
    
    func testJsonImport() {
        let bundle = NSBundle(forClass: self.dynamicType)
        if
            let path = bundle.pathForResource("JsonExample1.txt", ofType: ""),
            let data = NSData(contentsOfFile: path),
            let json = Json(data: data)
        {
            let coordinates = json["coordinates"]
            XCTAssert(coordinates != nil, "")
            XCTAssert(coordinates!.isNull, "")
            
            let favorited = json["favorited"]
            XCTAssert(favorited != nil, "")
            XCTAssert(favorited!.isBoolean, "")
            XCTAssert(favorited!.boolean != nil, "")
            XCTAssert(favorited!.boolean! == false, "")
            
            let url = json["entities" ~> "urls" ~> 0 ~> "expanded_url"]
            XCTAssert(url != nil, "")
            XCTAssert(url! == "https://dev.twitter.com/terms/display-guidelines", "")
            
            let index = json["entities" ~> "urls" ~> 0 ~> "indices" ~> 1]
            XCTAssert(index != nil, "")
            XCTAssert(index! == 97, "")
        } else {
            XCTAssert(false, "")
        }
    }
    

    func testObjectMapping() {
        let bundle = NSBundle(forClass: self.dynamicType)
        if
            let path = bundle.pathForResource("JsonExample2.txt", ofType: ""),
            let data = NSData(contentsOfFile: path),
            let users = Json(data: data)?.toArray(User.fromJson)
        {
            XCTAssert(users.count == 2, "")
            XCTAssert(users[0].number == 102, "")
            XCTAssert(users[1].name == "Ken", "")
            XCTAssert(users[1].imageurl == "http://dummy2.jpeg", "")
        } else {
            XCTAssert(false, "")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
