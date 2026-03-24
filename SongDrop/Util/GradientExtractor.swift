//
//  GradientExtractor.swift
//  SongDrop
//
//  Created by Rohan Sastri on 3/9/26.
//

import UIKit

struct GradientColors {
    let top: UIColor
    let bottom: UIColor
}

enum GradientExtractor {
    // Max dimension for downsampling before regression
    private static let maxSampleDimension: Int = 32

    /// Swift implementation of JS dont-crop library
    static func fitGradient(from image: UIImage) -> GradientColors? {
        guard let cgImage = image.cgImage else { return nil }

        // Downsample to max 32x32
        let originalWidth = cgImage.width
        let originalHeight = cgImage.height
        guard originalWidth > 0, originalHeight > 0 else { return nil }

        let scale = min(
            Double(maxSampleDimension)
                / Double(max(originalWidth, originalHeight)),
            1.0
        )
        let width = Int(Double(originalWidth) * scale)
        let height = Int(Double(originalHeight) * scale)
        guard width > 0, height > 0 else { return nil }

        let bytesPerRow = width * 4
        var pixelData = [UInt8](repeating: 0, count: bytesPerRow * height)

        guard
            let context = CGContext(
                data: &pixelData,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        else { return nil }

        context.interpolationQuality = .low
        context.draw(
            cgImage,
            in: CGRect(x: 0, y: 0, width: width, height: height)
        )

        let totalPixels = width * height

        var sumT: Double = 0
        var sumT2: Double = 0
        var sumR: Double = 0
        var sumG: Double = 0
        var sumB: Double = 0
        var sumTR: Double = 0
        var sumTG: Double = 0
        var sumTB: Double = 0
        let n = Double(totalPixels)
        let h = Double(height)

        for y in 0..<height {
            let t = Double(y) / h
            let rowOffset = y * bytesPerRow
            var rowR = 0
            var rowG = 0
            var rowB = 0
            for x in 0..<width {
                let offset = rowOffset + x * 4
                rowR += Int(pixelData[offset])
                rowG += Int(pixelData[offset + 1])
                rowB += Int(pixelData[offset + 2])
            }
            let r = Double(rowR)
            let g = Double(rowG)
            let b = Double(rowB)
            let w = Double(width)
            sumT += t * w
            sumT2 += t * t * w
            sumR += r
            sumG += g
            sumB += b
            sumTR += t * r
            sumTG += t * g
            sumTB += t * b
        }

        let denom = n * sumT2 - sumT * sumT
        guard denom != 0 else {
            let avg = UIColor(
                red: sumR / (n * 255),
                green: sumG / (n * 255),
                blue: sumB / (n * 255),
                alpha: 1
            )
            return GradientColors(top: avg, bottom: avg)
        }

        func regress(sumX: Double, sumTX: Double) -> (
            intercept: Double, slope: Double
        ) {
            let slope = (n * sumTX - sumT * sumX) / denom
            let intercept = (sumX - slope * sumT) / n
            return (intercept, slope)
        }

        let rReg = regress(sumX: sumR, sumTX: sumTR)
        let gReg = regress(sumX: sumG, sumTX: sumTG)
        let bReg = regress(sumX: sumB, sumTX: sumTB)

        func clamp01(_ v: Double) -> CGFloat {
            CGFloat(max(0, min(v / 255.0, 1.0)))
        }

        let top = UIColor(
            red: clamp01(rReg.intercept),
            green: clamp01(gReg.intercept),
            blue: clamp01(bReg.intercept),
            alpha: 1
        )
        let bottom = UIColor(
            red: clamp01(rReg.intercept + rReg.slope),
            green: clamp01(gReg.intercept + gReg.slope),
            blue: clamp01(bReg.intercept + bReg.slope),
            alpha: 1
        )

        return GradientColors(top: top, bottom: bottom)
    }

    static func isDark(colors: GradientColors?) -> Bool {
        guard let colors else { return false }
        
        let color = average(colors.top, colors.bottom)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        guard color.getRed(&red, green: &green, blue: &blue, alpha: nil) else {
            return false
        }

        // Calculate luminance using the standard formula
        let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue

        // Return true if the luminance is below a certain threshold (e.g., 0.5)
        return luminance < 0.5
    }

    static func average(_ c1: UIColor, _ c2: UIColor) -> UIColor {
        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (
            0, 0, 0, 0
        )
        var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (
            0, 0, 0, 0
        )

        // Convert both colors to RGBA in the extended sRGB space
        c1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        c2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return UIColor(
            red: (r1 + r2) / 2,
            green: (g1 + g2) / 2,
            blue: (b1 + b2) / 2,
            alpha: (a1 + a2) / 2
        )
    }

}
