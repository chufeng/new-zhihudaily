//
//  HomeViewController.swift
//  new soft
//
//  Created by qianfeng on 2017/1/6.
//  Copyright © 2017年 易达威. All rights reserved.
//

import UIKit
let WINDOW_HEIGHT = UIScreen.main.bounds.size.height
let WINDOW_WIDTH  = UIScreen.main.bounds.size.width
let identifier = "cell"

let url = "http://news-at.zhihu.com/api/4/stories/latest?client=0"
let continueUrl = "http://news-at.zhihu.com/api/4/stories/before/"

let launchImgUrl = "https://news-at.zhihu.com/api/4/start-image/640*1136?client=0"

let topimageHeight:Float = 400
let toWindowHeight:Float = 200

class HomeViewController: UIViewController,TTCollectionViewDelegate,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableview: UITableView!
        var dataKey = NSMutableArray()
        var dataFull = NSMutableDictionary() //date as key, above
        var slideArray = NSMutableArray()
        var slideImgArray = NSMutableArray()
        var slideTtlArray = NSMutableArray()
        let headview=UIView()
        var slieMenu=LLSlideMenu()
        var bloading = false
        var leftSwipe=UIPanGestureRecognizer()
        var percent=UIPercentDrivenInteractiveTransition()
        var dateString = ""
        
        //MARK:-
        
        override  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            self.title = "今日热闻"
            
            let menu=UIBarButtonItem.init(image: UIImage.init(named: "Menu"), style: .plain, target: self, action: #selector(self.text))
            self.navigationItem.leftBarButtonItem = menu
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    func text(){
        if (slieMenu.ll_isOpen) {
            slieMenu.ll_close()
        } else {
            slieMenu.ll_open()
        }
    }
        override func viewDidLoad() {
            super.viewDidLoad()
            self.view.backgroundColor = UIColor.white
            
            let nib = UINib(nibName:"HomeViewCell", bundle: nil)
            self.tableview?.register(nib, forCellReuseIdentifier: identifier)
            self.tableview.delegate=self
            self.tableview.dataSource=self
            self.edgesForExtendedLayout = UIRectEdge.top
            createMenu()
//            showLauchImage()
//            self.tableview.tableHeaderView=headview
            loadData()
        }
    func createMenu(){
        slieMenu=LLSlideMenu()
        self.view.addSubview(slieMenu)
        slieMenu.ll_menuWidth=200
        slieMenu.ll_menuBackgroundColor=UIColor.cyan
        slieMenu.ll_springDamping=20
        slieMenu.ll_springVelocity=15
        slieMenu.ll_springFramesNum=60
        self.leftSwipe=UIPanGestureRecognizer.init(target: self, action: #selector(swipeLeftHandle))
        self.leftSwipe.maximumNumberOfTouches=1;
//        self.view.addGestureRecognizer(leftSwipe)
        let menutb=UITableView.init(frame: CGRect(x: 10, y: 140, width: 180, height: 600), style: .plain)
        let img=UIImageView.init(frame: CGRect(x: 50, y: 60, width: 80, height: 80))
        img.image=UIImage.init(named: "avatar")
        slieMenu.addSubview(menutb)
        slieMenu.addSubview(img)
        
    }
    func swipeLeftHandle(_ recognizer:UIScreenEdgePanGestureRecognizer){
        if (slieMenu.ll_isOpen||slieMenu.ll_isAnimating){
            return;
        }
        var progress=recognizer.translation(in: self.view).x/(self.view.bounds.size.width * 1.0)
        progress=min(1.0, max(0.0,progress))
        if (recognizer.state==UIGestureRecognizerState.began){
            self.percent=UIPercentDrivenInteractiveTransition()
        }else if (recognizer.state==UIGestureRecognizerState.changed){
            self.percent.update(progress)
            slieMenu.ll_distance=recognizer.translation(in: self.view).x
        }else if (recognizer.state==UIGestureRecognizerState.cancelled||recognizer.state==UIGestureRecognizerState.ended){
            if(progress>0.4){
                self.percent.finish()
                slieMenu.ll_open()
            }else{
                self.percent.cancel()
                slieMenu.ll_close()
            }
//            self.percent=nil
        }
        
    }
    lazy var adView:TTCollectionView = {
        let adView = TTCollectionView.init(frame: CGRect(x: 0, y: 0, width: WINDOW_WIDTH, height: 240))
        adView.collectionViewDelegate=self
        adView.timeInterval = 4;
        self.headview.addSubview(adView)
//        self.view.addSubview(adView)
//        self.tableview.tableHeaderView=adView
        
        return adView
        
    }()

        func loadData()
        {
            if(bloading){
                return;
            }
            
            self.bloading = true;
            var curUrl = url;
            if(dateString.lengthOfBytes(using: String.Encoding.utf8) > 0){
                curUrl = continueUrl + dateString;
            }
            ChufengNetworking.GET(succer: { (data) in
                self.bloading = false
                let jsonData = try! JSONSerialization.jsonObject(with: data as Data,options: .allowFragments)as!NSDictionary

                
                
                if(self.dateString.isEmpty){
                    let topArr = jsonData["top_stories"] as! NSArray
                    self.slideArray = NSMutableArray(array:topArr)
                    for topData in topArr
                    {
                        let dic = topData as! NSDictionary
                        let imgUrl = dic["image"] as! String
                        self.slideImgArray.add(imgUrl)
                        
                        let title = dic["title"] as! String
                        self.slideTtlArray.add(title)
                    }
                    self.adView.imagesArr=self.slideImgArray as [AnyObject]
                    self.adView.titleArr=self.slideTtlArray as! [AnyObject]
                    self.adView.imagesCount = self.slideImgArray.count
                    
                }
                
                self.dateString = jsonData["date"] as! String
                
                
                let arr = jsonData["stories"] as! NSArray
                self.dataKey.add(self.dateString);
                self.dataFull.addEntries(from: [self.dateString : arr])
                
                self.tableview!.reloadData()
                
            
                }, failed: { (error) in
                    print(error)
                }, urlSting: curUrl)
    }
        
        func showLauchImage () {
            ChufengNetworking.GET(succer: { (data1) in
                 let data = try! JSONSerialization.jsonObject(with: data1 as Data,options: .allowFragments)as!NSDictionary
                if data as! NSObject == NSNull()
                {
                    return
                }
                
                let imgUrl = data["img"] as! String
                
                let height = UIScreen.main.bounds.size.height
                let width = UIScreen.main.bounds.size.width
                let img = UIImageView(frame:CGRect(x: 0, y: 0, width: width, height: height))
                img.backgroundColor = UIColor.black
                img.contentMode = UIViewContentMode.scaleAspectFit
                
                let window = UIApplication.shared.keyWindow
                window!.addSubview(img)
                let imgurl=URL.init(string: imgUrl)
                img.sd_setImage(with: imgurl)
                
                let lbl = UILabel(frame:CGRect(x: 0,y: height-50,width: width,height: 20))
                lbl.backgroundColor = UIColor.clear
                lbl.text = data["text"] as? String
                lbl.textColor = UIColor.lightGray
                lbl.textAlignment = NSTextAlignment.center
                lbl.font = UIFont.systemFont(ofSize: 14)
                window!.addSubview(lbl)
                
                UIView.animate(withDuration: 2,animations:{
                    let height = UIScreen.main.bounds.size.height
                    let rect = CGRect(x: -100,y: -100,width: width+200,height: height+200)
                    img.frame = rect
                    },completion:{
                        (etion) in
                        
                        if etion {
                            UIView.animate(withDuration: 1,animations:{
                                img.alpha = 0
                                lbl.alpha = 0
                                },completion:{
                                    (etion) in
                                    
                                    if etion {
                                        img.removeFromSuperview()
                                        lbl.removeFromSuperview()
                                    }
                            })
                        }
                })
            
            
                }, failed: { (error) in
                    print(error)
                }, urlSting: launchImgUrl)
            
    }
        //MARK:
        //MARK: -------tableView delegate&datasource
        
        func numberOfSections(in tableView: UITableView) -> Int{
            return 1 + self.dataKey.count
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if section==0{
                return 0
            }
            else
            {
                print("section=",section)
            print((self.dataFull[self.dataKey[section-1] as! String] as! NSArray).count)
                let array1 = self.dataFull[self.dataKey[section-1] as! String] as! NSArray
                return array1.count
            }
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
        {
//            if indexPath.section==0{
//                return CGFloat(toWindowHeight)
//            }
//            else{
                return 106
//            }

        
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            var cell:UITableViewCell
            if (indexPath as NSIndexPath).section==0{
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
//                cell.backgroundColor = UIColor.clear
//                cell.contentView.backgroundColor = UIColor.clear
//                cell.selectionStyle = UITableViewCellSelectionStyle.none
//                cell.clipsToBounds = true
            }
            else{
                let c = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? HomeViewCell
                let index = (indexPath as NSIndexPath).row
                let array1 = self.dataFull[self.dataKey[((indexPath as NSIndexPath?)?.section)!-1] as! String] as! NSArray
                let data = array1[index] as! NSDictionary
                c!.data = data
                cell = c!
            }
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
        {
            print(indexPath.row)
            if (indexPath as NSIndexPath).section==0 {return}
            tableView.deselectRow(at: indexPath,animated: true)
            let index = (indexPath as NSIndexPath).row
            let array1 = self.dataFull[self.dataKey[((indexPath as NSIndexPath?)?.section)!-1] as! String] as! NSArray
            let data = array1[index] as! NSDictionary
            let detailCtrl = DetailViewController(nibName :"DetailViewController", bundle: nil)
            
            detailCtrl.aid = data["id"] as! Int
            self.navigationController!.pushViewController(detailCtrl, animated: true)
        }
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
        {
            if(section < 1)
            {
                return 240
            }else if (section==1){
                return 0
            }else{
            return 30 //NavigationBar Height
            }
            
        }
        
        
        
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
        {
            let lbl = UILabel(frame:CGRect(x: 0,y: 0,width: 320,height: 30))
            lbl.backgroundColor = UIColor.lightGray
            if(section > 0){
                lbl.text = self.dataKey[section-1] as? String
            }else{
                return headview
            }
            lbl.textColor = UIColor.white
            lbl.textAlignment = NSTextAlignment.center
            lbl.font = UIFont.systemFont(ofSize: 14)
            return lbl;
        }
        
        //MARK:
        //MARK:------slidescroll delegate
        
        
        func scrollViewDidScroll(_ scrollView: UIScrollView){
            if(scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.height < scrollView.frame.height/3){
                loadData()
            }
        }
        
        func SlideScrollViewDidClicked(_ index:Int)
        {
            if index == 0 {return} // when you click scrollview too soon after the view is presented
            let data = self.slideArray[index-1] as! NSDictionary
            let detailCtrl = DetailViewController(nibName :"DetailViewController", bundle: nil)
            detailCtrl.aid = data["id"] as! Int
            self.navigationController!.pushViewController(detailCtrl, animated: true)
        }
    func cellClick(with index: Int) {
        print(index)
        let data = self.slideArray[index] as! NSDictionary
        let detailCtrl = DetailViewController(nibName :"DetailViewController", bundle: nil)
        detailCtrl.aid = data["id"] as! Int
        self.navigationController!.pushViewController(detailCtrl, animated: true)
    }
        //MARK:
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
}
