//
//  StorageBarView.swift
//  SongDrop
//
//  Created by Rohan Sastri on 5/1/26.
//

import Charts
import SwiftUI

struct StorageBarView: View {
    let info: CacheStorageInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            bar
            legend
        }
    }

    @ViewBuilder
    private var bar: some View {
        if info.isEmpty {
            Color(.gray)
                .frame(height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            Chart(info.segments) { segment in
                BarMark(
                    x: .value("Size", Double(segment.bytes)),
                    y: .value("Cache", "")
                )
                .foregroundStyle(segment.color)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartXScale(domain: 0...Double(info.totalBytes))
            .frame(height: 28)
            .clipShape(
                ConcentricRectangle(
                    corners: .concentric(minimum: 8),
                    isUniform: true
                )
            )
        }
    }

    @ViewBuilder
    private var legend: some View {
        if info.isEmpty {
            Text("No cached data")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            HStack(spacing: 16) {
                ForEach(info.segments) { segment in
                    HStack(spacing: 6) {
                        ConcentricRectangle(
                            corners: .concentric(minimum: 8),
                            isUniform: true
                        )
                        .fill(segment.color)
                        .frame(width: 12, height: 12)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(segment.name)
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(segment.formattedSize)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    StorageBarView(
        info: .init(segments: [
            .init(name: "Images", bytes: 256, color: .red),
            .init(name: "Network", bytes: 64, color: .blue),
        ])
    )
}
