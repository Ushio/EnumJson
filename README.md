## Type Safe, Thread Safe, Light Json Library in Swift

### Required Swift 1.2

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

```
github "Ushio/EnumJson"
```

#### Definision of Json
```
public enum Json {
    case JObject  ([String : Json])
    case JArray   ([Json])
    case JNumber  (NSNumber)
    case JString  (String)
    case JBoolean (Bool)
    case JNull
}
```
#### Building Json
```
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
```

#### Export Json
```
if let data = json.jsonData {
  // do something
}
```
#### Import Json
```
if let json = Json(data: data) {
  // do something
}
```

#### Definision of JsonPath
```
enum JsonPath {
    case Key   (String, () -> JsonPath)
    case Index (Int,    () -> JsonPath)
    case Nil
}
```
#### JsonPath Access
```
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
let string_value: String? = json["string_value"]?.string
let green: String? = json["array" ~> 1]?.string
let three: Double? = json["object" ~> "three"]?.double
```

#### Remove
```
var json: Json = [
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

json["number_int"] = nil
json["array" ~> 1] = nil
json["object" ~> "one"] = nil

let yes = json == [
    "string" : "string_value",
    "number_double" : 10.5,
    "array" : ["red", "blue", "blue"],
    "object" : [
        "two" : 2,
        "three" : 3
    ]
]
```
#### Replace
```
var json: Json = [
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
json["number_double"] = 100
json["array" ~> 0] = "head"
json["object"] = ["four" : 4]

let yes = json == [
    "string" : "string_value",
    "number_double" : 100,
    "number_int" : 15,
    "array" : ["head", "green", "blue", "blue"],
    "object" : ["four" : 4]
]

```
#### Set Value
```
var json: Json = [:]

json["string_key"] = "string"
json["key1" ~> "key2"] = true
json["key3"] = "a"
json["key3"] = "c"

let yes = json == [
    "string_key" : "string",
    "key1" : ["key2" : true],
    "key3" : "c"
]
```

#### Object Mapping
```
struct User {
    let number: Double
    let name: String

    static func fromJson(json: Json) -> User? {
        if
            let number = json["number"]?.double,
            let name = json["name"]?.string
        {
            return User(number: number, name: name)
        }
        return nil
    }
}

let json: Json = [
    "number" : 17.4,
    "name" : "ken"
]

if let user = User.fromJson(json) {
    // do something
}
```
