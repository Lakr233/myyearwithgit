//
//  ResultView.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/27.
//

import Quartz
import SwiftUI

extension Notification.Name {
    static let scroll = Notification.Name("wiki.qaq.scroll.result")
}

final class PageData: ObservableObject {
    var pageIndexes: [Int] = []
    var pageRects: [CGRect] = []
    var numberOfPages: Int {
        pageIndexes.count
    }

    func rect(of pageAtIndex: Int) -> CGRect? {
        if let pageIndex = pageIndexes.firstIndex(of: pageAtIndex) {
            return pageRects[pageIndex]
        }
        return nil
    }
}

struct ResultView: View {
    let resultPackage: ResultPackage
    @EnvironmentObject var pageData: PageData

    var displayPackage: some View {
        VStack(alignment: .center, spacing: 25) {
            ForEach(0 ..< resultPackage.resultSections.count, id: \.self) { index in
                ZStack {
                    Rectangle()
                        .foregroundColor(Color(NSColor.textBackgroundColor))
                        .frame(
                            width: preferredApplicationSize.width * 0.9,
                            height: preferredApplicationSize.height * 0.9,
                            alignment: .center
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 0)
                    resultPackage
                        .resultSections[index]
                        .makeView()
                        .frame(
                            width: preferredApplicationSize.width * 0.9,
                            height: preferredApplicationSize.height * 0.9,
                            alignment: .center
                        )
                        .clipped()
                }

                // MARK: INDEX IS USED AS IDENTITY

                .id(index)
            }
            Spacer()
                .frame(height: 20)
        }
    }

