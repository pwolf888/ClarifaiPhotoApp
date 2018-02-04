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
    var selectedFont = "HelveticaNeue-Light"
    var iconSize = 40
    
    // Poem generator globals
//    var poemGenerator:PoemGenerator = PoemGenerator()
//    var imageTags:[String] = []
    
    var poemGenerator:PoemGenerator = PoemGenerator()
    var imageTags:[String] = []

    @IBOutlet weak var snapoetryLoader: UIImageView!
    
    // Photo options
    @IBOutlet weak var backNavButton: UIButton!
    @IBOutlet weak var shareNavButton: UIButton!
    @IBOutlet weak var savePhoto: UIButton!
    @IBOutlet weak var fontStyle: UIButton!
    @IBOutlet weak var textColour: UIButton!

    @IBOutlet weak var poeticText: UILabel!
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
        
        //hide buttons while API is being called
        self.fontSize.isHidden = true
        self.fontStyle.isHidden = true
        self.textColour.isHidden = true
        self.shareNavButton.isHidden = true
        self.savePhoto.isHidden = true
        
        //Animate logo will API is creating poem
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
                            tags.add(concept.conceptName)
                        }
                        let tagsArray = tags as NSArray as! [String]
                        
                        // Wait for the API to load before outputing to screen
                        DispatchQueue.main.async {
                            // Update the new tags in the UI.
                            //self.textView.text = String(format: "Tags: ", tags.componentsJoined(by: " "))
                            
                            self.imageTags = tagsArray
                            self.poeticText.text = self.poemGenerator.generateTopicalPoem(tags: self.imageTags)
                            
                        }
                        
                    }
                    
                    // Once finished enable buttons again
                    DispatchQueue.main.async {
                        
                        UIView.animate(withDuration: 0.2, animations: {
                            self.snapoetryLoader.alpha = 0
                        
                        })
                        
                        // show buttons to edit image once poem has loaded
                        self.fontSize.isHidden = false
                        self.fontStyle.isHidden = false
                        self.textColour.isHidden = false
                        self.shareNavButton.isHidden = false
                        self.savePhoto.isHidden = false
                    }
                    
                    
                    
                })
            })
        }
        
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
    
    @IBAction func selectFontSize(_ sender: UIButton) {
        
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
            selectedFont = "HelveticaNeue-Light"
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

        // set scale for font size in relation to image size
        let mlpScale = image.size.height/photoTaken.frame.size.height
        
        // pull the current user selected text format
        let selectedTextColor = poeticText.textColor
        let fontToDraw = UIFont(name: selectedFont, size: CGFloat(selectedFontSize).multiplied(by: mlpScale))!
        let scale = 0.3
        UIGraphicsBeginImageContextWithOptions(image.size, false, CGFloat(scale))

        //** code implemented to change text alignment to center, and add spacing between text
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 1.2
        paraStyle.alignment = NSTextAlignment.center;
        
        let textFontAttributes = [
            NSFontAttributeName: fontToDraw,
            NSParagraphStyleAttributeName: paraStyle,
            NSForegroundColorAttributeName: selectedTextColor as Any,
            ] as [String : Any]
        
        // Put the image into a rectangle as large as the original image
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        // get the bounding-box for the string
        var stringSize = text.size(attributes: textFontAttributes)
        
        // draw in rect functions as whole numbers
        stringSize.width = ceil(stringSize.width)
        stringSize.height = ceil(stringSize.height)
        
        let rect = CGRect(origin: CGPoint.zero, size: image.size)

        // Draw the text into an image
        text.draw(in: rect, withAttributes: textFontAttributes)

        // Create a new image out of the images we have created
        savedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
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
                                            
                                            self.newImage = nil
                                            self.poeticText.text = nil
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
        addShadow(icon: shareNavButton)
        shareNavButton.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(20)
            make.right.equalTo(contentView).offset(-20)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }

        //*** BACK BUTTON
        contentView.addSubview(backNavButton)
        contentView.bringSubview(toFront: backNavButton)
        addShadow(icon: backNavButton)
        backNavButton.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(10)
            make.centerY.equalTo(shareNavButton.snp.centerY)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }

        //*** SAVE BUTTON
        contentView.addSubview(savePhoto)
        contentView.bringSubview(toFront: savePhoto)
        addShadow(icon: savePhoto)
        savePhoto.snp.makeConstraints { (make) in
            make.centerX.equalTo(photoTaken.snp.centerX)
            make.centerY.equalTo(shareNavButton.snp.centerY)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }

        //*** POETIC TEXT
        photoTaken.addSubview(poeticText)
        poeticText.numberOfLines = 0
        poeticText.font = UIFont(name: "HelveticaNeue-Light", size: 24.0)
        poeticText.textAlignment = NSTextAlignment.center
        poeticText.textColor = .white
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
        addShadow(icon: textColour)
        textColour.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView.snp.bottom).offset(-15)
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.height.width.equalTo(iconSize)
        }
        
        //** CONFIGURE FONT BUTTON SINGLE
        contentView.addSubview(fontStyle)
        contentView.bringSubview(toFront: fontStyle)
        addShadow(icon: fontStyle)
        fontStyle.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView.snp.bottom).offset(-15)
            make.right.equalTo(textColour.snp.left).offset(-10)
            make.height.width.equalTo(iconSize)
        }
        
        //** CONFIGURE FONT SIZE BUTTON SINGLE
        contentView.addSubview(fontSize)
        contentView.bringSubview(toFront: fontSize)
        addShadow(icon: fontSize)
        fontSize.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView.snp.bottom).offset(-15)
            make.right.equalTo(fontStyle.snp.left).offset(-10)
            make.height.width.equalTo(iconSize)
        }
        
        //** CONFIGURE LOADING ANIMATION
        snapoetryLoader.image = UIImage.animatedImageNamed("eyelash_", duration: 2.0)
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
        addShadow(icon: font1)
        font1.snp.makeConstraints { (make) in
            make.right.equalTo(changeFontView.snp.right)
            make.bottom.equalTo(changeFontView.snp.bottom)
            make.height.width.equalTo(40)
        }

        changeFontView.addSubview(font2)
        changeFontView.bringSubview(toFront: font2)
        font2.setTitle("Aa", for: .normal)
        addShadow(icon: font2)
        font2.snp.makeConstraints { (make) in
            make.right.equalTo(changeFontView.snp.right)
            make.bottom.equalTo(font1.snp.top)
            make.height.width.equalTo(40)
        }
        
        changeFontView.addSubview(font3)
        changeFontView.bringSubview(toFront: font3)
        font3.setTitle("Aa", for: .normal)
        addShadow(icon: font3)
        font3.snp.makeConstraints { (make) in
            make.right.equalTo(changeFontView.snp.right)
            make.bottom.equalTo(font2.snp.top).offset(-5)
            make.height.width.equalTo(40)
        }
        
        changeFontView.addSubview(font4)
        changeFontView.bringSubview(toFront: font4)
        font4.setTitle("Aa", for: .normal)
        addShadow(icon: font4)
        font4.snp.makeConstraints { (make) in
            make.right.equalTo(changeFontView.snp.right)
            make.bottom.equalTo(font3.snp.top).offset(-5)
            make.height.width.equalTo(40)
        }
        
        changeFontView.addSubview(font5)
        changeFontView.bringSubview(toFront: font5)
        font5.setTitle("Aa", for: .normal)
        addShadow(icon: font5)
        font5.snp.makeConstraints { (make) in
            make.right.equalTo(changeFontView.snp.right)
            make.bottom.equalTo(font4.snp.top).offset(-5)
            make.height.width.equalTo(40)
        }
        
        changeFontView.addSubview(font6)
        changeFontView.bringSubview(toFront: font6)
        font6.setTitle("Aa", for: .normal)
        addShadow(icon: font6)
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
        addShadow(icon: smallText)
        smallText.setTitle("+", for: .normal)
        smallText.snp.makeConstraints { (make) in
            make.right.equalTo(changeFontSizeView.snp.right)
            make.bottom.equalTo(changeFontSizeView.snp.bottom)
            make.height.width.equalTo(iconSize)
        }

        changeFontSizeView.addSubview(mediumText)
        changeFontSizeView.bringSubview(toFront: mediumText)
        mediumText.setTitle("+", for: .normal)
        addShadow(icon: mediumText)
        mediumText.snp.makeConstraints { (make) in
            make.right.equalTo(changeFontSizeView.snp.right)
            make.bottom.equalTo(smallText.snp.top).offset(-5)
            make.height.width.equalTo(iconSize)
        }
        
        changeFontSizeView.addSubview(largeText)
        changeFontSizeView.bringSubview(toFront: largeText)
        addShadow(icon: largeText)
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
        addShadow(icon: colourBlack)
        colourBlack.snp.makeConstraints { (make) in
            make.right.equalTo(changeColourView.snp.right)
            make.bottom.equalTo(changeColourView.snp.bottom)
            make.height.width.equalTo(iconSize)
        }
        
        changeColourView.addSubview(colourWhite)
        changeColourView.bringSubview(toFront: colourWhite)
        addShadow(icon: colourWhite)
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
    
    
    // adds shadows to the UI buttons
    func addShadow(icon: UIButton) {
        if (icon == colourBlack) {
            icon.layer.shadowColor = UIColor.white.cgColor
        } else {
            icon.layer.shadowColor = UIColor.black.cgColor
        }
        icon.layer.shadowOpacity = 0.9
        icon.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        
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
