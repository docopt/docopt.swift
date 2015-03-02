//
//  Pattern.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/1/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

typealias MatchResult = (match: Bool, left: [Pattern], collected: [Pattern])

internal class Pattern: Equatable, Hashable, Printable {
    internal func fix() -> Pattern {
        fixIdentities()
        fixRepeatingArguments()
        return self;
    }
    
    internal var description: String {
        get {
            return "Pattern"
        }
    }
    var hashValue: Int { get {
            return self.description.hashValue
        }
    }

    internal func fixIdentities(_ unq: Array<Pattern>? = nil) {}
    
    internal func fixRepeatingArguments() -> Pattern {
        var either = Pattern.transform(self).children.map { ($0 as! Required).children }
        
        for c in either {
            for ch in c {
                let filteredChildren = c.filter {$0 == ch}
                if count(filteredChildren) > 1 {
                    for child in filteredChildren {
                        var e = child as! LeafPattern
                        if (e as? Argument != nil) || ((e as? Option != nil) && (e as! Option).argCount != 0) {
                            if e.value == nil {
                                e.value = Array<String>()
                            } else if (e.value as? Array<String> == nil) {
                                e.value = e.value!.description.splitR()
                            }
                        }
                        if (e as? Command != nil) || ((e as? Option != nil) && (e as! Option).argCount != 0) {
                            e.value = 0
                        }
                    }
                }
            }
        }
        
        return self
    }
    
    internal static func isInParents(child: Pattern) -> Bool {
        return (child as? Required != nil)
            || (child as? Optional != nil)
            || (child as? OptionsShortcut != nil)
            || (child as? Either != nil)
            || (child as? OneOrMore != nil)
    }
    
    internal static func transform(pattern: Pattern) -> Either {
        var result = Array<Array<Pattern>>()
        var groups = Array<Array<Pattern>>()
        groups.append([pattern])
        while !groups.isEmpty {
            var children = groups[0]
            groups.removeAtIndex(0)
            var child: BranchPattern? = nil
            for c in children {
                if isInParents(c) {
                    child = c as? BranchPattern
                    break
                }
            }
            
            if let child = child {
                var index = find(children, child)
                children.removeAtIndex(index!)
                
                if (child as? Either != nil) {
                    for pattern in child.children {
                        var group = [pattern]
                        group += children
                        groups.append(group)
                    }
                } else if (child as? OneOrMore != nil) {
                    var group = child.children
                    group += child.children
                    group += children
                    groups.append(group)
                } else {
                    var group = child.children
                    group += children
                    groups.append(group)
                }
            } else {
                result.append(children)
            }
        }
        
        var required = result.map {Required($0)}
        return Either(required)
    }

    internal func flat() -> Array<Pattern> {
        return flat(LeafPattern)
    }

    internal func flat<T: Pattern>(_: T.Type) -> Array<Pattern> {
        return []
    }
    
    internal func match<T: Pattern>(left: T, collected clld: [T]? = nil) -> MatchResult {
        return match([left], collected: clld)
    }
    
    internal func match<T: Pattern>(left: [T], collected clld: [T]? = nil) -> MatchResult {
        return (false, [], [])
    }

    internal func singleMatch<T: Pattern>(left: [T]) -> SingleMatchResult {return (0, nil)}
}

internal func ==(lhs: Pattern, rhs: Pattern) -> Bool {
    if lhs is BranchPattern && rhs is BranchPattern {
        return lhs as! BranchPattern == rhs as! BranchPattern
    } else if lhs is LeafPattern && rhs is LeafPattern {
        return lhs as! LeafPattern == rhs as! LeafPattern
    }
    return lhs === rhs // Pattern is abstract and shouldn't be instantiated :)
}

internal func ==(lhs: MatchResult, rhs: MatchResult) -> Bool {
    return lhs.match == rhs.match
        && lhs.left == rhs.left
        && lhs.collected == rhs.collected
}
