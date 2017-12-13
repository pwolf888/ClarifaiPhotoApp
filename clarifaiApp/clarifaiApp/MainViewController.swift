//
//  ViewController.swift
//  Snapoetry
//  
//  An app that can take a photo, recognize the image with tags,
//  then display hardcoded poetry from another api using the first tag.
//
//  Created by Jonathan Turnbull on 18/08/2017.
//  Copyright © 2017 partywolfAPPS. All rights reserved.
//

import UIKit
import Clarifai
import SnapKit


class MainViewController: UIViewController,
        UIImagePickerControllerDelegate,
        UINavigationControllerDelegate {
    
    // Declared Variables - IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var selectPhoto: UIButton!
    @IBOutlet weak var poeticText: UITextView!
    @IBOutlet weak var openCamera: UIButton!
    @IBOutlet weak var snapoetryTitle: UIImageView!
    @IBOutlet weak var selectFont: UIButton!
    
    @IBOutlet weak var backNavButton: UIButton!
    @IBOutlet weak var shareNavButton: UIButton!
    
    
    // Declaring Variables - Globals
    var app:ClarifaiApp?
    let picker = UIImagePickerController()
    var poems = [String]()
    var loaded = false
    var tagOne = "no poem"
    
    // Load Clarifai API
    override func viewDidLoad() {
        
        setupInitialUI()
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Declare my api key
        app = ClarifaiApp(apiKey: "ab5e1c0750f14e5685e24b243de99d27")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Make the eye icon blink when touched
    @IBAction func cameraDown(_ sender: UIButton) {
        openCamera.setImage(UIImage(named: "snapoetry_closed"), for: .normal)
    }
    
    // Open the devices camera
    @IBAction func openCamera(_ sender: Any) {
        openCamera.setImage(UIImage(named: "snapoetry_camera"), for: .normal)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            
            // Present it to screen
            self.present(imagePicker, animated: true, completion: nil)
            
            // Clear poem array
            if poems.capacity != 0 {
                poems.remove(at: 0)
            }
            poeticText.text.removeAll()
        }
    }
    
    // select photo icon blinks
    @IBAction func selectPhotoDown(_ sender: UIButton) {
         selectPhoto.setImage(UIImage(named: "snapoetry_closed"), for: .normal)
    }
    
    
    // Select a photo from the album
    @IBAction func selectPhoto(_ sender: UIButton) {
        
        // Open the eye on touch up
        selectPhoto.setImage(UIImage(named: "snapoetry_photo_alt"), for: .normal)
        
        // Show a UIImagePickerController to let the user pick an image from their library.
        picker.allowsEditing = false;
        
        // Open Users device photo library
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.delegate = self;
        
        // present photo to screen
        present(picker, animated: true, completion: nil)
        
        
        // Clear poem array
        if poems.capacity != 0 {
            poems.remove(at: 0)
        }
        poeticText.text.removeAll()
        
    }
    
    // Pick an image from the users library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The user picked an image. Send it to Clarifai for recognition.
        dismiss(animated: true, completion: nil)
        //redraw UI
        setupPhotolUI()
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            // Needs a fix
            // Set image to the UIImageView
            imageView.image = image
            
            // Get Width and Height of Chosen Image
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            // Create a new frame for the image to sit in
            imageView.frame = CGRect(x: 0.0, y: 0.0, width: imageWidth, height: imageHeight)
            
            // Automatically resizes the height of the image
            imageView.autoresizingMask = UIViewAutoresizing.flexibleHeight
            
            // Scales the image to fit on the screen
            self.imageView.contentMode = UIViewContentMode.scaleAspectFit
            
            // Recognizes the image
            recognizeImage(image: image)
            textView.text = "Hmmmm..."
            
            // Disable buttons while recognizing
            selectPhoto.isEnabled = false
            openCamera.isEnabled = false
            selectPhoto.setImage(UIImage(named: "snapoetry_closed"), for: .normal)
            openCamera.setImage(UIImage(named: "snapoetry_closed"), for: .normal)
            
            
        }
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
                        
                        // Wait for the API to load before outputing to screen
                        DispatchQueue.main.async {
                            // Update the new tags in the UI.
                            self.textView.text = String(format: "Tags:\n%@", tags.componentsJoined(by: ", "))
                            
                            // Take the first tag from the list
                            self.tagOne = "\(tags[0] as! CVarArg)"
                            
                            // Send tag to our API to generate poetry
                            self.getRequest(poemName: self.tagOne)
                        
                        }
                        
                    }
                    
                    // Once finished enable buttons again
                    DispatchQueue.main.async {
                        
                        // Enable buttons
                        self.selectPhoto.isEnabled = true;
                        self.openCamera.isEnabled = true;
                        self.selectPhoto.setImage(UIImage(named: "snapoetry_photo_alt"), for: .normal)
                        self.openCamera.setImage(UIImage(named: "snapoetry_camera_alt"), for: .normal)
                        
                    }
                    
                })
            })
        }
    
    }
    

    // Gets a poem from our heroku api
    func getRequest(poemName: String) {
        
        // Url to our API
        let todoEndpoint: String = "https://radiant-lake-85816.herokuapp.com/poems?poem=\(poemName)"
        // new API link: https://radiant-lake-85816.herokuapp.com/poems?poem=
        // old API link: https://nameless-gorge-75596.herokuapp.com/poems?poem=
        guard let url = URL(string: todoEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        
        // Turn it into a request
        let urlRequest = URLRequest(url: url)
        
        // Begin the session
        let session = URLSession.shared
        
        // Session becomes a data task with a completion handler
        let task = session.dataTask(with: urlRequest, completionHandler:{ data, response, error in
            
            // Wait for a 200 OK code
            if let response = response {
                print(response)
            }
            
            // Turn data into JSON Object
            if let data = data {
                print(data)
                
                // Serialise Data
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
                    
                    // If data is the first poem in the list
                    if let poem = json[0]["poem"] {
                        
                        // Wait for the request to load before output
                        DispatchQueue.main.async {
                            
                            // Store poem into a string array
                            self.poems.append(poem as! String)
                            print(self.poems)
                            
                            // Output to text view element
                            self.poeticText.text = "\(self.poems[0])"
                            
                        }
                    }
                    
                } catch {
                    print(error)
                }
            }
            if let error = error {
                print(error)
            }
        
        })
        task.resume()
        
    }
    
    @IBAction func cancelSnap(sender: UIButton) {
        // Confirm Cancellation.
        
        print("User pressed back")
        let defaultAction = UIAlertAction(title: "Okay",
                                          style: .default) { (action) in
                                            // Respond to user selection of the action.
                                            self.setupInitialUI()
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
    
    


    func setupInitialUI(){
                
        //** CONFIGURE OVERALL LAYOUT
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.backgroundColor = .whiteColour
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        //** CONFIGURE BACKGROUND VIEW
        let backgroundView = UIView()
        contentView.addSubview(backgroundView)
        //        self.view.bringSubview(toFront: titleView)
        backgroundView.backgroundColor = .snapoetryBackground
        backgroundView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(contentView)
            make.bottom.equalTo(contentView.snp.centerY)
        }
        
        //** CONFIGURE TITLE VIEW
        let titleView = UIView()
        view.addSubview(titleView)
        self.view.bringSubview(toFront: titleView)
        titleView.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(100)
            make.left.right.equalTo(contentView)
        }
        
        
        //** CONFIGURE TITLE TEXT
        titleView.addSubview(snapoetryTitle)
        snapoetryTitle.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleView.snp.centerY).offset(-25)
            make.centerX.equalTo(titleView.snp.centerX)
            make.width.equalTo(400)
            make.height.equalTo(94)
            
        }
        
        
        //** CONFIGURE ICON VIEW
        let iconView = UIView()
        view.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.left.right.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-50)
            make.height.equalTo(self.view.snp.height).multipliedBy(0.15)
        }
        
        //** CONFIGURE PHOTO VIEW
        let photoView = UIView()
        contentView.addSubview(photoView)
        photoView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(contentView)
            make.left.right.equalTo(contentView)
        }
        
        //** CONFIGURE CAMERA ICON
        iconView.addSubview(openCamera)
        self.view.bringSubview(toFront: openCamera)
        openCamera.layer.borderWidth = 2
        openCamera.layer.borderColor = UIColor.snapoetryBackground.cgColor
        openCamera.layer.cornerRadius = 10
        openCamera.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconView.snp.centerY)
            make.left.equalTo(iconView.snp.left).offset(30)
            make.height.equalTo(iconView).multipliedBy(0.95)
            make.width.equalTo(iconView.snp.height)
            
        }
        
        //** CONFIGURE PHOTO LIBRARY ICON
        iconView.addSubview(selectPhoto)
        self.view.bringSubview(toFront: selectPhoto)
        selectPhoto.layer.borderWidth = 2
        selectPhoto.layer.borderColor = UIColor.snapoetryBackground.cgColor
        selectPhoto.layer.cornerRadius = 10
        selectPhoto.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconView.snp.centerY)
            make.right.equalTo(iconView.snp.right).offset(-30)
            make.height.equalTo(iconView).multipliedBy(0.9)
            make.width.equalTo(iconView.snp.height)
            
        }
        
    }
    
    func setupPhotolUI(){
        
        //** CONFIGURE OVERALL LAYOUT
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.backgroundColor = .whiteColour
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        //** CONFIGURE NAVBAR VIEW
        let navBar = UIView()
        view.addSubview(navBar)
        navBar.backgroundColor = .whiteColour
        navBar.snp.makeConstraints { (make) in
            make.left.right.equalTo(contentView)
            make.top.equalTo(contentView)
            make.height.equalTo(64)
        }
        
        //** CONFIGURE BACK BUTTON
        navBar.addSubview(backNavButton)
        self.view.bringSubview(toFront: backNavButton)
        backNavButton.snp.makeConstraints { (make) in
            make.left.equalTo(navBar.snp.left).offset(10)
            make.bottom.equalTo(navBar.snp.bottom).offset(-10)
            make.height.equalTo(navBar).multipliedBy(0.8)
            make.width.equalTo(backNavButton.snp.height)
        }
        
        //** CONFIGURE SOCIAL MEDIA SHARE BUTTON
        navBar.addSubview(shareNavButton)
        self.view.bringSubview(toFront: shareNavButton)
        shareNavButton.snp.makeConstraints { (make) in
            make.right.equalTo(navBar.snp.right).offset(-10)
            make.bottom.equalTo(navBar.snp.bottom).offset(-10)
            make.height.width.equalTo(30)
        }
        
        //** CONFIGURE ICON VIEW
        let iconView = UIView()
        view.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.left.right.equalTo(contentView)
            make.bottom.equalTo(contentView)
            make.height.equalTo(64)
        }
        
        //** CONFIGURE PHOTO VIEW
        let photoView = UIView()
        contentView.addSubview(photoView)
        photoView.snp.makeConstraints { (make) in
            make.top.equalTo(navBar.snp.bottom)
            make.bottom.equalTo(contentView.snp.bottom)
            make.left.right.equalTo(contentView)
        }
        
        //** CONFIGURE FONT BUTTON SINGLE
        iconView.addSubview(selectFont)
        selectFont.backgroundColor = .whiteColour
        selectFont.layer.borderWidth = 1
        selectFont.layer.borderColor = UIColor.snapoetryBackground.cgColor
        selectFont.layer.cornerRadius = 10
        selectFont.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconView.snp.centerY)
            make.left.equalTo(iconView.snp.left).offset(10)
            make.height.equalTo(iconView).multipliedBy(0.8)
            make.width.equalTo(selectFont.snp.height)

        }
        
