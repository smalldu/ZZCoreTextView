//
//  ZZCoreTextView.swift
//  ZZCoreTextView
//
//  Created by duzhe on 16/6/29.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit

@IBDesignable
public class ZZCoreTextView: UIView {
    
    /// 文本
    @IBInspectable var text:String = ""{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    private var fromNib = false
    private var urlTap:((url:NSURL?)->())?
    private var telTap:((str:String)->())?
    private var atTap:((str:String)->())?
    private var keyRectArr:[NSValue:String] = [:]
    private var keyAttributeArr:[String:String] = [:]
    private var keyDatas:[String] = []
    public var styleModel:ZZStyleModel
    private var firstRect = CGRectZero
    private var selfHeight:CGFloat = 0
    
    private var currentRect:[CGRect] = []
    
    override init(frame: CGRect) {
        styleModel = ZZStyleModel()
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        styleModel = ZZStyleModel()
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        styleModel = ZZStyleModel()
        fromNib = true
        super.awakeFromNib()
    }
    
    public func handleUrlTap(urlTap:((url:NSURL?)->())?){
        self.urlTap = urlTap
    }
    
    public func handleTelTap(telTap:((str:String)->())?){
        self.telTap = telTap
    }
    
    public func handleAtTap(atTap:((str:String)->())?){
        self.atTap = atTap
    }
    
    
    public override func intrinsicContentSize() -> CGSize {
        selfHeight = ZZUtil.getRowHeightWithText(text, rectSize: CGSizeMake(CGRectGetWidth(self.bounds),10000), styleModel: styleModel)
        return CGSizeMake(UIViewNoIntrinsicMetric, selfHeight)
    }

    public override func layoutSubviews() {
        // 通知系统改变 内建大小
        if fromNib{
            self.invalidateIntrinsicContentSize()
        }
        super.layoutSubviews()
    }
    
    
    
    public override func drawRect(rect: CGRect) {
        
        super.drawRect(rect)
        
        self.keyRectArr.removeAll()
        self.keyAttributeArr.removeAll()
        self.keyDatas.removeAll()
        //        let isAutoHeight = styleModel.isAutoHeight
        let font = styleModel.font
        //        let numberOfLines = styleModel.numberOfLines
        let lineSpace = styleModel.lineSpace
        
        let highlightBackgroundRadius = styleModel.highlightBackgroundRadius
        let highlightBackgroundColor = styleModel.highlightBackgroundColor
        
        let attrString = ZZUtil.createAttributedStringWithText(text, styleModel: styleModel)
        
        let textRun = ZZTextRun(styleModel: styleModel)
        textRun.runsWithAttrString(attrString)
        
        // 绘图
        let contextRef = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(contextRef, self.backgroundColor?.CGColor)
        
        CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity)
        CGContextTranslateCTM(contextRef, 0, CGRectGetHeight(self.bounds))
        CGContextScaleCTM(contextRef, 1.0, -1.0)
        
        let viewRect = CGRectMake(0, 0, CGRectGetWidth(self.bounds),10000)
        
        //创建一个用来描画文字的路径，其区域为当前视图的bounds  CGPath
        let pathRef = CGPathCreateMutable()
        CGPathAddRect(pathRef, nil, viewRect)
        
        let framesetterRef  = CTFramesetterCreateWithAttributedString(attrString as CFAttributedStringRef)
        
        // 创建由framesetter管理的frame 是描画文字的一个视图范围 CTFrame
        let frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), pathRef, nil)
        
        let lines = CTFrameGetLines(frameRef)
        let lineCount = CFArrayGetCount(lines)
        
        var lineOrigins:[CGPoint] = Array(count:lineCount,repeatedValue:CGPointZero)
        CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0),&lineOrigins)
        
        // 绘制高亮区域
        if self.currentRect.count != 0{
            for rect in self.currentRect{
                let path = UIBezierPath(roundedRect: rect, cornerRadius: highlightBackgroundRadius).CGPath
                CGContextSetFillColorWithColor(contextRef, highlightBackgroundColor.CGColor)
                CGContextAddPath(contextRef, path)
                CGContextFillPath(contextRef)
            }
        }
        
        // ================================= 分割线 =====================================
        var frameY:CGFloat = 0
        let lineHeight = CGFloat( font.lineHeight+lineSpace )
        var prevImgRect:CGRect = CGRectZero
        for i in 0..<lineCount{
            
            let lineRef = unsafeBitCast(CFArrayGetValueAtIndex(lines,i), CTLineRef.self)
            // 获得行首的CGPoint
            var lineOrigin = lineOrigins[i]
            
            frameY = CGRectGetHeight(self.bounds) - CGFloat(i + 1)*lineHeight - font.descender
            lineOrigin.y = frameY
            
            CGContextSetTextPosition(contextRef, lineOrigin.x, lineOrigin.y)
            CTLineDraw(lineRef, contextRef!)
            
            let runs = CTLineGetGlyphRuns(lineRef)
            
            for j in 0..<CFArrayGetCount(runs){
                
                let runRef = unsafeBitCast(CFArrayGetValueAtIndex(runs, j),CTRunRef.self)
                
                var runAscent:CGFloat = 0
                var runDescent:CGFloat = 0
                var runRect:CGRect = CGRectZero
                
                runRect.size.width = CGFloat(CTRunGetTypographicBounds(runRef, CFRangeMake(0,0), &runAscent, &runDescent, nil))
                runRect = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(lineRef, CTRunGetStringRange(runRef).location, nil) , lineOrigin.y ,  runRect.size.width , runAscent + runDescent )
                
                let attributes = CTRunGetAttributes(runRef) as NSDictionary
                let keyAttribute = attributes.objectForKey("keyAttribute") as? String
                
                if let keyAttribute = keyAttribute{
                    
                    var runAscent:CGFloat = 0
                    var runDescent:CGFloat = 0
                    let runWidth = CGFloat(CTRunGetTypographicBounds(runRef, CFRangeMake(0,0), &runAscent, &runDescent, nil))
                    let runPointX = runRect.origin.x + lineOrigin.x
                    let runPointY = lineOrigin.y - styleModel.faceOffset
                    
                    var keyRect = CGRectZero
                    
                    if keyAttribute.characters.first == "U" && styleModel.urlShouldInstead{
                        
                        print(keyAttribute)
                        
                        if !keyDatas.contains(keyAttribute){
                            let img = UIImage(named: "hyperlink.png")
                            keyDatas.append(keyAttribute)
                            
                            firstRect = CGRectMake(runPointX, runPointY-(lineHeight+styleModel.highlightBackgroundAdjustHeight-lineSpace)/4-styleModel.highlightBackgroundOffset, runWidth, lineHeight+styleModel.highlightBackgroundAdjustHeight)
                            // url
                            
                            prevImgRect = CGRectMake(runPointX+2, lineOrigin.y-((lineHeight - styleModel.tagImgSize.height)/4), styleModel.tagImgSize.width,styleModel.tagImgSize.height)
                            CGContextDrawImage(contextRef, prevImgRect, img!.CGImage)
                            
                        }else{
                            if firstRect != CGRectZero{
                                keyRect = CGRectMake(firstRect.origin.x , firstRect.origin.y ,firstRect.width+runWidth,firstRect.height)
                                firstRect = CGRectZero
                            }else{
                                keyRect = CGRectMake(runPointX, runPointY-(lineHeight+styleModel.highlightBackgroundAdjustHeight-lineSpace)/4-styleModel.highlightBackgroundOffset, runWidth, lineHeight+styleModel.highlightBackgroundAdjustHeight)
                            }
                            self.keyRectArr[NSValue(CGRect:keyRect)] = keyAttribute
                        }
                        
                    }else if keyAttribute.characters.first == "T" ||  keyAttribute.characters.first == "A"{
                        
                        keyRect = CGRectMake(runPointX, runPointY-(lineHeight+styleModel.highlightBackgroundAdjustHeight-lineSpace)/4-styleModel.highlightBackgroundOffset, runWidth, lineHeight+styleModel.highlightBackgroundAdjustHeight)
                        self.keyRectArr[NSValue(CGRect:keyRect)] = keyAttribute
                    }else{
                        // 不修改文字的 url
                        keyRect = CGRectMake(runPointX, runPointY-(lineHeight+styleModel.highlightBackgroundAdjustHeight-lineSpace)/4-styleModel.highlightBackgroundOffset, runWidth, lineHeight+styleModel.highlightBackgroundAdjustHeight)
                        self.keyRectArr[NSValue(CGRect:keyRect)] = keyAttribute
                    }
                    
                    
                }
            }
            
        }
    }
    
    
    
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let touches = touches as NSSet
        guard let location = touches.anyObject()?.locationInView(self) else {return}
        let runLocation = CGPointMake(location.x, self.frame.size.height - location.y)
        // 遍历 rect
