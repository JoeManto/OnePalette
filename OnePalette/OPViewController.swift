//
//  OPViewController.swift
//  OnePalette
//
//  Created by Joe Manto on 4/29/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa

extension NSTextField{
    func controlTextDidChange(obj: NSNotification){}
    func controlTextDidEndEditing(obj: NSNotification){}
    func isValid(forCharSet:NSCharacterSet)->Bool{
        if(self.stringValue.rangeOfCharacter(from: forCharSet as CharacterSet) != nil){
            return true
        }else{
            return false
        }
    }
}

class OPViewController: NSViewController,ColorSquareViewDelegate,NSTextFieldDelegate,ColorGroupSelectorDelegate {

    var colorGroupViewDelegate:ColorViewerController!
    var isViewConfigred = false
    var editingMode = false
    private var hexField = NSTextField()
    private var compArray:[NSTextField] = [NSTextField(),NSTextField(),NSTextField()]
    private var isHeaderColorBtn = NSButton(checkboxWithTitle: "Display Color", target: self, action: #selector(setHeaderColor))
    private var colorSelectors:[ColorGroupSelector] = []
    private var colorSqArray:[ColorSquareView] = []
    private var selectedColorSq:Int?
    private var selectedSelector = 1
    private var colorGroup:OPColorGroup?
    private var groupCount:Int?
    private var keys:[String] = ["Red","Green","Blue"]
    private var editBtn = NSButton(frame: NSRect(x: 460, y: 5, width: 50, height: 30))
    private var saveBtn = NSButton(frame: NSRect(x: 500, y: 5, width: 60, height: 30))
    private var cancelBtn = NSButton(frame:NSRect(x: 400, y: 5, width: 65, height: 30))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.frame = NSMakeRect(0, 0, 600, 450)
        self.view.layer?.backgroundColor = NSColor.white.cgColor
        self.view.layer?.cornerRadius = 10
    }

    private func configOptionsView(){
        isViewConfigred = true
        var x = 160
        let colors:[NSColor] = [NSColor.init(red: 244/255, green: 67/255, blue: 54/255, alpha: 1),
                                NSColor.init(red: 76/255, green: 175/255, blue: 80/255, alpha: 1),
                                NSColor.init(red: 33/255, green: 150/255, blue: 243/255, alpha: 1)]
        let hexLabel:NSTextField = NSTextField(frame: NSRect(x: x, y: Int(self.view.frame.height-150), width: 30, height: 30))
        hexLabel.stringValue = "Hex"
        hexLabel.isEditable = false
        hexLabel.isBordered = false
        hexLabel.textColor = NSColor.black
        
        let helpLabel:NSTextField = NSTextField(frame: NSRect(x: x-50, y: Int(self.view.frame.height/2-55), width: 400, height: 80))
        helpLabel.stringValue = "select a color from this color group to start modifying the color value \nor select a color on the left side to switch color group"
        helpLabel.textColor = NSColor.init(red:189/255 ,green: 189/255, blue: 189/255,alpha:1)
        helpLabel.isEditable = false
        helpLabel.isBordered = false
        
        for (i,key) in keys.enumerated(){
            let tempTextField = NSTextField(frame: NSRect(x: x, y: Int(self.view.frame.height-100), width: 50, height: 30))
            tempTextField.textColor = NSColor.black
            tempTextField.wantsLayer = true
            tempTextField.layer?.borderColor = NSColor.white.cgColor
            tempTextField.layer?.cornerRadius = 5
            tempTextField.delegate = self
            tempTextField.isEditable = false
            tempTextField.tag = i
            compArray[i] = tempTextField
            
            let label = NSTextField()
            label.frame = NSRect(x: x, y: Int(self.view.frame.height-70), width: 50, height: 30)
            label.stringValue = key
            label.textColor = colors[i]
            label.isBordered = false
            label.isEditable = false
            self.view.addSubview(label)
            self.view.addSubview(compArray[i])
            x+=100
        }
        
        hexField.frame = NSRect(x: 190, y: Int(self.view.frame.height-145), width: 100, height: 30)
        hexField.tag = 3
        hexField.isEditable = false
        hexField.delegate = self
        
        editBtn.bezelStyle = NSButton.BezelStyle.rounded
        editBtn.title = "Edit"
        editBtn.target = self
        editBtn.action = #selector(startEditing)
        editBtn.setButtonType(NSButton.ButtonType.pushOnPushOff)
        
        saveBtn.bezelStyle = NSButton.BezelStyle.rounded
        saveBtn.title = "Save"
        saveBtn.target = self
        saveBtn.action = #selector(save)
        saveBtn.setButtonType(NSButton.ButtonType.momentaryPushIn)
        saveBtn.alignment = NSTextAlignment.center
        
        cancelBtn.bezelStyle = NSButton.BezelStyle.rounded
        cancelBtn.title = "Close"
        cancelBtn.target = self
        cancelBtn.action = #selector(cancel)
        cancelBtn.setButtonType(NSButton.ButtonType.momentaryPushIn)
        cancelBtn.alignment = NSTextAlignment.center
        
        isHeaderColorBtn.frame = NSRect(x: 400, y:self.view.frame.height/2+80, width: 150, height: 20)
        
        self.view.addSubview(editBtn)
        self.view.addSubview(saveBtn)
        self.view.addSubview(cancelBtn)
        self.view.addSubview(hexLabel)
        self.view.addSubview(hexField)
        self.view.addSubview(helpLabel)
        self.view.addSubview(isHeaderColorBtn)
    }
    
