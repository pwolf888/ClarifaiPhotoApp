//
//  CameraViewController.swift
//  clarifaiApp
//
//  Created by Erin Abrams on 17/1/18.
//  Copyright © 2018 partywolfAPPS. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

class CameraViewController: UIViewController,
    UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    // Custom camera view outlets
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var takePhoto: UIButton!
    @IBOutlet weak var selectPhoto: UIButton!
    @IBOutlet weak var openHelp: UIButton!
    @IBOutlet weak var photoTaken: UIImageView!
    
    // Custom camera variables
    var session: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    let picker = UIImagePickerController()

    override func viewDidLoad() {
        
        setupInitialUI()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        print("fire")
        super.viewWillAppear(animated)
        
        // Setup your camera here...
        
        // Setup Session to use camera inputs
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSessionPresetPhoto
        
        // Rear Camera is chosen
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // Prepare the rear camera as input
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        // Check Errors for the session
        if error == nil && session!.canAddInput(input) {
            session!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            if session!.canAddOutput(stillImageOutput) {
                session!.addOutput(stillImageOutput)
                
                // Configure the live stream of the camera
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                previewView.layer.addSublayer(videoPreviewLayer!)
                session!.startRunning()
                
            }
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("fire2")
        super.viewDidAppear(animated)
        videoPreviewLayer!.frame = previewView.bounds

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // Select a photo from the album
    @IBAction func selectPhoto(_ sender: UIButton) {
        
        // Show a UIImagePickerController to let the user pick an image from their library.
        picker.allowsEditing = false;
        
        // Open Users device photo library
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.delegate = self;
        
        // present photo to screen
        present(picker, animated: true, completion: nil)
        
//  <-- CODE TO BE MOVED TO NEW VC
        //poeticText.text.removeAll()
// -->
        
    }
    

    // Take a photo
    @IBAction func didTakePhoto(_ sender: UIButton) {
        
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
            
            // Take a still image from the stream
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) -> Void in
                
                // Take an image from the live stream of the camera
                // Turn it into a jpeg
                if sampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProvider(data: imageData! as CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                    
                    // Output image to imageView
                    self.photoTaken.image = image
                    
                    let svc = self.storyboard!.instantiateViewController(withIdentifier: "editSnapVC") as! EditSnapViewController
                    svc.newImage = self.photoTaken.image
                    print(svc.newImage)
                    self.present(svc, animated: true, completion: nil)
                    
                    
//  <-- CODE TO BE MOVED TO NEW VC
                    // send image to Clarifai
                    // self.recognizeImage(image: image)
                    
//  -->
                }
                
                
            })
            
        }
        
//        let svc = self.storyboard!.instantiateViewController(withIdentifier: "editSnapVC") as! EditSnapViewController
//        svc.newImage = photoTaken.image
//        print(svc.newImage)
//        self.present(svc, animated: true, completion: nil)
        
    }
    
    
    // Pick an image from the users library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The user picked an image. Send it to Clarifai for recognition.
        dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            // Needs a fix
            // Set image to the UIImageView
            photoTaken.image = image
            
            // Get Width and Height of Chosen Image
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            // Create a new frame for the image to sit in
            photoTaken.frame = CGRect(x: 0.0, y: 0.0, width: imageWidth, height: imageHeight)
            
            // Automatically resizes the height of the image
            photoTaken.autoresizingMask = UIViewAutoresizing.flexibleHeight
            
            // Scales the image to fit on the screen
            self.photoTaken.contentMode = UIViewContentMode.scaleAspectFit
            
//  <-- CODE TO BE MOVED TO NEW VC
            // Recognizes the image
            // recognizeImage(image: image)
            
            //redraw UI
           // self.setupPhotoUI()
//  -->
        }
        
        let svc = self.storyboard!.instantiateViewController(withIdentifier: "editSnapVC") as! EditSnapViewController
        svc.newImage = photoTaken.image
        self.present(svc, animated: true, completion: nil)
        
    }
    
    
    func setupInitialUI(){
        
        //** CONFIGURE OVERALL LAYOUT
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        //** CONFIGURE CAMERA PREVIEW VIEW
        contentView.addSubview(previewView)
        previewView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        //** CONFIGURE TAKE PHOTO BUTTON
        contentView.addSubview(takePhoto)
        contentView.bringSubview(toFront: takePhoto)
        takePhoto.snp.makeConstraints { (make) in
            make.centerX.equalTo(previewView)
            make.bottom.equalTo(previewView).offset(-10)
        }
        
        //** CONFIGURE SELECT PHOTO BUTTON
        contentView.addSubview(selectPhoto)
        contentView.bringSubview(toFront: selectPhoto)
        selectPhoto.snp.makeConstraints { (make) in
            make.bottom.equalTo(previewView).offset(-10)
            make.height.equalTo(45)
            make.width.equalTo(selectPhoto.snp.height).multipliedBy( 50 / 40.5 )
            make.right.equalTo(previewView).offset(-10)
        }
        
        //** CONFIGURE HELP BUTTON
        contentView.addSubview(openHelp)
        contentView.bringSubview(toFront: openHelp)
        openHelp.snp.makeConstraints { (make) in
            make.bottom.equalTo(previewView).offset(-10)
            make.left.equalTo(contentView.snp.left).offset(10)
            make.width.height.equalTo(45)
        }
        
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "sendPhotoToEdit" {
//            let destination = segue.destination as! EditSnapViewController
//            destination.newImage = self.photoTaken.image
//        }
//    }

}
