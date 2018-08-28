//
//  Subject.swift
//  GPA Manager
//
//  Created by Jia Rui Shan on 5/23/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

struct Subject {
    var name = ""
    
    var group = 0
    var categories = [String: CGFloat]()
    var hl = false
    var assignments = [String: [String: [Int]]]() // CGFloat[0] = max; CGFloat[1] = score
    var boundaries = [CGFloat]()
    
    var fullname: String {
        if name == "All" {return "All"}
        return name + (hl ? " HL" : " SL")
    }
    
    init(name: String, group: Int, categories: [String: CGFloat], hl: Bool, assignments: [String: [String: [Int]]], boundaries: [CGFloat]) {
        self.hl = hl
        self.name = name
        self.group = group
        self.categories = categories
        self.assignments = assignments
        self.boundaries = boundaries
    }
    
    init(encodedForm: [NSObject]) {
        name = encodedForm[0] as! String
        group = encodedForm[1] as! Int
        categories = encodedForm[2] as! [String: CGFloat]
        hl = encodedForm[3] as! Bool
        assignments = encodedForm[4] as! [String: [String: [Int]]]
//        keys = Array(assignments.keys)
        boundaries = encodedForm[5] as! [CGFloat]
    }
    
    var percentage: Int {
        
        if scores.count == 0 {return -1}
        
        var totalPercentage: CGFloat = 0
        for i in scores.keys {
            totalPercentage += specificScores[i]!
        }
        return Int(totalPercentage)
    }
    
    var specificPercentage: CGFloat {
        
        if scores.count == 0 {return -1}
        
        var totalPercentage: CGFloat = 0
        for i in scores.keys {
            totalPercentage += specificScores[i]!
        }
        return totalPercentage
    }
    
    var scoreOutOf7: Int {
        if specificPercentage == -1 {return -1}
        
        var accumulation: CGFloat = 0
        
        for i in 0..<6 {
            accumulation += boundaries[i] * 100
            if accumulation > specificPercentage {return i+1}
        }
        
        return 7
    }
    
    func minPercentageFor(_ level: Int) -> Int {
        var total = 1
        for i in 0..<level {
            total += Int(boundaries[i] * 100)
        }
        return total
    }
    
    var scores: [String: Int] {
        var tmp = [String: Int]()
        for i in assignments.keys {
            // key = category; value = [String: [CGFloat]]
            var maxPercentage = 0, total = 0
            for c in assignments[i]!.keys {
                // key = assignment name; value = [CGFloat]
                maxPercentage += assignments[i]![c]![0]
                total += assignments[i]![c]![1]
            }
            if maxPercentage != 0 {
                tmp[i] = Int( floor (CGFloat(total) / CGFloat(maxPercentage) * 100 * (categories[i] ?? 0)) )
            }
        }
        return tmp
    }
    
    var specificScores: [String: CGFloat] {
        var tmp = [String: CGFloat]()
        for i in assignments.keys {
            // key = category; value = [String: [CGFloat]]
            var maxPercentage = 0, total = 0
            for c in assignments[i]!.keys {
                // key = assignment name; value = [CGFloat]
                maxPercentage += assignments[i]![c]![0]
                total += assignments[i]![c]![1]
            }
            if maxPercentage == 0 {
                tmp[i] = -1
            } else {
                tmp[i] = CGFloat(total) / CGFloat(maxPercentage) * 100 * (categories[i] ?? 0)
            }
        }
        return tmp
    }
    
    var readableAssignments: [(name: String, category: String, timeReference: Int, total: Int, score: Int)] {
        var all = [(name: String, category: String, timeReference: Int, total: Int, score: Int)]()
        for i in assignments.keys {
            for a in self.assignments[i]!.keys {
                all.append( (a, i, self.assignments[i]![a]![2], self.assignments[i]![a]![0], self.assignments[i]![a]![1]) )
            }
        }
        return all.sorted(by: {$0.0.timeReference < $0.1.timeReference})
    }
    
    var encodedForm: [NSObject] {
        get {
            
            return [name as NSObject, group as NSObject, categories as NSObject, hl as NSObject, assignments as NSObject, boundaries as NSObject]
            
        }
    }
}