    func configColorView(colorgroup:OPColorGroup){
        configOptionsView()
        self.colorGroup = colorgroup
        var id = 0
        var x = 120
        var y = 140
        for i in 0..<10{
            if(i<(self.colorGroup?.colorsArray.count)!){
                colorSqArray.append(ColorSquareView(fra: NSRect(x: x, y: y, width: 60, height: 60), opColor: (self.colorGroup?.colorsArray[i])!, id: id, type: 0))
            }else{
                colorSqArray.append(ColorSquareView(fra: NSRect(x: x, y: y, width: 60, height: 60),opColor: (self.colorGroup?.colorsArray[0])!, id: id, type: 0))
                colorSqArray.last?.makeBlankColorSq()
            }
            colorSqArray.last?.delegate = self as ColorSquareViewDelegate;
            self.view.addSubview(colorSqArray.last!)
            x+=70
            if id==4 {y-=75
                      x=120}
            id+=1
        }
        self.updateColorSqs(curNumColors: self.colorGroup?.colorsArray.count)
    }
    
    func configColorGroupSelectors(colorgroups:[String:OPColorGroup],keys:[String]){
        var y = 0
        self.groupCount = colorgroups.count
        let height = (420/colorgroups.count)
        //print("height = ",height)
        //print("numColorGroups",colorgroups.count)
        for (i,key) in keys.enumerated(){
            colorSelectors.append( ColorGroupSelector(frameRect: NSRect(x: 0, y: y, width: 50, height: height), color: (colorgroups[key]?.getHeaderColor().color)!, id: i))
            colorSelectors.last!.delegate = self as ColorGroupSelectorDelegate
            self.view.addSubview(colorSelectors.last!)
            y+=height
        }
        colorSelectors.append( ColorGroupSelector(frameRect: NSRect(x: 0, y: (Int(self.view.frame.height-32)), width: 50, height: 31), color:NSColor.white, id: -1))
        colorSelectors.last!.delegate = self as ColorGroupSelectorDelegate
        self.view.addSubview(colorSelectors.last!)
    }
    
    
    func updateAndAppendNewGroupSelector() {
        let group = colorGroupViewDelegate.curPal?.generateTempColorGroup()
        //print("group count ", groupCount!+1)
        let height:Double = 419.0/Double(groupCount!+1)
        var y:Double = 0
        colorSelectors.append(ColorGroupSelector(frameRect: NSRect(x: 0, y: 0, width: 50, height: height), color: group!.colorsArray[0].color, id: groupCount!))
        colorSelectors.last?.delegate = self
        //print("num selectors",colorSelectors.count)
        self.view.addSubview(colorSelectors.last!)
        for selector in colorSelectors{
            if selector.getID() != -1{
                selector.frame = NSRect(x: 0.0, y: y, width: 50.0, height: height)
                y+=height
            }
        }
        groupCount!+=1
    }
    
    func updateSelectorColorForHeaderColor(selectorId:Int){
        colorSelectors[selectorId].layer?.backgroundColor = colorGroup?.getHeaderColor().color.cgColor
    }
    
    func colorSelectClicked(id: Int) {
        //print("colorSelector Clicked, ",id)
         selectedSelector = id
        let name = self.colorGroupViewDelegate.curPal?.paletteKey![id]
        _ = updateColorGroup(name:name!)
        let curNumColors = self.colorGroup?.colorsArray.count;
        updateColorSqs(curNumColors: curNumColors)
    }
    
