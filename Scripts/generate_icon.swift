#!/usr/bin/env swift

import Foundation
import CoreGraphics
import AppKit

// Claude purple gradient colors
let purpleStart = NSColor(red: 0.847, green: 0.584, blue: 0.839, alpha: 1.0) // #D895D6
let purpleEnd = NSColor(red: 0.706, green: 0.416, blue: 0.698, alpha: 1.0)   // #B46AB2

let assetPath = "ClaudeCompass/Resources/Assets.xcassets/AppIcon.appiconset"

struct IconSize {
    let size: Int
    let scale: Int
    var pixels: Int { size * scale }
    var filename: String { "icon_\(size)x\(size)@\(scale)x.png" }
}

let sizes: [IconSize] = [
    IconSize(size: 16, scale: 1),
    IconSize(size: 16, scale: 2),
    IconSize(size: 32, scale: 1),
    IconSize(size: 32, scale: 2),
    IconSize(size: 128, scale: 1),
    IconSize(size: 128, scale: 2),
    IconSize(size: 256, scale: 1),
    IconSize(size: 256, scale: 2),
    IconSize(size: 512, scale: 1),
    IconSize(size: 512, scale: 2),
]

func generateIcon(pixels: Int) -> NSImage {
    let size = NSSize(width: pixels, height: pixels)
    let image = NSImage(size: size)

    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let w = CGFloat(pixels)
    let h = CGFloat(pixels)
    let center = CGPoint(x: w / 2, y: h / 2)
    let radius = w * 0.42

    // Background: rounded rect with purple gradient
    let cornerRadius = w * 0.22
    let bgRect = CGRect(x: w * 0.02, y: h * 0.02, width: w * 0.96, height: h * 0.96)
    let bgPath = CGPath(roundedRect: bgRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let gradientColors = [purpleStart.cgColor, purpleEnd.cgColor] as CFArray
    let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: h), end: CGPoint(x: w, y: 0), options: [])
    ctx.restoreGState()

    // Compass circle outline
    ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.9))
    ctx.setLineWidth(w * 0.025)
    ctx.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    ctx.strokePath()

    // Tick marks at N, S, E, W
    let tickLength = w * 0.06
    let tickWidth = w * 0.02
    ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.8))
    ctx.setLineWidth(tickWidth)

    let tickAngles: [CGFloat] = [.pi / 2, -.pi / 2, 0, .pi] // N, S, E, W
    for angle in tickAngles {
        let outerX = center.x + cos(angle) * radius
        let outerY = center.y + sin(angle) * radius
        let innerX = center.x + cos(angle) * (radius - tickLength)
        let innerY = center.y + sin(angle) * (radius - tickLength)
        ctx.move(to: CGPoint(x: outerX, y: outerY))
        ctx.addLine(to: CGPoint(x: innerX, y: innerY))
        ctx.strokePath()
    }

    // Compass needle - North (white, pointing up)
    let needleLength = radius * 0.75
    let needleWidth = w * 0.06

    // North half (white)
    ctx.saveGState()
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1.0))
    ctx.move(to: CGPoint(x: center.x, y: center.y + needleLength))
    ctx.addLine(to: CGPoint(x: center.x - needleWidth, y: center.y))
    ctx.addLine(to: CGPoint(x: center.x + needleWidth, y: center.y))
    ctx.closePath()
    ctx.fillPath()
    ctx.restoreGState()

    // South half (semi-transparent white)
    ctx.saveGState()
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.45))
    ctx.move(to: CGPoint(x: center.x, y: center.y - needleLength))
    ctx.addLine(to: CGPoint(x: center.x - needleWidth, y: center.y))
    ctx.addLine(to: CGPoint(x: center.x + needleWidth, y: center.y))
    ctx.closePath()
    ctx.fillPath()
    ctx.restoreGState()

    // Center dot
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1.0))
    let dotRadius = w * 0.035
    ctx.addArc(center: center, radius: dotRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    ctx.fillPath()

    image.unlockFocus()
    return image
}

// Generate all sizes
let scriptDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let assetDir = scriptDir.appendingPathComponent(assetPath)

// Ensure directory exists
try? FileManager.default.createDirectory(at: assetDir, withIntermediateDirectories: true)

var imagesJSON: [[String: Any]] = []

for iconSize in sizes {
    let image = generateIcon(pixels: iconSize.pixels)

    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("Failed to generate \(iconSize.filename)")
        continue
    }

    let filePath = assetDir.appendingPathComponent(iconSize.filename)
    try pngData.write(to: filePath)
    print("Generated: \(iconSize.filename) (\(iconSize.pixels)x\(iconSize.pixels) px)")

    imagesJSON.append([
        "filename": iconSize.filename,
        "idiom": "mac",
        "scale": "\(iconSize.scale)x",
        "size": "\(iconSize.size)x\(iconSize.size)"
    ])
}

// Write Contents.json
let contentsJSON: [String: Any] = [
    "images": imagesJSON,
    "info": [
        "author": "xcode",
        "version": 1
    ]
]

let jsonData = try JSONSerialization.data(withJSONObject: contentsJSON, options: [.prettyPrinted, .sortedKeys])
let contentsPath = assetDir.appendingPathComponent("Contents.json")
try jsonData.write(to: contentsPath)
print("Updated Contents.json")
print("Done! Generated \(sizes.count) icon sizes.")
