//
//  DictionaryBuilder.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/29.
//

import Foundation

class DictionaryBuilder {
    static let sharedIncrease = DictionaryBuilder()
    static let sharedDecrease = DictionaryBuilder()
    static let sharedCommit = DictionaryBuilder()
    private init() {}

    var currentSession = UUID()
    var dictionary: [String: Int] = [:]

    var trimCounter = 1024

    func beginSession() -> UUID {
        let session = UUID()
        currentSession = session
        dictionary = [:]
        return session
    }

    private let lock = NSLock()

    func feed(buffer: String, session: UUID) {
        lock.lock()
        defer {
            lock.unlock()
        }
        guard session == currentSession else {
            return
        }
        buffer.enumerateSubstringsByWordsWithCamelCase { substring, _, _, _ in
            guard let substring,
                  substring.count > 3,
                  substring.elegantForDictonary,
                  Double(substring) == nil
            else {
                return
            }
            if self.dictionary[substring.lowercased(), default: 0] > 2_147_483_647 {
                return
            }
            self.dictionary[substring.lowercased(), default: 0] += 1
            self.trimCounter -= 1
            if self.trimCounter < 0 {
                self.trimCounter = 1024
            }
            if self.trimCounter == 1024 {
                self.trimMemory()
            }
        }
    }

    func trimMemory() {
        var currentTrimCount = 0 // why would it be zero? for robust
        while dictionary.keys.count > 65535 {
            var currentTrimPassCount = 0
            for key in dictionary.keys {
                let value = dictionary[key, default: 0]
                if value == currentTrimCount {
                    dictionary.removeValue(forKey: key)
                    currentTrimPassCount += 1
                }
            }
            currentTrimCount += 1
            debugPrint("trimming dictionary passed \(currentTrimPassCount)")
        }
    }

    func commitSession(session: UUID) -> [String: Int] {
        guard session == currentSession else {
            return [:]
        }
        let copy = dictionary
        _ = beginSession()
        return copy
    }
}

private let invalidCharacters = [
    CharacterSet.controlCharacters,
    CharacterSet.illegalCharacters,
    CharacterSet.controlCharacters,
    CharacterSet.whitespacesAndNewlines,
    CharacterSet.punctuationCharacters,
    CharacterSet.decimalDigits,
]

private extension String {
    var elegantForDictonary: Bool {
        if isEmpty {
            return false
        }
        for charSet in invalidCharacters {
            if rangeOfCharacter(from: charSet) != nil {
                return false
            }
        }
        return true
    }
}
