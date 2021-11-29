//
//  SourceLanguage.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/28.
//

import Foundation

enum SourceLanguage: String, Codable, HumanReadable {
    static func languageDecision(withFileExtension pathExtension: String) -> Self? {
        switch pathExtension.lowercased() {
        case "c":
            return .c
        case "cs", "csharp":
            return .csharp
        case "cpp", "cc", "cxx", "c++":
            return .cpp
        case "css":
            return .css
        case "dart":
            return .dart
        case "ex":
            return .elixir
        case "go":
            return .go
        case "groovy", "gvy", "gy", "gsh":
            return .groovy
        case "html", "htm":
            return .html
        case "java", "jav", "j":
            return .java
        case "js", "jsx":
            return .javascript
        case "kt", "ktm":
            return .kotlin
        case "m", "mm":
            return .objc
        case "pl":
            return .perl
        case "php":
            return .php
        case "ps1":
            return .powershell
        case "py":
            return .python
        case "rb":
            return .rbuy
        case "rs":
            return .rust
        case "scala", "sc":
            return .scala
        case "sh", "command":
            return .shell
        case "swift":
            return .swift
        case "ts", "tsx":
            return .typescript
        default:
            return nil
        }
    }

    case c
    case csharp
    case cpp
    case css
    case dart
    case elixir
    case go
    case groovy
    case html
    case java
    case javascript
    case kotlin
    case objc
    case perl
    case php
    case powershell
    case python
    case rbuy
    case rust
    case scala
    case shell
    case swift
    case typescript

    func readableDescription() -> String {
        switch self {
        case .c:
            return "C"
        case .csharp:
            return "C#"
        case .cpp:
            return "C++"
        case .css:
            return "CSS"
        case .dart:
            return "Dart"
        case .elixir:
            return "Elixir"
        case .go:
            return "Go"
        case .groovy:
            return "Groovy"
        case .html:
            return "HTML"
        case .java:
            return "Java"
        case .javascript:
            return "JavaScript"
        case .kotlin:
            return "Kotlin"
        case .objc:
            return "Objective-C"
        case .perl:
            return "Perl"
        case .php:
            return "PHP"
        case .powershell:
            return "PowerShell"
        case .python:
            return "Python"
        case .rbuy:
            return "Ruby"
        case .rust:
            return "Rust"
        case .scala:
            return "Scala"
        case .shell:
            return "Shell"
        case .swift:
            return "Swift"
        case .typescript:
            return "TypeScript"
        }
    }
}
