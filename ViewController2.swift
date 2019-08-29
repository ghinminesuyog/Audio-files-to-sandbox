import UIKit
import MobileCoreServices
import AVFoundation

class ViewController2: UIViewController, UITableViewDataSource, UITableViewDelegate,AVAudioPlayerDelegate {
    
    
    var arrayRecordings : [String] = []
    
    @IBOutlet weak var myTableView: UITableView!
  
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        
        
        
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            
            let directoryContents = try FileManager.default.contentsOfDirectory( at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            print(directoryContents)
                
            
            let audioFiles = directoryContents.filter{ $0.pathExtension == "m4a" }
            print("m4a urls:",audioFiles)
            
            for i in 0 ..< audioFiles.count
            {
                let audioFileName = audioFiles[i]
            //flatMap({$0.deletingPathExtension().lastPathComponent})
            print("m4a list:", audioFileName)
                arrayRecordings.append("\(audioFileName)")
            }
            
            
            print(arrayRecordings[0].suffix(23))
            
            
            
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return arrayRecordings.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = myTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            
        
            cell.textLabel?.text = "\(arrayRecordings[indexPath.row].suffix(23))"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let f = NSURL.init(fileURLWithPath: arrayRecordings[indexPath.row])
        print(f)
        let fileURL: URL = f as URL
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        print(fileExists)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
     func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}

    
   
