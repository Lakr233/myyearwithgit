//
//  App.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/26.
//

import AppKit
import SwiftUI

let preferredApplicationSize = CGSize(width: 750, height: 450)
let preferredTitleSize: CGFloat = 32

// just in case if we are going to use it later
let currentBootWorkingDir: String = FileManager
    .default
    .currentDirectoryPath

let requiredYear = 2023

let processCount: Int = {
    var count = ProcessInfo
        .processInfo
        .processorCount
    if count < 0 {
        count = 1
    }
    return count
}()

@main
struct MyYearWithGitApp: App {
    init() {
        unprotectWindowFromClose()

        // override
        setenv("GIT_TERMINAL_PROMPT", "0", 1)
        setenv("GIT_LFS_SKIP_SMUDGE", "1", 1)

        AuxiliaryExecuteWrapper.setupExecutables()

        // now check if git is working
        do {
            let command = AuxiliaryExecuteWrapper.spawn(
                command: AuxiliaryExecuteWrapper.git,
                args: [
                    "version",
                ],
                timeout: 0
            ) { _ in
            }
            if !command.1.contains("git version") {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.alertStyle = .critical
                    alert.messageText = "git 似乎没有安装，程序可能不工作。"
                    alert.addButton(withTitle: "确定")
                    alert.beginSheetModal(for: NSApp.keyWindow ?? NSWindow()) { _ in
                    }
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup { content }
            .windowStyle(.hiddenTitleBar)
            .commands { CommandGroup(replacing: .newItem) {} }
            .restrictWindowResizing()
    }

    // fixed size for better control over layout effect
    var content: some View {
        NavigatorView()
            .ignoresSafeArea()
            .frame(
                width: preferredApplicationSize.width,
                height: preferredApplicationSize.height,
                alignment: .center
            )
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.willUpdateNotification), perform: { _ in
                hideWindowRelatedButtons()
            })
    }

    func hideWindowRelatedButtons() {
        for window in NSApplication.shared.windows {
            window.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isHidden = true
            window.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)?.isHidden = true
        }
    }
}

private extension Scene {
    func restrictWindowResizing() -> some Scene {
        if #available(macOS 13.0, *) {
            return self.windowResizability(.contentSize)
        }
        return self
    }
}

extension View {
    func makeHoverPointer() -> some View {
        onHover { hover in
            if hover {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

func unprotectWindowFromClose() {
    UserDefaults.standard.set(false, forKey: "wiki.qaq.window.confirm.close")
}

func protectWindowFromClose() {
    UserDefaults.standard.set(true, forKey: "wiki.qaq.window.confirm.close")
}
