import Foundation

class JBox<T> {
    let unbox: T
    init(_ value: T) {
        self.unbox = value
    }
}

enum JsonPath {
    case Key(String, JBox<JsonPath>)
    case Index(Int, JBox<JsonPath>)
    case End
}

extension JsonPath {
    var isEnd : Bool {
        get {
            switch self {
            case .End:
                return true
            default:
                return false
            }
        }
    }
}

extension JsonPath : IntegerLiteralConvertible {
    init(integerLiteral value: IntegerLiteralType) {
        self = JsonPath.Index(value, JBox(JsonPath.End))
    }
}
extension JsonPath : StringLiteralConvertible {
    init(stringLiteral value: StringLiteralType) {
        self = JsonPath.Key(value, JBox(JsonPath.End))
    }
    
    typealias ExtendedGraphemeClusterLiteralType = String
    init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = JsonPath.Key(value, JBox(JsonPath.End))
    }
    
    typealias UnicodeScalarLiteralType = String
    init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = JsonPath.Key(value, JBox(JsonPath.End))
    }
}

infix operator ~> { associativity left precedence 160}
func ~>(lhs: JsonPath, rhs: JsonPath) -> JsonPath {
    switch lhs {
    case .End:
        return rhs
    case let .Key(k, n):
        return JsonPath.Key(k, JBox(n.unbox ~> rhs))
    case let .Index(i, n):
        return JsonPath.Index(i, JBox(n.unbox ~> rhs))
    default:
        break;
    }
}

extension JsonPath : Printable {
     var description: String {
        get {
            switch self {
            case .End:
                return "@"
            case let .Key(k, n):
                return "\"\(k)\" ~> " + n.unbox.description
            case let .Index(i, n):
                return "\(i) ~> " + n.unbox.description
            }
        }
    }
}
extension JsonPath {
    var isKey: Bool {
        get {
            switch self {
            case let .Key:
                return true
            default:
                return false
            }
        }
    }
    var isIndex: Bool {
        get {
            switch self {
            case let .Index:
                return true
            default:
                return false
            }
        }
    }
}
func ==(lhs: JsonPath, rhs: JsonPath) -> Bool{
    switch (lhs, rhs) {
    case (.End, .End):
        return true
    case (let .Key(key_l, next_l), let .Key(key_r, next_r)):
        return key_l == key_r && next_l.unbox == next_r.unbox
    case (let .Index(index_l, next_l), let .Index(index_r, next_r)):
        return index_l == index_r && next_l.unbox == next_r.unbox
    default:
        return false
    }
}
func !=(lhs: JsonPath, rhs: JsonPath) -> Bool {
    return !(lhs == rhs)
}

enum Json {
    case JObject  (Dictionary<String, Json>)
    case JArray   (Array<Json>)
    case JNumber  (Double)
    case JString  (String)
    case JBoolean (Bool)
    case JNull
}

extension Json {
    subscript(jsonPath: JsonPath) -> Json? {
        switch jsonPath {
        case .End:
            return self
        case let .Key(key, next):
            switch self {
            case let .JObject(dictionary):
                return dictionary[key]?[next.unbox]
            default:
                return nil
            }
        case let .Index(index, next):
            switch self {
            case let .JArray(array):
                if array.startIndex <= index && index < array.endIndex {
                    return array[index][next.unbox]
                }
                return nil
            default:
                return nil
            }
        }
    }
    
    var asDictionary: Dictionary<String, Json>? {
        get {
            switch self {
            case let .JObject(value):
                return value
            default:
                return nil
            }
        }
    }
    var asArray: [Json]? {
        get {
            switch self {
            case let .JArray(value):
                return value
            default:
                return nil
            }
        }
    }
    var asString: String? {
        get {
            switch self {
            case let .JString(value):
                return value
            default:
                return nil
            }
        }
    }
    var asNumber: Double? {
        get {
            switch self {
            case let .JNumber(value):
                return value
            default:
                return nil
            }
        }
    }
    var asBoolean: Bool? {
        get {
            switch self {
            case let .JBoolean(value):
                return value
            default:
                return nil
            }
        }
    }


