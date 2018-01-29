//
//  PoemGenerator.swift
//  clarifaiApp
//
//  Created by 李阳 on 24/1/18.
//  Copyright © 2018 partywolfAPPS. All rights reserved.
//

import Foundation

class PoemGenerator{
    var rules:[String] = []
    var sentenceArrays:[[String]] = [[]]
    var sentenceIndexes:[Int] = []
    var wordList:[String:[String]] = [:]
    
    init() {
        readDataFromJsonFile()
    }
    
    func readDataFromJsonFile(){
        var path = Bundle.main.path(forResource: "sentences", ofType: "json")
        var url = URL(fileURLWithPath: path!)
        
        do{
            let data = try Data(contentsOf: url)
            let dic = try JSONDecoder().decode([String:[String]].self, from: data)
            
            rules = Array(dic.keys)
            sentenceArrays = Array(dic.values)
            sentenceIndexes = Array(repeating: 0, count: rules.count)
        }
        catch{}
        
        path = Bundle.main.path(forResource: "wordlist", ofType: "json")
        url = URL(fileURLWithPath: path!)
        
        do{
            let data = try Data(contentsOf: url)
            wordList = try JSONDecoder().decode([String:[String]].self, from: data)
        }
        catch{}
    }
    
    func checkSubRule(subRule: String, tags: [String]) -> Bool{
        var subRuleCopy = subRule
        var matchSubRule = true
        
        if(subRuleCopy[subRuleCopy.startIndex] == "!"){
            matchSubRule = false
            subRuleCopy.removeFirst()
        }
        
        let words = subRuleCopy.components(separatedBy: "|")
        for word in words{
            if(tags.contains(word)){
                return matchSubRule
            }
        }
        
        return (matchSubRule ? false : true)
    }
    
    func checkWordList(tags:[String], category: String) -> [String]{
        var words:[String] = []
        
        for tag in tags{
            for word in wordList[category]!{
                if(tag == word){
                    words.append(word)
                    break
                }
            }
        }
        
        return words
    }
    
    func checkRule(rule: String, tags: [String]) -> (Bool, [String]){
        var popularNouns:[String] = []
        var subRules = rule.components(separatedBy: "&")
        var category = subRules.removeLast()
        
        for subRule in subRules{
            if(!checkSubRule(subRule: subRule, tags: tags)){
                return (false, popularNouns)
            }
        }
        
        if(category != "nil"){
            category.removeFirst()
            popularNouns = checkWordList(tags: tags, category: category)
        }
        
        return (true, popularNouns)
    }
    
    func processChosenSentence(chosenSentence: String, popularNouns: [String]) -> String{
        var result = chosenSentence
        let firstCharacter = chosenSentence[chosenSentence.startIndex]
        
        if(firstCharacter == "*"){
            result.removeFirst()
            
            var partsOfSentence = result.components(separatedBy: " ")
            var index = 0
            
            for i in 0..<partsOfSentence.count{
                var part = partsOfSentence[i]
                var flag = ""
                
                if(part != ""){
                    flag = String(part[part.startIndex])
                }
                
                if(flag == "@"){
                    part.removeFirst()
                    let optionalWords = part.components(separatedBy: "/")
                    partsOfSentence[i] = optionalWords[Int(arc4random_uniform(UInt32(optionalWords.count)))]
                }
                else if(flag == "#"){
                    part.removeFirst()
                    
                    if(index < popularNouns.count){
                        partsOfSentence[i] = popularNouns[index]
                        index += 1
                    }
                    else{
                        partsOfSentence[i] = part
                    }
                }
                
                result = partsOfSentence.joined(separator: " ")
            }
        }
        
        return result
    }
    
    func generateTopicalSentence(template: [[String]], index: Int, popularNouns: [String]) -> String{
        var topicalSentence = ""
        let subIndex = sentenceIndexes[index] % (sentenceArrays[index].count)
        let chosenSentence = sentenceArrays[index][subIndex]
        sentenceIndexes[index] += 1
        topicalSentence = processChosenSentence(chosenSentence: chosenSentence, popularNouns: popularNouns)
        
        return topicalSentence
    }
    
    func generateTopicalPoem(tags: [String]) -> String{
        var poem = ""
        for i in 0..<rules.count{
            let r = checkRule(rule: rules[i], tags: tags)
            
            if(r.0){
                let popularNouns = r.1
                poem += generateTopicalSentence(template: sentenceArrays, index: i, popularNouns: popularNouns) + "\n\n"
            }
        }
        
        return (poem != "" ? poem : "no poem")
    }
}
