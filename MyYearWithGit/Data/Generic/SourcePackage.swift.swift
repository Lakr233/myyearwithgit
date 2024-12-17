//
//  SourcePackage.swift.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/27.
//

import Foundation

extension Notification.Name {
    static let postAnalysis = Notification.Name("wiki.qaq.source.done")
}

struct SourcePackage {
    let tempDir: URL
    let representedObjects: [SourceRegistrationData]

    init(sources: [SourceRegistrationData]) {
        tempDir = {
            let tempDir = NSTemporaryDirectory()
            let uuid = UUID().uuidString
            let location = URL(fileURLWithPath: tempDir)
                .appendingPathComponent("wiki.qaq.myyearwithgit")
                .appendingPathComponent(uuid)
            try? FileManager.default.removeItem(at: location)
            do {
                try FileManager
                    .default
                    .createDirectory(
                        at: location,
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
            } catch {
                fatalError("error when creating analysis temp bundle \(error.localizedDescription)")
            }
            return location
        }()
        representedObjects = sources
    }

    func postToAnalysis() {
        NotificationCenter.default.post(name: .postAnalysis, object: self)
    }
}
