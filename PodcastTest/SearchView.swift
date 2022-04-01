//
//  SearchView.swift
//  PodcastTest
//
//  Created by Hunter Haufler on 1/16/21.
//

import SwiftUI
import MediaPlayer

struct SearchView: View {
//    @Binding var musicPlayer: MPMusicPlayerController

    @State private var searchText = ""
    let songs = ["Blinding Lights", "That Way", "This Is Me"]

    var displaySongs: [String] {
        songs.filter { $0.starts(with: searchText)}
    }
    
    var body: some View {
        VStack {
            TextField("Search Songs", text: $searchText, onCommit:  {
                print(self.searchText)
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal, 16)
            .accentColor(.pink)
            
            List(displaySongs, id: \.self) { song in
                HStack {
                    Image(systemName: "rectangle.stack.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .cornerRadius(5)
                        .shadow(radius: 2)
                    
                    VStack(alignment: .leading) {
                        Text(song)
                            .font(.headline)
                        Text("Artist Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        print("Playing \(song)")
//                        self.musicPlayer.setQueue(with: [song])
//                        self.musicPlayer.play()
                    }) {
                        Image(systemName: "play.fill")
                            .foregroundColor(.pink)
                    }
                }
            }
            .accentColor(.pink)
        }
    }
}
