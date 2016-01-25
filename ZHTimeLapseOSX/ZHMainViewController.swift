//
//  ZHMainViewController.swift
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 1/24/16.
//  Copyright © 2016 Zakk Hoyt. All rights reserved.
//

import Cocoa

class ZHMainViewController: NSViewController {

    
    var inputFileURLs = [NSURL]()
    
    
    @IBOutlet weak var tableView: NSTableView!
    
    
    
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
            inputFileURLs = panel.URLs
            tableView.reloadData()
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
        
        
        guard let url = inputFileURLs[row] as? NSURL else {
            print("Could not find url for row")
        }
//        let url = inputFileURLs[row] as? NSURL
        
        
        if tableColumn == tableView.tableColumns[0] {
            cellID = "ZHFileTableViewCell"
            text = (url.pathComponents?.last)!
            imageName = "picture"
        } else if tableColumn == tableView.tableColumns[1] {
            cellID = "ZHResolutionTableViewCell"
//            text = u
            imageName = "resolution"
            text = "res"
        } else if tableColumn == tableView.tableColumns[2] {
            cellID = "ZHSizeTableViewCell"
            imageName = "size'"
            text = "size"
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