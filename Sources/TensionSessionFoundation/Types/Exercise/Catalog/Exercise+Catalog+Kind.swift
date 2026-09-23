//
//  Exercise+Catalog+Kind.swift
//  TensionSession
//
//  Created by Kevin on 9/17/26.
//

import Foundation

extension Exercise.Catalog {
    
    public struct Kind: Codable, Hashable {
        
        public let name: String
        
        public let isBuiltIn: Bool
        
        public init(_ name: String, isBuiltIn: Bool) {
            
            self.name = name
            self.isBuiltIn = isBuiltIn
        }
        
        public static func trimmedAndNeatened(_ name: String) -> String {
            
            var result = ""
            
            for character in name {
                
                if character.isLetter {
                    
                    if result.last == ")" {
                        result.append(" ")
                    }
                    
                    if result.last?.isLetter == true {
                        result.append(contentsOf: character.lowercased())
                    } else {
                        result.append(contentsOf: character.uppercased())
                    }
                    
                    continue
                }
                
                switch character {
                    
                case " ":
                    guard let last = result.last else { break }
                    if last == " " || last == "-" || last == "(" { break }
                    if last.isLetter || last == ")" {
                        result.append(" ")
                    }
                    
                case "-":
                    while result.last == " " {
                        result.removeLast()
                    }
                    guard result.last?.isLetter == true else { break }
                    result.append("-")
                    
                case "(":
                    if result.last == "-" {
                        result.removeLast()
                    }
                    while result.last == " " {
                        result.removeLast()
                    }
                    guard result.last?.isLetter == true || result.last == ")" else { break }
                    result.append(" ")
                    result.append("(")
                    
                case ")":
                    while result.last == " " {
                        result.removeLast()
                    }
                    if result.last == "-" {
                        result.removeLast()
                    }
                    guard result.last?.isLetter == true else { break }
                    result.append(")")
                    
                default:
                    break
                }
            }
            
            while let last = result.last, last == " " || last == "-" || last == "(" {
                result.removeLast()
            }
            
            return result
        }
        
        public static func isValid(_ trimmedAndNeatenedName: String) -> Bool {
            
            if trimmedAndNeatenedName.isEmpty { return false }
            if trimmedAndNeatenedName.count > 30 { return false }
            if trimmedAndNeatenedName.count < 3 { return false }
            if trimmedAndNeatenedName.first?.isLetter != true { return false }
            
            let characters = Array(trimmedAndNeatenedName)
            
            for index in characters.indices {
                
                let current = characters[index]
                let previous = index > 0 ? characters[index - 1] : nil
                let next = index + 1 < characters.count ? characters[index + 1] : nil
                
                if current.isLetter {
                    if let previous, previous.isLetter, current.isUppercase {
                        return false
                    }
                    continue
                }
                
                switch current {
                    
                case " ":
                    guard let previous, previous.isLetter || previous == ")" else {
                        return false
                    }
                    guard let next, next.isLetter || next == "(" else {
                        return false
                    }
                    
                case "-":
                    guard let previous, previous.isLetter else { return false }
                    guard let next, next.isLetter else { return false }
                    
                case "(":
                    guard previous == " " else { return false }
                    guard let next, next.isLetter else { return false }
                    
                case ")":
                    guard let previous, previous.isLetter else { return false }
                    if let next, next != " " { return false }
                    
                default:
                    return false
                }
            }
            
            return true
        }
    }
}
