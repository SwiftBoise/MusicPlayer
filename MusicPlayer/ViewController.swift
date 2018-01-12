//
//  MusicPlayer
//
//  Copyright © 2018 Swift Boise. All rights reserved.
//

import MediaPlayer
import UIKit

class ViewController: UIViewController, MPMediaPickerControllerDelegate {
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var playbackTimeLabel: UILabel!
    @IBOutlet weak var playbackTimeSlider: UISlider!
    @IBOutlet weak var playbackTimeDeltaLabel: UILabel!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var backwardBackground: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var playPauseBackground: UIView!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var forwardBackground: UIView!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    
    var musicPlayer: MPMusicPlayerController!
    
    var timer: Timer?
    let pauseImage = UIImage(named: "Pause")
    let playImage = UIImage(named: "Play")
    var timerCount = 0
    
    var isPlaying: Bool! {
        didSet {
            print("isPlaying didSet")
            if isPlaying {
                playPauseButton.setImage(pauseImage, for: .normal)
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateThumb), userInfo: nil, repeats: true)
                timer?.tolerance = 0
            } else {
                playPauseButton.setImage(playImage, for: .normal)
                timer?.invalidate()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 10.3, *) {
            musicPlayer = MPMusicPlayerApplicationController.systemMusicPlayer
        } else {
            musicPlayer = MPMusicPlayerController.systemMusicPlayer
        }
        playbackTimeSlider.setThumbImage(UIImage(named: "Thumb"), for: .normal)
        musicPlayer.beginGeneratingPlaybackNotifications()
        musicPlayer.prepareToPlay()
        musicPlayer.repeatMode = .default
        musicPlayer.shuffleMode = .default
        isPlaying = musicPlayer.playbackState == .playing
        updateInterface()
        NotificationCenter.default.addObserver(self, selector: #selector(updateInterface), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Media Picker Controller Delegate
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        musicPlayer.setQueue(with: mediaItemCollection)
        mediaPicker.dismiss(animated: true) {
            self.updateInterface()
        }
        musicPlayer.play()
        isPlaying = true
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - Actions
    
    @IBAction func touchedDown(_ sender: UIButton) {
        let buttonBackground: UIView
        switch sender {
        case backwardButton:
            buttonBackground = backwardBackground
        case playPauseButton:
            buttonBackground = playPauseBackground
        case forwardButton:
            buttonBackground = forwardBackground
        default:
            return
        }
        UIView.animate(withDuration: 0.25) {
            buttonBackground.alpha = 0.3
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
    
    @IBAction func touchedUpInside(_ sender: UIButton) {
        let buttonBackground: UIView
        switch sender {
        case backwardButton:
            buttonBackground = backwardBackground
        case playPauseButton:
            buttonBackground = playPauseBackground
        case forwardButton:
            buttonBackground = forwardBackground
        default:
            return
        }
        UIView.animate(withDuration: 0.25, animations: {
            buttonBackground.alpha = 0
            buttonBackground.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            sender.transform = CGAffineTransform.identity
        }) { (_) in
            buttonBackground.transform = CGAffineTransform.identity
        }
    }
    
    @IBAction func backwardButtonTapped(_ sender: UIButton) {
        musicPlayer.skipToPreviousItem()
    }
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        if isPlaying {
            UIView.animate(withDuration: 0.5) {
                self.albumImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
            musicPlayer.pause()
        } else {
            UIView.animate(withDuration: 0.5) {
                self.albumImageView.transform = CGAffineTransform.identity
            }
            musicPlayer.play()
        }
        isPlaying = !isPlaying
        updateThumb()
    }
    
    @IBAction func forwardButtonTapped(_ sender: UIButton) {
        musicPlayer.skipToNextItem()
    }
    
    @IBAction func repeatButtonTapped(_ sender: UIButton) {
        switch musicPlayer.repeatMode {
        case .all:
            musicPlayer.repeatMode = .one
            repeatButton.setTitle("One", for: .normal)
            repeatButton.setTitleColor(.white, for: .normal)
            repeatButton.backgroundColor = Color.Primary.regular
        case .none:
            musicPlayer.repeatMode = .all
            repeatButton.setTitle("All", for: .normal)
            repeatButton.setTitleColor(.white, for: .normal)
            repeatButton.backgroundColor = Color.Primary.regular
        case .one:
            musicPlayer.repeatMode = .none
            repeatButton.setTitle("Repeat", for: .normal)
            repeatButton.setTitleColor(Color.Primary.regular, for: .normal)
            repeatButton.backgroundColor = .white
        default:
            break
        }
    }
    
    @IBAction func musicButtonTapped(_ sender: UIButton) {
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.allowsPickingMultipleItems = true
        mediaPicker.modalPresentationStyle = .currentContext
        mediaPicker.popoverPresentationController?.sourceView = sender
        mediaPicker.delegate = self
        present(mediaPicker, animated: true, completion: nil)
    }
    
    @IBAction func shuffleButtonTapped(_ sender: UIButton) {
        switch musicPlayer.shuffleMode {
        case .albums:
            musicPlayer.shuffleMode = .off
            shuffleButton.setTitle("Shuffle", for: .normal)
            shuffleButton.setTitleColor(Color.Primary.regular, for: .normal)
            shuffleButton.backgroundColor = .white
        case .off:
            musicPlayer.shuffleMode = .songs
            shuffleButton.setTitle("Songs", for: .normal)
            shuffleButton.setTitleColor(.white, for: .normal)
            shuffleButton.backgroundColor = Color.Primary.regular
        case .songs:
            musicPlayer.shuffleMode = .albums
            shuffleButton.setTitle("Albums", for: .normal)
            shuffleButton.setTitleColor(.white, for: .normal)
            shuffleButton.backgroundColor = Color.Primary.regular
        default:
            break
        }
    }
    
    // MARK: - Helpers
    
    // This doesn't need to be updated every timer fire
    @objc func updateInterface() {
        guard let playerItem = musicPlayer.nowPlayingItem else { return }
        titleLabel.text = playerItem.title
        artistLabel.text = playerItem.artist ?? playerItem.albumArtist ?? "Unknown Artist"
        albumLabel.text = playerItem.albumTitle ?? "Unknown Album"
        let orientation = UIApplication.shared.statusBarOrientation
        switch orientation {
        case .portrait:
            albumImageView.image = playerItem.artwork?.image(at: CGSize(width: albumImageView.bounds.height, height: albumImageView.bounds.height))
        case .landscapeLeft, .landscapeRight:
            albumImageView.image = playerItem.artwork?.image(at: CGSize(width: albumImageView.bounds.width, height: albumImageView.bounds.width))
        default:
            break
        }
        playbackTimeSlider.maximumValue = Float(playerItem.playbackDuration)
        updateThumb()
    }
    
    // This does need to update every timer fire
    @objc func updateThumb() {
        timerCount += 1
        print("updateThumb \(timerCount)")
        //guard !musicPlayer.currentPlaybackTime.isNaN else {return}
        let playbackTime = musicPlayer.currentPlaybackTime
        let playbackTimeMinutes = Int(playbackTime / 60)
        let playbackTimeSeconds = Int(playbackTime.truncatingRemainder(dividingBy: 60))
        playbackTimeLabel.text = String(format: "%01d:%02d", arguments: [playbackTimeMinutes, playbackTimeSeconds])
        playbackTimeSlider.value = Float(musicPlayer.currentPlaybackTime)
        
        guard let playerItem = musicPlayer.nowPlayingItem else { return }
        let playbackTimeDelta = playerItem.playbackDuration - musicPlayer.currentPlaybackTime
        let playbackTimeDeltaMinutes = Int(playbackTimeDelta / 60)
        let playbackTimeDeltaSeconds = Int(playbackTimeDelta.truncatingRemainder(dividingBy: 60))
        playbackTimeDeltaLabel.text = String(format: "-%01d:%02d", arguments: [playbackTimeDeltaMinutes, playbackTimeDeltaSeconds])
    }
    
}
