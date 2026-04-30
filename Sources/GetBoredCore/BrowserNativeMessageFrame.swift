import Foundation

/// Encodes and decodes Chrome native messaging frames.
///
/// Direction:
/// - The Chrome extension initiates by sending a framed JSON message.
/// - The native host executable receives that frame and decodes it here.
/// - The native host executable encodes the response here before replying.
enum BrowserNativeMessageFrame {
    enum FrameError: Error, Equatable {
        case missingLengthPrefix
        case lengthMismatch(expected: UInt32, actual: Int)
        case messageTooLarge(Int)
    }

    static let maximumMessageSize = 1_048_576

    static func decode(_ framedData: Data) throws -> Data {
        guard framedData.count >= 4 else {
            throw FrameError.missingLengthPrefix
        }

        let length = framedData.prefix(4).enumerated().reduce(UInt32(0)) { partial, pair in
            partial | (UInt32(pair.element) << UInt32(pair.offset * 8))
        }
        let body = framedData.dropFirst(4)

        guard body.count == Int(length) else {
            throw FrameError.lengthMismatch(expected: length, actual: body.count)
        }

        return Data(body)
    }

    static func encode(_ messageData: Data) throws -> Data {
        guard messageData.count <= maximumMessageSize else {
            throw FrameError.messageTooLarge(messageData.count)
        }

        let length = UInt32(messageData.count)
        var framedData = Data([
            UInt8(length & 0xff),
            UInt8((length >> 8) & 0xff),
            UInt8((length >> 16) & 0xff),
            UInt8((length >> 24) & 0xff),
        ])
        framedData.append(messageData)
        return framedData
    }
}
