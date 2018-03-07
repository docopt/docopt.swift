//
//  Docopt.swift
//  Docopt
//
//  Created by Pavel S. Mazurin on 2/28/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation
import Darwin

@objc
open class Docopt : NSObject {
    fileprivate(set) open var result: [String: AnyObject]!
    fileprivate let doc: String
    fileprivate let version: String?
    fileprivate let help: Bool
    fileprivate let optionsFirst: Bool
    fileprivate let arguments: [String]
    
    @objc open static func parse(_ doc: String, argv: [String], help: Bool = false, version: String? = nil, optionsFirst: Bool = false) -> [String: AnyObject] {
        return Docopt(doc, argv: argv, help: help, version: version, optionsFirst: optionsFirst).result
    }
    
    internal init(_ doc: String, argv: [String]? = nil, help: Bool = false, version: String? = nil, optionsFirst: Bool = false) {
        self.doc = doc
        self.version = version
        self.help = help
        self.optionsFirst = optionsFirst
        
        var args: [String]
        if argv == nil {
            if CommandLine.argc > 1 {
                args = CommandLine.arguments
                args.remove(at: 0) // arguments[0] is always the program_name
            } else {
                args = [String]()
            }
        } else {
            args = argv!
        }
        
        arguments = args.filter { $0 != "" }
        super.init()
        result = parse(optionsFirst)
    }
    
    fileprivate func parse(_ optionsFirst: Bool) -> [String: AnyObject] {
        let usageSections = Docopt.parseSection("usage:", source: doc)

        if usageSections.count == 0 {
            DocoptLanguageError("\"usage:\" (case-insensitive) not found.").raise()
        } else if usageSections.count > 1 {
            DocoptLanguageError("More than one \"usage:\" (case-insensitive).").raise()
        }
        
        DocoptExit.usage = usageSections[0]
        
        var options = Docopt.parseDefaults(doc)
        let pattern = Docopt.parsePattern(Docopt.formalUsage(DocoptExit.usage), options: &options)
        let argv = Docopt.parseArgv(Tokens(arguments), options: &options, optionsFirst: optionsFirst)
        let patternOptions = Set(pattern.flat(Option.self))
        
        for optionsShortcut in pattern.flat(OptionsShortcut.self) {
            let docOptions = Set(Docopt.parseDefaults(doc))
            optionsShortcut.children = Array(docOptions.subtracting(patternOptions))
        }

        Docopt.extras(help, version: version, options: argv, doc: doc)
        
        let (matched, left, collected) = pattern.fix().match(argv)
        
        var result = [String: AnyObject]()
        
        if matched && left.isEmpty {
            let collectedLeafs = collected as! [LeafPattern]
            let flatPattern = pattern.flat().filter { pattern in
                (collectedLeafs.filter {$0.name == pattern.name}).isEmpty
            } + collectedLeafs
            
            for leafChild: LeafPattern in flatPattern {
                result[leafChild.name!] = leafChild.value ?? NSNull()
            }
            return result
        }

        DocoptExit().raise()
        return result
    }
    
    static fileprivate func extras(_ help: Bool, version: String?, options: [LeafPattern], doc: String) {
        let helpOption = options.filter { $0.name == "--help" || $0.name == "-h" }
        if help && !(helpOption.isEmpty) {
            print(doc.strip())
            exit(0)
        }
        let versionOption = options.filter { $0.name == "--version" }
        if version != nil && !(versionOption.isEmpty) {
            print(version!.strip())
            exit(0)
        }
    }
    
    static internal func parseSection(_ name: String, source: String) -> [String] {
        return source.findAll("^([^\n]*\(name)[^\n]*\n?(?:[ \t].*?(?:\n|$))*)", flags: [.caseInsensitive, .anchorsMatchLines] )
    }
    
    static internal func parseDefaults(_ doc: String) -> [Option] {
        var defaults = [Option]()
        let optionsSection = parseSection("options:", source: doc)
        for s in optionsSection {
            // FIXME corner case "bla: options: --foo"
            let (_, _, s) = s.partition(":")  // get rid of "options:"
            var splitgen = ("\n" + s).split("\n[ \t]*(-\\S+?)").makeIterator()
            var split = [String]()
            while let s1 = splitgen.next(), let s2 = splitgen.next() {
                split.append(s1 + s2)
            }
            defaults += split.filter({$0.hasPrefix("-")}).map {
                Option.parse($0)
            }
        }
        return defaults
    }
    
    static internal func parseLong(_ tokens: Tokens, options: inout [Option]) -> [Option] {
        let (long, eq, val) = tokens.move()!.partition("=")
        assert(long.hasPrefix("--"))
        
        var value: String? = eq != "" || val != "" ? val : nil
        var similar = options.filter {$0.long == long}
        
        if tokens.error is DocoptExit && similar.isEmpty {  // if no exact match
            similar = options.filter {$0.long?.hasPrefix(long) ?? false}
        }

        var o: Option
        if similar.count > 1 {
            let allSimilar = similar.map {$0.long ?? ""}.joined(separator: " ")
            tokens.error.raise("\(long) is not a unique prefix: \(allSimilar)")
            return []
        } else if similar.count < 1 {
            let argCount: UInt = (eq == "=") ? 1 : 0
            o = Option(nil, long: long, argCount: argCount)
            options.append(o)
            if tokens.error is DocoptExit {
                o = Option(nil, long: long, argCount: argCount, value: (argCount > 0) ? value as AnyObject : true as AnyObject)
            }
        } else {
            o = Option(similar[0])
            if o.argCount == 0 {
                if value != nil {
                    tokens.error.raise("\(String(describing: o.long)) requires argument")
                }
            } else {
                if value == nil {
                    if let current = tokens.current(), current != "--" {
                        value = tokens.move()
                    } else {
                        tokens.error.raise("\(String(describing: o.long)) requires argument")
                    }
                }
            }
            if tokens.error is DocoptExit {
                o.value = value as AnyObject? ?? true as AnyObject
            }
        }
        return [o]
    }
    
