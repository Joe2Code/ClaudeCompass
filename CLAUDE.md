# Claude Compass

macOS menu bar app that tracks Claude AI usage by reading `~/.claude/stats-cache.json`.

## Build

```bash
cd /Users/admin/Desktop/Apps/ClaudeCompass
xcodegen generate
xcodebuild -project ClaudeCompass.xcodeproj -scheme ClaudeCompass -configuration Debug build
```

## Architecture

- **Swift 6 / SwiftUI / macOS 14+** (Sonoma; @Observable requires 14+)
- **XcodeGen** for project generation (`project.yml` → `.xcodeproj`)
- **MenuBarExtra** with `.window` style for popover
- **@Observable** for state management
- **LSUIElement** = true (no dock icon)
- **No App Sandbox** (reads `~/.claude/stats-cache.json`)

## Key Files

- `project.yml` — XcodeGen project spec
- `ClaudeCompass/App/ClaudeCompassApp.swift` — @main entry point
- `ClaudeCompass/Models/StatsCache.swift` — Codable matching stats-cache.json
- `ClaudeCompass/Services/LocalStatsService.swift` — reads the JSON file
- `ClaudeCompass/ViewModels/DashboardViewModel.swift` — main orchestrator
