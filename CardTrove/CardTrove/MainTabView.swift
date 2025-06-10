import SwiftUI

struct MainTabView: View {
    @StateObject private var clientManager = ClientProfileManager()
    @StateObject private var orderManager = OrderEntryManager()
    @StateObject private var materialManager = MaterialStockManager()
    @StateObject private var designRequestManager = DesignRequestManager()

    var body: some View {
        TabView {
            ClientProfileListView(manager: clientManager)
                .tabItem {
                    Image(systemName: "person.crop.rectangle")
                    Text("Clients")
                }

            OrderEntryListView(manager: orderManager)
                .tabItem {
                    Image(systemName: "doc.richtext")
                    Text("Orders")
                }

            MaterialStockListView(manager: materialManager)
                .tabItem {
                    Image(systemName: "cube.box.fill")
                    Text("Materials")
                }

            DesignRequestListView(manager: designRequestManager)
                .tabItem {
                    Image(systemName: "pencil.and.outline")
                    Text("Designs")
                }

            OverviewTabView(
                clientManager: clientManager,
                orderManager: orderManager,
                materialManager: materialManager,
                designManager: designRequestManager
            )
            .tabItem {
                Image(systemName: "rectangle.stack.fill.badge.plus")
                Text("Overview")
            }
        }
    }
}
