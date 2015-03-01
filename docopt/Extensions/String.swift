//
//  String.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 2/28/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

public extension String {
    public func partition(separator: String) -> (String, String, String) {
        let components = self.componentsSeparatedByString(separator)
        if count(components) > 1 {
            return (components[0], separator, separator.join(components[1...count(components) - 1]))
        }
        return (self, "", "")
    }
    
    public func strip() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    public func findAll(regex: String, flags: NSRegularExpressionOptions) -> Array<String> {
        let re = NSRegularExpression(pattern: regex, options: flags, error: nil)!
        let all = NSMakeRange(0, count(self))
        if let matches = re.matchesInString(self, options: .allZeros, range: all) as? Array<NSTextCheckingResult> {
            var stringMatches = matches.map {(self as NSString).substringWithRange($0.range)}
            return stringMatches.map {$0.strip()}
        }
        return []
    }
    
    public func splitR() -> Array<String> {
        return split(self, isSeparator: {$0 == " " || $0 == "\n"})
    }
    
    public func splitByRegex(regex: String) -> Array<String> {
        let re = NSRegularExpression(pattern: regex, options: .DotMatchesLineSeparators, error: nil)!
//        let hg = hasGrouping(regex)
        let all = NSMakeRange(0, count(self))
        var result = Array<String>()
        let source = self as NSString
        if let matches = re.matchesInString(self, options: .allZeros, range: all) as? Array<NSTextCheckingResult> where count(matches) > 0 {
            var lastEnd = 0
            for match in matches {
                let range = match.rangeAtIndex(1)
                if range.location != NSNotFound {
                    if (lastEnd != 0) {
                        let fullRange = match.range
                        result.append(source.substringWithRange(NSMakeRange(lastEnd, fullRange.location - lastEnd)))
                    }
                    
                    result.append(source.substringWithRange(range))
                    lastEnd = range.location + range.length
                } else {
                    let fullRange = match.range
                    result.append(source.substringWithRange(NSMakeRange(lastEnd, fullRange.location - lastEnd)))
                    lastEnd = fullRange.location + fullRange.length
                }
            }
            if lastEnd != count(self) {
                result.append(source.substringWithRange(NSMakeRange(lastEnd, count(self) - lastEnd)))
            }
        } else {
            return [self]
        }
        return result
    }
}

//private func hasGrouping(pattern: String) -> Bool {
//    var range = pattern.startIndex..<pattern.endIndex;
//    
//    // Find the potential beginning of a group by looking for a left parenthesis character.
//    while let idx = pattern.rangeOfString("(", options: NSStringCompareOptions.allZeros, range: range) {
//        var c = 0
//
//        // Count the number of escape characters immediately preceding the left parenthesis character.
//        for j in pattern.startIndex..<idx.startIndex {
//            if (pattern[j] != "\\") {
//                break
//            }
//
//            c++
//        }
//    
//        // If there is an even number of consecutive escape characters, the character is not escaped and begins a group.
//        if c % 2 == 0 {
//            return true
//        }
//        
//        range = idx.endIndex..<pattern.endIndex
//    }
//    
//    return false
//}
