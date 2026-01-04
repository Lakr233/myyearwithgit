//
//  RS9.swift
//  MyYearWithGit
//
//  Created by diablohl on 2025/1/5.
//

import Foundation
import SwiftUI

private let calendar = Calendar.current

class ResultSection6-1: ResultSection {
    // 每天的提交次数 [日期字符串: 提交次数]
    var dailyCommits: [String: Int] = [:]
    // 每月的代码行数 [月份: 代码行数]
    var monthlyLines: [Int: Int] = [:]
    // 一年中的最大提交天数（用于热力图）
    var maxCommitsInDay: Int = 0
    
    func update(with scannerResult: ResultPackage.DataSource) -> ResultSectionUpdateRecipe? {
        dailyCommits = [:]
        monthlyLines = [:]
        maxCommitsInDay = 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // 统计每天的提交次数和每月的代码行数
        for repo in scannerResult.repoResult.repos {
            for commit in repo.commits {
                // 统计每天的提交次数
                let dateKey = dateFormatter.string(from: commit.date)
                dailyCommits[dateKey, default: 0] += 1
                
                // 统计每月的代码行数
                let month = calendar.component(.month, from: commit.date)
                let linesAdded = commit.diffFiles.map(\.increasedLine).reduce(0, +)
                monthlyLines[month, default: 0] += linesAdded
            }
        }
        
        // 找出单日最大提交次数
        maxCommitsInDay = dailyCommits.values.max() ?? 0
        
        // 如果全年每天都有提交，返回成就
        if dailyCommits.count >= 365 {
            return .init(achievement: .init(
                name: NSLocalizedString("全勤战士", comment: ""),
                describe: NSLocalizedString("全年每天都有提交记录", comment: "")
            ))
        }
        
        return nil
    }
    
    func makeView() -> AnyView {
        AnyView(AssociatedView(
            dailyCommits: dailyCommits,
            monthlyLines: monthlyLines,
            maxCommitsInDay: maxCommitsInDay
        ))
    }
    
    func makeScreenShotView() -> AnyView {
        makeView()
    }
    
    struct AssociatedView: View {
        let dailyCommits: [String: Int]
        let monthlyLines: [Int: Int]
        let maxCommitsInDay: Int
        
        let preferredContextSize: CGFloat = 12
        
        // 日期格式化器
        private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }
        
        var body: some View {
            Group {
                container
                    .padding(50)
            }
        }
        
        var container: some View {
            VStack(alignment: .center, spacing: 20) {
                // 标题
                Text("时光印记")
                    .font(.system(size: preferredContextSize * 2, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
                
                // 热力图
                VStack(alignment: .leading, spacing: 5) {
                    Text("全年提交热力图")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 0) {
                        heatmapView
                            .frame(height: 90)
                        
                        // 月份时间轴
                        monthAxisView
                            .frame(height: 15)
                    }
                }
                
                Spacer().frame(height: 10)
                
                // 每月代码量柱状图
                VStack(alignment: .leading, spacing: 5) {
                    Text("每月代码量统计")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 0) {
                        // 纵坐标
                        yAxisView
                            .frame(width: 35)
                        
                        // 柱状图
                        monthlyChartView
                            .frame(height: 120)
                    }
                }
            }
        }
        
