//
//  PlayerView.swift
//  CQAVPlayer
//
//  Created by 陈庆 on 2021/8/1.
//  视频播放view

import UIKit
import AVFoundation
class PlayerView: UIView {
    public var myPlayer:AVPlayer? //播放器
    
    fileprivate var myPlayeritem:AVPlayerItem?  //播放单元
    
    fileprivate var playerLayer:AVPlayerLayer? //播放界面（layer）
    
    fileprivate var timerObserver:Any?
    
    fileprivate var periodicTimeObserver:Any?
    
    fileprivate var isPlayerEnd:Bool = false
//    回调出去
    public var playerStart:(()->())?
//    播放结束
    public var playerEnd:(()->())?
//    更改播放时间
    public var updateTime:((_ timeStr:String)->())?
    
    //进度条进度
    public var updateProgress:((_ progressValue:Float)->())?
//    总时间
    public var setTotalTime:((_ totalTimeStr:String)->())?
    
//    更新进度监听
    public var updateProgressMonitor:(()->())?
//  自定义初始化方法，携带视频播放地址
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 添加播放完成通知
        NotificationCenter.default.addObserver(self, selector: #selector(playbackFinished), name: .AVPlayerItemDidPlayToEndTime, object: nil)
       
        initView()
        setFrame()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    private func initView(){
        
    }
    
    private func setFrame(){
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.bounds
    }
    public func playerClick(videoUrl:String?){
        myPlayeritem = AVPlayerItem(url: URL(string: videoUrl ?? "")!)
        myPlayer = AVPlayer(playerItem: myPlayeritem)
//        视频开始播放
        timerObserver = myPlayer?.addBoundaryTimeObserver(forTimes: [NSValue(time: CMTimeMake(value: 1, timescale: 30))], queue: DispatchQueue.main, using: {[weak self] in
//
            self?.playerStart?()
            if let playerItem = self?.myPlayeritem{
                let totalTime = TimeInterval(playerItem.duration.value)/TimeInterval(playerItem.duration.timescale)
                self?.setTotalTime?(self?.formatSecondsToString(totalTime) ?? "")
            }
            
            print("开始播放")
        })
        periodicTimeObserver = myPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: {[weak self] time in
            if let playerItem = self?.myPlayeritem{
                if playerItem.duration.timescale != 0 {
                    let currentTime = CMTimeGetSeconds((self?.myPlayer!.currentTime())!)
                    let totalTime = TimeInterval(playerItem.duration.value)/TimeInterval(playerItem.duration.timescale)
                    self?.updateProgress?(Float(currentTime/totalTime))
                    self?.updateTime?(self?.formatSecondsToString(currentTime) ?? "")
                }
            }
        })
        playerLayer = AVPlayerLayer(player: myPlayer)
        
        self.layer.addSublayer(playerLayer ?? CALayer())
        myPlayeritem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    }

//    kvo
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let item = object as? AVPlayerItem, let keyPath = keyPath {
            switch keyPath {
            case "status":
                if item.status == .failed {
                    
                }else if item.status == .readyToPlay {
                    
                    myPlayer?.play()
                }
            default:
                break
            }
        }
    }
    deinit {
        myPlayeritem?.removeObserver(self, forKeyPath: "status")
        myPlayer?.removeTimeObserver(timerObserver as Any)
        myPlayer?.removeTimeObserver(periodicTimeObserver as Any)
    }
}
extension PlayerView{
    @objc fileprivate func playbackFinished(){
        print("播放结束")
        playerEnd?()
    }
//    播放视频 重头播放
    public func onStartPlay(){
        myPlayer?.seek(to: CMTimeMakeWithSeconds(Float64(0), preferredTimescale: Int32((myPlayer?.currentItem?.duration.timescale)!)), completionHandler: { (Bool) in
                   self.myPlayer?.play()
               })
    }
    public func onCurrentStartPlay(){
        self.myPlayer?.play()
    }
    public func onStopPlay(){
        myPlayer?.pause()
    }
    
//    滑块滑动停止后指定到滑动播放位置
    public func setSlidingPlayer(value:Float){
        let totalTime = TimeInterval(myPlayeritem?.duration.value ?? 0)/TimeInterval(myPlayeritem?.duration.timescale ?? 0)
        myPlayer?.seek(to: CMTimeMakeWithSeconds(Float64(value * Float(totalTime)), preferredTimescale: Int32((myPlayer?.currentItem?.duration.timescale)!)), completionHandler: {[weak self] (Bool) in
                   self?.myPlayer?.play()
//                    在这回调出去
                    self?.updateProgressMonitor?()
               })
        playerStart?()
    }
//    点击滑块，并且播放到指定位置
    public func setPlayerLocation(value:Float){
        let totalTime = TimeInterval(myPlayeritem?.duration.value ?? 0)/TimeInterval(myPlayeritem?.duration.timescale ?? 0)
        myPlayer?.seek(to: CMTimeMakeWithSeconds(Float64(value * Float(totalTime)), preferredTimescale: Int32((myPlayer?.currentItem?.duration.timescale)!)), completionHandler: {[weak self] (Bool) in
                    self?.myPlayer?.play()
                    self?.updateProgressMonitor?()
               })
        playerStart?()
    }
    fileprivate func formatSecondsToString(_ seconds: TimeInterval) -> String {
        if seconds.isNaN {
            return "00:00"
        }
        let min = Int(seconds / 60)
        let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", min, sec)
    }
}
