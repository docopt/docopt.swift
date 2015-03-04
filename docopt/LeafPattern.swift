//
//  LeafPattern.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/1/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

typealias SingleMatchResult = (position: Int, match: Pattern?)
enum ValueType {
    case Nil, Bool, Int, List, String
}

internal class LeafPattern : Pattern, Equatable {
    var name: String?
    var value: AnyObject? {
        willSet {
            switch newValue {
            case is Bool:
                valueType = valueType != .Int ? .Bool : valueType
            case is Array<String>:
                valueType = .List
            case is String:
                valueType = .String
            case is Int:
                valueType = .Int // never happens. Set manually when explicitly set value to int :(
            default:
                valueType = .Nil
            }
        }
    }
    var valueType: ValueType = .Nil
    override internal var description: String {
        get {
            switch valueType {
            case .Bool: return "LeafPattern(\(name), \(value as! Bool))"
            case .List: return "LeafPattern(\(name), \(value as! Array<String>))"
            case .String: return "LeafPattern(\(name), \(value as! String))"
            case .Int: return "LeafPattern(\(name), \(value as! Int))"
            case .Nil: fallthrough
            default: return "LeafPattern(\(name), \(value))"
            }
            
        }
    }
    
    internal init(_ name: String?, value: AnyObject? = nil) {
        self.name = name
        self.value = value
    }
    
    override internal func flat<T: LeafPattern>(_: T.Type) -> Array<T> {
        if let cast = self as? T {
            return [cast]
        }
        return []
    }
    
    override internal func match<T: Pattern>(left: [T], collected clld: [T]? = nil) -> MatchResult {
        var collected: [Pattern] = clld ?? []
        let (pos, mtch) = singleMatch(left)
        
        if mtch == nil {
            return (false, left, collected)
        }
        let match = mtch as! LeafPattern
        
        var left_ = left
        left_.removeAtIndex(pos)
        
        var sameName = collected.filter({ item in
            if let cast = item as? LeafPattern {
                return self.name == cast.name
            }
            return false
        }) as! [LeafPattern]
        
        if (valueType == .Int) || (valueType == .List) {
            var increment: AnyObject?
            if valueType == .Int {
                increment = 1
            } else {
                if let val = match.value as? String {
                    increment = Array<String>([val])
                } else {
                    increment = match.value
                }
            }
            if sameName.isEmpty {
                match.value = increment
                match.valueType = valueType
                collected.append(match)
                return (true, left_, collected)
            }
            if let inc = increment as? Int {
                sameName[0].value = sameName[0].value as! Int + inc
                sameName[0].valueType = .Int
            } else if let inc = increment as? Array<String> {
                sameName[0].value = ((sameName[0].value as? Array<String>) ?? Array<String>()) + inc
            }
            return (true, left_, collected)
        }
        
        return (true, left_, collected + [match])
    }
}

internal func ==(lhs: LeafPattern, rhs: LeafPattern) -> Bool {
    let valEqual: Bool
    if lhs.value is String && rhs.value is String {
        valEqual = lhs.value as! String == rhs.value as! String
    } else if let lval = lhs.value as? Bool, let rval = rhs.value as? Bool {
        valEqual = lval == rval
    } else if let lval = lhs.value as? Array<String>, let rval = rhs.value as? Array<String> {
        valEqual = lval == rval
    } else {
        valEqual = lhs.value === rhs.value
    }
    return lhs.name == rhs.name && valEqual
}
