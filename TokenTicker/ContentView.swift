import SwiftUI

struct ContentView: View {
    @StateObject private var dataProvider = TokenDataProvider()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(nsColor: .systemGray).opacity(0.85))

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text("\(dataProvider.percentage)%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    Text(dataProvider.trendLobster)
                        .font(.system(size: 32))
                        .scaleEffect(x: dataProvider.isRising ? 1 : -1, y: 1)
                }

                Text(dataProvider.tokenDisplay)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))

                Spacer()

                Text("Haiku-4-5")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(20)
        }
        .frame(width: 220, height: 160)
        .onAppear {
            dataProvider.startPolling()
        }
    }
}

#Preview {
    ContentView()
}