//        print(self.keyRectArr.count)
        self.currentRect.removeAll()
        var keyAttr = ""
        self.keyRectArr.forEach { (k,v) in
            let rect = k.CGRectValue()
            if CGRectContainsPoint(rect, runLocation){
                keyAttr = v
            }
        }
        if keyAttr != ""{
            self.keyRectArr.forEach { (k,v) in
                if v == keyAttr{
                    self.currentRect.append(k.CGRectValue())
                }
            }
            self.setNeedsDisplay()
        }
    }
    
    
    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        self.keyRectArr.removeAll()
        self.currentRect.removeAll()
        self.setNeedsDisplay()
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        let touches = touches as NSSet
        guard let location = touches.anyObject()?.locationInView(self) else {return}
        let runLocation = CGPointMake(location.x, self.frame.size.height - location.y)
        // 遍历 rect
        self.keyRectArr.forEach { (k,v) in
            let rect = k.CGRectValue()
            if CGRectContainsPoint(rect, runLocation){
                if self.currentRect.contains(rect){
                    if v.hasPrefix("U"){
                        // url 连接
                        if v.containsString("{"){
                            var url = v.split("{")[0].substringFromIndex(1)
                            //                            print(url)
                            if !url.hasPrefix("http"){
                                url = "https://\(url)"
                            }
                            self.urlTap?(url: NSURL(string: url))
                        }
                    }else if v.hasPrefix("T"){
                        let tel = v.split("{")[0].substringFromIndex(1)
                        self.telTap?(str: tel)
                    }else if v.hasPrefix("A"){
                        let someOne = v.split("{")[0].substringFromIndex(1)
                        self.atTap?(str: someOne)
                    }
                    // TODO: - 其他类型
                    
                }
            }
        }
        if self.currentRect.count != 0{
            self.keyRectArr.removeAll()
            self.currentRect.removeAll()
            self.setNeedsDisplay()
        }
    }
    
}

