//
//  ZHMainViewController.swift
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 1/24/16.
//  Copyright © 2016 Zakk Hoyt. All rights reserved.
//

import Cocoa

class ZHMainViewController: NSViewController {

    
    var inputFileURLs = [ZHImageMetadata]()
    var outputURL: NSURL? = nil
    
    @IBOutlet weak var outputPathLabel: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var inputPathLabel: NSTextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


    @IBAction func inputURLsButtonAction(sender: AnyObject) {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = [kUTTypeImage as String]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        
        let clicked = panel.runModal()
        
        if clicked == NSFileHandlingPanelOKButton {
            
            for url in panel.URLs {
                if let metadata = ZHImageMetadata(url: url) {
                    inputFileURLs.append(metadata)
                } else {
                    print("Failed to create metadata from url")
                }
            }
            
            tableView.reloadData()

        }
    }
    
    @IBAction func outputURLButtonAction(sender: AnyObject) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        let clicked = panel.runModal()
        
        if clicked == NSFileHandlingPanelOKButton {
            for url in panel.URLs {
                print("selected output dir: " + url.description)
                outputURL = url
                outputPathLabel.stringValue = url.description
            }
        }

    }
}

extension ZHMainViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return inputFileURLs.count
    }
}

extension ZHMainViewController: NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var imageName = ""
        var cellID = ""
        var text = ""
        
        
        guard let metadata = inputFileURLs[row] as? ZHImageMetadata else {
            print("Could not find url for row")
        }
        
        if tableColumn == tableView.tableColumns[0] {
            cellID = "ZHFileTableViewCell"
            text = (metadata.file)!
            imageName = "picture"
        } else if tableColumn == tableView.tableColumns[1] {
            cellID = "ZHResolutionTableViewCell"
            imageName = "resolution"
            text = metadata.resolution!
        } else if tableColumn == tableView.tableColumns[2] {
            cellID = "ZHSizeTableViewCell"
            imageName = "size'"
            text = metadata.size!
        }
        
        if let view = tableView.makeViewWithIdentifier(cellID, owner: nil) as? NSTableCellView {
            if let image = NSImage(named: imageName) {
                view.imageView?.image = image
            }
            view.textField?.stringValue = text
            return view
            
        }
        
        assert(false)
        return nil
    }
}