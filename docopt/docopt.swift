//
//  docopt.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 2/28/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation
import Darwin

public struct Docopt {
    public var result: AnyObject!
    private let doc: String
    private let version: String?
    private let help: Bool
    private let optionsFirst: Bool
    private let arguments: [String]
    
    public init(_ doc: String, argv: [String]? = nil, help: Bool = false, version: String? = nil, optionsFirst: Bool = false) {
        self.doc = doc
        self.version = version
        self.help = help
        self.optionsFirst = optionsFirst
        
        var args: [String]
        if argv == nil {
            if Process.argc > 1 {
                args = Process.arguments
                args.removeAtIndex(0) // arguments[0] is always the program_name
            } else {
                args = [String]()
            }
        } else {
            args = argv!
        }
        
        arguments = args.filter { $0 != "" }
        result = parse(optionsFirst)
    }
    
    private func parse(optionsFirst: Bool) -> AnyObject {
        let usageSections = Docopt.parseSection("usage:", source: doc)

        if count(usageSections) == 0 {
            DocoptLanguageError("\"usage:\" (case-insensitive) not found.").raise()
        } else if count(usageSections) > 1 {
            DocoptLanguageError("More than one \"usage:\" (case-insensitive).").raise()
        }
        
        DocoptExit.usage = usageSections[0]
        
        var options = Docopt.parseDefaults(doc)
        let pattern = Docopt.parsePattern(Docopt.formalUsage(DocoptExit.usage), options: &options)
        let argv = Docopt.parseArgv(Tokens(arguments), options: &options, optionsFirst: optionsFirst)
        let patternOptions = Set(pattern.flat(Option))
        
        for optionsShortcut in pattern.flat(OptionsShortcut) {
            let docOptions = Set(Docopt.parseDefaults(doc))
            optionsShortcut.children = Array(docOptions.subtract(patternOptions))
        }

        Docopt.extras(help, version: version, options: argv, doc: doc)
        
        let (matched, left, collected) = pattern.fix().match(argv)
        
        if matched && left.isEmpty {
            var result = [String: AnyObject]()
            
            let collectedLeafs = collected as! [LeafPattern]
            let flatPattern = pattern.flat().filter { pattern in
                (collectedLeafs.filter {$0.name == pattern.name}).isEmpty
            } + collectedLeafs
            
            for leafChild: LeafPattern in flatPattern {
                result[leafChild.name!] = leafChild.value ?? NSNull()
            }
            return result
        }

        return "user-error"
    }
    
    static private func extras(help: Bool, version: String?, options: [LeafPattern], doc: String) {
        let helpOption = options.filter { $0.name == "--help" || $0.name == "-h" }
        if help && !(helpOption.isEmpty) {
            println(doc.strip())
            exit(0)
        }
        let versionOption = options.filter { $0.name == "--version" }
        if version != nil && !(versionOption.isEmpty) {
            println(version!.strip())
            exit(0)
        }
    }
    
    static internal func parseSection(name: String, source: String) -> [String] {
        return source.findAll("^([^\n]*\(name)[^\n]*\n?(?:[ \t].*?(?:\n|$))*)", flags: .CaseInsensitive | .AnchorsMatchLines )
    }
    
