//
//  ColorGroupSelector.swift
//  OnePalette
//
//  Created by Joe Manto on 3/8/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa

protocol ColorGroupSelectorDelegate: class {
    func colorSelectClicked(id:Int)
    func shouldAddColorGroup(id:Int)
}

class ColorGroupSelector: NSView {

    weak var delegate: ColorGroupSelectorDelegate?
    
    private var color:NSColor
    private var id:Int
    
    private var width:CGFloat = 100.0
    private var height:CGFloat = 100.0
    private var x:CGFloat?
    private var y:CGFloat?
    
    init(frameRect: NSRect,color:NSColor,id:Int) {
        self.color = color
        self.id = id
        super.init(frame: frameRect)
        self.x = frame.origin.x
        self.y = frame.origin.y
        self.wantsLayer = true
        self.layer?.cornerRadius = 0
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if(id == -1){
            let addBtn = NSTextField(frame: NSRect(x: self.frame.width/2-8, y: self.frame.height/2-5, width: 20, height: 20))
            addBtn.font = NSFont(name: "Helvetica Neue", size: 20)
            addBtn.textColor = NSColor(calibratedRed: 30/255, green:32/255, blue: 34/255, alpha: 1)
            addBtn.backgroundColor = NSColor.white
            addBtn.isBezeled = false
            addBtn.isHighlighted = false
            addBtn.isBordered = false
            addBtn.isSelectable = false
            addBtn.isEditable = false
            addBtn.stringValue = "+"
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.bounds
            
            let color1 = NSColor(calibratedRed: 30/255, green:32/255, blue: 34/255, alpha: 1).cgColor
            let color2 = NSColor(calibratedRed: 30/255, green: 32/255, blue: 34/255, alpha: 1).cgColor
            gradientLayer.colors = [color1, color2]
            gradientLayer.locations = [0.1,1.5]
            
            self.layer?.backgroundColor = NSColor.white.cgColor
            self.layer?.borderWidth = 0
            self.layer?.borderColor = NSColor(calibratedRed: 30/255, green:32/255, blue: 34/255, alpha: 1).cgColor
            //self.layer?.addSublayer(gradientLayer)
            self.addSubview(addBtn)
            
        }else{
            self.layer?.backgroundColor = self.color.cgColor
        }
    }
    
    func getID()->Int{
        return self.id
    }
    
    override func mouseUp(with event: NSEvent) {
        print(self.id)
        if id != -1 {
            print("id = ", id)
            delegate?.colorSelectClicked(id:self.id)
        }else{
            delegate?.shouldAddColorGroup(id: self.id)
        }
    }
    
}
