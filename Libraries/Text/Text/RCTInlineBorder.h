/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCTInlineBorder : NSObject
+ (void)setInlineBorder:(NSLayoutManager *)layoutManager textContainer:(NSTextContainer *)textContainer contentFrame:(CGRect)contentFrame textStorage:(NSTextStorage *)textStorage textCodeBlockAttribute:(NSString *)attribute textLayer:(CALayer *)textLayer;
@end

NS_ASSUME_NONNULL_END