    static internal func parseDefaults(doc: String) -> [Option] {
        var defaults = [Option]()
        let optionsSection = parseSection("options:", source: doc)
        for s in optionsSection {
            // FIXME corner case "bla: options: --foo"
            let (_, _, s) = s.partition(":")  // get rid of "options:"
            var splitgen = ("\n" + s).split("\n[ \t]*(-\\S+?)").generate()
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
    
    static internal func parseLong(tokens: Tokens, inout options: [Option]) -> [Option] {
        var (long, eq, val) = tokens.move()!.partition("=")
        assert(long.hasPrefix("--"))
        
        var value: String? = eq != "" || val != "" ? val : nil
        var similar = options.filter {$0.long == long}
        
        if tokens.error is DocoptExit && similar.isEmpty {  // if no exact match
            similar = options.filter {$0.long?.hasPrefix(long) ?? false}
        }

        var o: Option
        if count(similar) > 1 {
            let allSimilar = " ".join(similar.map {$0.long ?? ""})
            tokens.error.raise("\(long) is not a unique prefix: \(allSimilar)")
            return []
        } else if count(similar) < 1 {
            let argCount: UInt = (eq == "=") ? 1 : 0
            o = Option(nil, long: long, argCount: argCount)
            options.append(o)
            if tokens.error is DocoptExit {
                o = Option(nil, long: long, argCount: argCount, value: argCount > 0 ? value : true)
            }
        } else {
            o = Option(similar[0])
            if o.argCount == 0 {
                if value != nil {
                    tokens.error.raise("\(o.long) requires argument")
                }
            } else {
                if value == nil {
                    if let current = tokens.current() where current != "--" {
                        value = tokens.move()
                    } else {
                        tokens.error.raise("\(o.long) requires argument")
                    }
                }
            }
            if tokens.error is DocoptExit {
                o.value = value ?? true
            }
        }
        return [o]
    }
    
    static internal func parseShorts(tokens: Tokens, inout options: [Option]) -> [Option] {
        let token = tokens.move()!
        assert(token.hasPrefix("-") && !token.hasPrefix("--"))
        var left = token.stringByReplacingOccurrencesOfString("-", withString: "")
        var parsed = [Option]()
        while left != "" {
            let short = "-" + left[0..<1]
            let similar = options.filter {$0.short == short}
            var o: Option
            left = left[1..<count(left)]
            
            if count(similar) > 1 {
                tokens.error.raise("\(short) is specified ambiguously \(count(similar)) times")
                return []
            } else if count(similar) < 1 {
                o = Option(short)
                options.append(o)
                if tokens.error is DocoptExit {
                    o = Option(short, value: true)
                }
            } else {
                var value: String? = nil
                o = Option(similar[0])
                if o.argCount != 0 {
                    if let current = tokens.current() where current != "--" && left == "" {
                        value = tokens.move()
                    } else if left == "" {
                        tokens.error.raise("\(short) requires argument")
                    } else {
                        value = left
                    }
                    left = ""
                }
                if tokens.error is DocoptExit {
                    o.value = value ?? true
                }
            }
            
            parsed.append(o)
        }
        return parsed
    }
    
    static internal func parseAtom(tokens: Tokens, inout options: [Option]) -> [Pattern] {
        let token = tokens.current()!
        if contains(["(", "["], token) {
            tokens.move()
            let u = parseExpr(tokens, options: &options)
            let (matching: String, result) = (token == "(")
                                            ? (")", [Required(u)])
                                            : ("]", [Optional(u)])
            
            if tokens.move() != matching {
                tokens.error.raise("unmatched '\(token)'")
            }
            
            return result
        }
        
        if token == "options" {
            tokens.move()
            return [OptionsShortcut()]
        }
        if token.hasPrefix("--") && token != "--" {
            return parseLong(tokens, options: &options)
        }
        if token.hasPrefix("-") && !contains(["--", "-"], token) {
            return parseShorts(tokens, options: &options)
        }
        if (token.hasPrefix("<") && token.hasSuffix(">")) || token.isupper() {
            return [Argument(tokens.move()!)]
        }
        
        return [Command(tokens.move()!)]
    }

    static internal func parseSeq(tokens: Tokens, inout options: [Option]) -> [Pattern] {
        var result = [Pattern]()
        while let current = tokens.current() where !contains(["]", ")", "|"], current) {
            var atom = parseAtom(tokens, options: &options)
            if tokens.current() == "..." {
                atom = [OneOrMore(atom)]
                tokens.move()
            }
            result += atom
        }

        return result
    }
    
    static internal func parseExpr(tokens: Tokens, inout options: [Option]) -> [Pattern] {
        var seq = parseSeq(tokens, options: &options)
        if tokens.current() != "|" {
            return seq
        }
        
        var result = count(seq) > 1 ? [Required(seq)] : seq
        while tokens.current() == "|" {
            tokens.move()
            seq = parseSeq(tokens, options: &options)
            result += count(seq) > 1 ? [Required(seq)] : seq
        }
        
        return count(result) > 1 ? [Either(result)] : result
    }

    /**
     * Parse command-line argument vector.
     *
     * If options_first:
     *     argv ::= [ long | shorts ]* [ argument ]* [ '--' [ argument ]* ] ;
     * else:
     *     argv ::= [ long | shorts | argument ]* [ '--' [ argument ]* ] ;
     */
    static internal func parseArgv(tokens: Tokens, inout options: [Option], optionsFirst: Bool = false) -> [LeafPattern] {
        var parsed = [LeafPattern]()
        while let current = tokens.current() {
            if tokens.current() == "--" {
                while let token = tokens.move() {
                    parsed.append(Argument(nil, value: token))
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
                    parsed.append(Argument(nil, value: token))
                }
                return parsed
            } else {
                parsed.append(Command(nil, value: tokens.move()))
            }
        }
        return parsed
    }
    
    static internal func parsePattern(source: String, inout options: [Option]) -> Pattern {
        let tokens: Tokens = Tokens.fromPattern(source)
        let result: [Pattern] = parseExpr(tokens, options: &options)
        
        if tokens.current() != nil {
            tokens.error.raise("unexpected ending: \(tokens)")
        }
        
        return Required(result)
    }
    
    static internal func formalUsage(section: String) -> String {
        let (_, _, s: String) = section.partition(":") // drop "usage:"
        let pu: [String] = s.split()
        return "( " + " ".join(pu[1..<count(pu)].map { $0 == pu[0] ? ") | (" : $0 }) + " )"
    }
}
