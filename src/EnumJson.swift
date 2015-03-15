import Foundation

/// Json Data Structure
public enum Json {
    case JObject  ([String : Json])
    case JArray   ([Json])
    case JNumber  (NSNumber)
    case JString  (String)
    case JBoolean (Bool)
    case JNull
}

/// Json Data Access Path
enum JsonPath {
    case Key   (String, () -> JsonPath)
    case Index (Int,    () -> JsonPath)
    case Nil
}

extension JsonPath : IntegerLiteralConvertible {
    init(integerLiteral value: IntegerLiteralType) {
        self = .Index(value, { .Nil })
    }
}
extension JsonPath {
    init(_ key: String) {
        self = JsonPath.Key(key, { .Nil })
    }
    init(_ index: Int) {
        self = JsonPath.Index(index, { .Nil })
    }
}
extension JsonPath : StringLiteralConvertible {
    init(stringLiteral value: StringLiteralType) {
        self = .Key(value, { .Nil })
    }
    
    typealias ExtendedGraphemeClusterLiteralType = String
    init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = .Key(value, { .Nil })
    }
    
    typealias UnicodeScalarLiteralType = String
    init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = .Key(value, { .Nil })
    }
}
extension JsonPath : NilLiteralConvertible {
    init(nilLiteral: ()) {
        self = .Nil
    }
}


extension Json {
    init(_ object: Dictionary<String, Json>) {
        self = .JObject(object)
    }
    init(_ array: Array<Json>) {
        self = .JArray(array)
    }
    init(_ number: NSNumber) {
        self = .JNumber(number)
    }
    init(_ string: String) {
        self = .JString(string)
    }
    init(_ boolean: Bool) {
        self = .JBoolean(boolean)
    }
}
extension Json : DictionaryLiteralConvertible {
    public typealias Key = String
    public typealias Value = Json
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        var dictionary = [String : Json]()
        for (key, value) in elements {
            dictionary[key] = value
        }
        self = .JObject(dictionary)
    }
}
extension Json : ArrayLiteralConvertible {
    public typealias Element = Json
    public init(arrayLiteral elements: Element...) {
        self = .JArray(elements)
    }
}
extension Json : StringLiteralConvertible {
    public init(stringLiteral value: StringLiteralType) {
        self = .JString(value)
    }
    
    public typealias ExtendedGraphemeClusterLiteralType = String
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = .JString(value)
    }
    
    public typealias UnicodeScalarLiteralType = String
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = .JString(value)
    }
}
extension Json : FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self = .JNumber(value)
    }
}
extension Json : IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .JNumber(value)
    }
}
extension Json : BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .JBoolean(value)
    }
}
extension Json : NilLiteralConvertible {
    public init(nilLiteral: ()) {
        self = .JNull
    }
}

extension JsonPath {
    var key: String? {
        switch self {
        case let .Key(key, cdr):
            return key
        default:
            return nil
        }
    }
    var index: Int? {
        switch self {
        case let .Index(index, cdr):
            return index
        default:
            return nil
        }
    }
    var cdr: JsonPath {
        switch self {
        case let .Key(car, cdr):
            return cdr()
        case let .Index(car, cdr):
            return cdr()
        case .Nil:
            return .Nil
        }
    }
    var isNil: Bool {
        switch self {
        case .Nil:
            return true
        default:
            return false
        }
    }
}

infix operator ~> { associativity left precedence 160}
func ~>(a: JsonPath, b: JsonPath) -> JsonPath {
    switch a {
    case let .Key(key, cdr):
        return .Key(key, { a.cdr ~> b })
    case let .Index(index, cdr):
        return .Index(index, { a.cdr ~> b })
    case .Nil:
        return b
    }
}

extension JsonPath : Printable {
    var description: String {
        switch self {
        case let .Key(key, cdr):
            return "\"\(key)\" ~> " + cdr().description
        case let .Index(index, cdr):
            return "\(index) ~> " + cdr().description
        case .Nil:
            return "@"
        }
    }
}

extension JsonPath : Equatable {}
func ==(lhs: JsonPath, rhs: JsonPath) -> Bool{
    switch (lhs, rhs) {
    case (.Nil, .Nil):
        return true
    case (let .Key(key_l, cdr_l), let .Key(key_r, cdr_r)):
        return key_l == key_r && cdr_l() == cdr_r()
    case (let .Index(index_l, cdr_l), let .Index(index_r, cdr_r)):
        return index_l == index_r && cdr_l() == cdr_r()
    default:
        return false
    }
}

