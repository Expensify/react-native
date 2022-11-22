#import "RCTInputPasteboard.h"

@implementation RCTInputPasteboard

+ (NSData *)getDataForImageItem:(NSData *)imageData type:(NSString *)type {
  UIImage *image;
  if ([type isEqual:@"public.heic"]) {
    CFDataRef cfdata = CFDataCreate(NULL, [imageData bytes], [imageData length]);
    CGImageSourceRef source = CGImageSourceCreateWithData(cfdata, nil);
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, nil);
    image = [[UIImage alloc] initWithCGImage:imageRef];
  } else {
    image = (UIImage *)imageData;
  }
  
  if ([type isEqual:@"public.png"]) {
    return UIImagePNGRepresentation(image);
  }
  
  return UIImageJPEGRepresentation(image, 1.0);
}

+ (NSString *)getExtensionForImageItem:(NSString *)type {
  if ([type isEqual:@"public.jpeg"]) {
    return @"jpeg";
  }
  if ([type isEqual:@"public.heic"]) {
    return @"heic";
  }
  if ([type isEqual:@"public.png"]) {
    return @"png";
  }
  return @"";
}

+ (NSArray<NSDictionary *> *)handlePasteboardItems:(UIPasteboard *)pasteboard {
  NSMutableArray<NSDictionary *> *images = [[NSMutableArray alloc] init];
  
  // the items property contains dictionary with key being the representation type and the
  // "value" the object associated with that type.
  for (NSDictionary *item in [pasteboard items]) {
    BOOL added = NO;

    for (NSString *type in [item allKeys]) {
      if (added) {
        continue;
      }

      @try {
        NSData *fileData = item[type];
        NSString *fileExtension = type;
        
        // accepts jpeg, heic, png formats only
        if ([type isEqual:@"public.jpeg"] || [type isEqual:@"public.heic"] || [type isEqual:@"public.png"]) {
          fileData = [self getDataForImageItem:item[type] type:type];
          fileExtension = [self getExtensionForImageItem:type];
        } else {
          [NSException raise:@"Invalid file extension" format:@"file extension of %@ is not supported", type];
        }
        
        NSString *tempFilename = [NSString stringWithFormat:@"%@.%@", [[NSProcessInfo processInfo] globallyUniqueString], fileExtension];
        NSURL *tempFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tempFilename]];

        if ([fileData writeToURL:tempFileURL atomically:YES]) {
          added = YES;

          [images addObject:@{
            @"fileName": tempFilename,
            @"fileSize": @([fileData length]),
            @"type": fileExtension,
            @"uri": tempFileURL.absoluteString,
          }];
        }
      } @catch (NSException *exception) {
        [images addObject:@{
          @"error": exception.reason,
        }];
      }
    }
  }
  
  return images;
}

@end