        // 热力图视图
        var heatmapView: some View {
            GeometryReader { geometry in
                // 计算每个方块的大小
                let columns = 53 // 一年约52-53周
                let rows = 7 // 一周7天
                let cellWidth = (geometry.size.width - CGFloat(columns + 1) * 2) / CGFloat(columns)
                let cellHeight = (geometry.size.height - CGFloat(rows + 1) * 2) / CGFloat(rows)
                let cellSize = min(cellWidth, cellHeight)
                
                VStack(spacing: 2) {
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0..<columns, id: \.self) { col in
                                let dayIndex = col * 7 + row
                                let date = getDateForDay(dayIndex)
                                let dateKey = dateFormatter.string(from: date)
                                let commits = dailyCommits[dateKey] ?? 0
                                
                                Rectangle()
                                    .fill(getColorForCommits(commits))
                                    .frame(width: cellSize, height: cellSize)
                                    .cornerRadius(2)
                            }
                        }
                    }
                }
            }
        }
        
        // 月份时间轴
        var monthAxisView: some View {
            GeometryReader { geometry in
                let columns = 53
                let cellWidth = (geometry.size.width - CGFloat(columns + 1) * 2) / CGFloat(columns)
                
                ZStack(alignment: .leading) {
                    ForEach(0..<12, id: \.self) { monthIndex in
                        let month = monthIndex + 1
                        let weekPosition = getWeekPositionForMonth(month)
                        
                        if weekPosition < columns {
                            Text(getMonthAbbreviation(month))
                                .font(.system(size: 7, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                                .frame(width: cellWidth * 4, alignment: .leading)
                                .offset(x: CGFloat(weekPosition) * (cellWidth + 2))
                        }
                    }
                }
                .frame(width: geometry.size.width, alignment: .leading)
            }
        }
        
        // 每月柱状图
        var monthlyChartView: some View {
            GeometryReader { geometry in
                let maxLines = monthlyLines.values.max() ?? 1
                
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(1...12, id: \.self) { month in
                        VStack(spacing: 2) {
                            // 柱状条
                            let lines = monthlyLines[month] ?? 0
                            let height = geometry.size.height - 15
                            let barHeight = height * CGFloat(lines) / CGFloat(maxLines)
                            
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            getColorForMonth(month),
                                            getColorForMonth(month).opacity(0.6)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: max(barHeight, 2))
                            
                            // 月份标签
                            Text("\(month)")
                                .font(.system(size: 8, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        
        // 纵坐标轴
        var yAxisView: some View {
            GeometryReader { geometry in
                let maxLines = monthlyLines.values.max() ?? 1
                let height = geometry.size.height - 15
                
                VStack(alignment: .trailing, spacing: 0) {
                    // 显示 4 个刻度
                    ForEach([1.0, 0.75, 0.5, 0.25, 0.0], id: \.self) { ratio in
                        let value = Int(Double(maxLines) * ratio)
                        Spacer()
                            .frame(height: ratio == 1.0 ? 0 : height * 0.25)
                        HStack(spacing: 2) {
                            Text(formatNumber(value))
                                .font(.system(size: 7, weight: .regular, design: .monospaced))
                                .foregroundColor(.secondary)
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 3, height: 1)
                        }
                    }
                }
                .frame(height: height)
            }
        }
        
        // 根据提交次数返回颜色
        func getColorForCommits(_ commits: Int) -> Color {
            if commits == 0 {
                return Color.gray.opacity(0.1)
            } else if commits <= maxCommitsInDay / 4 {
                return Color.green.opacity(0.3)
            } else if commits <= maxCommitsInDay / 2 {
                return Color.green.opacity(0.5)
            } else if commits <= maxCommitsInDay * 3 / 4 {
                return Color.green.opacity(0.7)
            } else {
                return Color.green.opacity(0.9)
            }
        }
        
        // 获取一年中第几天的日期
        func getDateForDay(_ dayIndex: Int) -> Date {
            let year = requiredYear
            var components = DateComponents()
            components.year = year
            components.month = 1
            components.day = 1
            
            if let startDate = calendar.date(from: components),
               let date = calendar.date(byAdding: .day, value: dayIndex, to: startDate) {
                return date
            }
            return Date()
        }
        
        // 为不同月份分配颜色
        func getColorForMonth(_ month: Int) -> Color {
            let colors: [Color] = [
                .blue, .cyan, .green, .mint, .yellow, .orange,
                .red, .pink, .purple, .indigo, .teal, .brown
            ]
            return colors[(month - 1) % colors.count]
        }
        
        // 格式化数字（简化大数字显示）
        func formatNumber(_ number: Int) -> String {
            if number >= 10000 {
                return String(format: "%.1fk", Double(number) / 1000.0)
            } else if number >= 1000 {
                return String(format: "%.1fk", Double(number) / 1000.0)
            } else {
                return "\(number)"
            }
        }
        
        // 获取月份的周位置（更准确的计算）
        func getWeekPositionForMonth(_ month: Int) -> Int {
            let year = requiredYear
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = 1
            
            guard let monthStart = calendar.date(from: components),
                  let yearStart = calendar.date(from: DateComponents(year: year, month: 1, day: 1))
            else {
                // 降级为粗略估算
                let daysInMonths = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
                return daysInMonths[month - 1] / 7
            }
            
            let days = calendar.dateComponents([.day], from: yearStart, to: monthStart).day ?? 0
            return days / 7
        }
        
        // 获取月份缩写
        func getMonthAbbreviation(_ month: Int) -> String {
            let months = ["1月", "2月", "3月", "4月", "5月", "6月",
                         "7月", "8月", "9月", "10月", "11月", "12月"]
            return months[month - 1]
        }
    }
}

