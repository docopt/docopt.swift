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
    
    override internal func flat<T: Pattern>(_: T.Type) -> Array<Pattern> {
        if let cast = self as? T {
            return [self]
        }
        return []
    }
    
    override internal func match<T: LeafPattern>(left: [T], collected clld: [T]? = nil) -> MatchResult {
        var collected: [LeafPattern] = clld ?? []
        let (pos, mtch) = singleMatch(left)
        
        if mtch == nil {
            return (false, left, collected)
        }
        let match = mtch as! LeafPattern
        
        var left_ = left
        left_.removeAtIndex(pos)
        
        var sameName = collected.filter({self.name == $0.name})
        if sameName.isEmpty {
            collected.append(match)
            return MatchResult(true, left_, collected)
        }

        switch value {
        case let val as Int:
            sameName[0].value = val + 1
        case var val as Array<String>:
            if let v = match.value as? String {
                val += [v]
            } else {
                val += match.value as! Array<String>
            }
        default:
            collected.append(match)
        }
        
        return (true, left_, collected)
    }
}

internal func ==(lhs: LeafPattern, rhs: LeafPattern) -> Bool {
    let valEqual: Bool
    if lhs.value is String && rhs.value is String {
        valEqual = lhs.value as! String == rhs.value as! String
    } else if lhs.value is Bool && rhs.value is Bool {
        valEqual = lhs.value as! Bool == rhs.value as! Bool
    } else {
        valEqual = lhs.value === rhs.value
    }
    return lhs.name == rhs.name && valEqual
}
