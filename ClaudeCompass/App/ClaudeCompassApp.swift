import SwiftUI
import AppKit

@main
struct ClaudeCompassApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var viewModel = DashboardViewModel()

    var body: some Scene {
        MenuBarExtra {
            DashboardView(viewModel: viewModel)
        } label: {
            menuBarLabel
        }
        .menuBarExtraStyle(.window)
    }

    private var menuBarLabel: some View {
        HStack(spacing: 0) {
            Image(nsImage: menuBarImage)
        }
        .onAppear {
            viewModel.start()
        }
    }

    private var menuBarImage: NSImage {
        let font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        let attrString = NSMutableAttributedString()

        let usagePercent: Double
        let timePercent: Double

        switch viewModel.displayMode {
        case .weekly:
            usagePercent = viewModel.snapshot.weeklyPacingPercent
            timePercent = viewModel.snapshot.weeklyTimePercent
        case .daily:
            usagePercent = viewModel.snapshot.pacingPercent
            timePercent = 0
        case .dual:
            usagePercent = viewModel.snapshot.pacingPercent
            timePercent = viewModel.snapshot.weeklyPacingPercent
        case .iconOnly:
            usagePercent = viewModel.snapshot.weeklyPacingPercent
            timePercent = 0
        }

        let usageColor = Theme.Colors.nsColorForUsagePercent(usagePercent)

        // Status dot
        if viewModel.showStatusIcon {
            attrString.append(NSAttributedString(string: "◉ ", attributes: [
                .font: font,
                .foregroundColor: usageColor,
            ]))
        }

        // First number (usage)
        let usageText = "\(Int(usagePercent))%"
        attrString.append(NSAttributedString(string: usageText, attributes: [
            .font: font,
            .foregroundColor: usageColor,
        ]))

        // Second number (time) if applicable
        if timePercent > 0 {
            let timeColor = Theme.Colors.nsColorForUsagePercent(timePercent)
            attrString.append(NSAttributedString(string: " · ", attributes: [
                .font: font,
                .foregroundColor: NSColor.secondaryLabelColor,
            ]))
            attrString.append(NSAttributedString(string: "\(Int(timePercent))%", attributes: [
                .font: font,
                .foregroundColor: timeColor,
            ]))
        }
        let size = attrString.size()
        let scale = NSScreen.main?.backingScaleFactor ?? 2.0
        let pixelSize = NSSize(width: ceil(size.width * scale), height: ceil(size.height * scale))

        let image = NSImage(size: NSSize(width: ceil(size.width), height: ceil(size.height)))
        let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(pixelSize.width),
            pixelsHigh: Int(pixelSize.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )!
        rep.size = NSSize(width: ceil(size.width), height: ceil(size.height))

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        attrString.draw(at: .zero)
        NSGraphicsContext.restoreGraphicsState()

        image.addRepresentation(rep)
        image.isTemplate = false
        return image
    }
}
