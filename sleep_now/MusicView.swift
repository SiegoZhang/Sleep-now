import SwiftUI

// 临时音乐播放器，仅用于睡眠音乐预览和选择
class SleepMusicPreviewViewModel: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentPreviewTrack: MusicTrack?
    
    static let shared = SleepMusicPreviewViewModel()
    
    private init() {}
    
    func togglePlayPause() {
        isPlaying.toggle()
        
        // 如果停止预览播放，则恢复主音乐播放器的状态
        if !isPlaying && MusicPlayerViewModel.shared.isPlaying {
            // 不需要任何操作，保持主播放器继续播放
        }
    }
    
    func previewTrack(_ track: MusicTrack) {
        // 保存主播放器状态以便稍后恢复
        let wasMainPlayerPlaying = MusicPlayerViewModel.shared.isPlaying
        let mainPlayerTrack = MusicPlayerViewModel.shared.currentTrack
        
        // 暂停主播放器的播放
        if wasMainPlayerPlaying {
            MusicPlayerViewModel.shared.isPlaying = false
        }
        
        // 播放预览音乐
        currentPreviewTrack = track
        isPlaying = true
    }
    
    func stopPreview() {
        isPlaying = false
        currentPreviewTrack = nil
        
        // 此处不需要恢复主播放器状态，关闭sheet时会处理
    }
}

struct SleepMusicView: View {
    @ObservedObject private var previewViewModel = SleepMusicPreviewViewModel.shared
    @EnvironmentObject var shieldViewModel: ShieldViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var savedMainPlayerState: (isPlaying: Bool, track: MusicTrack?)?
    
    let musicItems = [
        MusicItem(id: 1, title: "柔和雨声", category: "睡眠白噪音", duration: "8:00", image: "cloud.rain"),
        MusicItem(id: 2, title: "海浪轻声", category: "睡眠白噪音", duration: "10:00", image: "water.waves"),
        MusicItem(id: 3, title: "森林夜晚", category: "自然音", duration: "15:00", image: "leaf"),
        MusicItem(id: 4, title: "安静钢琴曲", category: "轻音乐", duration: "5:30", image: "pianokeys"),
        MusicItem(id: 5, title: "深度冥想", category: "冥想音乐", duration: "20:00", image: "person.and.background.dotted"),
        MusicItem(id: 6, title: "溪流轻声", category: "自然音", duration: "12:00", image: "water"),
    ]
    
    var body: some View {
        List {
            ForEach(musicItems) { item in
                HStack {
                    Image(systemName: item.image)
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.headline)
                        Text(item.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(item.duration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            let track = MusicTrack(
                                id: item.id,
                                title: item.title,
                                artist: item.category,
                                coverImage: item.image
                            )
                            
                            if isCurrentlyPreviewing(item) {
                                previewViewModel.togglePlayPause()
                            } else {
                                previewViewModel.previewTrack(track)
                            }
                        }) {
                            Image(systemName: isCurrentlyPreviewing(item) ? "pause.circle.fill" : "play.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        // 添加设置为睡眠音乐的按钮
                        Button(action: {
                            let track = MusicTrack(
                                id: item.id,
                                title: item.title,
                                artist: item.category,
                                coverImage: item.image
                            )
                            shieldViewModel.setSleepMusic(track)
                            previewViewModel.stopPreview()
                            dismiss()
                        }) {
                            Image(systemName: isSelectedForSleep(item) ? "checkmark.circle.fill" : "moon.fill")
                                .font(.title2)
                                .foregroundColor(isSelectedForSleep(item) ? .green : .gray)
                        }
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("选择睡眠音乐")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // 保存主播放器状态
            savedMainPlayerState = (
                isPlaying: MusicPlayerViewModel.shared.isPlaying,
                track: MusicPlayerViewModel.shared.currentTrack
            )
        }
        .onDisappear {
            // 恢复主播放器状态
            if let saved = savedMainPlayerState, saved.isPlaying {
                MusicPlayerViewModel.shared.isPlaying = true
            }
            // 停止预览播放
            previewViewModel.stopPreview()
        }
    }
    
    private func isCurrentlyPreviewing(_ item: MusicItem) -> Bool {
        guard let currentTrack = previewViewModel.currentPreviewTrack, previewViewModel.isPlaying else {
            return false
        }
        return currentTrack.id == item.id
    }
    
    private func isSelectedForSleep(_ item: MusicItem) -> Bool {
        guard let selectedMusic = shieldViewModel.selectedSleepMusic else {
            return false
        }
        return selectedMusic.id == item.id
    }
}

struct MusicView: View {
    @ObservedObject private var playerViewModel = MusicPlayerViewModel.shared
    @Environment(\.dismiss) private var dismiss
    
    let musicItems = [
        MusicItem(id: 1, title: "柔和雨声", category: "睡眠白噪音", duration: "8:00", image: "cloud.rain"),
        MusicItem(id: 2, title: "海浪轻声", category: "睡眠白噪音", duration: "10:00", image: "water.waves"),
        MusicItem(id: 3, title: "森林夜晚", category: "自然音", duration: "15:00", image: "leaf"),
        MusicItem(id: 4, title: "安静钢琴曲", category: "轻音乐", duration: "5:30", image: "pianokeys"),
        MusicItem(id: 5, title: "深度冥想", category: "冥想音乐", duration: "20:00", image: "person.and.background.dotted"),
        MusicItem(id: 6, title: "溪流轻声", category: "自然音", duration: "12:00", image: "water"),
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(musicItems) { item in
                    HStack {
                        Image(systemName: item.image)
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 40, height: 40)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.headline)
                            Text(item.category)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(item.duration)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            playerViewModel.playTrack(MusicTrack(
                                id: item.id,
                                title: item.title,
                                artist: item.category,
                                coverImage: item.image
                            ))
                        }) {
                            Image(systemName: isCurrentlyPlaying(item) ? "pause.circle.fill" : "play.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("音乐列表")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func isCurrentlyPlaying(_ item: MusicItem) -> Bool {
        guard let currentTrack = playerViewModel.currentTrack, playerViewModel.isPlaying else {
            return false
        }
        return currentTrack.id == item.id
    }
}

struct MusicItem: Identifiable {
    let id: Int
    let title: String
    let category: String
    let duration: String
    let image: String
}

#Preview {
    MusicView()
} 