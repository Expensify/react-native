/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTTextCodeBlock.h"
#import "RCTTextAttributes.h"

@implementation RCTTextCodeBlock

- (UIColor*)hexStringToColor:(NSString *)stringToConvert
{
    NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *stringScanner = [NSScanner scannerWithString:noHashString];
    
    unsigned hex;
    if (![stringScanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

-(void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {
    [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];

    if ((glyphsToShow.location + glyphsToShow.length) > [[self textStorage] length]) {
      return;
    }
  
    [[self textStorage] enumerateAttribute:RCTTextAttributesIsTextCodeBlockAttributeName
                                    inRange:glyphsToShow
                                    options:0
                                 usingBlock:^(NSDictionary *textCodeBlock, NSRange range, __unused BOOL *stop) {

      NSString *backgroundColor = [textCodeBlock objectForKey:@"backgroundColor"];
      NSString *borderColor = [textCodeBlock objectForKey:@"borderColor"];
      float borderRadius = [[textCodeBlock objectForKey:@"borderRadius"] floatValue];
      
      CGContextRef context = UIGraphicsGetCurrentContext();
      CGContextSetFillColorWithColor(context, [self hexStringToColor:backgroundColor].CGColor);
      CGContextSetStrokeColorWithColor(context, [self hexStringToColor:borderColor].CGColor);
      
      if (!backgroundColor) {
        return;
      }
      
      // Enumerates line fragments intersecting with the whole text container.
      [self enumerateLineFragmentsForGlyphRange:range
                                     usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange lineGlyphRange, BOOL * _Nonnull stop) {
        
          __block UIBezierPath *textCodeBlockPath = nil;

          NSRange lineRange = NSIntersectionRange(range, lineGlyphRange);
        
          [self enumerateEnclosingRectsForGlyphRange:lineRange
                            withinSelectedGlyphRange:lineRange
                                     inTextContainer:textContainer
                                          usingBlock:^(CGRect enclosingRect, __unused BOOL *anotherStop) {

              UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(enclosingRect, 0, 0) cornerRadius:borderRadius];

              if (textCodeBlockPath) {
                [textCodeBlockPath appendPath:path];
              } else {
                textCodeBlockPath = path;
              }
              
              [textCodeBlockPath stroke];
              [textCodeBlockPath fill];
          }];
      }];
      
    }];
}

@end
