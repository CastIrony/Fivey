//
//  GraphViews.swift
//  Fivey (iOS)
//
//  Created by Joel Bernstein on 8/31/20.
//

import SwiftUI

struct GraphMajorGridLines: Shape
{
    let poll: Poll?
    
    func path(in rect: CGRect) -> Path {

        var path = Path()

        let data = poll?.candidates.first?.dataPoints.reversed() ?? []
        
        for (index, dataPoint) in data.enumerated() {
            guard let date = dataPoint.date else { continue }
            
            let x = rect.minX + (CGFloat(index) / CGFloat(data.count - 1)) * rect.width
            let day = Calendar.autoupdatingCurrent.component(.day, from: date)
            
            if day == 1 && index != 0 && index != (data.count - 1) {
                path.move(to: CGPoint(x: x, y: rect.minY))
                path.addLine(to: CGPoint(x: x, y: rect.maxY))
            }
        }
        
        for percent: CGFloat in stride(from: 0.2, through: 0.8, by: 0.2) {
            let y = rect.minY + rect.height * percent
            
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }

        
        return path
    }
}

//struct StatRangeGraphShape: Shape
//{
//    let candidate: Candidate?
//    let keyPath: KeyPath<Candidate, [StatRange]>
//
//    let min: Double
//    let max: Double
//
//    func percent(_ value: Double) -> CGFloat
//    {
//        CGFloat((value - min) / (max - min))
//    }
//
//    func path(in rect: CGRect) -> Path {
//
//        var path = Path()
//
//        if let candidate = candidate {
//
//            let dataSet = candidate[keyPath: keyPath]
//
//            for (index, statRange) in dataSet.enumerated() {
//
//                let x = rect.minX + CGFloat(index) / CGFloat(dataSet.count - 1) * rect.width
//                let y = rect.minY + CGFloat(1 - percent(statRange.high)) * rect.height
//
//                if index == 0 {
//                    path.move(to: CGPoint(x: x, y: y))
//                } else {
//                    path.addLine(to: CGPoint(x: x, y: y))
//                }
//            }
//
//            for (index, statRange) in dataSet.enumerated().reversed() {
//
//                let x = rect.minX + CGFloat(index) / CGFloat(dataSet.count - 1) * rect.width
//                let y = rect.minY + CGFloat(1 - percent(statRange.low)) * rect.height
//
//                path.addLine(to: CGPoint(x: x, y: y))
//            }
//        }
//
//        return path
//    }
//}
//
//struct StatRangeGraphLine: Shape
//{
//    let candidate: Candidate?
//    let keyPath: KeyPath<Candidate, [StatRange]>
//
//    let min: Double
//    let max: Double
//
//    func percent(_ value: Double) -> CGFloat
//    {
//        CGFloat((value - min) / (max - min))
//    }
//
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//
//        if let candidate = candidate {
//
//            let dataSet = candidate[keyPath: keyPath]
//            for (index, statRange) in dataSet.enumerated() {
//                let x = rect.minX + CGFloat(index) / CGFloat(dataSet.count - 1) * rect.width
//                let y = rect.minY + CGFloat(1 - percent(statRange.mean)) * rect.height
//
//                if index == 0 {
//                    path.move(to: CGPoint(x: x, y: y))
//                } else {
//                    path.addLine(to: CGPoint(x: x, y: y))
//                }
//            }
//        }
//
//        return path
//    }
//}


struct WinProbabilityGraphLine: Shape
{
    let candidate: Candidate?
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
                
        for (index, percent) in (candidate?.winProbabilities ?? []).enumerated() {
            let x = rect.minX + (CGFloat(index) / CGFloat((candidate?.dataPoints.count)! - 1)) * rect.width
            let y = rect.minY + (CGFloat(100 - percent) / 100) * rect.height
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
                
        return path
    }
}

struct WinProbabilityGraphDot: Shape
{
    let candidate: Candidate?

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let y = rect.minY + (CGFloat(100 - (candidate?.winProbabilities.last ?? 200)) / 100) * rect.height

        path.addEllipse(in: CGRect(x: rect.maxX + 2, y: y - 2, width: 4, height: 4))
                
        return path
    }
}

struct WinProbabilityGraph: View
{
    let poll: Poll?

    var body: some View {
        ZStack {
            GraphMajorGridLines(poll: poll).stroke(Color(UIColor.systemBackground), lineWidth: 1)
            
            WinProbabilityGraphLine(candidate: poll?.candidate(named: "Biden")).stroke(Color.blue, lineWidth: 2)
            WinProbabilityGraphLine(candidate: poll?.candidate(named: "Trump")).stroke(Color.red, lineWidth: 2)
            
            WinProbabilityGraphDot(candidate: poll?.candidate(named: "Biden")).fill(Color.blue)
            WinProbabilityGraphDot(candidate: poll?.candidate(named: "Trump")).fill(Color.red)
        }
    }
}

//struct PopularVoteGraph: View
//{
//    let poll: Poll?
//
//    var body: some View {
//        ZStack {
//            GraphMajorGridLines(poll: poll).stroke(Color(UIColor.systemBackground), lineWidth: 1)
//
//            StatRangeGraphLine(candidate: poll?.candidate(named: "Biden"), keyPath: \.popularVotes, min: 40, max: 60).stroke(Color.blue, lineWidth: 2).blendMode(.multiply)
//            StatRangeGraphLine(candidate: poll?.candidate(named: "Trump"), keyPath: \.popularVotes, min: 40, max: 60).stroke(Color.red, lineWidth: 2).blendMode(.multiply)
//
//            StatRangeGraphShape(candidate: poll?.candidate(named: "Biden"), keyPath: \.popularVotes, min: 40, max: 60).fill(Color.blue.opacity(0.3)).blendMode(.multiply)
//            StatRangeGraphShape(candidate: poll?.candidate(named: "Trump"), keyPath: \.popularVotes, min: 40, max: 60).fill(Color.red.opacity(0.3)).blendMode(.multiply)
//        }
//    }
//}


struct GraphViews: View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct GraphViews_Previews: PreviewProvider {
    
    static var previews: some View {
    
        let data = try? Data(contentsOf: Bundle.main.url(forResource: "fixture", withExtension: "json")!)
        let polls = try? JSONDecoder().decode([Poll].self, from: data!)

        Group {
            WinProbabilityGraph(poll: polls?.first).padding(.trailing ,8).background(Color(UIColor.secondarySystemBackground))
                .previewLayout(.fixed(width: 600, height: 400))
            
//            PopularVoteGraph(poll: polls?.first).padding(.trailing ,8).background(Color(UIColor.secondarySystemBackground))
//                .previewLayout(.fixed(width: 600, height: 550))
        }
    }
}
