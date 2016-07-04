//
//  ZZStyleModel.swift
//  ZZCoreTextView
//
//  Created by duzhe on 16/6/29.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit

public class ZZStyleModel{
     /// 文本颜色
    public var textColor:UIColor = UIColor.blackColor()
    
    public var font:UIFont = UIFont.systemFontOfSize(15)
     /// 字间距
    public var fontSpace:CGFloat = 0
    
    public var faceOffset:CGFloat = 2
     /// 标签图片尺寸
    public var tagImgSize:CGSize = CGSizeMake(14, 14)

     /// 行间距
    public var lineSpace:CGFloat = 4
    
    public var urlUnderLine = false
    
     /// 默认为-1 （<0 为不限制行数）
    public var numberOfLines:Int = -1
    
     /// 高亮圆角
    public var highlightBackgroundRadius:CGFloat = 2
     /// 高亮背景色
    public var highlightBackgroundColor:UIColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
     /// 高亮背景偏移
    public var highlightBackgroundOffset:CGFloat = 0
     /// 高亮背景高度
    public var highlightBackgroundAdjustHeight:CGFloat = 0
    
    public var urlColor:UIColor = UIColor.blueColor()
     /// 号码
    public var numberColor:UIColor = UIColor.blueColor()
    
    public var atSomeOneColor:UIColor = UIColor.blueColor()
    
}

