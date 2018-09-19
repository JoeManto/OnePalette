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

class OPViewController: NSViewController,ColorSquareViewDelegate,NSTextFieldDelegate,
                        ColorGroupSelectorDelegate {

    var colorGroupViewDelegate:ColorViewerController!
    var isViewConfigred = false
    var editingMode = false
   
    private var hexField = NSTextField()
    private var compArray:[NSTextField] = [NSTextField(),NSTextField(),NSTextField()]
    private var isHeaderColorBtn = NSButton(checkboxWithTitle: "Header Color", target: self, action: #selector(setHeaderColor))
    private var colorSelectors:[ColorGroupSelector] = []
    private var addSelector:ColorGroupSelector?
    
    private var colorSqArray:[ColorSquareView] = []
    private var selectedColorSq:Int?
    private var selectedSelector = 1
    private var colorGroup:OPColorGroup?
    private var groupCount:Int?
    private var inititalGroupCount:Int?

    private var keys:[String] = ["Red","Green","Blue"]
    private var editBtn = NSButton(frame: NSRect(x: 460, y: 61, width: 50, height: 30))
    private var cancelBtn = NSButton(frame: NSRect(x: 535, y: 5, width: 60, height: 30))

    private let groupName = OPNameTextField(frameRect: NSRect(x: 120, y: 195, width: 100, height: 30), name:"Blank")
    private let palTitle = OPNameTextField(frameRect: NSRect(x: 60, y: 412, width: 100, height: 30))
    
    private let sortBtns:[NSButton] = [NSButton(frame: NSRect(x: 600, y: 90, width: 130, height:30))]


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
        
        let helpLabel:NSTextField = NSTextField(frame: NSRect(x: x-50, y: Int(self.view.frame.height/2), width: 400, height: 30))
        helpLabel.stringValue = "select a color from this color group to start modifying the color value"
        helpLabel.textColor = NSColor.init(red:189/255 ,green: 189/255, blue: 189/255,alpha:1)
        helpLabel.isEditable = false
        helpLabel.isBordered = false
        helpLabel.backgroundColor = NSColor.clear
        
        
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
        
        cancelBtn.bezelStyle = NSButton.BezelStyle.rounded
        cancelBtn.title = "Close and Update"
        cancelBtn.target = self
        cancelBtn.action = #selector(cancel)
        cancelBtn.setButtonType(NSButton.ButtonType.momentaryPushIn)
        cancelBtn.alignment = NSTextAlignment.center
        
        isHeaderColorBtn.frame = NSRect(x: 400, y:self.view.frame.height/2+80, width: 150, height: 20)
     
        groupName.delegate = self
        groupName.refusesFirstResponder = true
        
        palTitle.delegate = self
        palTitle.tag = 5
        palTitle.placeholderString = "Palette Title"
        palTitle.refusesFirstResponder = true
        
        sortBtns[0].bezelStyle = NSButton.BezelStyle.rounded
        sortBtns[0].title = "Sort By Brightness"
        sortBtns[0].action = #selector(performSort)
        sortBtns[0].setButtonType(NSButton.ButtonType.momentaryPushIn)
        sortBtns[0].alignment = NSTextAlignment.center
        
        self.view.addSubview(editBtn)
        self.view.addSubview(cancelBtn)
        self.view.addSubview(hexLabel)
        self.view.addSubview(groupName)
        self.view.addSubview(palTitle)
        self.view.addSubview(hexField)
        self.view.addSubview(helpLabel)
        self.view.addSubview(isHeaderColorBtn)
        self.view.addSubview(sortBtns[0])
    }
    
    func configColorView(colorgroup:OPColorGroup){
        configOptionsView()
        self.colorGroup = colorgroup
        self.inititalGroupCount = colorgroup.colorsArray.count
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
        self.updateGroupName()
        self.updatePalTitle()
    }
    
    func configColorGroupSelectors(colorgroups:[String:OPColorGroup],keys:[String]){
        var y = 0
        self.groupCount = colorgroups.count
        let height = (420/colorgroups.count)
        for (i,key) in keys.enumerated(){
            colorSelectors.append( ColorGroupSelector(frameRect: NSRect(x: 0, y: y, width: 50, height: height), color: (colorgroups[key]?.getHeaderColor().color)!, id: i))
            colorSelectors.last!.delegate = self as ColorGroupSelectorDelegate
            self.view.addSubview(colorSelectors.last!)
            y+=height
        }
        addSelector = ColorGroupSelector(frameRect: NSRect(x: 0, y: (Int(self.view.frame.height-32)), width: 50, height: 31), color:NSColor.white, id: -1)
        addSelector?.delegate = self as ColorGroupSelectorDelegate
        self.view.addSubview(addSelector!)
    }
    
    
    func updateAndAppendNewGroupSelector() {
        let group = colorGroupViewDelegate.curPal?.generateTempColorGroup()
        let height:Double = 419.0/Double(groupCount!+1)
        var y:Double = 0
        colorSelectors.append(ColorGroupSelector(frameRect: NSRect(x: 0, y: 0, width: 50, height: height), color: group!.colorsArray[0].color, id: groupCount!))
        colorSelectors.last?.delegate = self
        self.view.addSubview(colorSelectors.last!)
        for selector in colorSelectors{
                selector.frame = NSRect(x: 0.0, y: y, width: 50.0, height: height)
                y+=height
        }
        groupCount!+=1
    }
    
    func updateSelectorColorForHeaderColor(selectorId:Int){
        let color:OPColor = (colorGroup?.getHeaderColor())!
        if(color.calcLum() > 0.95){
            colorSelectors[selectorId].layer?.borderWidth = 1
        }else{
            colorSelectors[selectorId].layer?.borderWidth = 0
        }
        colorSelectors[selectorId].setColor(color:color.color)
        colorSelectors[selectorId].layer?.backgroundColor = color.color.cgColor
    }
    
    func colorSelectClicked(id: Int) {
        selectedSelector = id
        let groupID = self.colorGroupViewDelegate.curPal?.paletteKey![id]
        _ = updateColorGroup(groupID:groupID!)
        let curNumColors = self.colorGroup?.colorsArray.count;
        updateColorSqs(curNumColors: curNumColors)
        updateGroupName()
    }
    
    func shouldAddColorGroup(id: Int) {
        if((colorGroupViewDelegate.curPal?.paletteData?.count)! <= 25){
            updateAndAppendNewGroupSelector()
            colorSelectClicked(id:((colorGroupViewDelegate.curPal?.paletteKey?.count)!-1))
        }
    }
    
    func updateGroupName(){
       let name =  self.colorGroup?.getName()
        if name != "blank"{
            self.groupName.stringValue = (self.colorGroup?.getName())!
        }else{
            self.groupName.stringValue = ""
        }
    }
    
    func updatePalTitle(){
        let name = self.colorGroupViewDelegate.curPal?.paletteName
        palTitle.stringValue = name!
    }
    
    func updateColorSqs(curNumColors:Int?){
        let pastnumColors = 10
        if(pastnumColors > curNumColors!){
            for i in curNumColors! ..< pastnumColors{
                colorSqArray[i].makeBlankColorSq()
                colorSqArray[i].editButton?.isHidden = true
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
        groupName.window?.makeFirstResponder(nil)
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
        if(self.selectedColorSq != nil &&
            !self.colorSqArray[self.selectedColorSq!].blankColor ){
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
        colorSqArray[sqId].layer?.borderWidth = 2
        colorSqArray[sqId].layer?.borderColor = NSColor.black.cgColor
    }
    
    func unMarkSq(id:Int) {
        colorSqArray[id].layer?.borderWidth = 0
    }
    
    @objc func startEditing(){
        editingMode = !editingMode
        toggleSortBtnByAnimation(flag:editingMode)
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
    
    func countGroupChanges() -> Int {
        return groupCount! - inititalGroupCount!
    }
    
    func save(){
        self.colorGroupViewDelegate.curPal?.addColorGroup(group: self.colorGroup!)
        _ = self.colorGroupViewDelegate.curPal?.save()
        self.saveGroupName()
        print("selected selector ",selectedSelector )
        self.colorGroupViewDelegate.updateColorSeletors(groupChanges:self.countGroupChanges())
        self.colorGroupViewDelegate.updatePalViewForIndex(index: selectedSelector)
    }
    @objc func cancel(){
        self.save()
        self.view.window?.orderOut(self)
        self.view.window?.close()
    }
    @objc func performSort(){
        self.colorGroup!.sortColorGroupByBrightness()
        self.colorGroup!.updateColorWeights(weights:(self.colorGroupViewDelegate.curPal?.paletteWeights)!)
        self.updateColorSqs(curNumColors: self.colorGroup!.colorsArray.count)
    }
    
    override func controlTextDidChange(_ obj: Notification)
    {
        let object = obj.object as! NSTextField
        let value:Int!
        switch (object.tag){
        case 0,1,2:
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
            }else{
                removeFieldError(textField: object)
                if !doOptionsHaveErrors(optionType:1){ updateColor(hex:hexField.stringValue) }
            }
            break
        case 4:
            if object.stringValue.count > 10{
                object.stringValue = String(object.stringValue.dropLast())
            }
            break
        default: break
        }
    }
    func saveGroupName(){
        self.colorGroup?.setName(name: groupName.stringValue)
    }
    
    func savePalName(){
       let data:NSArray = OPUtil.retrievePaletteForName(name: palTitle.stringValue)
        if data.count > 0{
            palTitle.textColor = NSColor.red
        }else{
            palTitle.textColor = NSColor.black
            self.colorGroupViewDelegate.curPal?.paletteName = palTitle.stringValue
        }
    }
    override func controlTextDidEndEditing(_ obj: Notification) {
        //add the new group the the current color group
       let object = obj.object as! NSTextField
        switch object.tag {
        case 4:
            saveGroupName()
            break
        case 5:
            savePalName()
            break
        default:
            break
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
        if self.colorGroup?.headerColorIndex == self.selectedColorSq {
            setHeaderColor()
        }
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
    
    func updateColorGroup(groupID:String) -> Int?{
        let temp = self.colorGroup?.colorsArray.count
        self.colorGroup = self.colorGroupViewDelegate.curPal?.paletteData![groupID]
        return temp
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
    
    @objc func toggleSortBtnByAnimation(flag:Bool){
        NSAnimationContext.runAnimationGroup({_ in
            NSAnimationContext.current.duration = 1.0
            if flag{
                sortBtns[0].animator().frame = NSRect(x: 460, y: 90, width: 130, height:30)
            }else{
                sortBtns[0].animator().frame = NSRect(x: 600, y: 90, width: 130, height:30)
            }
            
        }, completionHandler:{
        })
    }
}


