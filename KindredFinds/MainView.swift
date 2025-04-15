import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            FeedView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Feed")
                }
                .tag(0)

            PostView(onSubmit: { _ in })
                .tabItem {
                    Image(systemName: "plus.square")
                    Text("Post")
                }
                .tag(1)
        }.navigationBarBackButtonHidden(true)
            .navigationTitle("KindredFinds")
    }
}

#Preview{
    MainTabView()
}
