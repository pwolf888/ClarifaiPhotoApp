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


class ViewController: UIViewController,
        UIImagePickerControllerDelegate,
        UINavigationControllerDelegate {
    
    // Declared Variables - IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var selectPhoto: UIButton!
    @IBOutlet weak var poeticText: UITextView!
    @IBOutlet weak var openCamera: UIButton!
    @IBOutlet weak var snapoetryTitle: UIImageView!
    
    // Declaring Variables - Globals
    var app:ClarifaiApp?
    let picker = UIImagePickerController()
    var poems = [String]()
    var loaded = false
    var tagOne = "no poem"
    
    // Load Clarifai API
    override func viewDidLoad() {
        
        setupUI()
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
        selectPhoto.setImage(UIImage(named: "snapoetry_photos"), for: .normal)
        
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
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
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
                        self.selectPhoto.setImage(UIImage(named: "snapoetry_photos"), for: .normal)
                        self.openCamera.setImage(UIImage(named: "snapoetry_camera"), for: .normal)
                        
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
    
    func setupUI(){
        
         //declare global variables to use for layout.
        
        //** CONFIGURE OVERALL LAYOUT
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.backgroundColor = .snapoetryBackground
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        //** CONFIGURE TITLE VIEW
        
        contentView.addSubview(snapoetryTitle)
        snapoetryTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(90)
            make.width.equalTo(327)
        }
        
        //** CONFIGURE CAMERA ICON VIEW
         contentView.addSubview(openCamera)
        openCamera.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(75)
            make.width.equalTo(100)
            
        }
        
        //** CONFIGURE PHOTO LIBRARY ICON VIEW
        contentView.addSubview(selectPhoto)
        selectPhoto.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(20)
            make.height.equalTo(75)
            make.width.equalTo(100)
            
        }
        
        
         //** CONFIGURE POEM TEXT VIEW
        contentView.addSubview(poeticText)
        poeticText.font = UIFont(name: "HelveticaNeue-Light", size: 18.0)
        poeticText.textAlignment = NSTextAlignment.center
        poeticText.textColor = .whiteColour
        
        poeticText.snp.makeConstraints { (make) in
            make.center.equalTo(contentView)
            make.height.equalTo(128)
            make.width.equalTo(240)
            
        }
        
    }
    
}