extension String{
    /**
     字符串长度
     */
    public var length:Int{
        get{
            return self.characters.count
        }
    }
    
    /**
     是否包含某个字符串
     
     - parameter s: 字符串
     
     - returns: bool
     */
    func has(s:String)->Bool{
        if self.rangeOfString(s) != nil {
            return true
        }else{
            return false
        }
    }
    
    /**
     分割字符
     
     - parameter s: 字符
     
     - returns: 数组
     */
    func split(s:String)->[String]{
        if s.isEmpty{
            return []
        }
        return self.componentsSeparatedByString(s)
    }
    
    /**
     去掉左右空格
     
     - returns: string
     */
    func trim()->String{
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    /**
     字符串替换
     
     - parameter old: 旧字符串
     - parameter new: 新字符串
     
     - returns: 替换后的字符串
     */
    func replace(old:String,new:String)->String{
        return self.stringByReplacingOccurrencesOfString(old, withString: new, options: NSStringCompareOptions.NumericSearch, range: nil)
    }
    
    /**
     substringFromIndex  int版本
     
     - parameter index: 开始下标
     
     - returns: 截取后的字符串
     */
    func substringFromIndex(index:Int)->String{
        let startIndex = self.characters.startIndex
        return self.substringFromIndex(startIndex.advancedBy(index))
    }
    
    /**
     substringToIndex int版本
     
     - parameter index: 介绍下标
     
     - returns: 截取后的字符串
     */
    func substringToIndex(index:Int)->String{
        let startIndex = self.characters.startIndex
        return self.substringToIndex(startIndex.advancedBy(index))
    }
    
    /**
     substringWithRange int版本
     
     - parameter start: 开始下标
     - parameter end:   结束下标
     
     - returns: 截取后的字符串
     */
    func substringWithRange(start:Int,end:Int)->String{
        let startIndex = self.characters.startIndex
        let range = Range( startIndex.advancedBy(start) ... startIndex.advancedBy(end))
        return self.substringWithRange(range)
    }
    

}
