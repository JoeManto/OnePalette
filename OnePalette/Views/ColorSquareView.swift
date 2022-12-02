//
//  ColorSquareView.swift
//  OnePalette
//
//  Created by Joe Manto on 3/4/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa

@objc protocol ColorSquareViewDelegate: class {
    func colorSqClicked(id: Int)
    @objc optional func shouldRemoveColor(id: Int)
}

class ColorSquareView: NSView {
    weak var delegate: ColorSquareViewDelegate?
    
    private var colorWeightLabel: NSTextView
    private var colorHexLabel: NSTextView
    var editButton: NSButton?
    
    private var x: CGFloat
    private var y: CGFloat
    private var width: CGFloat
    private var height: CGFloat
    private var opcolor: OPColor
    private var id: Int
    private var type: Int
    var blankColor = false
    
    init(fra: NSRect, opColor: OPColor, id: Int, type: Int) {
        self.x = fra.origin.x
        self.y = fra.origin.y
        self.width = fra.width
        self.height = fra.height
        self.opcolor = opColor
        self.id = id
        self.type = type
        self.colorHexLabel = NSTextView(frame: NSMakeRect(100, 100, 100, 20))
        self.colorWeightLabel = NSTextView(frame: NSMakeRect(100, 100, 100, 20))
        super.init(frame: fra)
        self.wantsLayer = true
        
        // Edit button that starts the editing process
        self.editButton = NSButton(frame:NSRect(x: self.frame.width - 35, y: -4, width: 38, height: 32))
        self.editButton?.wantsLayer = true
        self.editButton?.bezelStyle = .circular
        self.editButton?.target = self
        self.editButton?.setButtonType(NSButton.ButtonType.onOff)
        self.editButton?.action =  #selector(touchUpInRemoveBtn)
        self.editButton?.image = NSImage(imageLiteralResourceName: "removeBtn")
        self.editButton?.image?.size = NSSize(width: (self.editButton?.frame.width)!, height: (self.editButton?.frame.height)!)
        self.editButton?.isHidden = true
        
        self.config()
    }
    
    func config() {
        self.layer?.backgroundColor = self.opcolor.color.cgColor
        self.layer?.cornerRadius = 40
        
        // different values to fit both types of colorsquares big and small.
        // may add a type object to this class in the future
        var fontSize: CGFloat = 15
        var marginRight: CGFloat = 15
        var marginText: CGFloat = 0
        var marginTop: CGFloat = 30
        var fontColor = NSColor.white
        
        if type == 0 {
            fontSize = 12
            marginRight = 0
            marginText = 5
            marginTop = 25
            self.layer?.cornerRadius = 10
        }
        
        // Calcs the lum of the background so the color of the text is visiable
        if opcolor.calcLum() > CGFloat(0.90) {
            fontColor = NSColor(calibratedRed: 33.0/255.0, green: 33.0/255.0, blue: 33.0/255.0, alpha: 1)
        }
        
        colorHexLabel = NSTextView(frame: NSMakeRect(marginRight, self.height - marginTop, 100, 20))
        colorHexLabel.backgroundColor = NSColor.clear
        colorHexLabel.textColor = fontColor
        colorHexLabel.string = self.opcolor.getHexString()
        colorHexLabel.isEditable = false
        colorHexLabel.font = NSFont(name: "HelveticaNeue-Light", size: fontSize)!
        
        colorWeightLabel = NSTextView(frame: NSMakeRect(marginRight, self.height - (marginTop+20) + marginText, 100, 20))
        colorWeightLabel.backgroundColor = NSColor.clear
        colorWeightLabel.textColor = fontColor
        colorWeightLabel.string = String(self.opcolor.getWeight())
        colorWeightLabel.isEditable = false
        colorWeightLabel.isSelectable = false
        colorWeightLabel.font = NSFont(name: "HelveticaNeue-Light", size: fontSize-2)!
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        self.addSubview(colorHexLabel)
        self.addSubview(colorWeightLabel)
        self.addSubview(editButton!)
    }
    
    func updateForColor(opColor: OPColor) {
        self.opcolor = opColor
        self.colorWeightLabel.isHidden = false
        self.colorHexLabel.isHidden = false
        self.blankColor = false
        self.layer?.borderWidth = 0
        self.layer?.backgroundColor = self.opcolor.color.cgColor
        self.colorHexLabel.string = self.opcolor.getHexString()
        self.colorWeightLabel.string = String(self.opcolor.getWeight())
        var fontColor: NSColor = NSColor.white
        if opcolor.calcLum() > CGFloat(0.90) {
            fontColor = NSColor(calibratedRed: 33.0/255.0, green: 33.0/255.0, blue: 33.0/255.0, alpha: 1)
        }
        colorHexLabel.textColor = fontColor
        colorWeightLabel.textColor = fontColor
    }
    
    func hideView() {
        self.isHidden = true
    }
    
    func showView() {
        self.isHidden = false
    }
    
    func makeBlankColorSq() {
        self.blankColor = true
        self.layer?.backgroundColor = NSColor.init(red: 245/255 ,green: 245/255, blue: 245/255, alpha: 1).cgColor
        self.layer?.borderWidth = 0
        self.layer?.borderColor = NSColor.black.cgColor
        self.colorHexLabel.isHidden = true
        self.colorWeightLabel.isHidden = true
        self.updateLayer()
    }
    
    override func mouseUp(with event: NSEvent) {
        if let edit = editButton, edit.isHidden {
            delegate?.colorSqClicked(id: id)
        }
    }
    
    @objc func touchUpInRemoveBtn() {
        if !self.blankColor {
            delegate?.shouldRemoveColor!(id: id)
        }
    }
    
    func getId() -> Int {
        return self.id
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


