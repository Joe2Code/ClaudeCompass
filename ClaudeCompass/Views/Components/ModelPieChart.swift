import SwiftUI

struct ModelPieChart: View {
    let models: [ModelBreakdownItem]

    private var slices: [(model: ModelBreakdownItem, startAngle: Double, endAngle: Double)] {
        var current = -90.0 // start at top
        return models.map { model in
            let start = current
            let sweep = model.fraction * 360
            current += sweep
            return (model, start, start + sweep)
        }
    }

    var body: some View {
        if models.isEmpty {
            Text("No model data")
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.Colors.textTertiary)
        } else {
            HStack(spacing: 16) {
                ZStack {
                    ForEach(Array(slices.enumerated()), id: \.element.model.id) { index, slice in
                        DonutSlice(
                            startAngle: .degrees(slice.startAngle),
                            endAngle: .degrees(slice.endAngle),
                            thickness: 24
                        )
                        .fill(colorForIndex(index, name: slice.model.friendlyName))
                    }

                    // Center label
                    VStack(spacing: 2) {
                        Text("\(models.count)")
                            .font(Theme.Fonts.statSmall)
                            .foregroundStyle(Theme.Colors.textPrimary)
                        Text("models")
                            .font(.system(size: 9))
                            .foregroundStyle(Theme.Colors.textTertiary)
                    }
                }
                .frame(width: 120, height: 120)

                // Legend
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(models.enumerated()), id: \.element.id) { index, model in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(colorForIndex(index, name: model.friendlyName))
                                .frame(width: 8, height: 8)
                            Text(model.friendlyName)
                                .font(Theme.Fonts.caption)
                                .foregroundStyle(Theme.Colors.textPrimary)
                            Spacer()
                            Text((model.fraction * 100).percentFormatted)
                                .font(Theme.Fonts.caption)
                                .foregroundStyle(Theme.Colors.textSecondary)
                        }
                    }
                }
            }
        }
    }

    private func colorForIndex(_ index: Int, name: String) -> Color {
        if name.contains("Opus") { return Theme.Colors.primary }
        if name.contains("Sonnet") { return Theme.Colors.secondary }
        let palette: [Color] = [.blue, .teal, .indigo, .mint, .cyan]
        return palette[index % palette.count]
    }
}

private struct DonutSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let thickness: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let innerRadius = radius - thickness

        var path = Path()
        path.addArc(center: center, radius: radius,
                     startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.addArc(center: center, radius: innerRadius,
                     startAngle: endAngle, endAngle: startAngle, clockwise: true)
        path.closeSubpath()
        return path
    }
}
