//
//  NewPoemGenerator1.swift
//  clarifaiApp
//
//  Created by 李阳 on 29/1/18.
//  Copyright © 2018 partywolfAPPS. All rights reserved.
//

import Foundation

class PoemGenerator{
    var rules:[String] = []
    var poemStructures:[[String]] = [[]]
    var partOfSentence:[String:[[String]]] = [:]
    var nouns:[String : [String]] = [:]
    var defaultPoemIndex = -1
    var tagOne = ""
    
    init() {
        readDataFromJsonFile()
    }
    
    func readDataFromJsonFile(){
        var path = Bundle.main.path(forResource: "poem_structure1", ofType: "json")
        var url = URL(fileURLWithPath: path!)
        
        do{
            let data = try Data(contentsOf: url)
            let dic = try JSONDecoder().decode([String:[String]].self, from: data)
            //print(dic)
            
            rules = Array(dic.keys)
            poemStructures = Array(dic.values)
        }
        catch{}
        
        path = Bundle.main.path(forResource: "part_of_sentence1", ofType: "json")
        url = URL(fileURLWithPath: path!)
        do{
            let data = try Data(contentsOf: url)
            partOfSentence = try JSONDecoder().decode([String:[[String]]].self, from: data)
        }
        catch{}
        
        path = Bundle.main.path(forResource: "noun", ofType: "json")
        url = URL(fileURLWithPath: path!)
        do{
            let data = try Data(contentsOf: url)
            nouns = try JSONDecoder().decode([String:[String]].self, from: data)
            //print(nouns)
        }
        catch{}
    }
    
    func generateTopicalPoem(tags: [String])->String{
        tagOne = (tags[0] == "no person" ? tags[1] : tags[0])     //only used for no poem
        var tagsCopy = tags
        var poem = ""
        var poemOptions: [Int : String] = [:]
        
        tagsCopy.append("default")
        for i in 0..<rules.count{
            let r = checkRule(rule: rules[i], tags: tagsCopy)
            
            if(r.0){
                let subRules = rules[i].components(separatedBy: "@")
                poemOptions[r.1] = processPoemStructure(index: i ,subRule: subRules[1],topic: r.2, items: r.3) + "\n\n"
            }
        }
        
        for p in poemOptions.values{
            print(p)
        }
        
        var min = 100
        for key in poemOptions.keys{
            if(key<min){
                min = key
            }
        }
        
        poem = poemOptions[min]!
        
        return poem
    }
    
    func checkRule(rule: String, tags: [String]) -> (Bool, Int, String, [String]){
        var subRules = rule.components(separatedBy: "@")
        let priority = Int(subRules[0])
        let subSubRules = subRules[1].components(separatedBy: "|")
        let category = subRules[2]
        var result:(Bool, Int, String, [String]) = (false, 0, "", [])
        
        for e in subSubRules{
            if(tags.contains(e)){
                result.0 = true
                result.1 = priority!
                result.2 = e
                break
            }
        }
        
        if(category != "nil"){
            for item in nouns[category]!{
                if(tags.contains(item)){
                    result.3.append(item)
                }
            }
        }
        
        return result
    }
    
    func processPoemStructure(index: Int, subRule:String, topic: String, items: [String]) -> String{
        var poem = ""
        let temp = poemStructures[index]
        let poemStructure = temp[Int(arc4random_uniform(UInt32(temp.count)))]
        var partOfPoem = poemStructure.components(separatedBy: " ")
        var counter = 0
        
        for i in 0..<partOfPoem.count{
            var t = partOfPoem[i]
            var firstCharacter = ""
            
            if(t != ""){
                firstCharacter = String(t[t.startIndex])
            }
            
            if(firstCharacter == "@"){
                t.removeFirst()
                let t1 = partOfSentence[subRule]![Int(t)!]
                partOfPoem[i] = t1[Int(arc4random_uniform(UInt32(t1.count)))]
            }
            
            if(firstCharacter == "*"){
                partOfPoem[i] = topic
            }
            
            if(firstCharacter == "#"){
                t.removeFirst()
                
                if(counter < items.count){
                    partOfPoem[i] = items[counter]
                    counter += 1
                }
                else{
                    let ch = t[t.startIndex]
                    
                    if(ch == "@"){
                        t.removeFirst()
                        let t1 = partOfSentence[subRule]![Int(t)!]
                        partOfPoem[i] = t1[Int(arc4random_uniform(UInt32(t1.count)))]
                    }
                    else{
                        partOfPoem[i].removeFirst()
                    }
                }
            }
            
            //only for no poem
            if(firstCharacter == "$"){
                partOfPoem[i] = tagOne
            }
        }
        
        poem = partOfPoem.joined(separator: " ")
        
        return poem
    }
}