    func shouldAddColorGroup(id: Int) {
        if((colorGroupViewDelegate.curPal?.paletteData?.count)! <= 19){
            updateAndAppendNewGroupSelector()
            //colorSelectClicked(id:((colorGroupViewDelegate.curPal?.paletteKey?.count)!-1))
        }
    }
    
    func updateColorSqs(curNumColors:Int?){
        let pastnumColors = 10
        if(pastnumColors > curNumColors!){
            for i in curNumColors! ..< pastnumColors{
                colorSqArray[i].makeBlankColorSq()
                colorSqArray[i].editButton?.isHidden = true
                //print(i)
                if(isChangableBlankSq(id: i)){
                    colorSqArray[curNumColors!].layer?.backgroundColor = NSColor.white.cgColor
                    colorSqArray[curNumColors!].layer?.borderWidth = 1
                }
            }
        }else if pastnumColors < curNumColors!{
            for i in pastnumColors ..< curNumColors!{
                colorSqArray[i].showView()
            }
        }
        for (i,newColor) in (self.colorGroup?.colorsArray.enumerated())!{
            colorSqArray[i].updateForColor(opColor: newColor)
        }
        
    }

    func colorSqClicked(id: Int) {
        if isChangableBlankSq(id:id) || !colorSqArray[id].blankColor{
            markedSq(sqId: id)
            isOptionsEditable(value: true)
            selectedColorSq = id
            if !colorSqArray[id].blankColor{ updateFields(selectedIndex: id)}
        }
        if(!colorSqArray[id].blankColor){selectedColorSq = id}
        if self.colorGroup?.headerColorIndex == id{
            updateHeaderColorCheckBox(checked: true)
        }else{
            updateHeaderColorCheckBox(checked: false)
        }
    }
    @objc func shouldRemoveColor(id: Int) {
        colorGroup?.colorsArray.remove(at: id)
        let curNumColors = self.colorGroup?.colorsArray.count;
        self.colorGroup?.updateColorWeights(weights: (self.colorGroupViewDelegate.curPal?.paletteWeights)!)
        updateColorSqs(curNumColors: curNumColors)
       
    }
    
    @objc func setHeaderColor(){
        if(self.selectedColorSq != nil){
            self.colorGroup?.headerColorIndex = self.selectedColorSq!
            self.colorGroup?.setHeaderColor(header: (self.colorGroup?.colorsArray[self.selectedColorSq!])!)
            self.updateSelectorColorForHeaderColor(selectorId: selectedSelector)
        }
    }
    
    func updateHeaderColorCheckBox(checked:Bool){
        if checked{
             isHeaderColorBtn.state = NSControl.StateValue.on
        }else{
             isHeaderColorBtn.state = NSControl.StateValue.off
        }
    }
    
    func isChangableBlankSq(id:Int) -> Bool{
        if id != 0 && colorSqArray[id].blankColor {
            if !colorSqArray[id-1].blankColor{
                return true
            }
        }else{
            if (id == 0 && colorSqArray[id].blankColor){
                return true
            }
        }
        return false
    }
    
    func markedSq(sqId:Int){
        for (i,sq) in colorSqArray.enumerated(){
            if isChangableBlankSq(id: i) {
            sq.layer?.borderWidth = 1
            }else{sq.layer?.borderWidth = 0}
        }
        //print("set border width = 2")
        colorSqArray[sqId].layer?.borderWidth = 2
        colorSqArray[sqId].layer?.borderColor = NSColor.black.cgColor
    }
    
    func unMarkSq(id:Int) {
        colorSqArray[id].layer?.borderWidth = 0
    }
    
    @objc func startEditing(){
        editingMode = !editingMode
        isOptionsEditable(value:false)
        resetFields()
        if(selectedColorSq != nil){ unMarkSq(id: selectedColorSq!)
            selectedColorSq = nil}
       
        for colorsq in colorSqArray{
            if(!colorsq.blankColor || editingMode == false){
                colorsq.editButton?.isHidden = !editingMode
            }
        }
    }
    
    @objc func save(){
        //print((self.colorGroup?.getName())!)
       // print(self.colorGroupViewDelegate.curPal?.paletteData![(self.colorGroup?.getName())!])
        self.colorGroupViewDelegate.curPal?.addColorGroup(group: self.colorGroup!)
        //self.colorGroupViewDelegate.curPal?.paletteData![(self.colorGroup?.getName())!] = self.colorGroup
        _ = self.colorGroupViewDelegate.curPal?.save()
    }
    @objc func cancel(){
       self.view.window?.orderOut(self)
    }
    