//        //** CONFIGURE COLOUR BUTTON SINGLE
        let selectColourView = UIView()
        iconView.addSubview(selectColourView)
        selectColourView.backgroundColor = .whiteColour
        self.view.bringSubview(toFront: selectColourView)
        selectColourView.layer.borderWidth = 1
        selectColourView.layer.borderColor = UIColor.snapoetryBackground.cgColor
        selectColourView.layer.cornerRadius = 10
        selectColourView.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconView.snp.centerY)
            make.right.equalTo(iconView.snp.right).offset(-10)
            make.height.equalTo(iconView).multipliedBy(0.8)
            make.width.equalTo(selectColourView.snp.height)

        }
        
        let selectColour = UIButton()
        selectColourView.addSubview(selectColour)
        selectColour.backgroundColor = .whiteColour
        self.view.bringSubview(toFront: selectColour)
        selectColour.layer.borderWidth = 1
        selectColour.layer.borderColor = UIColor.greyColour.cgColor
        selectColour.layer.cornerRadius = 10
        selectColour.snp.makeConstraints { (make) in
            make.center.equalTo(selectColourView.snp.center)
            make.height.equalTo(35)
            make.width.equalTo(35)
        }
        
        //** CONFIGURE POEM VIEW
        let poemView = UIView()
        view.addSubview(poemView)
        self.view.bringSubview(toFront: poemView)
        poemView.snp.makeConstraints { (make) in
            make.left.right.equalTo(contentView)
            make.top.equalTo(navBar.snp.bottom)
        }
        
        //** CONFIGURE POEM TEXT
        poemView.addSubview(poeticText)
        // self.view.bringSubview(toFront: poeticText)
        poeticText.font = UIFont(name: "HelveticaNeue-Light", size: 18.0)
        poeticText.textAlignment = NSTextAlignment.center
        poeticText.textColor = .whiteColour
        
        poeticText.snp.makeConstraints { (make) in
            make.centerX.equalTo(poemView.snp.centerX)
            make.bottom.equalTo(poemView)
            make.height.equalTo(280)
            make.width.equalTo(280)
            
        }
        
        //** CONFIGURE PHOTO DISPLAYED VIEW
        photoView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(photoView.snp.top)
            make.bottom.equalTo(photoView.snp.bottom)
            //make.width.equalTo(200)
            make.center.equalTo(photoView.snp.center)
        }
        
    }
    
}

