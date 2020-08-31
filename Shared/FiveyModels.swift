//
//  FiveyModels.swift
//  Fivey
//
//  Created by Joel Bernstein on 8/30/20.
//

import Foundation

struct Poll: Codable {
    let type: String
    let state: String
    let candidates: [Candidate]
}

struct Candidate: Codable {
    let candidate: String
    let dates: [DataPoint]
}

struct DataPoint: Codable {
    let date: String
    let winprob: Double
//    let evs: StatRange
//    let voteshare: StatRange
}

//struct StatRange: Codable {
//    let mean: Double
//    let hi: Double
//    let lo: Double
//}
