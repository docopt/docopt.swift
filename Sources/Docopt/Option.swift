//
//  Option.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 2/28/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

internal class Option: LeafPattern {
    internal var short: String?
    internal var long: String?
    internal var argCount: UInt
    override internal var name: String? {
        get {
            return self.long ?? self.short
        }
        set {
        }
    }
    override var description: String {
        get {
            var valueDescription : String = value == nil ? "nil" : "\(value!)"
            if value is Bool, let val = value as? Bool
            {
                valueDescription = val ? "true" : "false"
            }
            return "Option(\(String(describing: short)), \(String(describing: long)), \(argCount), \(valueDescription))"
        }
    }

    convenience init(_ option: Option) {
        self.init(option.short, long: option.long, argCount: option.argCount, value: option.value)
    }

    init(_ short: String? = nil, long: String? = nil, argCount: UInt = 0, value: Any? = false) {
        assert(argCount <= 1)
        self.short = short
        self.long = long
        self.argCount = argCount

        super.init("", value: value)
        if argCount > 0 && value as? Bool == false {
            self.value = nil
        } else {
            self.value = value
        }
    }

    static func parse(_ optionDescription: String) -> Option {
        var short: String? = nil
        var long: String? = nil
        var argCount: UInt = 0
        var value: Any? = false

        var (options, _, description) = optionDescription.strip().partition("  ")
        options = options.replacingOccurrences(of: ",", with: " ", options: [], range: nil)
        options = options.replacingOccurrences(of: "=", with: " ", options: [], range: nil)

        for s in options.components(separatedBy: " ").filter({!$0.isEmpty}) {
            if s.hasPrefix("--") {
                long = s
            } else if s.hasPrefix("-") {
                short = s
            } else {
                argCount = 1
            }
        }

        if argCount == 1 {
            let matched = description.findAll("\\[default: (.*)\\]", flags: .caseInsensitive)
            if matched.count > 0
            {
                value =  matched[0]
            }
            else
            {
                value = nil
            }
        }

        return Option(short, long: long, argCount: argCount, value: value)
    }

    override func singleMatch<T: LeafPattern>(_ left: [T]) -> SingleMatchResult {
        for i in 0..<left.count {
            let pattern = left[i]
            if pattern.name == name {
                return (i, pattern)
            }
        }
        return (0, nil)
    }
}

func ==(lhs: Option, rhs: Option) -> Bool {
    let valEqual = lhs as LeafPattern == rhs as LeafPattern
    return lhs.short == rhs.short
        && lhs.long == lhs.long
        && lhs.argCount == rhs.argCount
        && valEqual
}
