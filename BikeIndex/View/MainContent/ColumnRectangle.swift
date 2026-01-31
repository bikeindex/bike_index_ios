//
//  ColumnRectangle.swift
//  BikeIndex
//
//  Created by Jack on 1/30/26.
//

import SwiftUI

struct ColumnRectangle: Shape {
    /// The "position index" that the Shape receiving this `.clippedShape(BifurcatedRectangle())` **should** display within
    var column: Int
    var totalCount: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)

        let colWidth = rect.width / CGFloat(totalCount)
        for layoutColumn in 0..<totalCount where layoutColumn != column {
            let clipRect = CGRect(
                x: colWidth * CGFloat(layoutColumn),
                y: rect.origin.y,
                width: colWidth,
                height: rect.height)
            var clipPath = Path()
            clipPath.addRect(clipRect)
            path = path.subtracting(clipPath)
        }

        return path
    }
}

#Preview {
    VStack(spacing: 0) {
        Rectangle()
            .foregroundStyle(.red)
            .clipShape(ColumnRectangle(column: 0, totalCount: 3))
        Rectangle()
            .foregroundStyle(.red)
            .clipShape(ColumnRectangle(column: 1, totalCount: 3))
        Rectangle()
            .foregroundStyle(.red)
            .clipShape(ColumnRectangle(column: 2, totalCount: 3))
    }
    .background(.yellow)
}