    var isObject: Bool {
        get {
            switch self {
            case let .JObject:
                return true
            default:
                return false
            }
        }
    }
    var isArray: Bool {
        get {
            switch self {
            case let .JArray:
                return true
            default:
                return false
            }
        }
    }
    var isString : Bool {
        get {
            switch self {
            case .JString:
                return true
            default:
                return false
            }
        }
    }
    var isNumber : Bool {
        get {
            switch self {
            case .JNumber:
                return true
            default:
                return false
            }
        }
    }
    var isBoolean : Bool {
        get {
            switch self {
            case .JBoolean:
                return true
            default:
                return false
            }
        }
    }
    
    var isNull : Bool {
        get {
            switch self {
            case .JNull:
                return true
            default:
                return false
            }
        }
    }
 
    func replace(value: Json, jsonPath: JsonPath) -> Json {
        switch jsonPath {
        case .End:
            return value
        case let .Key(key, next):
            switch self {
            case var .JObject(dictionary):
                if let child = dictionary[key] {
                    dictionary[key] = child.replace(value, jsonPath: next.unbox)
                }
                return Json.JObject(dictionary)
            default:
                return self
            }
        case let .Index(index, next):
            switch self {
            case var .JArray(array):
                if array.startIndex <= index && index < array.endIndex {
                    array[index] = array[index].replace(value, jsonPath: next.unbox)
                }
                return Json.JArray(array)
            default:
                return self
            }
        default:
            break
        }
        return self
    }
    
    func remove(jsonPath: JsonPath) -> Json {
        switch jsonPath {
        case .End:
            return self
        case let .Key(key, next):
            switch self {
            case var .JObject(dictionary):
                if next.unbox.isEnd {
                    dictionary[key] = nil
                } else {
                    if let child = dictionary[key] {
                        dictionary[key] = child.remove(next.unbox)
                    }
                }
                return Json.JObject(dictionary)
            default:
                return self
            }
        case let .Index(index, next):
            switch self {
            case var .JArray(array):
                if next.unbox.isEnd {
                    if array.startIndex <= index && index < array.endIndex {
                        array.removeAtIndex(index)
                    }
                } else {
                    if array.startIndex <= index && index < array.endIndex {
                        array[index] = array[index].remove(next.unbox)
                    }
                }
                return Json.JArray(array)
            default:
                return self
            }
        default:
            break
        }
        return self
    }
    
    func append(json: Json, jsonPath: JsonPath) -> Json {
        switch jsonPath {
        case .End:
            switch self {
            case var .JArray(array):
                array.append(json)
                return Json.JArray(array)
            default:
                return [self, json]
            }
        case let .Key(key, next):
            switch self {
            case var .JObject(dictionary):
                if next.unbox.isEnd {
                    if let child = dictionary[key] {
                        dictionary[key] = child.append(json, jsonPath: next.unbox)
                    } else {
                        dictionary[key] = json
                    }
                } else {
                    if let child = dictionary[key] {
                        dictionary[key] = child.append(json, jsonPath: next.unbox)
                    } else {
                        if next.unbox.isKey {
                            // if next is key, create object
                            let newOne = Json.JObject([:])
                            dictionary[key] = newOne.append(json, jsonPath: next.unbox)
                        }
                    }
                }
                return Json.JObject(dictionary)
            default:
                return self
            }
        case let .Index(index, next):
            switch self {
            case var .JArray(array):
                if array.startIndex <= index && index < array.endIndex {
                    array[index] = array[index].append(json, jsonPath: next.unbox)
                }
                return Json.JArray(array)
            default:
                return self
            }
        default:
            break
        }
        return self
    }
}

func ==(lhs: Json, rhs: Json) -> Bool {
    switch (lhs, rhs) {
    case (let .JObject(a), let .JObject(b)):
        if a.count != b.count {
            return false
        }
        let keys_a = sorted(a.keys)
        let keys_b = sorted(b.keys)
        for (value_a, value_b) in Zip2(keys_a, keys_b) {
            if value_a != value_b {
                return false
            }
        }
        
        for key in keys_a {
            switch (a[key], b[key]) {
            case (let .Some(a), let .Some(b)):
                if a != b {
                    return false
                }
            default:
                return false
            }
        }
        return true
    case (let .JArray(a), let .JArray(b)):
        if a.count != b.count {
            return false
        }
        for (value_a, value_b) in Zip2(a, b) {
            if value_a != value_b {
                return false
            }
        }
        return true
    case (let .JString(a), let .JString(b)):
        return a == b
    case (let .JNumber(a), let .JNumber(b)):
        return a == b
    case (let .JBoolean(a), let .JBoolean(b)):
        return a == b
    case (.JNull, .JNull):
        return true
    default:
        break
    }
    return false
}
func !=(lhs: Json, rhs: Json) -> Bool {
    return !(lhs == rhs)
}

