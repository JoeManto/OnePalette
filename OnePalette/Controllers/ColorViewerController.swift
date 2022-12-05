//
//  QuotesViewController.swift
//  OnePalette
//
//  Created by Joe Manto on 3/1/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa
import CoreData
import SwiftUI

class ColorViewerController: NSHostingController<PaletteView> { //, ColorSquareViewDelegate, ColorGroupSelectorDelegate {
    
    var curPal: Palette
    var curColorGroup: OPColorGroup
    var paletteViewModel: PaletteViewModel
    
    init(curPal: Palette) {
        self.curPal = curPal
        self.curColorGroup = curPal.paletteData?.first?.value ?? OPColorGroup(id: "empty")
        
        self.paletteViewModel = PaletteViewModel(palette: curPal, onNext: {
    
        }, onPrev: {

        })
        
        super.init(rootView: PaletteView(vm: self.paletteViewModel))
    }
    
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        //Adds transparency to the app
        //view.window?.isOpaque = false
        //view.window?.contentViewController?.view.layer?.backgroundColor = .clear
        //view.window?.alphaValue = 0.9 //you can remove this line but it adds a nice effect to it
        
        
        let blurView = NSVisualEffectView(frame: .zero)
        blurView.blendingMode = .withinWindow
        blurView.material = .popover
        blurView.state = .active
        blurView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(blurView)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: self.view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
       
    }
    
   /* /// Checks if the required Paletettes are installed and saves if them if they
    /// are not and sets the current pal to one of the required palettes
    func loadRequiredPalettes() -> Bool {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {return false}
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Pal", in: managedContext)
        
        
        //OPUtil.flushData(entity: entity!, insertInto: managedContext)
        let data = OPUtil.retrievePaletteForName(name: "Material")
        managedContext.shouldDeleteInaccessibleFaults = true
        
        if data.count > 0 {
            for (index,d) in data.enumerated() {
                let temp = d as! NSManagedObject
                if index < data.count - 1 {
                    OPUtil.deleteMangedObject(dataObject: temp, insertInto: managedContext)
                }
            }
            
            print("[GET] settng saved palette")
            _ = setCurrentPalForRetrivedPalette(data: data, entity: entity!, insertInto: managedContext)
            _ = self.curPal.save()
            
            OPUtil.deleteFaultingData(entity: entity!, insertInto: managedContext)
            OPUtil.printSavedData(entity: entity!, insertInto: managedContext)
            
            return true
        }
        else {
            print("[SET] Checking For unloaded required palettes")
            
            curPal = Palette.init(name: "Material", localFile: "MaterialDesginColors", entity: entity!, insertInto: managedContext)
            _ = curPal.save()
            return true
        }
    }
    
    /// Reterives and sets a palette from the imported data from the NSManangedObjectContext
    func setCurrentPalForRetrivedPalette(data: NSArray, entity: NSEntityDescription, insertInto context: NSManagedObjectContext!) -> Bool {
        let dataCount = data.count
        
        guard data.count > 0 else {
            print("No palettes found")
            return false
        }
        
        let materialPal = data.lastObject as! NSManagedObject
        
        curPal = Palette.init(name: materialPal.value(forKey: "paletteName") as! String,
                              data: NSKeyedUnarchiver.unarchiveObject(with: materialPal.value(forKey: "paletteDataToSave") as! Data) as! [String : OPColorGroup],
                              palWeights: materialPal.value(forKey: "paletteWeights") as! [Int],
                              palKeys: materialPal.value(forKey: "paletteKey") as! [String],
                              date: materialPal.value(forKey: "dateCreated") as! Date,
                              entity: entity,
                              insertInto: context)
        
        /*let _:[String:Any] = ["paletteName":curPal?.paletteName!,
                              "paletteDataToSave":NSKeyedUnarchiver.unarchiveObject(with: materialPal.value(forKey: "paletteDataToSave") as! Data) as![String : OPColorGroup]]*/
        //materialPal.setValuesForKeys()
        return true

    }*/
    
    /*@IBOutlet weak var addColorLabel: NSTextField!
    @IBOutlet weak var paletteTitle: NSTextField!
    @IBOutlet weak var ColorGroupView: NSView!
    @IBOutlet weak var ColorGroupSelectorView: NSView!
    var nextPalBtn: NSButton!
    var pastPalBtn: NSButton!
    var colorValueLabel:NSTextView!
    
    var colorSqArray = [ColorSquareView]()
    var colorSelcArray = [ColorGroupSelector]()
    var headerSqView: ColorSquareView?
    var curPal: Palette?
    var curColorGroup: OPColorGroup?
    
    override func viewWillAppear() {
        self.view.layer?.backgroundColor = NSColor.white.cgColor
    }
    
    override var representedObject: Any? {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        curColorGroup = curPal?.paletteData![(curPal?.paletteKey?.first)!]!

        colorValueLabel = NSTextView(frame: NSMakeRect(30, self.view.frame.height - 85, 150, 20))
        colorValueLabel.backgroundColor = NSColor.clear
        colorValueLabel.textColor = NSColor.black
        colorValueLabel.string = (curColorGroup?.getName())!
        colorValueLabel.isEditable = false
        colorValueLabel.font = NSFont(name: "HelveticaNeue-Light", size: 20.0)!
    
        let nextImage = NSImage(imageLiteralResourceName: "nextPalBtn")
        nextImage.size = NSSize(width: nextImage.size.width / 2, height: nextImage.size.height / 2)
        
        let pastImage = NSImage(imageLiteralResourceName: "pastPalBtn")
        pastImage.size = NSSize(width: pastImage.size.width / 2, height: pastImage.size.height / 2)
        
        nextPalBtn = NSButton.init(frame: NSMakeRect(47.0, 322.5, nextImage.size.width, nextImage.size.height))
        nextPalBtn.image = nextImage
        nextPalBtn.isBordered = false
        nextPalBtn.target = self
        nextPalBtn.action =  #selector(nextPal)
        
        pastPalBtn = NSButton.init(frame: NSMakeRect(20.0, 322.5, pastImage.size.width, pastImage.size.height))
        pastPalBtn.image = pastImage
        pastPalBtn.isBordered = false
        pastPalBtn.target = self
        pastPalBtn.action =  #selector(pastPal)

        paletteTitle.isBezeled = false
        paletteTitle.drawsBackground = false
        paletteTitle.isEditable = false
        
        self.configPalView(pal: curPal!)
        //self.addColorGroupView()
        
        self.configColorSelctors(pal: curPal!)
        self.view.addSubview(colorValueLabel)
        self.view.addSubview(nextPalBtn)
        self.view.addSubview(pastPalBtn)
 
        // The trackingArea of the Color Selector view
        let area = NSTrackingArea.init(rect: ColorGroupSelectorView.bounds,
                                       options: [NSTrackingArea.Options.mouseEnteredAndExited,
                                                 NSTrackingArea.Options.activeAlways],
                                       owner: self,
                                       userInfo: nil)
        // Adds a tracker to the area
        ColorGroupSelectorView.addTrackingArea(area)
    }
    
    func addColorGroupView() {
        
    }
    
    /// Checks if the required Paletettes are installed and saves if them if they
    /// are not and sets the current pal to one of the required palettes
    func loadRequiredPalettes() -> Bool {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {return false}
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Pal", in: managedContext)
        
        
        //OPUtil.flushData(entity: entity!, insertInto: managedContext)
        let data = OPUtil.retrievePaletteForName(name: "Material")
        managedContext.shouldDeleteInaccessibleFaults = true
        
        if data.count > 0 {
            for (index,d) in data.enumerated() {
                let temp = d as! NSManagedObject
                if index < data.count - 1 {
                    OPUtil.deleteMangedObject(dataObject: temp, insertInto: managedContext)
                }
            }
            
            print("[GET] settng saved palette")
            _ = setCurrentPalForRetrivedPalette(data: data, entity: entity!, insertInto: managedContext)
            _ = self.curPal?.save()
            
            OPUtil.deleteFaultingData(entity: entity!, insertInto: managedContext)
            OPUtil.printSavedData(entity: entity!, insertInto: managedContext)
            
            return true
        }
        else {
            print("[SET] Checking For unloaded required palettes")
            
            curPal = Palette.init(name: "Material", localFile: "MaterialDesginColors", entity: entity!, insertInto: managedContext)
            _ = curPal?.save()
            return true
        }
    }
    
    /// Reterives and sets a palette from the imported data from the NSManangedObjectContext
    func setCurrentPalForRetrivedPalette(data: NSArray, entity: NSEntityDescription, insertInto context: NSManagedObjectContext!) -> Bool {
        let dataCount = data.count;
        if(dataCount>0){
            
            let materialPal = data.lastObject as! NSManagedObject
            curPal = Palette.init(name: materialPal.value(forKey: "paletteName") as! String,
                                  data:NSKeyedUnarchiver.unarchiveObject(with: materialPal.value(forKey: "paletteDataToSave") as! Data) as![String : OPColorGroup],
                                  palWeights:materialPal.value(forKey: "paletteWeights") as! [Int],
                                  palKeys:materialPal.value(forKey: "paletteKey") as! [String],
                                  entity: entity,
                                  insertInto: context)
            
            /*let _:[String:Any] = ["paletteName":curPal?.paletteName!,
                                  "paletteDataToSave":NSKeyedUnarchiver.unarchiveObject(with: materialPal.value(forKey: "paletteDataToSave") as! Data) as![String : OPColorGroup]]*/
            //materialPal.setValuesForKeys()
            return true
            
        }else{
            print("no pal found")
            return false
        }
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        for selector in colorSelcArray{
            selector.frame = NSMakeRect(selector.frame.origin.x, selector.frame.origin.y-5, selector.frame.width, selector.frame.height+10)
        }
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        for selector in colorSelcArray{
            selector.frame = NSMakeRect(selector.frame.origin.x, selector.frame.origin.y+5, selector.frame.width, 10)
        }
    }
    
    func configPalView(pal:Palette) {
        let colorArray: [OPColor] = (curColorGroup?.getColorArray())!
        self.paletteTitle.stringValue = pal.paletteName;
        
        if colorArray.count > 1 {
            headerSqView = ColorSquareView.init(fra: NSMakeRect(15, self.view.frame.height/2-85, 150, 150), opColor: (curColorGroup?.getHeaderColor())!,id:0,type:1)
        }
        else {
          headerSqView = ColorSquareView.init(fra: NSMakeRect(15, self.view.frame.height/2-85, 450, 150), opColor: (curColorGroup?.getHeaderColor())!,id:0,type:1)
        }
        
        headerSqView!.delegate = self
        self.view.addSubview(headerSqView!)
       
        let xgap: CGFloat = 75
        let ygap: CGFloat = 75
        var x: CGFloat = 180
        var y: CGFloat = self.view.frame.height / 2 + 35
        var rowCount: Int = 0
        
        for (index, i) in colorArray.enumerated() {
            if rowCount == 3 {
                x += xgap
                y = self.view.frame.height / 2 + 35
                rowCount = 0
            }
            colorSqArray.append(ColorSquareView.init(fra: NSMakeRect(x, y, 60, 60), opColor: i, id: index + 1, type: 0))
            colorSqArray.last?.delegate = self

            y -= ygap
            rowCount += 1
            if colorArray.count > 1 {
                self.view.addSubview(colorSqArray.last!)
            }
        }
    }
    
    func configColorSelctors(pal:Palette) {
        let frame = ColorGroupSelectorView.frame
        let y = frame.height / 2 - 7.5
        var x: CGFloat = 0
        let width = frame.width / CGFloat((pal.paletteKey?.count)!)
        
        for (index,group) in (pal.paletteKey?.enumerated())! {
            let headerColor:OPColor = (pal.paletteData![group]?.getHeaderColor())!
            colorSelcArray.append(ColorGroupSelector.init(frameRect: NSMakeRect(x, y, width, 10),color:headerColor.color ,id:index))
            colorSelcArray.last?.delegate = self
            ColorGroupSelectorView.addSubview((colorSelcArray.last)!)
            x += width
        }
    }
    
    func addColorSelect() {
        colorSelcArray.append(ColorGroupSelector.init(frameRect: NSRect(x: 0, y: 0, width: 0, height: 10), color: NSColor.clear, id: (colorSelcArray.last?.getID())! + 1))
        colorSelcArray.last?.delegate = self
        ColorGroupSelectorView.addSubview((colorSelcArray.last)!)
    }
    
    func removeColorSelect() {
        self.colorSelcArray.last?.removeFromSuperview()
        self.colorSelcArray.last?.delegate = nil
        colorSelcArray.remove(at: colorSelcArray.count - 1)
    }
    
    func updateColorSeletors(groupChanges: Int?) {
        let frame: CGRect = ColorGroupSelectorView.frame // is nil if the pal view isnt allocated before you change colors
        let y = frame.height/2 - 7.5
        let width = frame.width/CGFloat((curPal?.paletteKey?.count)!)
        var x: CGFloat = 0
        var i: Int = groupChanges!
        while i != 0 {
            if i > 0 {
                self.addColorSelect()
                i -= 1
            }
            else if i < 0 {
                self.removeColorSelect()
                i += 1
            }
        }
        
        for(index, group) in (curPal?.paletteKey?.enumerated())! {
            let headerColor: OPColor = (curPal?.paletteData![group]?.getHeaderColor())!
            colorSelcArray[index].frame = NSMakeRect(x, y, width, 10)
            colorSelcArray[index].layer?.backgroundColor = headerColor.color.cgColor
            colorSelcArray[index].setColor(color: headerColor.color)
            x += width
        }
    }
    
    func updatePalViewForIndex(index: Int) {
        let colorGroup: OPColorGroup = curPal!.paletteData![(curPal?.paletteKey![index])!]!
        let colorArray: [OPColor] = colorGroup.getColorArray()
        
        if colorGroup.getName() == "" {
            colorGroup.setName(name: "blank")
        }
        colorValueLabel.string = colorGroup.getName()
        
        while colorArray.count > colorSqArray.count {
            let index = colorSqArray.count
            let yIndex = Int(index % 3)
            let x = CGFloat(Int(index / 3) * 75) + 180
            let y: CGFloat
            if yIndex == 0 {
                y = self.view.frame.height / 2 + 35
            } else {
                y = self.view.frame.height / 2 + 35 - CGFloat(Int(index % 3) * 75)
            }
            colorSqArray.append(ColorSquareView.init(fra: NSMakeRect(x, y, 60, 60), opColor: colorArray[0], id: index + 1, type: 0))
            colorSqArray.last?.delegate = self
            self.view.addSubview(colorSqArray.last!)
        }
        
        while colorArray.count < colorSqArray.count {
            colorSqArray.last?.removeFromSuperview()
            colorSqArray.remove(at: colorSqArray.count - 1)
        }
        
        for (index, i) in colorArray.enumerated() {
            colorSqArray[index].updateForColor(opColor: i)
        }
        headerSqView?.updateForColor(opColor:colorGroup.getHeaderColor())
    }

    func colorSqClicked(id: Int) {
        //print("button was clicked with ", id);
    }
    
    func colorSelectClicked(id: Int) {
        if curPal?.curGroupIndex != id {
            updatePalViewForIndex(index: id)
            curPal?.curGroupIndex = id
            print("color selector clicked with ",id)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func shouldAddColorGroup(id: Int) {
        
    }
    
    @objc func pastPal(){
        print("past")
    }
    
    @objc func nextPal(){
        print("next")
        //if(curPal?.paletteName != palNameList.last){
          //  let indexOfNext = palNameList.index(of: (curPal?.paletteName)!)!+1
           // let nextPal:String = palNameList[indexOfNext]
           // changePalForPalName(palName: nextPal)
        //}
    }
    
    func changePalForPalName(palName: String) -> Bool {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return false }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Pal", in: managedContext)
        
        let data = OPUtil.retrievePaletteForName(name: palName)
        _ = setCurrentPalForRetrivedPalette(data: data, entity: entity!, insertInto: managedContext)
        
        return true
    }
*/
}
