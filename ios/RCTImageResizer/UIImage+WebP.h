//
//  UIImage+WebP.h
//  RCTImageResizer
//
//  Created by Bill Nizeyimana on 7/3/19.
//  Copyright © 2019 Atticus White. All rights reserved.
//

#ifndef UIImage_WebP_h
#define UIImage_WebP_h

#import <UIKit/UIKit.h>
#import <libwebp/webp/decode.h>
#import <libwebp/webp/encode.h>
//#import <encode.h>
//#import <decode.h>
//#import <WebP/encode.h>
//#import <WebP/decode.h>


@interface UIImage (WebP)

+ (UIImage*)imageWithWebPData:(NSData*)imgData;

+ (UIImage*)imageWithWebP:(NSString*)filePath;

+ (NSData*)imageToWebP:(UIImage*)image quality:(CGFloat)quality;

+ (void)imageToWebP:(UIImage*)image
            quality:(CGFloat)quality
              alpha:(CGFloat)alpha
             preset:(WebPPreset)preset
    completionBlock:(void (^)(NSData* result))completionBlock
       failureBlock:(void (^)(NSError* error))failureBlock;

+ (void)imageToWebP:(UIImage*)image
            quality:(CGFloat)quality
              alpha:(CGFloat)alpha
             preset:(WebPPreset)preset
        configBlock:(void (^)(WebPConfig* config))configBlock
    completionBlock:(void (^)(NSData* result))completionBlock
       failureBlock:(void (^)(NSError* error))failureBlock;

+ (void)imageWithWebP:(NSString*)filePath
      completionBlock:(void (^)(UIImage* result))completionBlock
         failureBlock:(void (^)(NSError* error))failureBlock;

- (UIImage*)imageByApplyingAlpha:(CGFloat)alpha;

@end

#endif /* UIImage_WebP_h */
