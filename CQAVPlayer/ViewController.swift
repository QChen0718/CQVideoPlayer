//
//  ViewController.swift
//  CQAVPlayer
//
//  Created by 陈庆 on 2021/8/1.
//

import UIKit

class ViewController: UIViewController {

    fileprivate lazy var videoPlayerView:VideoPlayerView={
        let view = VideoPlayerView(frame: .zero)
        view.backgroundColor = .black
        return view
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
    
    fileprivate func initView(){
        view.addSubview(videoPlayerView)
    }
    fileprivate func setFrame(){
        videoPlayerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

