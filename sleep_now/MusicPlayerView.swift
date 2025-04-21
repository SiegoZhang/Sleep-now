import SwiftUI

struct MusicPlayerView: View {
    @StateObject private var viewModel = MusicPlayerViewModel()
    
    var body: some View {
        HStack(spacing: 15) {
            // Music icon
            Image(systemName: viewModel.currentTrack?.coverImage ?? "music.note")
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
            
            // Track title
            Text(viewModel.currentTrack?.title ?? "Not Playing")
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            // Play/pause button
            Button(action: {
                viewModel.togglePlayPause()
            }) {
                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color(UIColor.darkGray).opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
        .clipShape(Rectangle())
    }
}

// Extension to position the music player at the bottom of the page
struct MusicPlayerViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            
            MusicPlayerView()
                .padding(.horizontal, 0)
                .padding(.bottom, 0)
        }
    }
}

extension View {
    func withMusicPlayer() -> some View {
        self.modifier(MusicPlayerViewModifier())
    }
}

#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        VStack {
            Spacer()
            MusicPlayerView()
        }
    }
} 