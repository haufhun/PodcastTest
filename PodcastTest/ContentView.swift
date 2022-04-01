//
//  ContentView.swift
//  PodcastTest
//
//  Created by Hunter Haufler on 1/15/21.
//

import SwiftUI
//import MediaPlayer

struct ContentView: View {
//    @State private var musicPlayer = MPMusicPlayerController.applicationMusicPlayer

    var body: some View {
        MusicPlayer()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
