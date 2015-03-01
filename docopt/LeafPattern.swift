//
//  LeafPattern.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/1/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

internal struct SingleMatchResult: Printable {
    let position: Int
    let match: LeafPattern?
    
    internal var description: String {
        get {
            return "SingleMatchResult(\(position), \(match))"
        }
    }

    init(_ position: Int, match: LeafPattern? = nil) {
        self.position = position
        self.match = match
    }
}

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
    
    override internal func flat<T>(_: T.Type) -> Array<Pattern> {
        if let cast = self as? T {
            return [self]
        }
        return []
    }
    
    internal func match(left: [LeafPattern], collected clld: [LeafPattern]? = nil) -> MatchResult {
        var collected: [LeafPattern] = clld ?? []
        let m = singleMatch(left)
        let pos = m.position
        let match = m.match
        
        if match == nil {
            return MatchResult(false, left: left, collected: collected)
        }
        
        var left_ = [LeafPattern]()
        left_ += left[0..<pos]
        if (pos + 1 < count(left)) {
            left_ += left[(pos + 1)..<count(left)]
        }
        
        var sameName = collected.filter({self.name == $0.name})
        var increment: AnyObject?
        switch value {
        case let val as Int:
            increment = 1
        case let val as Array<String>:
            let v: AnyObject? = match!.value
            if let v = v as? String {
                increment = [v]
            } else {
                increment = v
            }
        default:
            collected.append(match!)
            return MatchResult(true, left: left_, collected: collected)
        }
        
        if sameName.isEmpty {
            collected.append(match!)
            return MatchResult(true, left: left_, collected: collected)
        }
        
        let p = sameName[0]
        let v: AnyObject? = p.value
        
        switch value {
        case let val as Int:
            let b: Int = increment as! Int
            p.value = val + b
        case var val as Array<String>:
            let b: Array<String> = increment as! Array<String>
            val += b
        default: () // not possible
        }
        
        return MatchResult(true, left: left_, collected: collected)
    }
    
    internal func singleMatch(left: [LeafPattern]) -> SingleMatchResult {return SingleMatchResult(0)}
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