    static internal func parseShorts(_ tokens: Tokens, options: inout [Option]) -> [Option] {
        let token = tokens.move()!
        assert(token.hasPrefix("-") && !token.hasPrefix("--"))
        var left = token.replacingOccurrences(of: "-", with: "")
        var parsed = [Option]()
        while left != "" {
            let short = "-" + left[0..<1]
            let similar = options.filter {$0.short == short}
            var o: Option
            left = left[1..<left.count]
            
            if similar.count > 1 {
                tokens.error.raise("\(short) is specified ambiguously \(similar.count) times")
                return []
            } else if similar.count < 1 {
                o = Option(short)
                options.append(o)
                if tokens.error is DocoptExit {
                    o = Option(short, value: true as AnyObject)
                }
            } else {
                var value: String? = nil
                o = Option(similar[0])
                if o.argCount != 0 {
                    if let current = tokens.current(), current != "--" && left == "" {
                        value = tokens.move()
                    } else if left == "" {
                        tokens.error.raise("\(short) requires argument")
                    } else {
                        value = left
                    }
                    left = ""
                }
                if tokens.error is DocoptExit {
                    o.value = true as AnyObject
                    if let val = value
                    {
                        o.value = val as AnyObject
                    }
                }
            }
            
            parsed.append(o)
        }
        return parsed
    }
    
    static internal func parseAtom(_ tokens: Tokens, options: inout [Option]) -> [Pattern] {
        let token = tokens.current()!
        if ["(", "["].contains(token) {
            _ = tokens.move()
            let u = parseExpr(tokens, options: &options)
            let (matching, result): (String, [BranchPattern]) = (token == "(")
                                            ? (")", [Required(u)])
                                            : ("]", [Optional(u)])
            
            if tokens.move() != matching {
                tokens.error.raise("unmatched '\(token)'")
            }
            
            return result
        }
        
        if token == "options" {
            _ = tokens.move()
            return [OptionsShortcut()]
        }
        if token.hasPrefix("--") && token != "--" {
            return parseLong(tokens, options: &options)
        }
        if token.hasPrefix("-") && !["--", "-"].contains(token) {
            return parseShorts(tokens, options: &options)
        }
        if (token.hasPrefix("<") && token.hasSuffix(">")) || token.isupper() {
            return [Argument(tokens.move()!)]
        }
        
        return [Command(tokens.move()!)]
    }

    static internal func parseSeq(_ tokens: Tokens, options: inout [Option]) -> [Pattern] {
        var result = [Pattern]()
        while let current = tokens.current(), !["]", ")", "|"].contains(current) {
            var atom = parseAtom(tokens, options: &options)
            if tokens.current() == "..." {
                atom = [OneOrMore(atom)]
                _ = tokens.move()
            }
            result += atom
        }

        return result
    }
    
    static internal func parseExpr(_ tokens: Tokens, options: inout [Option]) -> [Pattern] {
        var seq = parseSeq(tokens, options: &options)
        if tokens.current() != "|" {
            return seq
        }
        
        var result = seq.count > 1 ? [Required(seq)] : seq
        while tokens.current() == "|" {
            _ = tokens.move()
            seq = parseSeq(tokens, options: &options)
            result += seq.count > 1 ? [Required(seq)] : seq
        }
        
        return result.count > 1 ? [Either(result)] : result
    }

    /**
     * Parse command-line argument vector.
     *
     * If options_first:
     *     argv ::= [ long | shorts ]* [ argument ]* [ '--' [ argument ]* ] ;
     * else:
     *     argv ::= [ long | shorts | argument ]* [ '--' [ argument ]* ] ;
     */
    static internal func parseArgv(_ tokens: Tokens, options: inout [Option], optionsFirst: Bool = false) -> [LeafPattern] {
        var parsed = [LeafPattern]()
        while let current = tokens.current() {
            if tokens.current() == "--" {
                while let token = tokens.move() {
                    parsed.append(Argument(nil, value: token as AnyObject))
                }
                return parsed
            } else if current.hasPrefix("--") {
                for arg in parseLong(tokens, options: &options) {
                    parsed.append(arg)
                }
            } else if current.hasPrefix("-") && current != "-" {
                for arg in parseShorts(tokens, options: &options) {
                    parsed.append(arg)
                }
            } else if optionsFirst {
                while let token = tokens.move() {
                    parsed.append(Argument(nil, value: token as AnyObject))
                }
                return parsed
            } else {
                parsed.append(Command(nil, value: tokens.move() as AnyObject))
            }
        }
        return parsed
    }
    
    static internal func parsePattern(_ source: String, options: inout [Option]) -> Pattern {
        let tokens: Tokens = Tokens.fromPattern(source)
        let result: [Pattern] = parseExpr(tokens, options: &options)
        
        if tokens.current() != nil {
            tokens.error.raise("unexpected ending: \(tokens)")
        }
        
        return Required(result)
    }
    
    static internal func formalUsage(_ section: String) -> String {
        let (_, _, s) = section.partition(":") // drop "usage:"
        let pu = s.split()
        let formalUsageArray = Array(Array(pu[1..<pu.count].map { $0 == pu[0] ? ") | (" : $0 }))
        return "( " + formalUsageArray.joined(separator: " ") + " )"
    }
}
