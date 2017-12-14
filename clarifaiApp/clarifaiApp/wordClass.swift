////
////  wordClass.swift
////  clarifaiApp
////
////  Created by Jonathan Turnbull on 14/12/17.
////  Copyright © 2017 partywolfAPPS. All rights reserved.
////
//
//import UIKit
//import Foundation
//
//class wordClass {
//
//    //identify word class for each word in sentence
//    func getWordClass(text: String, language: String = "en")->[String:[String]]{
//
//        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
//        let schemes = NSLinguisticTagger.availableTagSchemes(forLanguage: language)
//        let tagger = NSLinguisticTagger(tagSchemes: schemes, options: Int(options.rawValue))
//
//        var words = [String:[String]]()
//
//        tagger.string = text
//        let string = text as NSString
//        let range = NSRange(location: 0, length: string.length)
//        let scheme = NSLinguisticTagScheme.nameTypeOrLexicalClass
//
//        tagger.enumerateTags(in: range, scheme: scheme, options: options) { (tag, tokenRange, _, _) in
//            let token = string.substring(with: tokenRange)
//
//            if(words[tag!.rawValue] == nil){
//                words[tag!.rawValue] = [String]()
//            }
//            words[tag!.rawValue]!.append(token)
//        }
//
//        return words
//    }
//
//    //if there aren't enough  adj/verb/adverb in image tags for us to choose from, we can use those supplement
//    let wordSupplement = ["Adjective":["sweet", "beautiful", "bright", "shining", "brilliant", "wonderful", "gigantic", "huge", "little", "amazing", "great", "shy", "lazy", "exciting", "slow", "smooth", "soft", "warm"], "Verb":["run", "walk", "jump", "fly", "laugh", "smile", "sing", "rise", "cry", "swim", "climb", "burn", "eat", "push", "sit", "look"], "Adverb":["happily", "excitedly", "cheerfully", "lightly", "alone", "fast", "gladly", "swiftly", "shyly", "brightly", "silently", "lazily", "excitingly", "slowly", "smoothly", "softly", "warmly"]]
//
//    //select a specific type of word from the image tags
//    func selectRandomWord(wordClass:String, imageTags:[String:[String]])->String{
//        if(imageTags[wordClass] == nil){
//            let len = wordSupplement[wordClass]!.count
//            let random = Int(arc4random_uniform(UInt32(len)))
//
//            return wordSupplement[wordClass]![random]
//        }
//        else{
//            let len = imageTags[wordClass]!.count
//            let random = Int(arc4random_uniform(UInt32(len)))
//
//            return imageTags[wordClass]![random]
//        }
//    }
//
//    //define article(a/an) before word
//    func getArticle(word: String)->String{
//        var firstCharacter = ""
//        firstCharacter.append(word[word.startIndex])
//        let vowels = ["a", "e", "i", "o", "u"]
//
//        for i in 0..<vowels.count{
//            if(firstCharacter.lowercased() == vowels[i]){
//                return "an"
//            }
//        }
//
//        return "a"
//    }
//
//    //image tags
//    let words = getWordClass(text: "computer language speak RAM gigabytes ROM cpu", language: "en")
//
//    for (wordClass, wordArray) in words{
//    print("\(wordClass): \(wordArray)")
//    }
//
//    /*poem structure 1
//     I am in the {0:noun}, it is so {1:adj}
//     What a/an {2:adj} {3:noun}
//     I cannot erase this {4:noun} in my mind
//     Just {5: adv} {6:verb}ing
//     */
//    func generatePoem1()->String{
//        /*print poem structure*/
//        print("Poem Structure:\n")
//        print("I am in the {0:noun}, it is so {1:adj}\nWhat a/an {2:adj} {3:noun}\nI cannot erase this {4:noun} in my mind\nJust {5: adv}{6:verb}ing\n")
//        print("Poem:\n")
//
//        let wordClasses = ["Noun", "Adjective", "Adjective", "Noun", "Noun", "Adverb", "Verb"]
//        var chosenWords = [String]()
//        for i in 0..<wordClasses.count{
//            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
//        }
//        var poem = "I am in the " + chosenWords[0] + ", it is so " + chosenWords[1] + ".\n"
//        poem += "What " + getArticle(word: chosenWords[2]) + " " + chosenWords[2] + " " + chosenWords[3]
//        poem += "\nI cannot erase that " + chosenWords[4] + " in my mind\n"
//        poem += "Just " + chosenWords[5] + " " + chosenWords[6] + "ing"
//
//        return poem
//    }
//
//    /*poem structure 2
//     Never ever I have seen
//     The {0: noun} so {1: adj},
//     The {2: adj}, {3: adj} {4: noun}
//     Where {5: noun} do {6: verb}.
//     */
//    func generatePoem2()->String{
//        /*print poem structure*/
//        print("Poem Structure:\n")
//        print("Never ever I have seen\nThe {0: noun} so {1: adj},\nThe {2: adj}, {3: adj} {4: noun}\nWhere {5: noun} do {6: verb}.\n")
//        print("Poem:\n")
//
//        let wordClasses = ["Noun", "Adjective", "Adjective", "Adjective", "Noun", "Noun", "Verb"]
//        var chosenWords = [String]()
//        for i in 0..<wordClasses.count{
//            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
//        }
//
//        var poem = "Never ever I have seen\n"
//        poem += "The " + chosenWords[0] + " so " + chosenWords[1] + " ,\n"
//        poem += "The " + chosenWords[2] + ", " + chosenWords[3] + " " + chosenWords[4] + "\n"
//        poem += "Where " + chosenWords[5] + " do " + chosenWords[6]
//
//        return poem
//    }
//
//    /*poem structure 3
//     {0: adj} {1: adj} {2: noun}
//     And {3: adj} {4: noun}
//     {5: verb} its {6: noun}
//     And {7: verb}ing {8: adv} in the {9: noun}
//
//     example:
//     Sweet red roses,
//     And golden sunflowers,
//     Tossing their heads
//     And dancing merrily in the breeze.
//     */
//    func generatePoem3()->String{
//        /*print poem structure*/
//        print("Poem Structure:\n")
//        print("{0: adj} {1: adj} {2: noun}\nAnd {3: adj} {4: noun}\n{5: verb} its {6: noun}\nAnd {7: verb}ing {8: adv} in the {9: noun}\n")
//        print("Poem:\n")
//
//        let wordClasses = ["Adjective", "Adjective", "Noun", "Adjective", "Noun", "Verb", "Noun", "Verb", "Adverb", "Noun"]
//        var chosenWords = [String]()
//        for i in 0..<wordClasses.count{
//            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
//        }
//
//        var poem = chosenWords[0] + " " + chosenWords[1] + " " + chosenWords[2] + "\n"
//        poem += "And " + chosenWords[3] + " " + chosenWords[4] + ",\n"
//        poem += chosenWords[5] + " its " + chosenWords[6] + "\n"
//        poem += "And " + chosenWords[7] + "ing " + chosenWords[8] + " in the " + chosenWords[9]
//
//        return poem
//    }
//
//    print("\n-------------------The Poem1----------------")
//    print(generatePoem1())
//    print("")
//
//    print("\n-------------------The Poem2----------------")
//    print(generatePoem2())
//    print("")
//
//    print("\n-------------------The Poem3----------------")
//    print(generatePoem3())
//    print("")
//
//
//}
//