    var screenShotPackage: some View {
        VStack(alignment: .center, spacing: 25) {
            ForEach(0 ..< resultPackage.resultSections.count, id: \.self) { index in
                ZStack {
                    Rectangle()
                        .foregroundColor(Color(NSColor.textBackgroundColor))
                        .frame(
                            width: preferredApplicationSize.width * 0.9,
                            height: preferredApplicationSize.height * 0.9,
                            alignment: .center
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 0)
                    resultPackage
                        .resultSections[index]
                        .makeScreenShotView()
                        .frame(
                            width: preferredApplicationSize.width * 0.9,
                            height: preferredApplicationSize.height * 0.9,
                            alignment: .center
                        )
                        .clipped()
                    GeometryReader { g -> Color in
                        let frame = g.frame(in: CoordinateSpace.global)
                        if !pageData.pageIndexes.contains(index) {
                            pageData.pageIndexes.append(index)
                            pageData.pageRects.append(frame)
                        }
                        return Color.clear
                    }
                }
            }
        }
        .padding(50)
        .background(Color(NSColor.textBackgroundColor))
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Group {
                ScrollViewReader { reader in
                    Group {
                        VStack(alignment: .center, spacing: 20) {
                            Divider()
                                .hidden()

                            Spacer()
                                .frame(height: 30)
                            Text("↓ 向下滑动开启报告 ↓")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .opacity(0.5)

                            Spacer()
                                .frame(height: 10)
                            displayPackage

                            HStack(alignment: .center, spacing: 12.0) {
                                Button {
                                    let data = resultPackage.representedData
                                    guard let jsonData = try? JSONEncoder().encode(data) else {
                                        print("failed to create json data")
                                        return
                                    }
                                    guard let keyWindow = NSApp.keyWindow else {
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        let savePanel = NSSavePanel()
                                        savePanel.nameFieldStringValue = "scanner.result.json"
                                        savePanel.beginSheetModal(for: keyWindow) { result in
                                            if result.rawValue == NSApplication.ModalResponse.OK.rawValue,
                                               let url = savePanel.url
                                            {
                                                try? jsonData.write(to: url)
                                            }
                                        }
                                    }
                                } label: {
                                    Text("导出分析数据")
                                }

                                Button {
                                    guard let keyWindow = NSApp.keyWindow,
                                          let image = takeSnapshot(of: screenShotPackage)
                                    else {
                                        print("failed to create image")
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        let savePanel = NSSavePanel()
                                        savePanel.nameFieldStringValue = "我的年度代码总结.png"
                                        savePanel.beginSheetModal(for: keyWindow) { result in
                                            if result.rawValue == NSApplication.ModalResponse.OK.rawValue,
                                               let url = savePanel.url,
                                               let data = image.pngData
                                            {
                                                try? data.write(to: url)
                                            }
                                        }
                                    }
                                } label: {
                                    Text("生成截图")
                                }

                                Button {
                                    guard let keyWindow = NSApp.keyWindow,
                                          let pdfURL = generatePDF(of: screenShotPackage, with: pageData)
                                    else {
                                        print("failed to create pdf")
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        if let pdfDocument = PDFDocument(url: pdfURL) {
                                            pdfDocument.documentAttributes?["Title"] = "我的年度代码总结"
                                            let printInfo = NSPrintInfo.shared
                                            printInfo.orientation = .landscape
                                            printInfo.topMargin = 0
                                            printInfo.bottomMargin = 0
                                            printInfo.leftMargin = 0
                                            printInfo.rightMargin = 0
                                            printInfo.horizontalPagination = .fit
                                            printInfo.verticalPagination = .fit
                                            if let printOperation = pdfDocument.printOperation(
                                                for: printInfo,
                                                scalingMode: .pageScaleDownToFit,
                                                autoRotate: true
                                            ) {
                                                printOperation.runModal(
                                                    for: keyWindow,
                                                    delegate: nil,
                                                    didRun: nil,
                                                    contextInfo: nil
                                                )
                                            }
                                        }
                                    }
                                } label: {
                                    Text("打印")
                                }

                                Button {
                                    let alert = NSAlert()
                                    alert.alertStyle = .critical
                                    alert.messageText = "这会删除分析记录。"
                                    alert.addButton(withTitle: "确定")
                                    alert.addButton(withTitle: "取消")
                                    guard let window = NSApp.keyWindow else {
                                        NotificationCenter.default.post(name: .analysisErase, object: nil)
                                        return
                                    }
                                    alert.beginSheetModal(for: window) { response in
                                        if response == .alertFirstButtonReturn {
                                            NotificationCenter.default.post(name: .analysisErase, object: nil)
                                        }
                                    }
                                } label: {
                                    Text("重新开始")
                                }
                            }

                            Spacer()
                                .frame(height: 50)
                            Divider()
                                .hidden()
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .scroll, object: nil)) { notification in
                        guard let identity = notification.object as? Int else {
                            return
                        }
                        reader.scrollTo(identity)
                        guard resultPackage.resultSections.count > identity, identity >= 0 else {
                            return
                        }
                        // tell our view to perform the animation if needed
                        // we are passing the reference from the struct so we can check object == Self
                        NotificationCenter.default.post(
                            name: .resultContextSwitch,
                            object: resultPackage.resultSections[identity]
                        )
                    }
                }
            }
            .padding(10)
        }
        .padding(-10)
    }

    func takeSnapshot<V: View>(of view: V) -> NSImage? {
        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = .init(origin: .zero, size: hostingView.fittingSize)

        let bounds = hostingView.bounds
        guard let bitmapRep = hostingView.bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        hostingView.cacheDisplay(in: bounds, to: bitmapRep)

        let image = NSImage(size: bounds.size)
        image.addRepresentation(bitmapRep)

        return image
    }

    func generatePDF<V: View>(of view: V, with pageData: PageData) -> URL? {
        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = .init(origin: .zero, size: hostingView.fittingSize)

        let bounds = hostingView.bounds
        guard let bitmapRep = hostingView.bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        hostingView.cacheDisplay(in: bounds, to: bitmapRep)

        if let pageBounds = pageData.rect(of: 0) {
            let dpi: CGFloat = 300.0 / 72.0
            var mediaBox = CGRect(origin: .zero, size: CGSize(width: pageBounds.size.width * dpi, height: pageBounds.size.height * dpi))
            let tempPathComponent = "MyYearWithGit.pdf"
            var tempPath = URL(fileURLWithPath: NSTemporaryDirectory())
            tempPath.appendPathComponent(tempPathComponent)
            if let pdfCtx = CGContext(tempPath as CFURL, mediaBox: &mediaBox, nil) {
                for pageIndex in (0 ... pageData.numberOfPages - 1).reversed() {
                    guard let pageRect = pageData.rect(of: pageIndex) else {
                        continue
                    }
                    pdfCtx.beginPDFPage(nil)
                    pdfCtx.saveGState()
                    pdfCtx.translateBy(x: -pageRect.minX * dpi, y: -pageRect.minY * dpi)
                    pdfCtx.scaleBy(x: dpi, y: dpi)
                    pdfCtx.concatenate(CGAffineTransform(
                        a: 1,
                        b: 0,
                        c: 0,
                        d: -1,
                        tx: 0,
                        ty: bounds.height
                    ))
                    hostingView.layer?.render(in: pdfCtx)
                    pdfCtx.restoreGState()
                    pdfCtx.endPDFPage()
                }

                pdfCtx.closePDF()
                return tempPath
            }
        }

        return nil
    }
}

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }

    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}

extension String {
    var uppercase: String {
        #if DEBUG
            return lowercased()
        #else
            return uppercased()
        #endif
    }
}
