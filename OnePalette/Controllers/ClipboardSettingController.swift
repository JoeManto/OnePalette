//
//  ClipboardSettingController.swift
//  OnePalette
//
//  Created by Joe Manto on 7/1/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa

class ClipboardSettingController: NSViewController,NSTableViewDelegate,NSTableViewDataSource{
    
    var testdata: [[String: String]]?
    var scroll:NSScrollView?
    let table:NSTableView = NSTableView(frame:NSRect(x:125, y: 100, width: 300, height: 200))
    
    override func viewWillAppear() {

    }
    override func awakeFromNib() {
        self.table.dataSource = self
        self.table.delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        scroll = NSScrollView(frame: NSRect(x:125, y: 100, width: 300, height: 200))
        let tableColumn = NSTableColumn()
        tableColumn.headerCell.title = "Age"
        tableColumn.headerCell.textColor = NSColor.black
        tableColumn.headerCell.alignment = .center
        tableColumn.identifier = NSUserInterfaceItemIdentifier(rawValue: "age")

        self.table.addTableColumn(tableColumn)
        scroll?.documentView = self.table
        
        scroll?.hasVerticalRuler = false
        scroll?.hasHorizontalRuler = false
        scroll?.focusRingType = NSFocusRingType.none
        scroll?.resignFirstResponder
        struct asset{
            let format:String
        }
        
        self.table.wantsLayer = true
        self.table.layer?.backgroundColor = NSColor.white.cgColor
        self.table.reloadData()
        self.view.addSubview(scroll!)
        
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        print("hello")
        let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
        cell?.textField?.stringValue = "hello"
        return cell
    }
    
    func numberOfRowsInTableView (tableView: NSTableView) -> Int {
        print ("numberOfRowsInTableView:")
        return 10
    }

    override func loadView() {
        self.view = NSView()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


