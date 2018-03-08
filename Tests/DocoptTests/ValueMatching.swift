//
//  ValueMatching.swift
//  Docopt
//
//  Created by Sam Deane on 08/03/2018.
//

import Foundation

/**
 Crude generic matching.
 
 Implements a slightly fuzzy generic test for equality between
 two values of unknown type.
 
 Allows us to check dictionaries, arrays for equality, in
 situations where values might be equivalent but not strictly equal.

 For example matching the integer 1 against the string "1" for a
 given key in a dictionary.
 */

/**
 If the values are both the same type, and it's equatable, then
 it's easy.
 */

internal func valuesMatch<T : Equatable>(_ v1 : T, _ v2 : T) -> Bool {
    return v1 == v2
}

/**
 If the values could be any type, we work through a series of
 alternatives attempting to case them to basic types, then
 compare those.
 
 Worst-case scenario we fall back on describing both values
 as strings and comparing that.
 */

internal func valuesMatch(_ v1 : Any, _ v2 : Any) -> Bool {
    if let d1 = v1 as? [String:Any], let d2 = v2 as? [String:Any] {
        return d1.matches(d2)
    }
    if let a1 = v1 as? [Any], let a2 = v2 as? [Any] {
        return a1.matches(a2)
    }
    if let i1 = v1 as? Int, let i2 = v2 as? Int {
        return i1 == i2
    }
    if let b1 = v1 as? Bool, let b2 = v2 as? Bool {
        return b1 == b2
    }
    if let s1 = v1 as? String, let s2 = v2 as? String {
        return s1 == s2
    }
    if let n1 = v1 as? NSNull, let n2 = v2 as? NSNull {
        return n1 == n2
    }
    
    return "\(v1)" == "\(v2)"
}

/**
 Arrays just match each element in turn.
 */

extension Array {
    func matches(_ other : [Any]) -> Bool {
        if count != other.count {
            return false
        }
        
        var index = 0
        for value in self {
            let otherValue = other[index]
            if !valuesMatch(value, otherValue) {
                return false
            }
            index += 1
        }
        return true
    }
}

/**
 Dictionaries match by filtering out all matching
 key/value pairs. If there's nothing left
 */
 
extension Dictionary {
    func matches(_ other : [String:Any]) -> Bool {
        if self.count != other.count {
            return false
        }
        
        let remaining = self.filter { (key, value) -> Bool in
            if let otherValue = other[key as! String] {
                return !valuesMatch(value, otherValue)
            }
            return true
        }
        
        return remaining.count == 0
    }
}