extension Json {
    var object: [String : Json]? {
        get {
            switch self {
            case let .JObject(value):
                return value
            default:
                return nil
            }
        }
    }
    var array: [Json]? {
        get {
            switch self {
            case let .JArray(value):
                return value
            default:
                return nil
            }
        }
    }
    var string: String? {
        get {
            switch self {
            case let .JString(value):
                return value
            default:
                return nil
            }
        }
    }
    var number: NSNumber? {
        get {
            switch self {
            case let .JNumber(value):
                return value.doubleValue
            default:
                return nil
            }
        }
    }
    var double: Double? {
        return self.number?.doubleValue
    }
    var int: Int? {
        get {
            return self.number?.integerValue
        }
    }
    var int64: Int64? {
        get {
            return self.number?.longLongValue
        }
    }
    var uint64: UInt64? {
        get {
            return self.number?.unsignedLongLongValue
        }
    }
    var boolean: Bool? {
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
    
    subscript(jsonPath: JsonPath) -> Json? {
        get {
            switch jsonPath {
            case let .Key(key, cdr):
                return self.object?[key]?[cdr()]
            case let .Index(index, cdr):
                if
                    let array = self.array
                    where array.startIndex <= index && index < array.endIndex
                {
                    return array[index][cdr()]
                }
                return nil
            case .Nil:
                return self
            }
        }
        set(json) {
            if let json = json {
                // set
                self = self.set(json, jsonPath: jsonPath)
            } else {
                // remove
                self = self.remove(jsonPath)
            }
        }
    }
    func set(json: Json, jsonPath: JsonPath) -> Json {
        switch jsonPath {
        case let .Key(key, cdr):
            if cdr().isNil {
                if var object = self.object {
                    object[key] = json
                    return Json(object)
                }
            } else {
                if var object = self.object {
                    object[key] = (object[key] ?? Json([:])).set(json, jsonPath: cdr())
                    return Json(object)
                }
            }
            break
        case let .Index(index, cdr):
            if cdr().isNil {
                if
                    var array = self.array
                    where array.startIndex <= index && index < array.endIndex
                {
                    array[index] = json
                    return .JArray(array)
                }
            } else {
                if
                    var array = self.array
                    where array.startIndex <= index && index < array.endIndex
                {
                    array[index] = array[index].set(json, jsonPath: cdr())
                    return .JArray(array)
                }
            }
            return self
        default:
            break
        }
        return self
    }
    
    func remove(jsonPath: JsonPath) -> Json {
        switch (jsonPath) {
        case let (.Nil):
            break
        case let .Key(key, cdr):
            if var object = self.object {
                if cdr().isNil {
                    object[key] = nil
                } else if let child = object[key] {
                    object[key] = child.remove(cdr())
                }
                return Json(object)
            }
        case let .Index(index, cdr):
            if
                var array = self.array
                where array.startIndex <= index && index < array.endIndex
            {
                if cdr().isNil {
                    array.removeAtIndex(index)
                } else {
                    array[index] = array[index].remove(cdr())
                }
                return Json(array)
            }
        }
        return self
    }
}

extension Json: Equatable { }
public func ==(lhs: Json, rhs: Json) -> Bool {
    switch (lhs, rhs) {
    case (let .JObject(a), let .JObject(b)):
        if a.count != b.count {
            return false
        }
        
        let keys_a = sorted(a.keys)
        let keys_b = sorted(b.keys)
        for (value_a, value_b) in zip(keys_a, keys_b) {
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
        for (value_a, value_b) in zip(a, b) {
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
    var isValidJsonObject: Bool {
        return NSJSONSerialization.isValidJSONObject(self.anyObject)
    }
    var jsonData: NSData? {
        get {
            var error: NSError? = nil
            let data = NSJSONSerialization.dataWithJSONObject(self.anyObject, options: NSJSONWritingOptions(0), error: &error)
            return data
        }
    }
    var jsonString: String {
        get {
            if let data = self.jsonData {
                return NSString(data: data, encoding: NSUTF8StringEncoding) as String? ?? ""
            }
            return ""
        }
    }
}

extension Json : Printable {
    public var readableData: NSData? {
        get {
            var error: NSError? = nil
            let data = NSJSONSerialization.dataWithJSONObject(self.anyObject, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
            return data
        }
    }
    
    public var description: String {
        get {
            if let data = self.readableData {
                return NSString(data: data, encoding: NSUTF8StringEncoding) as String? ?? ""
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
    case let dictionary as NSDictionary:
        var object = [String:Json](minimumCapacity: dictionary.count)
        dictionary.enumerateKeysAndObjectsUsingBlock { (key, value, stop) -> () in
            object[key as! String] = toJson(value)
        }
        return .JObject(object)
    case let array as [NSObject]:
        var jarray = [Json]()
        jarray.reserveCapacity(array.count)
        for value in array {
            if let json = toJson(value) {
                jarray += [json]
            }
        }
        return .JArray(jarray)
    case let string as String:
        return .JString(string)
    case let number as NSNumber:
        if CFNumberGetType(number as CFNumber) == .CharType {
            return .JBoolean(number.boolValue)
        }
        return .JNumber(number.doubleValue)
    case let null as NSNull:
        return .JNull
    default:
        return nil
    }
}

extension Json {
    /**
    Convert Json array to T array.
    if json is not array or has some conversion error, return nil
    
    :param: conversion funciton
    :returns: convered array
    */
    func toArray<T>(f:(Json -> T?)) -> [T]? {
        if let jsons = self.array {
            var values = [T]()
            for json in jsons {
                if let value = f(json) {
                    values += [value]
                } else {
                    return nil
                }
            }
            return values
        }
        return nil
    }
}
