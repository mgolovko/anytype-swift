import Foundation
import UIKit

final class SquareDynamicIconPainter: IconPainter {
    
    private let contentPainter: IconPainter
    
    init(contentPainter: IconPainter) {
        self.contentPainter = contentPainter
    }
    
    func drawPlaceholder(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        context.saveGState()
        
        drawBackground(bounds: bounds, context: context, iconContext: iconContext)
        contentPainter.drawPlaceholder(bounds: bounds, context: context, iconContext: iconContext)
        
        context.restoreGState()
    }
    
    func prepare(bounds: CGRect) async {
        await contentPainter.prepare(bounds: bounds)
    }
    
    func draw(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        context.saveGState()
        
        drawBackground(bounds: bounds, context: context, iconContext: iconContext)
        contentPainter.draw(bounds: bounds, context: context, iconContext: iconContext)
        
        context.restoreGState()
    }
    
    // MARK: - Private
    
    private func drawBackground(bounds: CGRect, context: CGContext, iconContext: IconContext) {
        let side = min(bounds.size.width, bounds.size.height)
        
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: side * (1/12)).cgPath
        context.addPath(path)
        context.clip()
        
        context.setFillColor(UIColor.Stroke.secondary.cgColor)
        context.fill(bounds)
    }
}