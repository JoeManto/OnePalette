//
//  QuotesViewController.swift
//  OnePalette
//
//  Created by Joe Manto on 3/1/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa
import CoreData



class ColorViewerController: NSViewController,ColorSquareViewDelegate,ColorGroupSelectorDelegate {
    
    @IBOutlet weak var addColorLabel: NSTextField!
    @IBOutlet weak var paletteTitle: NSTextField!
    @IBOutlet weak var ColorGroupView: NSView!
    @IBOutlet weak var ColorGroupSelectorView: NSView!
    var nextPalBtn: NSButton!
    var pastPalBtn: NSButton!
    var colorValueLabel:NSTextView!
    
    var colorSqArray = [ColorSquareView]()
    var colorSelcArray = [ColorGroupSelector]()
    var headerSqView:ColorSquareView?
    var curPal:Palette?
    var curColorGroup:OPColorGroup?
    
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

        colorValueLabel = NSTextView(frame: NSMakeRect(30,self.view.frame.height-85,120,20))
        colorValueLabel.backgroundColor = NSColor.clear
        colorValueLabel.textColor = NSColor.black
        colorValueLabel.string = (curColorGroup?.getName())!
        colorValueLabel.isEditable = false;
        colorValueLabel.font = NSFont(name: "HelveticaNeue-Light", size: 20.0)!
    
        nextPalBtn = NSButton.init(frame: NSMakeRect(35.0, 320.0, 22.0, 19.0))
        pastPalBtn = NSButton.init(frame: NSMakeRect(12.0, 320.0, 22.0, 19.0))
  
        let pastCell = NSButtonCell.init(textCell: "<")
        pastCell.backgroundColor = NSColor.white
        pastCell.bezelStyle = .texturedSquare
        let nextCell = NSButtonCell.init(textCell: ">")
        
        nextCell.backgroundColor = NSColor.white
        nextCell.bezelStyle = .texturedSquare
        pastPalBtn.state = .off
        pastPalBtn.isEnabled = true
        pastPalBtn.bezelStyle = .texturedSquare
        pastPalBtn.isBordered = false
        pastPalBtn.cell? = pastCell
        
        nextPalBtn.state = .off
        nextPalBtn.isEnabled = true
        nextPalBtn.bezelStyle = .texturedSquare
        nextPalBtn.isBordered = false
        nextPalBtn.cell? = nextCell

        paletteTitle.isBezeled = false
        paletteTitle.drawsBackground = false
        paletteTitle.isEditable = false
        
        self.configPalView(pal: curPal!)
        self.configColorSelctors(pal: curPal!)
        self.view.addSubview(colorValueLabel)
        self.view.addSubview(nextPalBtn)
        self.view.addSubview(pastPalBtn)
 
