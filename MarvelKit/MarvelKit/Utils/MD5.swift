//
//  from CryptoSwift
//  https://github.com/krzyzanowskim/CryptoSwift
//
//  Copyright (C) 2014 Marcin Krzyżanowski <marcin.krzyzanowski@gmail.com>
//  This software is provided 'as-is', without any express or implied warranty.
//
//  In no event will the authors be held liable for any damages arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
//
//  - The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation is required.
//  - Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
//  - This notice may not be removed or altered from any source or binary distribution.
//

//
//  Modified by Carsten Könemann on 09.05.16.
//
//  I took the MD5 related portions from CryptoSwift instead of adding it via Carthage, because
//
//  - i didn't want to introduce a dependency
//  - dynamic frameworks seem to inflate the binary size for some reason
//  - i was interested in how to implement MD5
//

extension SequenceType where Generator.Element == UInt8 {

    var hexString: String {
        return self.lazy.reduce("") { $0 + String(format: "%02x", $1) }
    }

    var md5: [Generator.Element] {
        return MD5(Array(self)).calculate()
    }
    
}

extension String {

    var md5: String {
        return self.utf8.lazy.map({ $0 as UInt8 }).md5.hexString
    }

}

struct BytesSequence: SequenceType {

    let chunkSize: Int
    let data: [UInt8]

    func generate() -> AnyGenerator<ArraySlice<UInt8>> {

        var offset: Int = 0

        return AnyGenerator {
            let end = min(self.chunkSize, self.data.count - offset)
            let result = self.data[offset ..< offset + end]
            offset += result.count
            return result.count > 0 ? result : nil
        }
    }

}

/// Array of bytes, little-endian representation. Don't use if not necessary.
/// I found this method slow
func arrayOfBytes<T>(value: T, length: Int? = nil) -> [UInt8] {

    let totalBytes = length ?? sizeof(T)

    let valuePointer = UnsafeMutablePointer<T>.alloc(1)
    valuePointer.memory = value

    let bytesPointer = UnsafeMutablePointer<UInt8>(valuePointer)
    var bytes = [UInt8](count: totalBytes, repeatedValue: 0)
    for j in 0 ..< min(sizeof(T), totalBytes) {
        bytes[totalBytes - 1 - j] = (bytesPointer + j).memory
    }

    valuePointer.destroy()
    valuePointer.dealloc(1)

    return bytes
}

/* array of bytes */
extension Int {

    /** Array of bytes with optional padding (little-endian) */
    func bytes(totalBytes: Int = sizeof(Int)) -> [UInt8] {
        return arrayOfBytes(self, length: totalBytes)
    }

}

internal protocol HashProtocol {
    var message: Array<UInt8> { get }

    /** Common part for hash calculation. Prepare header data. */
    func prepare(len:Int) -> Array<UInt8>
}

extension HashProtocol {

    func prepare(len: Int) -> Array<UInt8> {
        var tmpMessage = message

        // Step 1. Append Padding Bits
        tmpMessage.append(0x80) // append one bit (UInt8 with one bit) to message

        // append "0" bit until message length in bits ≡ 448 (mod 512)
        var msgLength = tmpMessage.count
        var counter = 0

        while msgLength % len != (len - 8) {
            counter += 1
            msgLength += 1
        }

        tmpMessage += Array<UInt8>(count: counter, repeatedValue: 0)
        return tmpMessage
    }
}

final class MD5: HashProtocol  {

    static let size: Int = 16 // 128 / 8

    let message: Array<UInt8>

    init (_ message: Array<UInt8>) {
        self.message = message
    }

    /** specifies the per-round shift amounts */
    private let s: [UInt32] = [
        7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
        5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
        4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
        6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21
    ]

    /** binary integer part of the sines of integers (Radians) */
    private let k: [UInt32] = [
        0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
        0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
        0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
        0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
        0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
        0xd62f105d, 0x2441453, 0xd8a1e681, 0xe7d3fbc8,
        0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
        0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
        0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
        0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
        0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x4881d05,
        0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
        0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
        0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
        0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
        0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
    ]

    private let h: [UInt32] = [
        0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476
    ]

    func calculate() -> [UInt8] {

        var tmpMessage = prepare(64)
        tmpMessage.reserveCapacity(tmpMessage.count + 4)

        // initialize hh with hash values
        var hh = h

        // Step 2. Append Length a 64-bit representation of lengthInBits
        let lengthInBits = (message.count * 8)
        let lengthBytes = lengthInBits.bytes(64 / 8)
        tmpMessage += lengthBytes.reverse()

        // Process the message in successive 512-bit chunks:
        let chunkSizeBytes = 512 / 8 // 64
        for chunk in BytesSequence(chunkSize: chunkSizeBytes, data: tmpMessage) {

            // break chunk into sixteen 32-bit words M[j], 0 ≤ j ≤ 15
            var M = toUInt32Array(chunk)
            assert(M.count == 16, "Invalid array")

            // Initialize hash value for this chunk:
            var A: UInt32 = hh[0]
            var B: UInt32 = hh[1]
            var C: UInt32 = hh[2]
            var D: UInt32 = hh[3]

            var dTemp: UInt32 = 0

            // Main loop
            for j in 0 ..< k.count {

                var g = 0
                var F: UInt32 = 0

                switch (j) {
                    case 0...15:
                        F = (B & C) | ((~B) & D)
                        g = j
                    case 16...31:
                        F = (D & B) | (~D & C)
                        g = (5 * j + 1) % 16
                    case 32...47:
                        F = B ^ C ^ D
                        g = (3 * j + 5) % 16
                    case 48...63:
                        F = C ^ (B | (~D))
                        g = (7 * j) % 16
                    default:
                        break
                }

                dTemp = D
                D = C
                C = B
                B = B &+ rotateLeft((A &+ F &+ k[j] &+ M[g]), s[j])
                A = dTemp
            }

            hh[0] = hh[0] &+ A
            hh[1] = hh[1] &+ B
            hh[2] = hh[2] &+ C
            hh[3] = hh[3] &+ D
        }

        var result = [UInt8]()
        result.reserveCapacity(hh.count / 4)

        hh.forEach {
            let itemLE = $0.littleEndian
            result += [UInt8(itemLE & 0xff), UInt8((itemLE >> 8) & 0xff), UInt8((itemLE >> 16) & 0xff), UInt8((itemLE >> 24) & 0xff)]
        }

        return result
    }

    func toUInt32Array(slice: ArraySlice<UInt8>) -> Array<UInt32> {

        var result = Array<UInt32>()
        result.reserveCapacity(16)

        for idx in slice.startIndex.stride(to: slice.endIndex, by: sizeof(UInt32)) {

            let val1: UInt32 = (UInt32(slice[idx.advancedBy(3)]) << 24)
            let val2: UInt32 = (UInt32(slice[idx.advancedBy(2)]) << 16)
            let val3: UInt32 = (UInt32(slice[idx.advancedBy(1)]) << 8)
            let val4: UInt32 = UInt32(slice[idx])
            let val: UInt32 = val1 | val2 | val3 | val4

            result.append(val)
        }

        return result
    }

    func rotateLeft(v: UInt32, _ n: UInt32) -> UInt32 {
        return ((v << n) & 0xFFFFFFFF) | (v >> (32 - n))
    }

}