infix operator >>== { associativity left }
public func >>==<T, U>(optional: T?, f: T -> U?) -> U? {
    if let x = optional {
        return f(x)
    } else {
        return nil
    }
}
