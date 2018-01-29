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
    @IBOutlet weak var rotateCamera: UIButton!
    
    //global variables
    var iconSize = 40
    
    // Custom camera variables
    var session: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    let picker = UIImagePickerController()
    var captureDevice : AVCaptureDevice?
    var frontBack : Bool = false

    override func viewDidLoad() {
        
        setupInitialUI()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    override func viewWillAppear(_ animated: Bool) {
        print("fire")
        
        super.viewWillAppear(animated)
        
        loadCamera()
        
    }
    
    
    // Loade the camera front or back
    func loadCamera() {
        
        // Setup your camera here...
        
        // Setup Session to use camera inputs
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices! {
            // Make sure this particular device supports video
            if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if((device as AnyObject).position == AVCaptureDevicePosition.back && frontBack == false) {
                    captureDevice = device as? AVCaptureDevice
                } else if((device as AnyObject).position == AVCaptureDevicePosition.front && frontBack == true) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        
        // Prepare the rear camera as input
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
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
                videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
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
        
    }
    
    // Rotate the camera
    @IBAction func rotateCamera(_ sender: UIButton) {
        backOrFront()
        print("camera swap")
        loadCamera()
        videoPreviewLayer!.frame = previewView.bounds
    }
    
    // Changes the value of frontback a key variable used to changed the camera direction
    func backOrFront() {
        if(self.frontBack == false) {
            self.frontBack = true
        } else {
            self.frontBack = false
        }
    }
   
    // Help button - gives info to user on how to user snapoetry
    @IBAction func helpButton(_ sender: UIButton) {
        
        // Create icon for alert box
        let imageRect = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 55))
        let snapoetryIcon = UIImage(named: "snapoetryIcon.png")
        imageRect.image = snapoetryIcon
        
        let defaultAction = UIAlertAction(title: "Get Snappin'",
                                          style: .default) { (action) in
                                            
        }
        
        // Create and configure the alert controller.
        let alert = UIAlertController(title: "How to Snapoetry",
                                      message: "< Take a photo with this",
                                      preferredStyle: .alert)
        
        alert.addAction(defaultAction)
        
        // Add snapoetry icon to alert box
        alert.view.addSubview(imageRect)
        
        self.present(alert, animated: true) {
            // The alert was presented
            
            
        }
        
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
                    
                }

            })
        }

        

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
            self.photoTaken.contentMode = UIViewContentMode.scaleAspectFill
            
            //prevents the image from stretching once photo taken
            self.photoTaken.clipsToBounds = true
        
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
            make.edges.equalTo(contentView)
        }
        
        //** CONFIGURE TAKE PHOTO BUTTON
        contentView.addSubview(takePhoto)
        contentView.bringSubview(toFront: takePhoto)
        takePhoto.snp.makeConstraints { (make) in
            make.centerX.equalTo(previewView)
            make.height.equalTo(65)
            make.width.equalTo(71.1)
            make.bottom.equalTo(previewView).offset(-15)
        }
        
        //** CONFIGURE SELECT PHOTO BUTTON
        contentView.addSubview(selectPhoto)
        contentView.bringSubview(toFront: selectPhoto)
        selectPhoto.snp.makeConstraints { (make) in
            make.bottom.equalTo(previewView).offset(-15)
            make.height.width.equalTo(iconSize)
            make.right.equalTo(previewView).offset(-15)
        }
        
        //** CONFIGURE HELP BUTTON
        contentView.addSubview(openHelp)
        contentView.bringSubview(toFront: openHelp)
        openHelp.snp.makeConstraints { (make) in
            make.bottom.equalTo(previewView).offset(-15)
            make.left.equalTo(contentView.snp.left).offset(15)
            make.height.width.equalTo(iconSize)
        }
        
        //** CONFIGURE ROTATE CAMERA BUTTON
        contentView.addSubview(rotateCamera)
        contentView.bringSubview(toFront: rotateCamera)
        rotateCamera.snp.makeConstraints { (make) in
            make.top.equalTo(previewView).offset(20)
            make.left.equalTo(contentView.snp.left).offset(15)
            make.height.width.equalTo(iconSize)
        }
        
    }

}
