//
//  IconRenderer.swift
//  Daily Todo
//
//  Created by MD Younus Foysal on 1/4/26.
//
//  Generates both the macOS app icon (for Spotlight / About dialog)
//  and the menu bar template icon purely in code, so no PNG assets
//  are required.
//

import AppKit

// MARK: - App Icon (coloured, used by Spotlight / About)

extension NSImage {
    /// Draws a rounded-rectangle checklist icon at the requested size.
    static func appIcon(size: CGFloat = 512) -> NSImage {
        let img = NSImage(size: NSSize(width: size, height: size))
        img.lockFocus()
        defer { img.unlockFocus() }

        guard let ctx = NSGraphicsContext.current?.cgContext else { return img }
        let fullRect = CGRect(origin: .zero, size: CGSize(width: size, height: size))

        // ── Background gradient ────────────────────────────────────
        let bgPath = CGPath(roundedRect: fullRect,
                            cornerWidth: size * 0.22, cornerHeight: size * 0.22,
                            transform: nil)
        ctx.addPath(bgPath)
        ctx.clip()

        let colors = [CGColor(red: 0.20, green: 0.47, blue: 0.95, alpha: 1),
                      CGColor(red: 0.10, green: 0.28, blue: 0.82, alpha: 1)] as CFArray
        let locs: [CGFloat] = [0, 1]
        if let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                 colors: colors, locations: locs) {
            ctx.drawLinearGradient(grad,
                                   start: CGPoint(x: size / 2, y: size),
                                   end:   CGPoint(x: size / 2, y: 0),
                                   options: [])
        }

        // ── Checklist rows ─────────────────────────────────────────
        let pad    = size * 0.20
        let lineH  = size * 0.11
        let gap    = size * 0.055
        let rows   = 4
        let startY = (size - (lineH * CGFloat(rows) + gap * CGFloat(rows - 1))) / 2

        for i in 0 ..< rows {
            let y       = startY + CGFloat(i) * (lineH + gap)
            let checked = i < 3
            let boxSz   = lineH * 0.90
            let boxX    = pad
            let boxY    = y + (lineH - boxSz) / 2
            let boxRect = CGRect(x: boxX, y: boxY, width: boxSz, height: boxSz)
            let boxPath = CGPath(roundedRect: boxRect,
                                 cornerWidth: boxSz * 0.30,
                                 cornerHeight: boxSz * 0.30, transform: nil)

            if checked {
                // Filled box
                ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.95))
                ctx.addPath(boxPath); ctx.fillPath()
                // Checkmark stroke
                ctx.setStrokeColor(CGColor(red: 0.15, green: 0.38, blue: 0.90, alpha: 1))
                ctx.setLineWidth(size * 0.022)
                ctx.setLineCap(.round); ctx.setLineJoin(.round)
                let cx = boxX + boxSz / 2, cy = boxY + boxSz / 2
                ctx.move(to:    CGPoint(x: cx - boxSz * 0.28, y: cy))
                ctx.addLine(to: CGPoint(x: cx - boxSz * 0.05, y: cy - boxSz * 0.25))
                ctx.addLine(to: CGPoint(x: cx + boxSz * 0.30, y: cy + boxSz * 0.25))
                ctx.strokePath()
            } else {
                // Outlined box (pending)
                ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.55))
                ctx.setLineWidth(size * 0.022)
                ctx.addPath(boxPath); ctx.strokePath()
            }

            // Text bar
            let barH    = lineH * 0.30
            let barX    = pad + boxSz + size * 0.055
            let barW    = (size - barX - pad) * (i == rows - 1 ? 0.55 : 1.0)
            let barRect = CGRect(x: barX, y: y + (lineH - barH) / 2, width: barW, height: barH)
            let barPath = CGPath(roundedRect: barRect,
                                 cornerWidth: barH / 2, cornerHeight: barH / 2,
                                 transform: nil)
            ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: checked ? 0.75 : 0.40))
            ctx.addPath(barPath); ctx.fillPath()
        }

        return img
    }

    // MARK: - Menu Bar Template Icon

    /// Black-only template image for the menu bar (18 × 18 pt logical).
    static func menuBarTemplateIcon(size: CGFloat = 18) -> NSImage {
        let img = NSImage(size: NSSize(width: size, height: size))
        img.isTemplate = true
        img.lockFocus()
        defer { img.unlockFocus() }

        guard let ctx = NSGraphicsContext.current?.cgContext else { return img }
        ctx.setFillColor(CGColor(gray: 0, alpha: 1))

        let pad    = size * 0.10
        let rows   = 4
        let avail  = size - pad * 2
        let lineH  = avail * 0.55 / CGFloat(rows)
        let gap    = (avail - lineH * CGFloat(rows)) / CGFloat(rows - 1)
        let boxSz  = lineH * 0.85
        let lw     = size * 0.07

        for i in 0 ..< rows {
            let y       = pad + CGFloat(i) * (lineH + gap)
            let boxRect = CGRect(x: pad, y: y + (lineH - boxSz) / 2, width: boxSz, height: boxSz)
            let boxPath = CGPath(roundedRect: boxRect,
                                 cornerWidth: boxSz * 0.25, cornerHeight: boxSz * 0.25,
                                 transform: nil)
            ctx.setLineWidth(lw)
            ctx.addPath(boxPath); ctx.strokePath()

            let barH    = lineH * 0.28
            let barX    = pad + boxSz + size * 0.10
            let barW    = (size - barX - pad * 0.5) * (i == rows - 1 ? 0.55 : 1.0)
            let barRect = CGRect(x: barX, y: y + (lineH - barH) / 2, width: barW, height: barH)
            ctx.fill(barRect)
        }

        return img
    }
}

