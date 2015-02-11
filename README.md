Type Safe, Thread Safe, Easy Object Mapping, Interface Json Library in Swift

####Definision of Json
```
enum EJson {
    case JObject  (Dictionary<String, EJson>)
    case JArray   (Array<EJson>)
    case JNumber  (Double)
    case JString  (String)
    case JBoolean (Bool)
    case JNull
}
```
####Building Json
```
let json: EJson = [
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
```

####Export Json
```
let data = json.jsonData
```
####Import Json
```
if let json = EJson(data: data) {
  // do something
}
```

####Definision of JsonPath
```
class JBox<T> {
    let unbox: T
    init(_ value: T) {
        self.unbox = value
    }
}
enum EJsonPath {
    case Key(String, JBox<EJsonPath>)
    case Index(Int, JBox<EJsonPath>)
    case End
}
```
####JsonPath Access
```
let json: EJson = [
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
let string_value: String? = json["string_value"]?.asString
let green: String? = json["array" ~> 1]?.asString
let three: Double? = json["object" ~> "three"]?.asNumber
```

####Remove Json (EJson is purely immutable)
```
let json_a: EJson = [
    "string" : "string_value",
    "number_double" : 10.5,
    "number_int" : 15,
    "array" : ["red", "green", "blue", "blue"],
    "object" : [
        "one" : 1,
        "two" : 2,
        "three" : 3
    ]
]
let json_b = json_a
    .remove("number_int")
    .remove("array" ~> 1)
    .remove("object" ~> "one")


let yes = json_b == [
    "string" : "string_value",
    "number_double" : 10.5,
    "array" : ["red", "blue", "blue"],
    "object" : [
        "two" : 2,
        "three" : 3
    ]
]
```
####Replace Json (EJson is purely immutable)
```
let json_a: EJson = [
    "string" : "string_value",
    "number_double" : 10.5,
    "number_int" : 15,
    "boolean" : true,
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
    .replace("aaaaa", jsonPath: "aaa") /* ignore it! */
    .replace(["four" : 4], jsonPath: "object")

let yes = json_b == [
    "string" : "string_value",
    "number_double" : 100,
    "number_int" : 15,
    "array" : ["head", "green", "blue", "blue"],
    "object" : ["four" : 4]
]

```
####Append Json
```
var json: EJson = [:]

json = json.append("string", jsonPath: "string_key")
json = json.append(true, jsonPath: "key1" ~> "key2")
json = json.append("a", jsonPath: "key3")
json = json.append("c", jsonPath: "key3")

let yes = json == [
    "string_key" : "string",
    "key1" : ["key2" : true],
    "key3" : ["a", "c"]
]
```

####Object Mapping
```
struct User {
    let name: String
    let imageurl: String
    let dummy: String?

    static func construct(name: String)(imageurl: String)(dummy: String?) -> User{
        return User(name: name, imageurl: imageurl, dummy:dummy)
    }
    static func fromJson(json: EJson) -> User? {
        return construct <*> json["name"]?.asString <*> json["profile_image_url"]?.asString <*> json["dummy"]?.asString
    }
}

let json: EJson = [
    "name" : "ken",
    "profile_image_url" : "http://image.png"
]

let user = User.fromJson(json)
```
