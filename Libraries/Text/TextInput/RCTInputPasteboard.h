#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCTInputPasteboard : NSObject
+ (NSArray<NSDictionary *> *)handlePasteboardItems:(UIPasteboard *)pasteboard;
@end

NS_ASSUME_NONNULL_END
