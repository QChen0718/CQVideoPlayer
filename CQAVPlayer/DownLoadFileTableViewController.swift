//
//  DownLoadFileTableViewController.swift
//  CQAVPlayer
//
//  Created by white on 2021/8/9.
//

import UIKit

import Alamofire
class DownLoadFileTableViewController: UIViewController {

    public var videoUrl:String?
//    进度条
    let pro = UIProgressView()
    
    var cancelledData:Data? //用于停止下载时，保存已下载的部分
    var downloadRequest:DownloadRequest? //下载请求对象
    var destination:DownloadRequest.Destination! //下载文件的保存路径
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        // Do any additional setup after loading the view.
    }
    fileprivate func configUI(){
        self.navigationItem.title = "下载"
        self.view.backgroundColor = UIColor.white
        pro.frame = CGRect.init(x: 50, y: 200, width: 200, height: 50)
        self.view.addSubview(pro)

    }
    
   fileprivate func loadData() {
    //下载的进度条显示
//             Alamofire.download(videoUrl).downloadProgress(queue: DispatchQueue.main) { (progress) in
//                self.pro.setProgress(Float(progress.fractionCompleted), animated: true)//下载进度条
//            }
//
//            //下载存储路径
//            self.destination = {_,response in
//                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
//                let fileUrl = documentsUrl?.appendingPathComponent(response.suggestedFilename!)
//                print(fileUrl)
//                return (fileUrl!,[.removePreviousFile, .createIntermediateDirectories] )
//            }
//
//            self.downloadRequest = Alamofire.download(videoUrl, to: self.destination)
//
//            self.downloadRequest.responseData(completionHandler: downloadResponse)

    }
}
