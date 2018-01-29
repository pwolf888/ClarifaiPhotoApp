//
//  NewPoemGenerator.swift
//  clarifaiApp
//
//  Created by 李阳 on 27/1/18.
//  Copyright © 2018 partywolfAPPS. All rights reserved.
//

import Foundation

class NewPoemGenerator{
    var rules:[String] = []
    var poemStructures:[[String]] = [[]]
    var partOfSentence:[String:[[String]]] = [:]
    var nouns:[String : [String]] = [:]
    
    init() {
        readDataFromJsonFile()
    }
    
    func readDataFromJsonFile(){
        var path = Bundle.main.path(forResource: "poem_structure", ofType: "json")
        var url = URL(fileURLWithPath: path!)
        
        do{
            let data = try Data(contentsOf: url)
            let dic = try JSONDecoder().decode([String:[String]].self, from: data)
            //print(dic)
            
            rules = Array(dic.keys)
            poemStructures = Array(dic.values)
        }
        catch{}
        
        path = Bundle.main.path(forResource: "part_of_sentence", ofType: "json")
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
        var poem = ""
        for i in 0..<rules.count{
            let r = checkRule(rule: rules[i], tags: tags)
            
            if(r.0){
                let subRules = rules[i].components(separatedBy: "@")
                poem += processPoemStructure(index: i, subRule: subRules[0],topic: r.1, items: r.2) + "\n\n"
            }
        }
        
        return (poem != "" ? poem : "no poem")
    }
    
    func checkRule(rule: String, tags: [String]) -> (Bool, String, [String]){
        var subRules = rule.components(separatedBy: "@")
        let subSubRules = subRules[0].components(separatedBy: "|")
        let category = subRules[1]
        var result:(Bool, String, [String]) = (false, "", [])
        
        for e in subSubRules{
            if(tags.contains(e)){
                result.0 = true
                result.1 = e
                break
            }
        }
        
        if(category != "nil"){
            for item in nouns[category]!{
                if(tags.contains(item)){
                    result.2.append(item)
                }
            }
        }
        
        return result
    }
    
    func processPoemStructure(index: Int, subRule:String, topic: String, items: [String]) -> String{
        var poem = ""
        let poemStructure = poemStructures[index][0]
        var partOfPoem = poemStructure.components(separatedBy: " ")
        var counter = 0
        
        for i in 0..<partOfPoem.count{
            var t = partOfPoem[i]
            let firstCharacter = t[t.startIndex]
            
            if(firstCharacter == "@"){
                t.removeFirst()
                let t1 = partOfSentence[subRule]![Int(t)!]
                partOfPoem[i] = t1[Int(arc4random_uniform(UInt32(t1.count)))]
            }
            
            if(firstCharacter == "*"){
                partOfPoem[i] = topic
            }
            
            if(firstCharacter == "#"){
                
                if(counter < items.count){
                    partOfPoem[i] = items[counter]
                    counter += 1
                }
                else{
                    partOfPoem[i].removeFirst()
                }
            }
        }
        
        poem = partOfPoem.joined(separator: " ")
        
        return poem
    }
}