        //the trackingArea of the Color Selector view
        let area = NSTrackingArea.init(rect: ColorGroupSelectorView.bounds,
                                       options: [NSTrackingArea.Options.mouseEnteredAndExited,
                                                 NSTrackingArea.Options.activeAlways],
                                       owner: self,
                                       userInfo: nil)
        //adds a tracker to the area
        ColorGroupSelectorView.addTrackingArea(area)
    }
    
    /*Checks if the required Paletettes are installed and saves if them if they
     are not and sets the current pal to one of the required palettes*/
    func loadRequiredPalettes() -> Bool {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {return false}
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Pal", in: managedContext)
        
        flushData(entity: entity!, insertInto: managedContext)
        let data = retrievePaletteForName(name: "Apple", insertInto: managedContext)
        managedContext.shouldDeleteInaccessibleFaults = true
        if(data.count>0){
        
            print("[GET] settng saved palette")
            _ = setCurrentPalForRetrivedPalette(data: data, entity: entity!, insertInto: managedContext)
            _ = self.curPal?.save()
            self.deleteFaultingData(entity: entity!, insertInto: managedContext)
            return true
        }else{
            print("[SET] Creating New Palette")
            curPal = Palette.init(name: "Apple", localFile: "AppleDesginColors", entity: entity!, insertInto: managedContext)
            _ = curPal?.save()
            return true
        }
        
    }
    /*Removes all saved entity data in the NSManagedContent*/
    func flushData(entity: NSEntityDescription, insertInto context: NSManagedObjectContext!){
        let Deleterequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pal")
        //Deleterequest.predicate = NSPredicate(format: "paletteName = %@", "Material")
        do {
            let result = try context.fetch(Deleterequest)
            for data in result as! [NSManagedObject] {
                context.delete(data)
                try context.save()
            }
        } catch {
            print("Failed to remove data")
        }
    }
    
    func deleteFaultingData(entity: NSEntityDescription, insertInto context: NSManagedObjectContext!) {
        let Deleterequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pal")
        //Deleterequest.predicate = NSPredicate(format: "paletteName = %@", "Material")
        do {
            let result = try context.fetch(Deleterequest)
            for data in result as! [NSManagedObject] {
                if(data.isFault){
                    context.delete(data)
                    try context.save()
                }
            }
        } catch {
            print("Failed to remove data")
        }
    }
    
    
    func printSavedData(entity: NSEntityDescription, insertInto context: NSManagedObjectContext!){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pal")
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print(data)
            }
        } catch {
            print("Failed to remove data")
        }
    }
    /*retrives a pal entity from the managedContent with a name predicate*/
    func retrievePaletteForName(name:String, insertInto context: NSManagedObjectContext!) ->NSArray{
        let palettesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Pal")
        palettesFetch.predicate = NSPredicate(format: "paletteName = %@", name)
        
        do {
            let fetchedPalettes = try context?.fetch(palettesFetch)
            print("Searching For Palettes Of Name %@",name)
            return fetchedPalettes! as NSArray;
        } catch {
            fatalError("Failed to fetch palettes: \(error)")
        }
        return NSArray.init()
    }
    
    /*Reterives and sets a palette from the imported data from the NSManangedObjectContext*/
    func setCurrentPalForRetrivedPalette(data:NSArray,entity: NSEntityDescription, insertInto context: NSManagedObjectContext!)->Bool {
        if(data.count>0){
            print("set Current Pal",data.count)
           
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
        
        let colorArray:Array<OPColor> = (curColorGroup?.getColorArray())!
        if(colorArray.count>1){
            headerSqView = ColorSquareView.init(fra: NSMakeRect(15, self.view.frame.height/2-85, 150, 150), opColor: (curColorGroup?.getHeaderColor())!,id:0,type:1)
        }else{
          headerSqView = ColorSquareView.init(fra: NSMakeRect(15, self.view.frame.height/2-85, 450, 150), opColor: (curColorGroup?.getHeaderColor())!,id:0,type:1)
        }
        headerSqView!.delegate = self
        self.view.addSubview(headerSqView!)
       
        let xgap:CGFloat = 75
        let ygap:CGFloat = 75
        var x:CGFloat = 180
        var y:CGFloat = self.view.frame.height/2+35
        var rowCount:Int = 0
        
        for (index, i) in colorArray.enumerated() {
            if(rowCount == 3){
                x += xgap
                y = self.view.frame.height/2+35
                rowCount = 0
            }
            colorSqArray.append( ColorSquareView.init(fra: NSMakeRect(x, y, 60, 60), opColor: i,id:index+1,type:0))
            colorSqArray.last?.delegate = self
            //print(i.calcLum())
            y -= ygap
            rowCount += 1
            if(colorArray.count > 1){self.view.addSubview(colorSqArray.last!)}
        }
    }
    
    func configColorSelctors(pal:Palette) {
        let frame:CGRect = ColorGroupSelectorView.frame
        let y = frame.height/2-7.5
        var x:CGFloat = 0
        let width = frame.width/CGFloat((pal.paletteKey?.count)!)
        
        for (index,group) in (pal.paletteKey?.enumerated())!{
            let headerColor:OPColor = (pal.paletteData![group]?.getHeaderColor())!
            colorSelcArray.append(ColorGroupSelector.init(frameRect: NSMakeRect(x, y, width, 10),color:headerColor.color ,id:index))
            colorSelcArray.last?.delegate = self
            ColorGroupSelectorView.addSubview((colorSelcArray.last)!)
            x+=width
        }
    }
    
    func updatePalViewForIndex(index:Int){
        let colorGroup:OPColorGroup = curPal!.paletteData![(curPal?.paletteKey![index])!]!
        let colorArray:Array<OPColor> = colorGroup.getColorArray()
        
        colorValueLabel.string = colorGroup.getName()
        while colorArray.count > colorSqArray.count{
            let index = colorSqArray.count
            let yIndex = Int(index%3)
            let x = CGFloat(Int(index/3)*75)+180
            let y:CGFloat
            if yIndex == 0{
                y = self.view.frame.height/2+35
            }else{
                y = self.view.frame.height/2+35 - CGFloat(Int(index%3)*75)
            }
            colorSqArray.append(ColorSquareView.init(fra: NSMakeRect(x, y, 60, 60), opColor: colorArray[0],id:index+1,type:0))
            colorSqArray.last?.delegate = self
            self.view.addSubview(colorSqArray.last!)
        }
        while colorArray.count < colorSqArray.count{
            colorSqArray.last?.removeFromSuperview()
            colorSqArray.remove(at: colorSqArray.count-1)
        }
        
        for (index, i) in colorArray.enumerated() {
            colorSqArray[index].updateForColor(opColor: i)
            //print(colorSqArray[index].getId())
        }
        headerSqView?.updateForColor(opColor:colorGroup.getHeaderColor())
    }
        

    func colorSqClicked(id:Int) {
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
    
    func shouldAddColorGroup(id: Int) {}

}

extension ColorViewerController {
    // MARK: Storyboard instantiation
    static func freshController() -> ColorViewerController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "ColorViewerController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ColorViewerController else {
            fatalError("Why cant i find ColorViewerController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
