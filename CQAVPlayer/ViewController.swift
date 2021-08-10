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
//        downloadFileWithUrl(url:  "https://media.w3.org/2010/05/sintel/trailer.mp4")
        let vc = DownLoadFileTableViewController()
        vc.videoUrl = "https://media.w3.org/2010/05/sintel/trailer.mp4"
        self.navigationController?.pushViewController(vc, animated: true)
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
