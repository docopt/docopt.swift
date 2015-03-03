//
//  LeafPattern.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/1/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

typealias SingleMatchResult = (position: Int, match: Pattern?)

internal class LeafPattern : Pattern, Equatable {
    var name: String?
    var value: AnyObject?
    override internal var description: String {
        get {
            return "LeafPattern(\(name), \(value))"
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

        if (value as? Int != nil) || (value as? Array<String> != nil) {
            var increment: AnyObject?
            if value as? Int != nil {
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
                collected.append(match)
                return (true, left_, collected)
            }
            if let inc = increment as? Int {
                sameName[0].value = sameName[0].value ?? 0 + inc
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
    } else if lhs.value is Bool && rhs.value is Bool {
        valEqual = lhs.value as! Bool == rhs.value as! Bool
    } else if lhs.value is Array<String> && rhs.value is Array<String> {
        valEqual = lhs.value as! Array<String> == rhs.value as! Array<String>
    } else {
        valEqual = lhs.value === rhs.value
    }
    return lhs.name == rhs.name && valEqual
}
