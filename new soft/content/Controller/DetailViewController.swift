//
//  DetailViewController.swift
//  testSwift
//
//  Created by XuDong Jin on 14-6-11.
//  Copyright (c) 2014年 XuDong Jin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController,UIScrollViewDelegate,UIWebViewDelegate {
    let WINDOW_WIDTH  = UIScreen.main.bounds.size.width
    
    @IBOutlet var webView : UIWebView!
    var aid:Int!
    var topImage:UIImageView = UIImageView()
    var url = "https://news-at.zhihu.com/api/3/news/" as String
    
    let kImageHeight:Float = 400
    let kInWindowHeight:Float = 200

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView!.scrollView.delegate = self
        self.webView.delegate=self
        let barImageView = self.navigationController?.navigationBar.subviews.first
        barImageView?.alpha=0
        
        
        loadData()
    }
    
    func loadData()
    {
        url = "\(url)\(aid!)"
        ChufengNetworking.GET(succer: { (data1) in
            let data = try! JSONSerialization.jsonObject(with: data1 as Data,options: .allowFragments)as!NSDictionary
//            if data as! NSObject == NSNull()
//            {
//                UIView.showAlertView("提示",message:"加载失败")
//                return
//            }
            
            var type = data["type"] as! Int
            
            let keys = data.allKeys as NSArray
            if keys.contains("image")
            {
                let imgUrl = data["image"] as! String
                self.topImage.frame = CGRect(origin: CGPoint(x: 0,y: -100),size: CGSize(width: self.WINDOW_WIDTH ,height: 300))
                let imgurl=URL.init(string: imgUrl)
                self.topImage.sd_setImage(with: imgurl, placeholderImage: UIImage(named: "avatar.png"))
                
                self.topImage.contentMode = UIViewContentMode.scaleAspectFill
                self.topImage.clipsToBounds = true
                self.webView!.scrollView.addSubview(self.topImage)
                
                let shadowImg:UIImageView = UIImageView()
                shadowImg.frame = CGRect(origin: CGPoint(x: 0,y: 120),size: CGSize(width: self.WINDOW_WIDTH,height: 80))
                shadowImg.image = UIImage(named:"shadow.png")
                self.webView!.scrollView.addSubview(shadowImg)
                
                var titleLbl:UILabel = UILabel()
                titleLbl.textColor = UIColor.white
                titleLbl.font = UIFont.boldSystemFont(ofSize: 16)
                titleLbl.numberOfLines = 0
                titleLbl.lineBreakMode = NSLineBreakMode.byCharWrapping
                titleLbl.text = (data["title"] as! String)
                titleLbl.frame = CGRect(origin: CGPoint(x: 10,y: 130),size: CGSize(width: 300,height: 50))
                self.webView!.scrollView.addSubview(titleLbl)
                self.title=(data["title"] as! String)
                var copyLbl:UILabel = UILabel()
                var copy = data["image_source"]
                copyLbl.textColor = UIColor.lightGray
                copyLbl.font = UIFont(name: "Arial",size:10)
                copyLbl.text = "图片：\(copy)"
                copyLbl.frame = CGRect(origin: CGPoint(x: 10,y: 180),size: CGSize(width: 300,height: 10))
                copyLbl.textAlignment = NSTextAlignment.right
                self.webView!.scrollView.addSubview(copyLbl)
            }
            
            
            var body = data["body"] as! String
            var css = data["css"] as! NSArray
            var cssUrl = css[0] as! String
            
            body = "<link href='\(cssUrl)' rel='stylesheet' type='text/css' />\(body)"
            
            self.webView!.loadHTMLString(body, baseURL:nil )
            }, failed: { (error) in
                print(error)
            }, urlSting: url)
  

  
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        
        updateOffsets()
    }
    
    func updateOffsets() {
        let yOffset   = self.webView!.scrollView.contentOffset.y
        let threshold = CGFloat(kImageHeight - kInWindowHeight)
        
        if Double(yOffset) > Double(-threshold) && Double(yOffset) < -64 {
            self.topImage.frame = CGRect(origin: CGPoint(x: 0,y: -100+yOffset/2),size: CGSize(width: self.WINDOW_WIDTH,height: 300-yOffset/2));
        }
        else if yOffset < -64 {
            self.topImage.frame = CGRect(origin: CGPoint(x: 0,y: -100+yOffset/2),size: CGSize(width: self.WINDOW_WIDTH,height: 300-yOffset/2));
        }
        else {
            UIView.animate(withDuration: 0.5, animations: { 
            self.topImage.frame = CGRect(origin: CGPoint(x: 0,y: -100),size: CGSize(width: self.WINDOW_WIDTH,height: 300));
            })
            
        }
        
        let barImageView = self.navigationController?.navigationBar.subviews.first
        if Double(yOffset) <= 250{
            barImageView?.alpha = yOffset/200
        }else{
            barImageView?.alpha = 1
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    
        let barImageView = self.navigationController?.navigationBar.subviews.first
        barImageView?.alpha=1
    

    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        
        if request.url==URL.init(string: "about:blank"){
            return true
            print("true")
        }else{
            print("false")
            
            UIApplication.shared.openURL(request.url!)
            return false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
