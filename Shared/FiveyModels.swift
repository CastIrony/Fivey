//
//  FiveyModels.swift
//  Fivey
//
//  Created by Joel Bernstein on 8/30/20.
//

import Foundation

struct Poll: Codable {
    let state: String
    let candidates: [Candidate]
    let updatedMilliseconds: Double

    var updated: Date {
        Date(timeIntervalSince1970: updatedMilliseconds / 1000)
    }
    
    func candidate(named name: String) -> Candidate? {
        candidates.filter { $0.name == name }.first
    }

    enum CodingKeys : String, CodingKey {
        case state
        case candidates
        case updatedMilliseconds = "updated"
    }
}

struct Candidate: Codable {
    let name: String
    let dataPoints: [DataPoint]
    
    enum CodingKeys : String, CodingKey {
        case name = "candidate"
        case dataPoints = "dates"
    }
}

struct DataPoint: Codable {
    let dateString: String
    let winProbability: Double
    let electoralVotes: StatRange
    let popularVote: StatRange

    var date: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from:dateString)
    }
    
    enum CodingKeys : String, CodingKey {
        case dateString = "date"
        case winProbability = "winprob"
        case electoralVotes = "evs"
        case popularVote = "voteshare"
    }
}

struct StatRange: Codable {
    let mean: Double
    let high: Double
    let low: Double

    enum CodingKeys : String, CodingKey {
        case mean
        case high = "hi"
        case low = "lo"
    }
    
    static var zero: StatRange {
        StatRange(mean: 0, high: 0, low: 0)
    }
}
