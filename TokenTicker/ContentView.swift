import SwiftUI

struct ContentView: View {
    @StateObject private var dataProvider = TokenDataProvider()

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(dataProvider.percentage)%")
                .font(.system(size: 42, weight: .light))
                .opacity(0.8)

            Spacer()

            Text(dataProvider.trendLobster)
                .font(.system(size: 26))
                .rotationEffect(.degrees(dataProvider.isRising ? 0 : 180))
                .animation(.easeInOut(duration: 0.6), value: dataProvider.isRising)
                .padding(.top, 8)

            Text("Haiku-4-5")
                .font(.system(size: 13, weight: .medium, design: .rounded))

            Text(dataProvider.tokenDisplay)
                .font(.system(size: 13, weight: .regular))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.top, 23)
        .padding(.bottom, 26)
        .padding(.leading, 20)
        .padding(.trailing, 16)
        .frame(width: 160, height: 160)
        .onAppear {
            dataProvider.startPolling()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
