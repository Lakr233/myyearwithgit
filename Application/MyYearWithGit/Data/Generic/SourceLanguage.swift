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
            .c
        case "cs", "csharp":
            .csharp
        case "cpp", "cc", "cxx", "c++":
            .cpp
        case "css":
            .css
        case "dart":
            .dart
        case "ex":
            .elixir
        case "go":
            .go
        case "groovy", "gvy", "gy", "gsh":
            .groovy
        case "html", "htm":
            .html
        case "java", "jav", "j":
            .java
        case "js", "jsx":
            .javascript
        case "kt", "ktm":
            .kotlin
        case "m", "mm":
            .objc
        case "pl":
            .perl
        case "php":
            .php
        case "ps1":
            .powershell
        case "py":
            .python
        case "rb":
            .rbuy
        case "rs":
            .rust
        case "scala", "sc":
            .scala
        case "sh", "command":
            .shell
        case "swift":
            .swift
        case "ts", "tsx":
            .typescript
        default:
            nil
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
            "C"
        case .csharp:
            "C#"
        case .cpp:
            "C++"
        case .css:
            "CSS"
        case .dart:
            "Dart"
        case .elixir:
            "Elixir"
        case .go:
            "Go"
        case .groovy:
            "Groovy"
        case .html:
            "HTML"
        case .java:
            "Java"
        case .javascript:
            "JavaScript"
        case .kotlin:
            "Kotlin"
        case .objc:
            "Objective-C"
        case .perl:
            "Perl"
        case .php:
            "PHP"
        case .powershell:
            "PowerShell"
        case .python:
            "Python"
        case .rbuy:
            "Ruby"
        case .rust:
            "Rust"
        case .scala:
            "Scala"
        case .shell:
            "Shell"
        case .swift:
            "Swift"
        case .typescript:
            "TypeScript"
        }
    }
}
