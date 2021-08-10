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
    fileprivate lazy var progressView:UIProgressView={
        let view = UIProgressView(progressViewStyle: .default)
        view.progressTintColor = .red
        view.tintColor = .blue
        return view
    }()
    
    var cancelledData:Data? //用于停止下载时，保存已下载的部分
    
    private lazy var session:URLSession={
        let config = URLSessionConfiguration.default;
//        视频下载的队列
        let sess = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        return sess
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configUI()
        initFrame()
        downloadFileWithUrl(url: videoUrl ?? "")
    }
    fileprivate func configUI(){
        self.navigationItem.title = "下载"
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(progressView)

    }
    
    fileprivate func initFrame(){
        progressView.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(100)
            make.right.equalTo(-20)
            make.height.equalTo(2)
        }
    }
    
    fileprivate func downloadFileWithUrl(url:String){
//        通过PHPhotoLibrary下载到相册中
//        DispatchQueue.global(qos: .background).async {
//            if let url = URL(string: url), let urlData = NSData(contentsOf: url){
//                let gallerPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
//                let filePath = "\(gallerPath ?? "")/nameX.mp4"
//                DispatchQueue.main.async {
//                    urlData.write(toFile: filePath, atomically: true)
//                    PHPhotoLibrary.shared().performChanges {
//                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
//                    } completionHandler: { success, error in
//                        if success {
//                            print("下载成功")
//                        }else {
//                            print("下载失败")
//                        }
//                    }
//
//                }
//            }
//        }
        
//        通过session下载到指定路径，然后保存到相册中
        if let url = URL(string: url) {
            let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5.0)
            self.session.downloadTask(with: request).resume()
            let task = self.session.downloadTask(with: url) {[weak self] location, response, error in
                let fileManger = FileManager.default
    //            沙盒路径

                let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                let path = "\(documents ?? "")/nameX.mp4"
                do{
                    try fileManger.moveItem(at: location!, to: URL(fileURLWithPath: path))
                }catch{}
    //            保存到相册
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path){
                    UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(self?.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
    //        开始下载任务
            task.resume()
        }
        
    }
    
    ///将下载的网络视频保存到相册
        @objc func video(videoPath: String, didFinishSavingWithError error: NSError, contextInfo info: AnyObject) {
     
            if error.code != 0{
                print("保存失败")
                print(error)
            }else{
                print("保存成功")
            }
     
        }
}
extension DownLoadFileTableViewController:URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        获取到下载结束的本地URL，存储该URL，播放视频
        print("下载结束----location=\(location)")
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        下载进度监听，添加进度条数值更新
        let progress:Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let pro = progress
        DispatchQueue.main.async {[weak self] in
            self?.progressView.progress = pro
        }
        
        print("pro---\(pro)")
    }
}
