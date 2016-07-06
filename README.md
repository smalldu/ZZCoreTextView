# ZZCoreTextView

在iOS开发中经常会有这样的需求，自动识别连接、电话号码等。而且把识别的连接显示成网页连接的形式，比如微博。下面看效果图

![效果图](http://upload-images.jianshu.io/upload_images/954071-b8419d0d2437ac94.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

为啥有上下两份呢？可以支持一些样式的自定义，而且上面是手写代码实现。下面是Autolayout实现的哦。只需要给定宽度约束，高度自适应的。非常方便 。


![配图](http://upload-images.jianshu.io/upload_images/954071-a01fdae207fb13cd.gif?imageMogr2/auto-orient/strip)

效果还不错，那么使用起来呢？

使用起来也很方便

`ZZCoreTextView`继承自UIView，使用CoreText技术开发的，支持两种方式的使用(纯代码方式和Autolayout方式)

1、纯代码方式 

在vc的viewDidLoad方法中加入以下代码 

```
 let text = "测试数据 数据www.baidu.com测试iOS学
13182737484习数据sfwgjuigkj系学习的体系学习的体系学习的体
系http://www.zuber.im我乐视接http://www.zuber.im待来访接受
http://www.zuber.im李文科http://www.jianshu.com测试测试测
试http://www.zuber.im测试测试测http://www.zuber.im试测试测
@张三 试测测试http://www.zuber.im测试测试🐦😊测试测
http://www.zuber.im试测试测试测试测试@wikkes 测试
http://www.lanwerwerwerwerwreewrtewrtewrwerewrewrewrwer
werwerewrewrewrewrewrewrwerwwrwerwou3g.com就问了句来了就忘了喂喂喂"
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
```

`ZZStyleModel` 这个方法中声明了一些样式，可以自定义。

![配图](http://upload-images.jianshu.io/upload_images/954071-9f317eb58cc1e98a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

然后就是用`ZZUtil`中的getRowHeightWithText计算出高度，然后使用frame方式创建一个ZZCoreTextView对象，将自定义的styleModel赋值给他就可以了，如果不赋值，则使用默认样式 。

这个的效果就是上半部分，这个库里目前就加了连接、电话以及@someone的识别 

处理方法都用的闭包 

```
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
```

非常方便

有人说些那么多代码太麻烦，我喜欢用AutoLayout，这个也考虑到了，下面看看AutoLayout的使用方式

2、Autolayout实现 

首先拖一个UIView上来

![配图](http://upload-images.jianshu.io/upload_images/954071-ea8b1d8ef8cc2ba8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

然后更改Class

![配图](http://upload-images.jianshu.io/upload_images/954071-671fe90af9ff1a61.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

设置约束，只需要固定宽度，不需要设置高度

![配图](http://upload-images.jianshu.io/upload_images/954071-c17c97a28974462b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这时候可能会报错说渲染失败，没关系，xcode的原因。不影响编译

然后给text赋值 

![配图](http://upload-images.jianshu.io/upload_images/954071-40247597f8e0579b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


就这么简单，这时候你运行 已经可以看到自动识别了，但是你要处理事件还是要关联一个变量，也可以简单自定义 

先声明，关联 
```
@IBOutlet weak var zztextView:ZZCoreTextView!
```

然后简单自定义，并实现闭包方法

```
let styleModel = ZZStyleModel()
            styleModel.urlColor = UIColor.redColor()
            styleModel.atSomeOneColor = UIColor.purpleColor()
            
            zztextView.styleModel = styleModel
            // Autolayout部分
            zztextView.handleUrlTap({ [weak self] (url) in
                self?.showAlert("您点击了== \(url)")
            })
            
            zztextView.handleTelTap({  [weak self](str) in
                 self?.showAlert("点击的电话号码是== \(str)")
            })
            
            zztextView.handleAtTap { [weak self] (str) in
                self?.showAlert("点击的@ some one 是== \(str)")
            }
```

这个就是最上面效果图的地下部分 。 具体实现可以看代码，代码已经上传github，地址 ： https://github.com/smalldu/ZZCoreTextView

喜欢给个star吧 ！
