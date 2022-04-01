//
//  MusicPlayerView.swift
//  PodcastTest
//
//  Created by Hunter Haufler on 1/16/21.
//

import SwiftUI
import MediaPlayer

struct AudioControlButtons: View {
    let buttonAction: () -> Void
    let imageSystemName: String
    
    var body: some View {
        Button(action: buttonAction) {
            ZStack {
                Circle()
                    .frame(width: 80, height: 80)
                    .accentColor(.pink)
                    .shadow(radius: 10)
                
                Image(systemName: imageSystemName)
                    .foregroundColor(.white)
                    .font(.title)
            }
        }
    }
}

class AudioPlayerWrapper: ObservableObject {
    let songs = ["Episode 1 - Fri Night - McCann", "Episode 2 - Fri Night - Kopecky"]
    @Published var current = 0

    @Published var title = "Title"
    @Published var artist = "Artist"
    @Published var artwork: Data = .init(count: 0)
    @Published var player: AVAudioPlayer!
    @Published var del = AVDelegate()
    
    @Published var width: CGFloat = 0
    
    @Published var isPlaying = false
    @Published var isFinished = false
    
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
            self.isFinished = true
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
            self.isPlaying = false
        }
        else {
            if self.isFinished {
                self.player.currentTime = 0
                self.width = 0
                self.isFinished = false
            }
            
            self.player.play()
            self.isPlaying = true
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
        
        self.isPlaying = true
        self.isFinished = false
        self.width = 0
        
        self.player.play()
    }
}

struct PlayerView: View {
    @State private var player = AudioPlayerWrapper()
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
                Image(systemName: "a.square")
                    .resizable()
                    .frame(width: geometry.size.width - 24, height: geometry.size.width - 24)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                
                VStack(spacing: 8) {
                    Text(self.player.title)
                        .font(.title)
                        .bold()
                    
                    Text(self.player.artist)
                        .font(.headline)
                }
                
                PlayerSliderView(player: $player.player, width: $player.width)
                
                HStack(spacing: 40) {
                    AudioControlButtons(buttonAction: player.previous, imageSystemName: "backward.fill")
                    
                    AudioControlButtons(buttonAction: player.pausePlay, imageSystemName: self.player.isPlaying ? "play.fill" : "pause.fill")
                    
                    AudioControlButtons(buttonAction: player.skip, imageSystemName: "forward.fill")
                }
            }.frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
        .onAppear(perform: player.setUp)
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
