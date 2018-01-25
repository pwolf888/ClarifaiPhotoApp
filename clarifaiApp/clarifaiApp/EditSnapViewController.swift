//
//  EditSnapViewController.swift
//  clarifaiApp
//
//  Created by Erin Abrams on 17/1/18.
//  Copyright © 2018 partywolfAPPS. All rights reserved.
//

import UIKit
import Clarifai
import SnapKit
import Foundation
import AVFoundation
import Social

class EditSnapViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    // Declaring Variables - Globals
    var app:ClarifaiApp?
    let picker = UIImagePickerController()
    var poems = [String]()
    var loaded = false
    var tagOne = "no poem"
    var newImage: UIImage!
    var savedImage: UIImage!
    var selectedFontSize = 24
    var selectedFont = String()
    var iconSize = 40

    @IBOutlet weak var snapoetryLoader: UIImageView!
    
    // Photo options
    @IBOutlet weak var backNavButton: UIButton!
    @IBOutlet weak var shareNavButton: UIButton!
    @IBOutlet weak var savePhoto: UIButton!
    @IBOutlet weak var fontStyle: UIButton!
    @IBOutlet weak var textColour: UIButton!
    @IBOutlet weak var poeticText: UITextView!
    @IBOutlet weak var photoTaken: UIImageView!
    @IBOutlet weak var fontSize: UIButton!
    
    // edit poem text colour options
    @IBOutlet weak var colourBlack: UIButton!
    @IBOutlet weak var colourWhite: UIButton!
    @IBOutlet weak var colourBlue: UIButton!
    @IBOutlet weak var colourYellow: UIButton!
    @IBOutlet weak var colourRed: UIButton!
    @IBOutlet weak var colourGreen: UIButton!
    @IBOutlet weak var colourOrange: UIButton!
    @IBOutlet weak var colourPurple: UIButton!
    
     // edit poem font options
    @IBOutlet weak var font1: UIButton!
    @IBOutlet weak var font2: UIButton!
    @IBOutlet weak var font3: UIButton!
    @IBOutlet weak var font4: UIButton!
    @IBOutlet weak var font5: UIButton!
    @IBOutlet weak var font6: UIButton!
    
    // edit font size options
    @IBOutlet weak var smallText: UIButton!
    @IBOutlet weak var mediumText: UIButton!
    @IBOutlet weak var largeText: UIButton!

    
    //Views that handle the edit poetrytext buttons
    @IBOutlet weak var changeFontView: UIView!
    @IBOutlet weak var changeFontSizeView: UIView!
    @IBOutlet weak var changeColourView: UIView!
    override func viewDidLoad() {
        
        
        
        photoTaken.image = newImage
        
        setupPhotoUI()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Declare my api key
        app = ClarifaiApp(apiKey: "ab5e1c0750f14e5685e24b243de99d27")
        
        recognizeImage(image: newImage)
        snapoetryLoader.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // Recognize the Image with Clarifai
    func recognizeImage(image: UIImage) {
        
        
        // Check that the application was initialized correctly.
        if let app = app {
            
            // Fetch Clarifai's general model.
            app.getModelByName("general-v1.3", completion: { (model, error) in
                
                // Create a Clarifai image from a uiimage.
                let caiImage = ClarifaiImage(image: image)!
                
                // Use Clarifai's general model to pedict tags for the given image.
                model?.predict(on: [caiImage], completion: { (outputs, error) in
                    print("%@", error ?? "no error")
                    guard
                        let caiOuputs = outputs
                        else {
                            print("Predict failed")
                            return
                    }
                    
                    if let caiOutput = caiOuputs.first {
                        // Loop through predicted concepts (tags), and display them on the screen.
                        let tags = NSMutableArray()
                        for concept in caiOutput.concepts {
                            
                            // Removes the tag "no person" as it was causing problems
                            if ( concept.conceptName! == "no person" ){
                                tags.remove(concept.conceptName)
                            } else {
                                tags.add("It is \(concept.conceptName!)")
                                
                                
                            }
                            
                        }
                        
                        // Wait for the API to load before outputing to screen
                        DispatchQueue.main.async {
                            // Update the new tags in the UI.
                            //self.textView.text = String(format: "Tags: ", tags.componentsJoined(by: " "))
                            
                            
                            // Take all the tags and push them into a string
                            
                            self.tagOne = "\(tags)"
                            
                            print(tags)
                            // Send tag to our API to generate poetry
                            //self.getRequest(poemName: self.tagOne)
                            
                            //Check if list of tags contains one of our key topics, to generate relevant poem
                            if (self.tagOne.contains("animal")){
                                print("Poem topic identified as Animals")
                                self.generateAnimal1()
                            }
                            else if (self.tagOne.contains("nature")){
                                print("Poem topic identified as Nature")
                                self.generateNature1()
                            }
                            else if (self.tagOne.contains("people")){
                                print("Poem topic identified as People")
                                self.generatePeople1()
                            }
                            else {
                                print("Poem topic not identified")
                                self.generatePoem2()
                            }
                            
                        }
                        
                    }
                    
                    // Once finished enable buttons again
                    DispatchQueue.main.async {
                        
                        UIView.animate(withDuration: 0.2, animations: {
                            self.snapoetryLoader.alpha = 0
                        })
                        
                    }
                    
                })
            })
        }
        
    }
    
    //identify word class for each word in sentence
    func getWordClass(text: String, language: String = "en")->[String:[String]]{
        
        // Disregards the unimportant things inside the text ie. gaps, puncuation etc..
        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        // Chooses a language english
        let schemes = NSLinguisticTagger.availableTagSchemes(forLanguage: language)
        // Tags will be english and the options will be disregarded.
        let tagger = NSLinguisticTagger(tagSchemes: schemes, options: Int(options.rawValue))
        
        var words = [String:[String]]()
        
        // Text perameter becomes a tagger string
        tagger.string = text
        // Text is then converted to NSString
        let tmpString = text as NSString
        // The range is the max length of tmpString
        let range = NSRange(location: 0, length: tmpString.length)
        
        // The tagger beginners classing the words inside the tmpString with Noun, Verb, Adj etc
        tagger.enumerateTags(in: range, scheme: NSLinguisticTagSchemeNameTypeOrLexicalClass, options: options) { (tag, tokenRange, _, _) in
            
            let token = tmpString.substring(with: tokenRange)
            
            if(words[tag] == nil){
                words[tag] = [String]()
            }
            
            words[tag]!.append(token)
            
        }
        
        return words
    }
    
    
    //if there aren't enough  adj/verb/adverb in image tags for us to choose from, we can use those supplement
    let wordSupplement = ["Adjective":["sweet", "beautiful", "bright", "shining", "brilliant", "wonderful", "gigantic", "huge", "little", "amazing", "great", "shy", "lazy", "exciting", "slow", "smooth", "soft", "warm"], "Verb":["run", "walk", "jump", "fly", "laugh", "smile", "sing", "rise", "cry", "swim", "climb", "burn", "eat", "push", "sit", "look"], "Adverb":["happily", "excitedly", "cheerfully", "lightly", "alone", "fast", "gladly", "swiftly", "shyly", "brightly", "silently", "lazily", "excitingly", "slowly", "smoothly", "softly", "warmly"], "Pronoun":["he","she","they"], "Detirminer":["the", "every", "this", "those", "that", "many", "my", "his", "hers", "yours"]]
    
    //select a specific type of word from the image tags
    func selectRandomWord(wordClass:String, imageTags:[String:[String]])->String{
        
        if(imageTags[wordClass] == nil){
            let len = wordSupplement[wordClass]!.count
            let random = Int(arc4random_uniform(UInt32(len)))
            
            return wordSupplement[wordClass]![random]
        }
        else{
            let len = imageTags[wordClass]!.count
            let random = Int(arc4random_uniform(UInt32(len)))
            
            return imageTags[wordClass]![random]
        }
    }
    
    //define article(a/an) before word
    func getArticle(word: String)->String{
        var firstCharacter = ""
        firstCharacter.append(word[word.startIndex])
        let vowels = ["a", "e", "i", "o", "u"]
        
        for i in 0..<vowels.count{
            if(firstCharacter.lowercased() == vowels[i]){
                return "an"
            }
        }
        
        return "a"
    }
    
    
    
    //    for (wordClass, wordArray) in words{
    //    print("\(wordClass): \(wordArray)")
    //    }
    
    /*poem structure 1
     I am in the {0:noun}, it is so {1:adj}
     What a/an {2:adj} {3:noun}
     I cannot erase this {4:noun} in my mind
     Just {5: adv} {6:verb}ing
     */
    
    func generatePoem1()->String{
        //image tags
        print(tagOne)
        let words = getWordClass(text: tagOne, language: "en")
        print(words)
        
        let wordClasses = ["Noun", "Adjective", "Adjective", "Noun", "Noun", "Adverb", "Verb"]
        var chosenWords = [String]()
        for i in 0..<wordClasses.count{
            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
        }
        var poem = "I am in the " + chosenWords[0] + ", it is so " + chosenWords[1] + ".\n"
        poem += "What " + getArticle(word: chosenWords[2]) + " " + chosenWords[2] + " " + chosenWords[3]
        poem += "\nI cannot erase that " + chosenWords[4] + " in my mind\n"
        poem += "Just " + chosenWords[5] + " " + chosenWords[6] + "ing"
        
        
        // Output to text view element
        self.poeticText.text = "\(poem)"
        print("\(poem)")
        return poem
    }
    
    /*poem structure 2
     The {0:noun} {1:verb} in the {2:noun}
     Without {3:determiner} {4:adjective} or {5:adjective}
     {6:Pronoun} {7:adverb} the {8:noun}"
     */
    
    func generatePoem2()->String{
        //image tags
        print(tagOne)
        let words = getWordClass(text: tagOne, language: "en")
        print(words)
        /*print poem structure*/
        print("Poem Structure:\n")
        
        print("The {noun} {verb} in the {noun}\nWithout {determiner} {adjective} or {adjective}\n{Pronoun} {adverb} the {noun}")
        print("Poem:\n")
        
        let wordClasses = ["Noun", "Verb", "Noun", "Detirminer", "Adjective", "Adjective", "Pronoun", "Verb", "Noun",]
        var chosenWords = [String]()
        for i in 0..<wordClasses.count{
            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
        }
        var poem = "The " + chosenWords[0] + " " + chosenWords[1] + " in the " + chosenWords[2]
        poem += ".\n Without " + chosenWords[3] + " " + chosenWords[4] + " or " + chosenWords[5] + ".\n"
        poem += chosenWords[6] + " " + chosenWords[7] + " the " + chosenWords[8]
        
        
        
        // Output to text view element
        self.poeticText.text = "\(poem)"
        
        return poem
    }
    
    
    /*
     Animal poem structure #1
     {0:adj} {1:noun}, with your eyes so {2:adj}
     You see the {3:noun} so {4:adj} and {5:adj}
     Time to {6:verb}, so much to {7:verb}
     */
    
    func generateAnimal1()->String{
        //image tags
        print(tagOne)
        let words = getWordClass(text: tagOne, language: "en")
        
        print(words)
        
        let wordClasses = ["Adjective", "Noun", "Adjective", "Noun", "Adjective", "Adjective", "Verb", "Verb"]
        var chosenWords = [String]()
        for i in 0..<wordClasses.count{
            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
        }
        var poem =  getArticle(word: chosenWords[0]) + " " + chosenWords[0] + " " + chosenWords[1] + ", with your eyes so " + chosenWords[2] + ", \n"
        poem += "You see the " + chosenWords[3] + " so " + chosenWords[4] + " and " + chosenWords[5] + ", \n"
        poem += "Time to " + chosenWords[6] + ", so much to " + chosenWords[7] + "."
        
        print(getArticle(word: chosenWords[0]))
        print(chosenWords[0])
        print(chosenWords[1])
        // Output to text view element
        self.poeticText.text = "\(poem)"
        print("\(poem)")
        return poem
    }
    
    /*
     Animal poem structure #2
     I have a {0:adj} {1:noun}
     Most {2: adj} for miles around
     Wherever there’s lots of {3:noun}
     That’s where he’ll {4:verb}
     
     */
    func generateAnimal2()->String{
        //image tags
        print(tagOne)
        let words = getWordClass(text: tagOne, language: "en")
        print(words)
        
        let wordClasses = ["Noun", "Adjective", "Adjective", "Noun", "Noun", "Adverb", "Verb"]
        var chosenWords = [String]()
        for i in 0..<wordClasses.count{
            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
        }
        var poem = "I am in the " + chosenWords[0] + ", it is so " + chosenWords[1] + ".\n"
        poem += "What " + getArticle(word: chosenWords[2]) + " " + chosenWords[2] + " " + chosenWords[3]
        poem += "\nI cannot erase that " + chosenWords[4] + " in my mind\n"
        poem += "Just " + chosenWords[5] + " " + chosenWords[6] + "ing"
        
        
        // Output to text view element
        self.poeticText.text = "\(poem)"
        print("\(poem)")
        return poem
    }
    
    /*
     Nature poem structure #1
     Let your eyes consume the beauty of {0:noun}
     Let {1: adj} {2:noun} soothe your mind
     You’ll feel the aloha spirit—
     A more {3:adj} {4:noun} you won’t find
     
     */
    func generateNature1()->String{
        //image tags
        print(tagOne)
        let words = getWordClass(text: tagOne, language: "en")
        print(words)
        
        let wordClasses = ["Noun", "Adjective", "Adjective", "Noun", "Noun", "Adverb", "Verb"]
        var chosenWords = [String]()
        for i in 0..<wordClasses.count{
            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
        }
        var poem = "I am in the " + chosenWords[0] + ", it is so " + chosenWords[1] + ".\n"
        poem += "What " + getArticle(word: chosenWords[2]) + " " + chosenWords[2] + " " + chosenWords[3]
        poem += "\nI cannot erase that " + chosenWords[4] + " in my mind\n"
        poem += "Just " + chosenWords[5] + " " + chosenWords[6] + "ing"
        
        
        // Output to text view element
        self.poeticText.text = "\(poem)"
        print("\(poem)")
        return poem
    }
    
    
    /*
     Nature poem structure #2
     {0:noun} is such a {1:adj} sight,
     With {2:adj} {3:noun} and {4:adj} {5:noun}
     An abundance of {6:noun}, what pure delight
     */
    
    func generateNature2()->String{
        //image tags
        print(tagOne)
        let words = getWordClass(text: tagOne, language: "en")
        print(words)
        
        let wordClasses = ["Noun", "Adjective", "Adjective", "Noun", "Adjective", "Noun", "Noun"]
        var chosenWords = [String]()
        for i in 0..<wordClasses.count{
            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
        }
        var poem = chosenWords[0] + " is such a " + chosenWords[1] + " sight,"
        poem += "\nWith " + chosenWords[2] + " " + chosenWords[3] + " and " + chosenWords[4] + " " + chosenWords[5]
        poem += "\nWith " + chosenWords[6] + " in my mind"
        poem += "\nAn abundance of " + chosenWords[7] + " what pure delight."
        
        
        // Output to text view element
        self.poeticText.text = "\(poem)"
        print("\(poem)")
        return poem
    }
    
    /*
     Room poem structure #1
     A {0:adj} {1:noun}
     A {2:adj} {3:adj} room
     With {4:noun} and {5:noun} tossed throughout
     Where does that {6:adj} {7:noun} come from ?
     */
    
    func generateRoom1()->String{
        //image tags
        print(tagOne)
        let words = getWordClass(text: tagOne, language: "en")
        print(words)
        
        let wordClasses = ["Adjective", "Noun", "Adjective", "Adjective", "Noun", "Noun", "Adjective", "Noun"]
        var chosenWords = [String]()
        for i in 0..<wordClasses.count{
            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
        }
        var poem = "A " + chosenWords[0] + " " + chosenWords[1]
        poem += "\n" + chosenWords[2] + " " + chosenWords[3] + " room "
        poem += "\nWith " + chosenWords[4] + " and " + chosenWords[5] + " tossed throughout"
        poem += "\nWhere does that " + chosenWords[6] + " " + chosenWords[7] + " come from?"
        
        
        // Output to text view element
        self.poeticText.text = "\(poem)"
        print("\(poem)")
        return poem
    }
    
    /*
     People poem structure #1
     {0:adj} {1:adj} eyes embedded in the {2:adj} face
     A {4:adj} mouth beneath {3:adj} nose
     The most {5:adj} person ever known
     Your {6:adj} {7:noun} lit up the New York City
     */
    
    func generatePeople1()->String{
        //image tags
        print(tagOne)
        let words = getWordClass(text: tagOne, language: "en")
        print(words)
        
        let wordClasses = ["Adjective", "Adjective", "Adjective", "Adjective", "Adjective", "Adjective", "Adjective", "Noun"]
        var chosenWords = [String]()
        for i in 0..<wordClasses.count{
            chosenWords.append(selectRandomWord(wordClass: wordClasses[i], imageTags: words))
        }
        var poem = chosenWords[0] + " " + chosenWords[1] + " eyes embedded in the " + chosenWords[2] + " face"
        poem += "\nA " + chosenWords[2] + " mouth beneath " + chosenWords[2] + " nose "
        poem += "\nThe most " + chosenWords[3] + " person ever known "
        poem += "\nYour " + chosenWords[5] + " " + chosenWords[6] + " blushes like a rose"
        
        
        // Output to text view element
        self.poeticText.text = "\(poem)"
        print("\(poem)")
        return poem
    }
    
    
    // Social media sharing button - Allows user to share to facebook
    @IBAction func facebookButton(_ sender: AnyObject) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
            
            let fbShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            //call function to combine text and image as one object
            let shareImage = textToImage(drawText: poeticText.text! as NSString, inImage: newImage!, atPoint: CGPoint(x: UIScreen.main.bounds.size.width*0.5,y: UIScreen.main.bounds.size.height*0.5))
            
            fbShare.add(shareImage)
            
            self.present(fbShare, animated: true, completion: nil)
            
        } else {
            
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    
    @IBAction func selectFont(_ sender: UIButton) {
        
        //call function to present user with text colour options
        print("User has selected to change font")
        changeFontSizeView.isHidden = true
        changeColourView.isHidden = true
        bringChangeFontToView()
    }
    
    @IBAction func selectTextColour(_ sender: UIButton) {
        
        //call function to present user with text colour options
        print("User has selected to change colour")
        changeFontView.isHidden = true
        changeFontSizeView.isHidden = true
        bringChangeColourToView()
    }
    
    @IBAction func selectFontSize(_ sender: Any) {
        
        //call function to present user with text colour options
        print("User has selected to change text size")
        changeColourView.isHidden = true
        changeFontView.isHidden = true
        bringFontSizeToView()
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        
        // Dismiss the Change Text colour view if user doesnt select a colour
        if touch?.view != changeColourView {
            changeColourView.isHidden = true
        }
        
        // Dismiss the Change Font view if user doesnt select a font
        if touch?.view != changeColourView {
            changeFontView.isHidden = true
        }
        
        // Dismiss the Change Size view if user doesnt select a size
        if touch?.view != changeColourView {
            changeFontSizeView.isHidden = true
        }
    }
    
    @IBAction func changeTextColour(_ sender: UIButton) {
        
        switch sender.tag{
        case 0:
            poeticText.textColor = UIColor.black
            changeColourView.isHidden = true
            break;
        case 1:
            poeticText.textColor = UIColor.white
            changeColourView.isHidden = true
            break;
        case 2:
            poeticText.textColor = UIColor.textPurple
            changeColourView.isHidden = true
            break;
        case 3:
            poeticText.textColor = UIColor.textBlue
            changeColourView.isHidden = true
            break;
        case 4:
            poeticText.textColor = UIColor.textGreen
            changeColourView.isHidden = true
            break;
        case 5:
            poeticText.textColor = UIColor.textYellow
            changeColourView.isHidden = true
            break;
        case 6:
            poeticText.textColor = UIColor.textOrange
            changeColourView.isHidden = true
            break;
        case 7:
            poeticText.textColor = UIColor.textRed
            changeColourView.isHidden = true
            break;
        default: ()
        break;
        }
    }
    
    @IBAction func changeFont(_ sender: UIButton) {
        
        switch sender.tag{
        case 0:
            changeFontView.isHidden = true
            selectedFont = "HelveticaNeue-UltraLight"
            poeticText.font = UIFont(name: selectedFont, size: CGFloat(selectedFontSize))!
            break;
        case 1:
            changeFontView.isHidden = true
            selectedFont = "MarkerFelt-Thin"
            poeticText.font = UIFont(name: selectedFont, size: CGFloat(selectedFontSize))!
            break;
        case 2:
            changeFontView.isHidden = true
            selectedFont = "AmericanTypewriter"
            poeticText.font = UIFont(name: selectedFont, size: CGFloat(selectedFontSize))!
            break;
        case 3:
            changeFontView.isHidden = true
            selectedFont = "Noteworthy-Light"
            poeticText.font = UIFont(name: selectedFont, size: CGFloat(selectedFontSize))!
            break;
        case 4:
            changeFontView.isHidden = true
            selectedFont = "Avenir-Book"
            poeticText.font = UIFont(name: selectedFont, size: CGFloat(selectedFontSize))!
            break;
        case 5:
            changeFontView.isHidden = true
            selectedFont = "Copperplate-Light"
            poeticText.font = UIFont(name: selectedFont, size: CGFloat(selectedFontSize))!
            break;
        default: ()
        break;
        }
    }
    
    @IBAction func changeFontSize(_ sender: UIButton) {
        
        switch sender.tag{
        case 0:
            changeFontSizeView.isHidden = true
            selectedFontSize = 24
            poeticText.font = poeticText.font?.withSize(CGFloat(selectedFontSize))
            break;
        case 1:
            changeFontSizeView.isHidden = true
            selectedFontSize = 30
            poeticText.font = poeticText.font?.withSize(CGFloat(selectedFontSize))
            break;
        case 2:
            changeFontSizeView.isHidden = true
            selectedFontSize = 36
            poeticText.font = poeticText.font?.withSize(CGFloat(selectedFontSize))
            break;
        default: ()
        break;
        }
    }
    
    
    
    // Save the users photo
    @IBAction func savePhoto(_ sender: Any) {
        
        //call function to combine text and image as one object
        textToImage(drawText: poeticText.text! as NSString, inImage: newImage!, atPoint: CGPoint(x: UIScreen.main.bounds.size.width*0.5,y: UIScreen.main.bounds.size.height*0.5))

        do {
            let imageData = try UIImagePNGRepresentation(savedImage)
            let compressedImage = UIImage(data: imageData!)
            UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil, nil)

            let savedPhotoAction = UIAlertAction(title: "Awesome!",
            style: .default) { (action) in }
            // Create and configure the alert controller.
            let alert = UIAlertController(title: "Snapoetry",
                                          message: "Image Saved!",
                                          preferredStyle: .alert)
            alert.addAction(savedPhotoAction)

            self.present(alert, animated: true) {
                // The alert was presented

            }

            } catch {
                print("Did not save")
            }

        }
    
        
    func textToImage(drawText text: NSString, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {

        // pull the current user selected text format
        let selectedTextColor = poeticText.textColor
        let fontToDraw = UIFont(name: selectedFont, size: (poeticText.font?.pointSize)!)!
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        //** code implemented to change text alignment to center, and add spacing between text
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 1.2
        paraStyle.alignment = NSTextAlignment.center;
        
        
        let textFontAttributes = [
            NSFontAttributeName: fontToDraw,
            NSParagraphStyleAttributeName: paraStyle,
            NSForegroundColorAttributeName: selectedTextColor as Any,
            ] as [String : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        savedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return savedImage!
    }
    

    
    
    
// <-- REDIRECT THIS METHOD TO OTHER VC
   @IBAction func cancelSnap(_ sender: UIButton) {
        // Confirm Cancellation.

        print("User pressed back")
        let defaultAction = UIAlertAction(title: "Okay",
                                          style: .default) { (action) in
                                            // Respond to user selection of the action.
                                            //self.setupInitialUI()
                                            let cameraVC = self.storyboard!.instantiateViewController(withIdentifier: "cameraVC") as! CameraViewController
                                            
                                            self.present(cameraVC, animated: true, completion: nil)

        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel) { (action) in
                                            // Respond to user selection of the action.
        }

        // Create and configure the alert controller.
        let alert = UIAlertController(title: "Cancel",
                                      message: "All changes will be lost. Continue?",
                                      preferredStyle: .alert)
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true) {
            // The alert was presented

        }

    }
    
    
    func setupPhotoUI(){
        
        //** CONFIGURE OVERALL LAYOUT
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        //** CONFIGURE PHOTO DISPLAYED VIEW
        contentView.addSubview(photoTaken)
        photoTaken.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(contentView)
            make.left.right.equalTo(contentView)
        }

        //*** SHARE BUTTON
        contentView.addSubview(shareNavButton)
        contentView.bringSubview(toFront: shareNavButton)
        shareNavButton.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }

        //*** BACK BUTTON
        contentView.addSubview(backNavButton)
        contentView.bringSubview(toFront: backNavButton)
        backNavButton.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(10)
            make.centerY.equalTo(shareNavButton.snp.centerY)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }

        //*** SAVE BUTTON
        contentView.addSubview(savePhoto)
        contentView.bringSubview(toFront: savePhoto)
        savePhoto.snp.makeConstraints { (make) in
            make.centerX.equalTo(photoTaken.snp.centerX)
            make.centerY.equalTo(shareNavButton.snp.centerY)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }

        //*** POETIC TEXT
        photoTaken.addSubview(poeticText)
        poeticText.font = UIFont(name: "HelveticaNeue-Light", size: 24.0)
        poeticText.textAlignment = NSTextAlignment.center
        poeticText.textColor = .black
        poeticText.layer.shadowColor = UIColor.black.cgColor
        poeticText.layer.shadowOpacity = 0.9
        poeticText.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)

        photoTaken.bringSubview(toFront: poeticText)
        poeticText.snp.makeConstraints { (make) in
            make.left.right.equalTo(photoTaken).inset(20)
            make.top.equalTo(photoTaken).offset(40)
            make.bottom.equalTo(photoTaken).offset(-40)

        }

        //** CONFIGURE COLOUR BUTTON SINGLE
        contentView.addSubview(textColour)
        contentView.bringSubview(toFront: textColour)
        textColour.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView.snp.bottom).offset(-15)
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.height.width.equalTo(iconSize)
        }
        
        //** CONFIGURE FONT BUTTON SINGLE
        contentView.addSubview(fontStyle)
        contentView.bringSubview(toFront: fontStyle)
        fontStyle.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView.snp.bottom).offset(-15)
            make.right.equalTo(textColour.snp.left).offset(-10)
            make.height.width.equalTo(iconSize)
        }
        
        //** CONFIGURE FONT SIZE BUTTON SINGLE
        contentView.addSubview(fontSize)
        contentView.bringSubview(toFront: fontSize)
        fontSize.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView.snp.bottom).offset(-15)
            make.right.equalTo(fontStyle.snp.left).offset(-10)
            make.height.width.equalTo(iconSize)
        }
        
        //** CONFIGURE LOADING ANIMATION
        snapoetryLoader.image = UIImage.animatedImageNamed("eyelash_", duration: 1.0)
        contentView.addSubview(snapoetryLoader)
        contentView.bringSubview(toFront: snapoetryLoader)
        snapoetryLoader.snp.makeConstraints { (make) in
            make.center.equalTo(contentView.snp.center)
        }
    }
    
    func bringChangeFontToView()
    {
        // create view to house all colours
        changeFontView.isHidden = false
        view.addSubview(changeFontView)
        view.bringSubview(toFront: changeFontView)
        changeFontView.snp.makeConstraints { (make) in
            make.right.equalTo(view.snp.right).offset(-10)
            make.width.equalTo(view).multipliedBy(0.1)
            make.bottom.equalTo(textColour.snp.top).offset(-10)
            make.height.equalTo(view.snp.height)
        }
        
        // lay out each font button within view
        changeFontView.addSubview(font1)
        changeFontView.bringSubview(toFront: font1)
        font1.setTitle("Aa", for: .normal)
        font1.snp.makeConstraints { (make) in
            make.right.equalTo(changeFontView.snp.right)
            make.bottom.equalTo(changeFontView.snp.bottom)
            make.height.width.equalTo(40)
        }

        changeFontView.addSubview(font2)
        changeFontView.bringSubview(toFront: font2)
        font2.setTitle("Aa", for: .normal)
        font2.snp.makeConstraints { (make) in
            make.right.equalTo(changeFontView.snp.right)
            make.bottom.equalTo(font1.snp.top)
            make.height.width.equalTo(40)
        }
        
        changeFontView.addSubview(font3)
        changeFontView.bringSubview(toFront: font3)
        font3.setTitle("Aa", for: .normal)
        font3.snp.makeConstraints { (make) in
            make.right.equalTo(changeFontView.snp.right)
            make.bottom.equalTo(font2.snp.top).offset(-5)
            make.height.width.equalTo(40)
        }
        
        changeFontView.addSubview(font4)
        changeFontView.bringSubview(toFront: font4)
        font4.setTitle("Aa", for: .normal)
        font4.snp.makeConstraints { (make) in
            make.right.equalTo(changeFontView.snp.right)
            make.bottom.equalTo(font3.snp.top).offset(-5)
            make.height.width.equalTo(40)
        }
        
        changeFontView.addSubview(font5)
        changeFontView.bringSubview(toFront: font5)
        font5.setTitle("Aa", for: .normal)
        font5.snp.makeConstraints { (make) in
            make.right.equalTo(changeFontView.snp.right)
            make.bottom.equalTo(font4.snp.top).offset(-5)
            make.height.width.equalTo(40)
        }
        
        changeFontView.addSubview(font6)
        changeFontView.bringSubview(toFront: font6)
        font6.setTitle("Aa", for: .normal)
        font6.snp.makeConstraints { (make) in
            make.right.equalTo(changeFontView.snp.right)
            make.bottom.equalTo(font5.snp.top).offset(-5)
            make.height.width.equalTo(40)
        }
        
    }
    
    func bringFontSizeToView()
    {
        // create view to house all colours
        changeFontSizeView.isHidden = false
        view.addSubview(changeFontSizeView)
        view.bringSubview(toFront: changeFontSizeView)
        changeFontSizeView.snp.makeConstraints { (make) in
            make.right.equalTo(view.snp.right).offset(-10)
            make.width.equalTo(view).multipliedBy(0.1)
            make.bottom.equalTo(textColour.snp.top).offset(-10)
            make.height.equalTo(view.snp.height)
        }
        
        // lay out each colour within view
        changeFontSizeView.addSubview(smallText)
        changeFontSizeView.bringSubview(toFront: smallText)
        smallText.setTitle("+", for: .normal)
        smallText.snp.makeConstraints { (make) in
            make.right.equalTo(changeFontSizeView.snp.right)
            make.bottom.equalTo(changeFontSizeView.snp.bottom)
            make.height.width.equalTo(iconSize)
        }

        changeFontSizeView.addSubview(mediumText)
        changeFontSizeView.bringSubview(toFront: mediumText)
        mediumText.setTitle("+", for: .normal)
        mediumText.snp.makeConstraints { (make) in
            make.right.equalTo(changeFontSizeView.snp.right)
            make.bottom.equalTo(smallText.snp.top).offset(-5)
            make.height.width.equalTo(iconSize)
        }
        
        changeFontSizeView.addSubview(largeText)
        changeFontSizeView.bringSubview(toFront: largeText)
        largeText.setTitle("+", for: .normal)
        largeText.snp.makeConstraints { (make) in
            make.right.equalTo(changeFontSizeView.snp.right)
            make.bottom.equalTo(mediumText.snp.top).offset(-5)
            make.height.width.equalTo(iconSize)
        }
        
    }
    
    
    func bringChangeColourToView()
    {
        
        // create view to house all colours
        changeColourView.isHidden = false
        view.addSubview(changeColourView)
        view.bringSubview(toFront: changeColourView)
        changeColourView.snp.makeConstraints { (make) in
            make.right.equalTo(view.snp.right).offset(-10)
            make.width.equalTo(view).multipliedBy(0.1)
            make.bottom.equalTo(textColour.snp.top).offset(-10)
            make.height.equalTo(view.snp.height)
        }
        
        // lay out each colour within view
        changeColourView.addSubview(colourBlack)
        changeColourView.bringSubview(toFront: colourBlack)
        colourBlack.snp.makeConstraints { (make) in
            make.right.equalTo(changeColourView.snp.right)
            make.bottom.equalTo(changeColourView.snp.bottom)
            make.height.width.equalTo(iconSize)
        }
        
        changeColourView.addSubview(colourWhite)
        changeColourView.bringSubview(toFront: colourWhite)
        colourWhite.snp.makeConstraints { (make) in
            make.right.equalTo(changeColourView.snp.right)
            make.bottom.equalTo(colourBlack.snp.top).offset(-5)
            make.height.width.equalTo(iconSize)
        }
        
        changeColourView.addSubview(colourPurple)
        changeColourView.bringSubview(toFront: colourPurple)
        colourPurple.snp.makeConstraints { (make) in
            make.right.equalTo(changeColourView.snp.right)
            make.bottom.equalTo(colourWhite.snp.top).offset(-5)
            make.height.width.equalTo(iconSize)
        }
        
        changeColourView.addSubview(colourBlue)
        changeColourView.bringSubview(toFront: colourBlue)
        colourBlue.snp.makeConstraints { (make) in
            make.right.equalTo(changeColourView.snp.right)
            make.bottom.equalTo(colourPurple.snp.top).offset(-5)
            make.height.width.equalTo(iconSize)
        }
        
        changeColourView.addSubview(colourGreen)
        changeColourView.bringSubview(toFront: colourGreen)
        colourGreen.snp.makeConstraints { (make) in
            make.right.equalTo(changeColourView.snp.right)
            make.bottom.equalTo(colourBlue.snp.top).offset(-5)
            make.height.width.equalTo(iconSize)
        }
        
        changeColourView.addSubview(colourYellow)
        changeColourView.bringSubview(toFront: colourYellow)
        colourYellow.snp.makeConstraints { (make) in
            make.right.equalTo(changeColourView.snp.right)
            make.bottom.equalTo(colourGreen.snp.top).offset(-5)
            make.height.width.equalTo(iconSize)
        }
        
        changeColourView.addSubview(colourOrange)
        changeColourView.bringSubview(toFront: colourOrange)
        colourOrange.snp.makeConstraints { (make) in
            make.right.equalTo(changeColourView.snp.right)
            make.bottom.equalTo(colourYellow.snp.top).offset(-5)
            make.height.width.equalTo(iconSize)
        }
        
        changeColourView.addSubview(colourRed)
        changeColourView.bringSubview(toFront: colourYellow)
        colourRed.snp.makeConstraints { (make) in
            make.right.equalTo(changeColourView.snp.right)
            make.bottom.equalTo(colourOrange.snp.top).offset(-5)
            make.height.width.equalTo(iconSize)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
