//
//  ViewController.swift
//  Save files to sandbox
//
//  Created by Suyog Ghinmine on 23/08/19.
//  Copyright © 2019 Suyog Ghinmine. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

class ViewController: UIViewController,AVAudioRecorderDelegate,AVAudioPlayerDelegate {
    
    //Variables:
    var audioRecorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    var totalTimeString = ""

   
    //IBOutlets:
    @IBOutlet var recordingTimeLabel: UILabel!
    @IBOutlet var record_btn_ref: UIButton!
    @IBOutlet weak var playBtn: UIButton!

    
    //View Did Load:
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //Check for recording permission:
        
        check_record_permission()
        
        //Add right bar button:
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Records", style: .plain, target: self, action: #selector(OpenDoc))
        
    }
    
    //Button action to start recording:
    
    @IBAction func start_recording(_ sender: UIButton)
    {
        //If already recording:
        if(isRecording)
        {
            //Stop recording:
            finishAudioRecording(success: true)
            //Set the title back to "Record":
            record_btn_ref.setTitle("Record", for: .normal)
            //Enable the play button:
            playBtn.isEnabled = true
            //Set the value of the variable "isRecording" to false
            isRecording = false
            
        }
            //If audio was not being recorded:
        else
        {
            //Setup the recorder:
            setup_recorder()
            //Start recording:
            audioRecorder.record()
            //Update label every 1 sec:
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            //Set the title of the label to "Stop":
            record_btn_ref.setTitle("Stop", for: .normal)
            //Disable play:
            playBtn.isEnabled = false
            //Set "isRecording" to true:
            isRecording = true
        }
    }
    
    //Play/pause button action
    
    @IBAction func playBtnAction(_ sender: Any) {
        //playSound()
        
        //If audio is already being played (i.e. it should pause on being clicked again):
        if(isPlaying)
        {
            //Stop audio player
            player.stop()
            //Enable record button:
            record_btn_ref.isEnabled = true
            //Set the title to "Play"
            playBtn.setTitle("Play", for: .normal)
            //Set value of "isPlaying" to false:
            isPlaying = false
        }
            //It is not playing (i.e. it should play when button is clicked)
        else
        {
            let filename = "myRecording\(totalTimeString).m4a"
            let url = getDocumentsDirectory().appendingPathComponent(filename)
            
            //If file path exists:
            if FileManager.default.fileExists(atPath: url.path)
            {
                //Disable the record button:
                record_btn_ref.isEnabled = false
                //Set the title of the button to "Pause":
                playBtn.setTitle("Pause", for: .normal)
                //Prepare to play:
                prepare_play()
                //Implement play method of audioPlayer:
                player.play()
                //Set variable "isPlaying" to true:
                isPlaying = true
            }
                //If file path doesn't exist:
            else
            {
                display_alert(msg_title: "Error", msg_desc: "Audio file is missing.", action_title: "OK")
            }
        }
    }
    
    
    //Recording permissions:
    
    //Function that checks for permission to record:
    
    func check_record_permission()
    {
        //Switch record permission instances:
        
        switch AVAudioSession.sharedInstance().recordPermission {
        //Case granted:
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            break
        //Case denied:
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            break
        //Case not determined, in which case ask for permission:
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        //Default case:
        default:
            break
        }
    }
    
    
    //Function that gets the directory path:
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    //Function that gets the URL file path:
    func getFileUrl() -> URL
    {
        let date = Date()
        let calendar = Calendar.current
        let hr = calendar.component(.hour, from: date)
        let min = calendar.component(.minute, from: date)
        let sec = calendar.component(.second, from: date)
        totalTimeString = String(format: "%02d.%02d.%02d", hr, min, sec)
        let filename = "myRecording\(totalTimeString).m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        
        return filePath
    }
    
    
    
    //Audio recorder functions:
    
    
    //Function that sets up the recorder:
    
    func setup_recorder()
    {
        //If access to record:
        if isAudioRecordingGranted
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
                try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
            }
            catch let error {
                display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }
        }
            //If permission not granted:
        else
        {
            display_alert(msg_title: "Error", msg_desc: "Don't have access to use your microphone.", action_title: "OK")
        }
    }
    
    //Function that defines what to do when audio recording is finished successfully/unsuccessfully:
    
    func finishAudioRecording(success: Bool)
    {
        //If recording was successful:
        if success
        {
            //Stop recording
            audioRecorder.stop()
            //Reset recorder
            audioRecorder = nil
            //Invalidate meter timer:
            meterTimer.invalidate()
        }
            //If recording was not successful:
        else
        {
            //Call function to display alert:
            display_alert(msg_title: "Error", msg_desc: "Recording failed.", action_title: "OK")
        }
    }
    
    //Function for audio record did finish recording:
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
    {
        if !flag
        {
            //Audio recording was not successful:
            finishAudioRecording(success: false)
        }
        
        //Enable play button
        playBtn.isEnabled = true
        
    }
    
    
    
    
    //Play/pause recorded audio:
    
    
    //Prepare to play:
    
    func prepare_play()
    {
        do
        {
            let filename = "myRecording\(totalTimeString).m4a"
            let url = getDocumentsDirectory().appendingPathComponent(filename)
            
            player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.prepareToPlay()
        }
        catch{
            print("Error")
        }
    }
    
    //If recorded audio was played:
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        //Enable record button:
        record_btn_ref.isEnabled = true
        //Set title of play button to Play:
        playBtn.setTitle("Play", for: .normal)
    }
    
    
    
    //Alerts:
    
    //Function to display alerts:
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
    
    
    
    
    //Timer label:
    
    //Objective C function to update text of the timer label:
    @objc func updateAudioMeter(timer: Timer)
    {
        if audioRecorder.isRecording
        {
            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            recordingTimeLabel.text = totalTimeString
            audioRecorder.updateMeters()
        }
    }
    
    
    
    //Navigation bar button action:
    
    @objc func OpenDoc()
    {
//        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeMPEG4Audio as String], in: .open)
//        documentPicker.delegate = self as? UIDocumentPickerDelegate
//        documentPicker.allowsMultipleSelection = false
//        present(documentPicker, animated: true, completion: nil)
        let sbObj = UIStoryboard(name: "Main", bundle: nil)
        let svcObj = sbObj.instantiateViewController(withIdentifier: "ViewController2SB")
        navigationController?.pushViewController(svcObj, animated: true)
    }
    
}
    
    
   
    

