//
//  ViewController.swift
//  ZZCoreTextView
//
//  Created by duzhe on 16/6/29.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit
import SafariServices


func scope(@noescape content:(()->())){
    content()
}
class ViewController: UIViewController {
    
    @IBOutlet weak var zztextView:ZZCoreTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        scope { 
            
            // 手写代码部分 
            let text = "测试数据 数据www.baidu.com测试iOS学13182737484习数据sfwgjuigkj系学习的体系学习的体系学习的体系http://www.zuber.im我乐视接http://www.zuber.im待来访接受http://www.zuber.im李文科http://www.jianshu.com测试测试测试http://www.zuber.im测试测试测http://www.zuber.im试测试测@张三 试测测试http://www.zuber.im测试测试🐦😊测试测http://www.zuber.im试测试测试测试测试@wikkes 测试http://www.lanwerwerwerwerwreewrtewrtewrwerewrewrewrwerwerwerewrewrewrewrewrewrwerwwrwerwou3g.com就问了句来了就忘了喂喂喂"
            let styleModel = ZZStyleModel()
            styleModel.urlColor = UIColor(red: 52/255.0, green: 197/255.0, blue:170/255.0, alpha: 1.0)
            let rowHeight = ZZUtil.getRowHeightWithText(text, rectSize: CGSizeMake(UIScreen.mainScreen().bounds.size.width-10, 1000) , styleModel: styleModel)
            
            let coreTextView = ZZCoreTextView(frame: CGRectMake(5,70,UIScreen.mainScreen().bounds.size.width-10,rowHeight))
            coreTextView.styleModel = styleModel
            coreTextView.backgroundColor = UIColor.whiteColor()
            coreTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
            coreTextView.layer.borderWidth = 0.5
            self.view.addSubview(coreTextView)
            
            coreTextView.text = text
            
            coreTextView.handleUrlTap { [weak self] (url) in
                guard let url = url else { return }
                let safariViewController = SFSafariViewController(URL: url)
                self?.presentViewController(safariViewController, animated: true, completion: nil)
            }
            
            coreTextView.handleTelTap { [weak self] (str) in
                self?.showAlert("点击的电话号码是== \(str)")
            }
            
            coreTextView.handleAtTap { [weak self] (str) in
                self?.showAlert("点击的@ some one 是== \(str)")
            }
            
        }
        
        scope {
            
            let styleModel = ZZStyleModel()
            styleModel.urlColor = UIColor.redColor()
            styleModel.atSomeOneColor = UIColor.purpleColor()
            
            zztextView.styleModel = styleModel
            // Autolayout部分
            zztextView.handleUrlTap({ [weak self] (url) in
                self?.showAlert("您点击了== \(url)")
            })
            
            zztextView.handleTelTap({  [weak self](str) in
                 self?.showAlert("点击的电话号码是== \(str)")
            })
            
            zztextView.handleAtTap { [weak self] (str) in
                self?.showAlert("点击的@ some one 是== \(str)")
            }

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UIViewController{
    func showAlert(meg:String,btn1:String,btn2:String?,handler:((UIAlertAction) -> Void)?){

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let alertController = UIAlertController(title:"提示",
                message:meg ,
                preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title:btn1, style: .Cancel, handler:nil)
            
            alertController.addAction(cancelAction)
            
            if btn2 != nil{
                let settingsAction = UIAlertAction(title: btn2, style: .Default, handler: { (action) -> Void in
                    handler?(action)
                })
                alertController.addAction(settingsAction)
            }
            
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    func showAlert(meg:String){
        showAlert(meg, btn1: "确定", btn2: nil, handler: nil)
    }
}

