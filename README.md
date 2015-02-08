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


