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
            var stringMatches = matches.map {(self as NSString).substringWithRange($0.rangeAtIndex(1))}
            return stringMatches.map {$0.strip()}
        }
        return []
    }
    
    public func split() -> Array<String> {
        return Swift.split(self, isSeparator: {$0 == " " || $0 == "\n"})
    }
    
    public func splitByRegex(regex: String) -> Array<String> {
        let re = NSRegularExpression(pattern: regex, options: .DotMatchesLineSeparators, error: nil)!
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
    
    public func isupper() -> Bool {
        var charset = NSCharacterSet.uppercaseLetterCharacterSet().invertedSet
        var range = self.rangeOfCharacterFromSet(charset)
        return range == nil
    }
}
