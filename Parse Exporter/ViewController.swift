//
//  ViewController.swift
//  Parse Exporter
//
//  Created by Nick Dalke on 1/12/17.
//  Copyright © 2017 Nick Dalke. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var displayTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        displayTextField.stringValue = ""
    }

    @IBAction func openFileAction(_ sender: Any) {
        
        displayTextField.stringValue = "Loading"
        let dialog = NSOpenPanel()
        dialog.worksWhenModal = true
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.resolvesAliases = true
        dialog.title = "Open JSON"
        dialog.message = "Open the json file you want to save."
        dialog.runModal()
        guard
            let url = dialog.url?.absoluteURL
            else {
                print("Loading canceled")
                return;
        }
        
        guard
            let stringData = try? Data(contentsOf: url)
            else {
                exit(-1)
        }
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            
            do {
                let  dataString = try JSONSerialization.jsonObject(with: stringData, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : Any]
                
                guard let results = dataString["results"] as? [[String : Any]] else {
                    return
                }
                
                
                for result in results  {
                    let description = (result["description"] as? String) ?? ""
                    let category = (result["category"]  as? String) ?? ""
                    let isPending = (result["isPending"] as? Bool) ?? false
                    let title = (result["title"]  as? String) ?? ""
                    let location = (result["location"]  as? String) ?? ""
                    let keywords = (result["keywords"]  as? String) ?? ""
                    let website = (result["website"]  as? String) ?? ""
                    let cost = (result["cost"]  as? String) ?? ""
                    
                    var coordinate : PFGeoPoint? = nil
                    if let coordinateDic = result["coordinate"] as? [String : Any] {
                        if let latitude = coordinateDic["latitude"] as? Double, let longitude = coordinateDic["longitude"]as? Double  {
                            coordinate = PFGeoPoint(latitude: latitude, longitude: longitude)
                        }
                    } else if let coordinateStr = result["coordinate"] as? String {
                        let coordinates = coordinateStr.components(separatedBy: ", ")
                        if let latitude = coordinates.first, let longitude = coordinates.last {
                            coordinate = PFGeoPoint(latitude: Double(latitude)!, longitude: Double(longitude)!)
                        }
                    }
                    
                    
                    var imageFile : PFFile? = nil
                    if let imageDic = result["image"] as? [String : Any] {
                        if let  imageDataURL = imageDic["url"] as? String {
                            let url = URL(string: imageDataURL)!
                            do {
                                if let imageData = try? Data(contentsOf: url) {
                                    imageFile = PFFile(name: "image.jpeg", data: imageData)
                                }
                            } catch {
                                print("Unable to get a image for \(title)")
                            }
                        }
                    } else if let  imageDataURL = result["image"] as? String {
                        let url = URL(string: imageDataURL)!
                        do {
                            if let imageData = try? Data(contentsOf: url) {
                                imageFile = PFFile(name: "image.jpeg", data: imageData)
                            }
                        } catch {
                            print("Unable to get a image for \(title)")
                        }
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    
                    let dateFormatter2 = DateFormatter()
                    dateFormatter2.dateFormat = "MM/dd/yyyy HH:mm:ss"
                    
                    dateFormatter.dateFormat = ""
                    
                    var startDate : Date? = nil
                    if let startDateDic = result["startDate"] as? [String: String] {
                        if let iso = startDateDic["iso"] {
                            if let tmpDate = dateFormatter.date(from: iso) {
                                startDate = tmpDate
                            } else if let tmpDate = dateFormatter2.date(from: iso) {
                                startDate = tmpDate
                            }
                        }
                    } else if let iso = result["startDate"] as? String {
                        if let tmpDate = dateFormatter.date(from: iso) {
                            startDate = tmpDate
                        } else if let tmpDate = dateFormatter2.date(from: iso) {
                            startDate = tmpDate
                        }
                    }
                    
                    var endDate : Date? = nil
                    if let endDateDic = result["endDate"] as? [String: String] {
                        if let iso = endDateDic["iso"] {
                            if let tmpDate = dateFormatter.date(from: iso) {
                                endDate = tmpDate
                            } else if let tmpDate = dateFormatter2.date(from: iso) {
                                endDate = tmpDate
                            }
                        }
                    } else if let iso = result["endDate"] as? String {
                        if let tmpDate = dateFormatter.date(from: iso) {
                            endDate = tmpDate
                        } else if let tmpDate = dateFormatter2.date(from: iso) {
                            endDate = tmpDate
                        }
                    }
                    
                    let event = PFObject(className: "Events")
                    event["description"] = description
                    event["category"] = category
                    event["isPending"] = isPending
                    event["title"] = title
                    event["location"] = location
                    event["keywords"] = keywords
                    event["website"] = website
                    event["cost"] = cost
                    event["startDate"] = startDate
                    event["endDate"] = endDate
                    
                    if let coordinate = coordinate {
                        event["coordinate"] = coordinate
                    }
                    
                    if let imageFile = imageFile {
                        do {
                            try  imageFile.save()
                            event["image"] = imageFile
                        } catch {
                            print("Unable to save image")
                        }
                    }
                    
                    
                    do {
                        try  event.save()
                    } catch {
                        print("error saving \(title)")
                    }
                    
                }
                
            } catch {
                
            }
            
            // Finished saving
            
            DispatchQueue.main.async {
                self.displayTextField.stringValue = "Success"
            }
        }
        
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

