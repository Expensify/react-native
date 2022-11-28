/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTInlineBorder.h"

@implementation RCTInlineBorder

+ (void)setInlineBorder:(NSLayoutManager *)layoutManager textContainer:(NSTextContainer *)textContainer contentFrame:(CGRect)contentFrame textStorage:(NSTextStorage *)textStorage textCodeBlockAttribute:(NSString *)textCodeBlockAttribute textLayer:(CALayer *)textLayer {
  
  // The range of glyphs lying within the whole text container.
  NSRange textGlyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
  [layoutManager drawBackgroundForGlyphRange:textGlyphRange atPoint:contentFrame.origin];
  [layoutManager drawGlyphsForGlyphRange:textGlyphRange atPoint:contentFrame.origin];
  
  // Enumerates line fragments intersecting with the whole text container.
  [layoutManager enumerateLineFragmentsForGlyphRange:textGlyphRange
                 usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange lineGlyphRange, BOOL * _Nonnull stop) {

    __block UIBezierPath *textCodeBlockPath = nil;
    NSRange characterRange = [layoutManager characterRangeForGlyphRange:lineGlyphRange actualGlyphRange:NULL];
    
    // Enumerates glyphs with the textCodeBlock attribute
    [textStorage enumerateAttribute:textCodeBlockAttribute
                 inRange:characterRange
                 options:0
                 usingBlock:^(NSNumber *value, NSRange range, __unused BOOL *stop) {
      
      if (!value.boolValue) {
        return;
      }
      
      [layoutManager enumerateEnclosingRectsForGlyphRange:range
                     withinSelectedGlyphRange:range
                     inTextContainer:textContainer
                     usingBlock:^(CGRect enclosingRect, __unused BOOL *anotherStop) {
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(enclosingRect, 0, 0) cornerRadius:2];
        
        if (textCodeBlockPath) {
          [textCodeBlockPath appendPath:path];
        } else {
          textCodeBlockPath = path;
        }
      }];
    }];
    
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    
    if (textCodeBlockPath) {
      borderLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.25].CGColor;
      borderLayer.borderWidth = 1.0;
      borderLayer.borderColor = [UIColor colorWithWhite:0 alpha:0.25].CGColor;
      [textLayer addSublayer:borderLayer];
      borderLayer.path = textCodeBlockPath.CGPath;
    } else {
      [borderLayer removeFromSuperlayer];
      borderLayer = nil;
    }
  }];
}

@end
