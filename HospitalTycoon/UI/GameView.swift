import SwiftUI
import SpriteKit

struct GameView: View {
    @Environment(GameState.self) private var gameState
    @State private var gameScene: GameScene?
    @State private var showBuildMenu = false
    @State private var showStaffMenu = false
    @State private var showFinanceView = false
    @State private var showPatientList = false
    @State private var showInsuranceView = false
    @State private var selectedTab: GameTab = .build

    var body: some View {
        ZStack {
            // SpriteKit Game View
            if let scene = gameScene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
            }

            // HUD Overlay
            VStack {
                HUDView()
                    .padding(.horizontal)
                    .padding(.top, 4)

                Spacer()

                // Bottom toolbar
                bottomToolbar
            }

            // Side panels
            if showBuildMenu {
                buildMenuOverlay
            }
            if showStaffMenu {
                staffMenuOverlay
            }
            if showFinanceView {
                financeOverlay
            }
            if showPatientList {
                patientListOverlay
            }
            if showInsuranceView {
                insuranceOverlay
            }

            // Event notifications
            VStack {
                Spacer()
                EventNotificationView()
                    .padding(.bottom, 80)
            }
        }
        .onAppear {
            setupScene()
        }
        .statusBarHidden()
    }

    private func setupScene() {
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        scene.gameState = gameState
        self.gameScene = scene
    }

    // MARK: - Bottom Toolbar

    private var bottomToolbar: some View {
        HStack(spacing: 0) {
            toolbarButton(icon: "hammer.fill", label: "Build", tab: .build) {
                showBuildMenu.toggle()
                showStaffMenu = false; showFinanceView = false; showPatientList = false; showInsuranceView = false
            }
            toolbarButton(icon: "person.2.fill", label: "Staff", tab: .staff) {
                showStaffMenu.toggle()
                showBuildMenu = false; showFinanceView = false; showPatientList = false; showInsuranceView = false
            }
            toolbarButton(icon: "cross.fill", label: "Patients", tab: .patients) {
                showPatientList.toggle()
                showBuildMenu = false; showStaffMenu = false; showFinanceView = false; showInsuranceView = false
            }
            toolbarButton(icon: "dollarsign.circle.fill", label: "Finance", tab: .finance) {
                showFinanceView.toggle()
                showBuildMenu = false; showStaffMenu = false; showPatientList = false; showInsuranceView = false
            }
            toolbarButton(icon: "doc.text.fill", label: "Insurance", tab: .insurance) {
                showInsuranceView.toggle()
                showBuildMenu = false; showStaffMenu = false; showFinanceView = false; showPatientList = false
            }
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    private func toolbarButton(icon: String, label: String, tab: GameTab, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(selectedTab == tab ? .blue : .gray)
        }
    }

    // MARK: - Overlay Helpers

    private var buildMenuOverlay: some View {
        HStack {
            BuildMenuView(onDismiss: { showBuildMenu = false }, gameScene: gameScene)
                .frame(width: 300)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()
            Spacer()
        }
    }

    private var staffMenuOverlay: some View {
        HStack {
            StaffMenuView()
                .frame(width: 320)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()
            Spacer()
        }
    }

    private var financeOverlay: some View {
        HStack {
            Spacer()
            FinanceView()
                .frame(width: 350)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()
        }
    }

    private var patientListOverlay: some View {
        HStack {
            PatientListView()
                .frame(width: 320)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()
            Spacer()
        }
    }

    private var insuranceOverlay: some View {
        HStack {
            Spacer()
            InsuranceContractView()
                .frame(width: 350)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()
        }
    }
}

enum GameTab {
    case build, staff, patients, finance, insurance
}
