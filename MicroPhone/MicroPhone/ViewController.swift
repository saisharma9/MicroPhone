//
//  ViewController.swift
//  MicroPhone
//
//  Created by Mantha,Sai Sharma on 4/30/22.
//

import UIKit
import Speech

class ViewController: UIViewController {
    

    @IBOutlet weak var startButtonOutlet: UIButton!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    
    //Local Properties
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer : SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task: SFSpeechRecognitionTask!
    var isStart : Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        colorView.layer.cornerRadius = 15
        requestPermission()
    }
    
    
    @IBAction func strt_stop_button_clicked(_ sender: Any)
    {
        isStart = !isStart
        
        if isStart {
            startSpeechRecognization()
            startButtonOutlet.setTitle("START", for: .normal)
            startButtonOutlet.backgroundColor = .systemGreen
        
        }
        else{
            cancelSpeechRecognization()
            startButtonOutlet.setTitle("STOP", for: .normal)
            startButtonOutlet.backgroundColor = .systemRed
        }
    }
    
    
    
    
    
    
   func requestPermission() {
       self.startButtonOutlet.isEnabled = false
       SFSpeechRecognizer.requestAuthorization { (authState) in
           OperationQueue.main.addOperation {
               if authState == .authorized {
                   print("Sharma and Vamsi given Access")
                   self.startButtonOutlet.isEnabled = true
               }
               else if authState == .denied{
                   self.alertView(message: "Bhaskar Denied The permisssion")
                 
               }
               
               
               else if authState == .notDetermined{
                   self.alertView(message: "User dont have speech regonisation functionality")
                 
               }
               else if authState == .restricted {
                   self.alertView(message: "User has been restricted to use speech regonisation functionality")
                 
               }
           }
           
       }
       
    }
    
    func startSpeechRecognization(){
            let node = audioEngine.inputNode
            let recordingFormat = node.outputFormat(forBus: 0)
            
            node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
                self.request.append(buffer)
            }
            
            audioEngine.prepare()
            do {
                try audioEngine.start()
            } catch let error {
                alertView(message: "Error comes here for starting the audio listner =\(error.localizedDescription)")
            }
            
            guard let myRecognization = SFSpeechRecognizer() else {
                self.alertView(message: "Recognization is not allow on your local")
                return
            }
            
            if !myRecognization.isAvailable {
                self.alertView(message: "Recognization is free right now, Please try again after some time.")
            }
            
            task = speechRecognizer?.recognitionTask(with: request, resultHandler: { (response, error) in
                guard let response = response else {
                    if error != nil {
                        self.alertView(message: error.debugDescription)
                    }else {
                        self.alertView(message: "Problem in giving the response")
                    }
                    return
                }
                
                let message = response.bestTranscription.formattedString
                print("Message : \(message)")
                self.displayLabel.text = message
                
                
                var lastString: String = ""
                for segment in response.bestTranscription.segments {
                    let indexTo = message.index(message.startIndex, offsetBy: segment.substringRange.location)
                    lastString = String(message[indexTo...])
                }
                
                if lastString == "red" {
                    self.colorView.backgroundColor = .systemRed
                } else if lastString.elementsEqual("green") {
                    self.colorView.backgroundColor = .systemGreen
                } else if lastString.elementsEqual("pink") {
                    self.colorView.backgroundColor = .systemPink
                } else if lastString.elementsEqual("blue") {
                    self.colorView.backgroundColor = .systemBlue
                } else if lastString.elementsEqual("black") {
                    self.colorView.backgroundColor = .black
                }
                
                
            })
        }
    
    func cancelSpeechRecognization() {
           task.finish()
           task.cancel()
           task = nil
           
           request.endAudio()
           audioEngine.stop()
           //audioEngine.inputNode.removeTap(onBus: 0)
           
           //MARK: UPDATED
           if audioEngine.inputNode.numberOfInputs > 0 {
               audioEngine.inputNode.removeTap(onBus: 0)
           }
       }
    
    
    func alertView(message :String)
    {
        let controller = UIAlertController.init(title: "Error occured!", message: "Testtttting ", preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "OKKKK", style: .default, handler: { (_) in
            controller.dismiss(animated: true, completion: nil)
        }))
        self.present(controller, animated: true, completion: nil)
    }

}

