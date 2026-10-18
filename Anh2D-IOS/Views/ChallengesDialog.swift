import SwiftUI

public struct ChallengesDialog: View {
    @ObservedObject public var viewModel: ProjectViewModel
    @Environment(\.presentationMode) var presentationMode

    let challenges: [WeeklyChallenge] = [
        WeeklyChallenge(
            title: "Cuộc Thi Bước Đi Nhân Vật (Walk Cycle Battle)",
            prompt: "Vẽ diễn hoạt một chuỗi bước đi hoàn chỉnh của một nhân vật bất kỳ (người, động vật hoặc robot) ít nhất 8 frame lặp.",
            prize: "Huy hiệu Top Animator + FlipaClip Plus 1 năm",
            daysRemaining: 4,
            tag: "#WalkCycle2026"
        ),
        WeeklyChallenge(
            title: "Tuyệt Kỹ Người Que (Stickman Stunts)",
            prompt: "Thực hiện chuỗi hành động võ thuật nhào lộn hoặc parkour của nhân vật người que với tốc độ 24 FPS.",
            prize: "Feature trên trang chủ cộng đồng",
            daysRemaining: 6,
            tag: "#StickmanStunts"
        ),
        WeeklyChallenge(
            title: "Biến Hình Ma Thuật (Morphing Madness)",
            prompt: "Biến đổi một đồ vật hàng ngày thành một sinh vật tưởng tượng qua 12 khung hình liên tục mượt mà.",
            prize: "Huy hiệu Nghệ sĩ Sáng Tạo",
            daysRemaining: 9,
            tag: "#MorphChallenge"
        )
    ]

    public var body: some View {
        NavigationView {
            List(challenges) { ch in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(ch.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(viewModel.project.isDarkMode ? .white : .black)
                        Spacer()
                        Text("Còn \(ch.daysRemaining) ngày")
                            .font(.system(size: 11, weight: .semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.flipaYellow)
                            .foregroundColor(.black)
                            .cornerRadius(4)
                    }

                    Text(ch.prompt)
                        .font(.system(size: 12))
                        .foregroundColor(viewModel.project.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))

                    HStack {
                        Label(ch.prize, systemImage: "gift.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color.flipaOrange)

                        Spacer()

                        Button(action: {
                            viewModel.showToast("Đã nộp bài tham gia \(ch.tag) thành công!")
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Nộp Bài")
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.flipaOrange)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                    }
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Cuộc Thi & Thử Thách Tuần")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
