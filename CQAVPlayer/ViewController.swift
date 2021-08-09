//
//  ViewController.swift
//  CQAVPlayer
//
//  Created by 陈庆 on 2021/8/1.
//

import UIKit
import Photos

class ViewController: UIViewController {

    fileprivate lazy var videoPlayerView:VideoPlayerView={
        let view = VideoPlayerView(frame: .zero)
        view.backgroundColor = .black
        return view
    }()
    
    fileprivate lazy var downBtn:UIButton={
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(download(btn:)), for: .touchUpInside)
        btn.setTitle("下载", for: .normal)
        return btn
    }()
    
    private var gesture:DragGestureHandler?
    
    private lazy var session:URLSession={
        let config = URLSessionConfiguration.default;
//        视频下载的队列
        let sess = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        return sess
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
        setFrame()
        videoPlayerView.videoUrl = "https://media.w3.org/2010/05/sintel/trailer.mp4"
        
        self.gesture = DragGestureHandler(gestureView: videoPlayerView.playerView, bgView: videoPlayerView)
        self.gesture?.completeBlock = {[weak self] (finish) in
            if finish {
//                隐藏视图
                self?.videoPlayerView.isUserInteractionEnabled = false
                self?.videoPlayerView.playerView.myPlayer?.pause()
                self?.videoPlayerView.playerView.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    self?.videoPlayerView.alpha = 0
                } completion: { finish in
                    self?.videoPlayerView.isUserInteractionEnabled = true
                    self?.videoPlayerView.removeFromSuperview()
                }

            }
        }
    }
    
    @objc private func download(btn:UIButton){
        downloadFileWithUrl(url:  "https://media.w3.org/2010/05/sintel/trailer.mp4")
    }
    
    fileprivate func downloadFileWithUrl(url:String){
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: url), let urlData = NSData(contentsOf: url){
                let gallerPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                let filePath = "\(gallerPath ?? "")/nameX.mp4"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges {
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    } completionHandler: { success, error in
                        if success {
                            print("下载成功")
                        }else {
                            print("下载失败")
                        }
                    }

                }
            }
        }
        
        
//        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5.0)
//        self.session.downloadTask(with: request).resume()
//        let task = self.session.downloadTask(with: url) {[weak self] location, response, error in
//            let fileManger = FileManager.default
////            沙盒路径
////            appending("Documents")
//            let documents = NSHomeDirectory()
//            let path = documents.appending(response?.suggestedFilename ?? "")
//            do{
//                try fileManger.moveItem(at: location!, to: URL(fileURLWithPath: path))
//            }catch{}
////            保存到相册
//            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path){
//                UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(self?.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
//            }
//        }
////        开始下载任务
//        task.resume()
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
    fileprivate func initView(){
        view.addSubview(videoPlayerView)
        view.addSubview(downBtn)
    }
    fileprivate func setFrame(){
        videoPlayerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        downBtn.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.top.equalTo(80)
            make.size.equalTo(CGSize(width: 50, height: 30))
        }
    }
}

extension ViewController:URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress:Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let pro = progress * 100
        print("pro---\(pro)")
    }
}
