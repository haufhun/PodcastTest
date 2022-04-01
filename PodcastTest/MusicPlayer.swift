//
//  MusicPlayer.swift
//  PodcastTest
//
//  Created by Hunter Haufler on 1/18/21.
//


import SwiftUI
import AVKit


class AVDelegate: NSObject,AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name("Finish"), object: nil)
    }
}

struct PlayerSliderView: View {
    @Binding var player: AVAudioPlayer!
    @Binding var width: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.black.opacity(0.08))
                .frame(height: 8)
            
            Capsule()
                .fill(Color.red)
                .frame(width: self.width, height: 8)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let x = value.location.x
                            self.width = x
                        }
                        .onEnded { value in
                            let x = value.location.x
                            let screen = UIScreen.main.bounds.width - 30
                            let percent = x / screen
                            
                            self.player.currentTime = Double(percent) * self.player.duration
                        }
                )
        }
    }
}

struct MusicPlayer : View {
    let songs = []
    @State var current = 0

    @State var title = ""
    @State var artwork: Data = .init(count: 0)
    @State var player: AVAudioPlayer!
    @State var del = AVDelegate()
    
    @State var width: CGFloat = 0
    
    @State var playing = false
    @State var finish = false
    
    var artworkImage: UIImage? {
        guard artwork.count > 0 else {
            return nil
        }
        
        return UIImage(data: self.artwork)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if let artworkImage = artworkImage {
                Image(uiImage: artworkImage)
                    .resizable()
                    .frame(width: 250, height: 250)
                    .cornerRadius(15)
            } else {
                Image(systemName: "music.note")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .cornerRadius(15)
            }
                
            Text(self.title)
                .font(.title)
                .padding(.top)
            
            PlayerSliderView(player: $player, width: $width)
                .padding(.top)
            
            HStack(spacing: UIScreen.main.bounds.width / 5 - 30) {
                Button(action: previous) {
                    Image(systemName: "backward.fill")
                        .font(.title)
                }
                
                Button(action: rewind15) {
                    Image(systemName: "gobackward.15")
                        .font(.title)
                }
                
                Button(action: pausePlay) {
                    Image(systemName: self.playing && !self.finish ? "pause.fill" : "play.fill")
                        .font(.title)
                }
                
                Button(action: fastForward15) {
                    Image(systemName: "goforward.15").font(.title)
                }
                
                Button(action: skip) {
                    Image(systemName: "forward.fill").font(.title)
                }
                
            }
            .padding(.top, 25)
            .foregroundColor(.black)
            
        }
        .padding()
        .onAppear(perform: setUp)
    }
    
    func setUp() {
        self.setUpPlayer()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.player.isPlaying{
                let screen = UIScreen.main.bounds.width - 30
                let value = self.player.currentTime / self.player.duration
                self.width = screen * CGFloat(value)
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Finish"), object: nil, queue: .main) { _ in
            self.finish = true
        }
    }
    
    func setUpPlayer() {
        let url = Bundle.main.path(forResource: self.songs[self.current], ofType: "mp3")
        self.player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: url!))
        self.player.delegate = self.del
        self.player.prepareToPlay()
        
        self.title = ""
        self.artwork = .init(count: 0)
        
        let asset = AVAsset(url: self.player.url!)
        for i in asset.commonMetadata {
            if i.commonKey?.rawValue == "artwork"{
                let data = i.value as! Data
                self.artwork = data
            }
            
            if i.commonKey?.rawValue == "title" {
                let title = i.value as! String
                self.title = title
            }
        }
    }
    
    func previous() {
        if self.current > 0 {
            self.current -= 1
            self.changeSongs()
        }
    }
    
    func rewind15() {
        self.player.currentTime -= 15
    }
    
    func pausePlay() {
        if self.player.isPlaying {
            self.player.pause()
            self.playing = false
        }
        else {
            if self.finish {
                self.player.currentTime = 0
                self.width = 0
                self.finish = false
            }
            
            self.player.play()
            self.playing = true
        }
    }
    
    func fastForward15() {
        let increase = self.player.currentTime + 15
        
        if increase < self.player.duration {
            self.player.currentTime = increase
        }
    }
    
    func skip() {
        if self.songs.count - 1 != self.current {
            self.current += 1
            self.changeSongs()
        }
    }
    
    func changeSongs() {
        self.player.pause()
        self.setUpPlayer()
        
        self.playing = true
        self.finish = false
        self.width = 0
        
        self.player.play()
    }
}

struct MusicPlayer_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayer()
    }
}
