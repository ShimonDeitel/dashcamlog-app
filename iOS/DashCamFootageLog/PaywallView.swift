import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @EnvironmentObject var store: ClipEntryStore
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                ClipEntryTheme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 48))
                        .foregroundColor(ClipEntryTheme.accent)
                    Text("Unlock Dash Cam Footage Log Pro")
                        .font(ClipEntryTheme.titleFont)
                        .foregroundColor(ClipEntryTheme.textPrimary)
                    Text("Incident categorization with photo attachment and export summary")
                        .font(ClipEntryTheme.bodyFont)
                        .foregroundColor(ClipEntryTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button {
                        Task { await purchase() }
                    } label: {
                        Text(isPurchasing ? "Processing..." : "Subscribe $1.99/month")
                            .font(ClipEntryTheme.bodyFont.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ClipEntryTheme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .disabled(isPurchasing)
                    .accessibilityIdentifier("subscribeButton")
                    .padding(.horizontal)
                    if let errorMessage {
                        Text(errorMessage).foregroundColor(.red).font(.caption)
                    }
                    Button("Not now") { dismiss() }
                        .foregroundColor(ClipEntryTheme.textSecondary)
                        .accessibilityIdentifier("dismissPaywallButton")
                }
                .padding()
            }
        }
    }

    private func purchase() async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await purchases.purchasePro()
            if purchases.isPro {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(PurchaseManager())
        .environmentObject(ClipEntryStore())
}
