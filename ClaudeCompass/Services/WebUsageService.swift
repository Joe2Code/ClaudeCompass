import Foundation

actor WebUsageService {
    static let shared = WebUsageService()

    private let baseURL = "https://api.anthropic.com"

    struct WebUsageData: Sendable {
        let dailyUsagePercent: Double?
        let remainingMessages: Int?
        let maxMessages: Int?
        let resetTime: Date?
    }

    func fetchUsage(sessionKey: String, orgId: String?) async throws -> WebUsageData {
        var urlString = "\(baseURL)/v1/usage"
        if let orgId {
            urlString += "?org_id=\(orgId)"
        }

        guard let url = URL(string: urlString) else {
            throw WebUsageError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(sessionKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WebUsageError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw WebUsageError.httpError(httpResponse.statusCode)
        }

        // Parse the response — structure may vary, handle gracefully
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        return WebUsageData(
            dailyUsagePercent: json?["daily_usage_percent"] as? Double,
            remainingMessages: json?["remaining_messages"] as? Int,
            maxMessages: json?["max_messages"] as? Int,
            resetTime: (json?["reset_time"] as? String).flatMap(Date.fromISO)
        )
    }
}

enum WebUsageError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL"
        case .invalidResponse: return "Invalid API response"
        case .httpError(let code): return "API error (HTTP \(code))"
        case .notConfigured: return "API credentials not configured"
        }
    }
}
