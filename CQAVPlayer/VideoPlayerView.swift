//
//  VideoPlayerView.swift
//  CQAVPlayer
//
//  Created by 陈庆 on 2021/8/1.
//

import UIKit

class VideoPlayerView: UIView {
    
    public var videoUrl:String?{
        didSet{
            playerView.playerClick(videoUrl: videoUrl)
        }
    }
    
    public lazy var playerView:PlayerView={
        let view = PlayerView(frame: .zero)
        return view
    }()
    
    fileprivate lazy var bottomView:BottomView={
        let view = BottomView(frame: .zero)
        return view
    }()
    //    加载指示器
    fileprivate lazy var activityView:UIActivityIndicatorView={
        let view = UIActivityIndicatorView(style: .large)
        view.color = .white
        view.hidesWhenStopped = true
        return view
    }()
    
    fileprivate lazy var playerBtn:UIButton={
        let btn = UIButton(type: .custom)
        btn.setBackgroundImage(UIImage(named: "icon_play_normal"), for: .normal)
        btn.addTarget(self, action: #selector(playerBtnClick), for: .touchUpInside)
        return btn
    }()
    
    fileprivate var isSliding:Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        setFrame()
        bottomView.isHidden = true
        activityView.startAnimating()
        self.bringSubviewToFront(activityView)
        playerBtn.isHidden = true
        playerView.playerStart={[weak self] in
            self?.playerBtn.isHidden = true
            self?.bottomView.isHidden = false
            self?.bottomView.playBtn.setImage(UIImage(named: "player_pause"), for: .normal)
            self?.activityView.stopAnimating()
        }
        playerView.playerEnd={[weak self] in
            self?.bottomView.playBtn.setImage(UIImage(named: "player_play"), for: .normal)
            self?.playerBtn.isHidden = false
        }
        playerView.updateTime={[weak self] timeStr in
            self?.bottomView.leftTimeLabel.text = timeStr
        }
        playerView.setTotalTime={[weak self] totalTimeStr in
            self?.bottomView.rightTimeLabel.text = totalTimeStr
        }
        playerView.updateProgress={[weak self] progressValue in
            if let isSliding = self?.isSliding, isSliding {
                self?.bottomView.progressView.value = progressValue
            }
        }
        bottomView.btnBlock={[weak self] in
            // rate属性表示avplayer的播放状态，1表示正在播放；0表示暂停播放
            if self?.playerView.myPlayer?.rate == 0 {
                self?.bottomView.playBtn.setImage(UIImage(named: "player_pause"), for: .normal)
                if let isHidden = self?.playerBtn.isHidden, isHidden {
                    self?.playerView.onCurrentStartPlay()
                }else {
                    self?.playerView.onStartPlay()
                }
                
            }else{
                self?.bottomView.playBtn.setImage(UIImage(named: "player_play"), for: .normal)
                self?.playerView.onStopPlay()
            }
        }
        self.playerView.updateProgressMonitor={
            self.isSliding = true
        }
        bottomView.slidingEnd={[weak self] value in
            self?.playerView.setSlidingPlayer(value: value)
        }
        bottomView.tapProgressLocation={[weak self] value in
            self?.playerView.setPlayerLocation(value: value)
        }
        bottomView.slidingStatus={[weak self] isSliding in
            self?.isSliding = isSliding
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func initView(){
        addSubview(playerView)
        addSubview(bottomView)
        addSubview(activityView)
        addSubview(playerBtn)
    }
    private func setFrame(){
        playerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        activityView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        playerBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-30)
            make.height.equalTo(30)
        }
    }
}

extension VideoPlayerView{
    @objc fileprivate func playerBtnClick(){
        playerView.onStartPlay()
    }
}

fileprivate class BottomView:UIView {
    fileprivate var btnBlock:(()->())?
    fileprivate var slidingEnd:((_ value:Float)->())?
    fileprivate var tapProgressLocation:((_ value:Float)->())?
    fileprivate var slidingStatus:((_ isSliding:Bool)->())?
    fileprivate var tapGesture:UITapGestureRecognizer?
    fileprivate lazy var playBtn:UIButton={
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "player_play"), for: .normal)
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        return btn
    }()
    
    fileprivate lazy var progressView:MySlider={
        let view = MySlider()
        view.minimumTrackTintColor = .red
        view.maximumTrackTintColor = .white
        view.minimumValue = 0
        view.addTarget(self, action: #selector(progressSliderTouchBegan(_:)), for: UIControl.Event.touchDown)
        view.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: UIControl.Event.valueChanged)
        view.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), for: [UIControl.Event.touchUpInside,UIControl.Event.touchCancel,UIControl.Event.touchUpOutside])
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapClick(tapGesture:)))
        view.addGestureRecognizer(tapGesture!)
        return view
    }()
    
    fileprivate lazy var leftTimeLabel:UILabel={
       let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    fileprivate lazy var rightTimeLabel:UILabel={
       let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        setFrame()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func initView(){
        addSubview(playBtn)
        addSubview(leftTimeLabel)
        addSubview(progressView)
        addSubview(rightTimeLabel)
    }
    
    private func setFrame(){
        playBtn.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        leftTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(playBtn.snp_rightMargin).offset(15)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 20))
        }
        progressView.snp.makeConstraints { make in
            make.left.equalTo(leftTimeLabel.snp_rightMargin).offset(15)
            make.right.equalTo(rightTimeLabel.snp_leftMargin).offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(2)
        }
        rightTimeLabel.snp.makeConstraints { make in
            make.right.equalTo(-30)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 20))
        }
    }
}

extension BottomView{
    @objc fileprivate func btnClick(){
        btnBlock?()
    }
    //        点击滑竿
    @objc fileprivate func tapClick(tapGesture:UITapGestureRecognizer){
       let point = tapGesture.location(in: progressView)
//        移动滑块到指定点击位置
        print("point---->\(point)")
        slidingStatus?(false)
        progressView.value = Float(point.x/progressView.bounds.width)
        tapProgressLocation?(Float(point.x/progressView.bounds.width))
    }
    
    @objc fileprivate func progressSliderTouchBegan(_ sender: UISlider) {
//      点击滑块,不进行
        
        print("Began--->\(sender.value)")
        tapGesture?.isEnabled = false
    }
    
    @objc fileprivate func progressSliderValueChanged(_ sender: UISlider) {
//        滑动中
        print("Changed--->\(sender.value)")
        slidingStatus?(false)
    }
    
    @objc fileprivate func progressSliderTouchEnded(_ sender:UISlider) {
//        滑动停止
        print("Ended--->\(sender.value)")
        tapGesture?.isEnabled = true
        slidingEnd?(sender.value)
    }
    
}