    override func controlTextDidChange(_ obj: Notification)
    {
        let object = obj.object as! NSTextField
        let value:Int!
        switch (object.tag){
        case 0,1,2:
        //print(object.stringValue)
        if(object.stringValue.count > 0 &&
           object.isValid(forCharSet: NSCharacterSet.decimalDigits as NSCharacterSet)){
            value = Int(object.stringValue)!
            if (value > 255 || value < 0){showFieldError(textField: object)}else
            {
                removeFieldError(textField: object)
                if !doOptionsHaveErrors(optionType:0){updateColor(red: compArray[0].stringValue, green: compArray[1].stringValue, blue: compArray[2].stringValue)}
            }
        }else
            if(object.textColor == NSColor.black){showFieldError(textField: object)}
        break
        case 3:
            if(!object.isValid(forCharSet: NSCharacterSet.alphanumerics as NSCharacterSet) || object.stringValue.count != 6){
               showFieldError(textField: object)
                //print("showing error")
            }else{
                removeFieldError(textField: object)
                if !doOptionsHaveErrors(optionType:1){ updateColor(hex:hexField.stringValue) }
            }
        default: break
        }
    }
    
    func updateColor(red:String,green:String,blue:String) {
        //need to add alpha
        hexField.stringValue = ""
        let newColor = OPColor(hexString: NSColor(red: CGFloat(Float(red)!/255), green: CGFloat(Float(green)!/255), blue: CGFloat(Float(blue)!/255), alpha: 1).toHexString, weight:50)
        if(colorSqArray[self.selectedColorSq!].blankColor){
            self.colorGroup?.colorsArray.append(newColor)
        }else{
            self.colorGroup?.colorsArray[self.selectedColorSq!] = newColor
        }
        self.colorGroup?.updateColorWeights(weights: (self.colorGroupViewDelegate.curPal?.paletteWeights)!)
        colorSqArray[self.selectedColorSq!].updateForColor(opColor: newColor)
        if (self.selectedColorSq!-1 <= 9){
            if(self.colorSqArray[self.selectedColorSq!+1].blankColor){
                let colorSqaure = self.colorSqArray[selectedColorSq!+1]
                colorSqaure.layer?.backgroundColor = NSColor.white.cgColor
                colorSqaure.layer?.borderWidth = 1
            }
        }
    }
    func updateColorGroup(name:String) -> Int?{
        let temp = self.colorGroup?.colorsArray.count
        self.colorGroup = self.colorGroupViewDelegate.curPal?.paletteData![name]
        return temp
    }
    
    func updateColor(hex:String) {
        for compFields in compArray{
            if(compFields.tag != 3){
                compFields.stringValue = ""
            }
        }
        let newColor = OPColor(hexString: hex, weight: (self.colorGroup?.colorsArray[self.selectedColorSq!].getWeight())!)
        self.colorGroup?.colorsArray[self.selectedColorSq!] = newColor
        colorSqArray[self.selectedColorSq!].updateForColor(opColor:newColor)
    }
    
    func updateFields(selectedIndex:Int){
        let color = self.colorGroup?.colorsArray[selectedIndex]
        compArray[0].stringValue = String(format: "%.0f", (color?.color.redComponent)!*255)
        compArray[1].stringValue = String(format: "%.0f", (color?.color.greenComponent)!*255)
        compArray[2].stringValue = String(format: "%.0f", (color?.color.blueComponent)!*255)
        let hexString = (color?.getHexString())!.dropFirst()//here
        self.hexField.stringValue = String(hexString)
    }
    
    func resetFields(){
        for field in compArray{
            field.stringValue = ""
            field.resignFirstResponder()
        }
        self.hexField.stringValue = ""
    }
    
    func isOptionsEditable(value:Bool){
        for text in compArray{
            text.isEditable = value
        }
        hexField.isEditable = value
    }
    
    func showFieldError(textField:NSTextField){
        textField.textColor = NSColor.red
    }
    func removeFieldError(textField:NSTextField){
        textField.textColor = NSColor.black
    }
    func doOptionsHaveErrors(optionType:Int) -> Bool {
        switch optionType {
        case 0:
            for textField in compArray{
                if(textField.textColor == NSColor.red || textField.stringValue.count <= 0){
                    return true
                }
            }
        default:
            if(hexField.textColor == NSColor.red){
                return true
            }
        }
        return false
    }
    override func awakeFromNib() {
        if self.view.layer != nil {
            
        }
    }
}


