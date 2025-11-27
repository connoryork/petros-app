//
//  GoogleCalendarAuthService.swift
//  petros-app
//
//  Created by GPT-5 Codex on 11/9/25.
//

import Foundation
import SwiftJWT

enum GoogleCalendarAuthError: LocalizedError {
    case missingCredentialsFile(String)
    case invalidCredentialsData
    case unsupportedKeyFormat
    case tokenRequestFailed(statusCode: Int, message: String?)
    case invalidTokenResponse

    var errorDescription: String? {
        switch self {
        case .missingCredentialsFile(let fileName):
            return "Unable to locate Google service account credentials file named \(fileName)."
        case .invalidCredentialsData:
            return "Google service account credentials could not be decoded."
        case .unsupportedKeyFormat:
            return "Google service account private key is in an unsupported format."
        case .tokenRequestFailed(let statusCode, let message):
            if let message = message {
                return "Google OAuth token request failed with status \(statusCode): \(message)"
            } else {
                return "Google OAuth token request failed with status \(statusCode)."
            }
        case .invalidTokenResponse:
            return "Google OAuth token response was invalid or missing data."
        }
    }
}

struct GoogleServiceAccountCredentials: Decodable {
    let privateKeyID: String
    let privateKey: String
    let clientEmail: String
    let tokenURI: String

    private enum CodingKeys: String, CodingKey {
        case privateKeyID = "private_key_id"
        case privateKey = "private_key"
        case clientEmail = "client_email"
        case tokenURI = "token_uri"
    }
}

struct GoogleAccessToken: Decodable {
    let accessToken: String
    let expiresIn: Int
    let tokenType: String

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

private struct GoogleJWTClaims: Claims {
    let iss: String
    let scope: String
    let aud: String
    let exp: Date
    let iat: Date
}

protocol GoogleServiceAccountCredentialsProviding {
    func loadCredentials() throws -> GoogleServiceAccountCredentials
}

struct BundleServiceAccountCredentialsProvider: GoogleServiceAccountCredentialsProviding {
    let fileName: String
    let fileExtension: String

    init(
        fileName: String = GoogleCalendarConfig.shared.serviceAccountFileName,
        fileExtension: String = GoogleCalendarConfig.shared.serviceAccountFileExtension
    ) {
        self.fileName = fileName
        self.fileExtension = fileExtension
    }

    func loadCredentials() throws -> GoogleServiceAccountCredentials {
        let possibleURLs: [URL?] = [
            Bundle.main.url(forResource: fileName, withExtension: fileExtension),
            Bundle.main.url(forResource: fileName, withExtension: fileExtension, subdirectory: "Secrets")
        ]

        guard let fileURL = possibleURLs.compactMap({ $0 }).first else {
            throw GoogleCalendarAuthError.missingCredentialsFile("\(fileName).\(fileExtension)")
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(GoogleServiceAccountCredentials.self, from: data)
        } catch {
            throw GoogleCalendarAuthError.invalidCredentialsData
        }
    }
}

actor GoogleCalendarAuthService {
    static let shared = GoogleCalendarAuthService()

    private let credentialsProvider: GoogleServiceAccountCredentialsProviding
    private var cachedTokens: [String: CachedToken] = [:]

    private struct CachedToken {
        let accessToken: String
        let expirationDate: Date

        var isValid: Bool {
            let refreshBuffer: TimeInterval = 60 // seconds
            return Date().addingTimeInterval(refreshBuffer) < expirationDate
        }
    }
    
    private func scopeKey(for scopes: [String]) -> String {
        scopes.sorted().joined(separator: " ")
    }

    init(credentialsProvider: GoogleServiceAccountCredentialsProviding = BundleServiceAccountCredentialsProvider()) {
        self.credentialsProvider = credentialsProvider
    }

    func accessToken(scopes: [String]) async throws -> String {
        let key = scopeKey(for: scopes)
        
        if let cachedToken = cachedTokens[key], cachedToken.isValid {
            return cachedToken.accessToken
        }

        let credentials = try credentialsProvider.loadCredentials()
        let signedJWT = try signJWT(credentials: credentials, scopes: scopes)
        let token = try await requestAccessToken(credentials: credentials, signedJWT: signedJWT)

        cachedTokens[key] = CachedToken(
            accessToken: token.accessToken,
            expirationDate: Date().addingTimeInterval(TimeInterval(token.expiresIn))
        )

        return token.accessToken
    }

    private func signJWT(credentials: GoogleServiceAccountCredentials, scopes: [String]) throws -> String {
        let now = Date()
        let header = Header(typ: "JWT", kid: credentials.privateKeyID)
        let claims = GoogleJWTClaims(
            iss: credentials.clientEmail,
            scope: scopes.joined(separator: " "),
            aud: credentials.tokenURI,
            exp: now.addingTimeInterval(3600),
            iat: now
        )
        var jwt = JWT(header: header, claims: claims)

        let privateKeyData = try decodePrivateKey(credentials.privateKey)
        let signer = JWTSigner.rs256(privateKey: privateKeyData)
        return try jwt.sign(using: signer)
    }

    private func decodePrivateKey(_ pemString: String) throws -> Data {
        let cleanedKey = pemString
            .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = Data(base64Encoded: cleanedKey) else {
            throw GoogleCalendarAuthError.unsupportedKeyFormat
        }

        return data
    }

    private func requestAccessToken(credentials: GoogleServiceAccountCredentials, signedJWT: String) async throws -> GoogleAccessToken {
        guard let tokenURL = URL(string: credentials.tokenURI) else {
            throw GoogleCalendarAuthError.invalidCredentialsData
        }

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "urn:ietf:params:oauth:grant-type:jwt-bearer"),
            URLQueryItem(name: "assertion", value: signedJWT)
        ]

        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GoogleCalendarAuthError.invalidTokenResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let message = String(data: data, encoding: .utf8)
            throw GoogleCalendarAuthError.tokenRequestFailed(statusCode: httpResponse.statusCode, message: message)
        }

        let decoder = JSONDecoder()
        do {
            return try decoder.decode(GoogleAccessToken.self, from: data)
        } catch {
            throw GoogleCalendarAuthError.invalidTokenResponse
        }
    }
}

