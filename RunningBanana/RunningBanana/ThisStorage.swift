//
//  ThisStorage.swift
//  RunningBanana
//
//  Created by Arturo Cecora on 13/12/23.
//

import Foundation


struct LeaderboardEntry{
    var user: String
    var score: Int
}

func decodeData(rawData: String) -> [LeaderboardEntry]{
    var userAndScore = rawData.split(separator: ",")
    
    var leaderboard: [LeaderboardEntry] = []
    
    for entry in userAndScore{
        var user = entry.split(separator: ": ")[0]
        var score = entry.split(separator: ": ")[1]
        
        leaderboard.append(LeaderboardEntry(user: String(user), score: Int(score) ?? 0))
    }
    
    return leaderboard
}

func encodeData(rawData: [LeaderboardEntry]) -> String{
    var output: String = ""
    
    for entry in rawData{
        output.append("\(entry.user): \(entry.score)")
    }
    return output
}

