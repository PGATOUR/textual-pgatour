#if TEXTUAL_ENABLE_TEXT_SELECTION
import SwiftUI

extension LiveTextLayoutCollection {
  /// `LayoutCollectionSignature`  provides a stable comparision between text layout.
  /// It compares resolved geometry and text semantics instead of SwiftUI's anchored-layout identity,
  struct LayoutCollectionSignature: Equatable {
    let layouts: [LayoutSignature]

    init(layouts: [any TextLayout], includeLayoutOrigin: Bool) {
      self.layouts = layouts.map {
        LayoutSignature($0, includeLayoutOrigin: includeLayoutOrigin)
      }
    }
  }
}

extension LiveTextLayoutCollection.LayoutCollectionSignature {
  struct LayoutSignature: Equatable {
    let string: String
    let origin: QuantizedPoint?
    let bounds: QuantizedRect
    let lines: [LineSignature]

    init(_ layout: any TextLayout, includeLayoutOrigin: Bool) {
      self.string = layout.attributedString.string
      self.origin = includeLayoutOrigin ? .init(layout.origin) : nil
      self.bounds = .init(layout.bounds)
      self.lines = layout.lines.map(LineSignature.init)
    }
  }

  struct LineSignature: Equatable {
    let origin: QuantizedPoint
    let bounds: QuantizedRect
    let runs: [RunSignature]

    init(_ line: any TextLine) {
      self.origin = .init(line.origin)
      self.bounds = .init(line.typographicBounds)
      self.runs = line.runs.map(RunSignature.init)
    }
  }

  struct RunSignature: Equatable {
    let url: URL?
    let bounds: QuantizedRect
    let slices: [RunSliceSignature]

    init(_ run: any TextRun) {
      self.url = run.url
      self.bounds = .init(run.typographicBounds)
      self.slices = run.slices.map(RunSliceSignature.init)
    }
  }

  struct RunSliceSignature: Equatable {
    let bounds: QuantizedRect
    let characterRange: Range<Int>

    init(_ slice: any TextRunSlice) {
      self.bounds = .init(slice.typographicBounds)
      self.characterRange = slice.characterRange
    }
  }

  struct QuantizedPoint: Equatable {
    let x: Int64
    let y: Int64

    init(_ point: CGPoint) {
      self.x = Self.quantize(point.x)
      self.y = Self.quantize(point.y)
    }

    static func quantize(_ value: CGFloat) -> Int64 {
      Int64((value * 1_000).rounded())
    }
  }

  struct QuantizedRect: Equatable {
    let x: Int64
    let y: Int64
    let width: Int64
    let height: Int64

    init(_ rect: CGRect) {
      self.x = Self.quantize(rect.origin.x)
      self.y = Self.quantize(rect.origin.y)
      self.width = Self.quantize(rect.size.width)
      self.height = Self.quantize(rect.size.height)
    }

    static func quantize(_ value: CGFloat) -> Int64 {
      Int64((value * 1_000).rounded())
    }
  }
}
#endif