extension Json : DictionaryLiteralConvertible {
    typealias Key = String
    typealias Value = Json
    
    init(dictionaryLiteral elements: (Key, Value)...) {
        var dictionary = [String : Json]()
        for (key, value) in elements {
            dictionary[key] = value
        }
        self = Json.JObject(dictionary)
    }
}
extension Json : ArrayLiteralConvertible {
    typealias Element = Json
    init(arrayLiteral elements: Element...) {
        self = Json.JArray(elements)
    }
}
extension Json : StringLiteralConvertible {
    init(stringLiteral value: StringLiteralType) {
        self = Json.JString(value)
    }
    
    typealias ExtendedGraphemeClusterLiteralType = String
    init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = Json.JString(value)
    }
    
    typealias UnicodeScalarLiteralType = String
    init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = Json.JString(value)
    }
}
extension Json : FloatLiteralConvertible {
    init(floatLiteral value: FloatLiteralType) {
        self = Json.JNumber(value)
    }
}
extension Json : IntegerLiteralConvertible {
    init(integerLiteral value: IntegerLiteralType) {
        self = Json.JNumber(Double(value))
    }
}
extension Json : BooleanLiteralConvertible {
    init(booleanLiteral value: BooleanLiteralType) {
        self = Json.JBoolean(value)
    }
}
extension Json : NilLiteralConvertible {
    init(nilLiteral: ()) {
        self = Json.JNull
    }
}

extension Json {
    var anyObject: AnyObject {
        get {
            switch self {
            case let .JObject(dictionary):
                let dic = NSMutableDictionary()
                for (key, value) in dictionary {
                    dic[key] = value.anyObject
                }
                return dic
            case let .JArray(array):
                return array.map { $0.anyObject }
            case let .JString(string):
                return string
            case let .JNumber(number):
                return number
            case let .JBoolean(boolean):
                return boolean
            case let .JNull:
                return NSNull()
            }
        }
    }
    var jsonData: NSData {
        get {
            // top level object should be object or array
            switch self {
            case .JObject:
                break;
            case .JArray:
                break;
            default:
                return NSData()
            }
            
            var error: NSError? = nil
            let data = NSJSONSerialization.dataWithJSONObject(self.anyObject, options: NSJSONWritingOptions(0), error: &error)
            return data ?? NSData()
        }
    }
    var jsonString: String {
        get {
            return NSString(data: self.jsonData, encoding: NSUTF8StringEncoding) ?? ""
        }
    }
}

extension Json : Printable {
    var readableData: NSData? {
        get {
            // top level object should be object or array
            switch self {
            case .JObject:
                break;
            case .JArray:
                break;
            default:
                return nil
            }
            var error: NSError? = nil
            let data = NSJSONSerialization.dataWithJSONObject(self.anyObject, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
            return data ?? NSData()
        }
    }
    
    var description: String {
        get {
            if let data = self.readableData {
                return NSString(data: data, encoding: NSUTF8StringEncoding) ?? ""
            }
            return ""
        }
    }
}
extension Json {
    init?(data: NSData) {
        var error: NSError? = nil
        if let jsonObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) {
            if let json = toJson(jsonObject) {
                self = json
                return
            }
        }
        return nil
    }
}

private func toJson(anyObject: AnyObject) -> Json? {
    switch anyObject {
    case let dictionary as [NSObject:AnyObject]:
        var object = [String:Json]()
        for (key, value) in dictionary {
            if let keystring = key as? NSString {
                object[keystring] = toJson(value)
            }
        }
        return Json.JObject(object)
    case let array as [NSObject]:
        var jarray = [Json]()
        for value in array {
            if let json = toJson(value) {
                jarray += [json]
            }
        }
        return Json.JArray(jarray)
    case let string as String:
        return Json.JString(string)
    case let number as NSNumber:
        if CFNumberGetType(number as CFNumber) == .CharType {
            return Json.JBoolean(number.boolValue)
        }
        return Json.JNumber(number.doubleValue)
    case let null as NSNull:
        return Json.JNull
    default:
        return nil
    }
}