//
//  ImageResize.m
//  ChoozItApp
//
//  Created by Florian Rival on 19/11/15.
//

#include "RCTImageResizer.h"
#include "ImageHelpers.h"
#import <React/RCTImageLoader.h>
#include "UIImage+WebP.h"
//#import <libwebp/webp/encode.h>

@implementation ImageResizer

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();


void saveImage(NSString * fullPath, UIImage * image, NSString * format, float quality, ImageResizerBlock callback)
{
    NSData* data = nil;
    if ([format isEqualToString:@"JPEG"]) {
        data = UIImageJPEGRepresentation(image, quality / 100.0);
        if (data == nil) {
            NSLog(@"NO Data JPEG");
            callback(NO);
        }
        
        NSFileManager* fileManager = [NSFileManager defaultManager];
        callback([fileManager createFileAtPath:fullPath contents:data attributes:nil]);
    } else if ([format isEqualToString:@"PNG"]) {
        data = UIImagePNGRepresentation(image);
        if (data == nil) {
            NSLog(@"NO Data PNG");
            callback(NO);
        }
        
        NSFileManager* fileManager = [NSFileManager defaultManager];
        bool result = [fileManager createFileAtPath:fullPath contents:data attributes:nil];
        if(result){
            NSLog(@" Data PNG");
        }else {
            NSLog(@"NO Data PNG");
        }
        callback(result);
    } else if([format isEqualToString:@"WEBP"]){
        data = UIImageJPEGRepresentation(image, quality / 100.0);
        if (data == nil) {
            NSLog(@"NO Data JPEG");
            callback(NO);
        }
        
        NSFileManager* fileManager = [NSFileManager defaultManager];
        callback([fileManager createFileAtPath:fullPath contents:data attributes:nil]);
       /* data = [UIImage imageToWebP:image quality:quality];
        [UIImage imageToWebP:image quality:quality alpha:1 preset:WEBP_PRESET_DEFAULT completionBlock:^(NSData *result) {
            if (result == nil) {
                NSLog(@"NO Data WEBP");
                callback(NO);
            }
            
            NSFileManager* fileManager = [NSFileManager defaultManager];
            callback([fileManager createFileAtPath:fullPath contents:result attributes:nil]);
        } failureBlock:^(NSError *error) {
            callback(NO);
        }];*/
    }
    
   
}

NSString * generateFilePath(NSString * ext, NSString * outputPath)
{
    NSString* directory;

    if ([outputPath length] == 0) {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        directory = [paths firstObject];
    } else {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        if ([outputPath hasPrefix:documentsDirectory]) {
            directory = outputPath;
        } else {
            directory = [documentsDirectory stringByAppendingPathComponent:outputPath];
        }
        
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"Error creating documents subdirectory: %@", error);
            @throw [NSException exceptionWithName:@"InvalidPathException" reason:[NSString stringWithFormat:@"Error creating documents subdirectory: %@", error] userInfo:nil];
        }
    }

    NSString* name = [[NSUUID UUID] UUIDString];
    NSString* fullName = [NSString stringWithFormat:@"%@.%@", name, ext];
    NSString* fullPath = [directory stringByAppendingPathComponent:fullName];

    return fullPath;
}

UIImage * rotateImage(UIImage *inputImage, float rotationDegrees)
{

    // We want only fixed 0, 90, 180, 270 degree rotations.
    const int rotDiv90 = (int)round(rotationDegrees / 90);
    const int rotQuadrant = rotDiv90 % 4;
    const int rotQuadrantAbs = (rotQuadrant < 0) ? rotQuadrant + 4 : rotQuadrant;
    
    // Return the input image if no rotation specified.
    if (0 == rotQuadrantAbs) {
        return inputImage;
    } else {
        // Rotate the image by 80, 180, 270.
        UIImageOrientation orientation = UIImageOrientationUp;
        
        switch(rotQuadrantAbs) {
            case 1:
                orientation = UIImageOrientationRight; // 90 deg CW
                break;
            case 2:
                orientation = UIImageOrientationDown; // 180 deg rotation
                break;
            default:
                orientation = UIImageOrientationLeft; // 90 deg CCW
                break;
        }
        
        return [[UIImage alloc] initWithCGImage: inputImage.CGImage
                                                  scale: 1.0
                                                  orientation: orientation];
    }
}

void transformImage(UIImage *image,
                    RCTResponseSenderBlock callback,
                    int rotation,
                    CGSize newSize,
                    NSString* fullPath,
                    NSString* format,
                    int quality)
{
    if (image == nil) {
        callback(@[@"Can't retrieve the file from the path.", @""]);
        return;
    }
    
    // Rotate image if rotation is specified.
    if (0 != (int)rotation) {
        image = rotateImage(image, rotation);
        if (image == nil) {
            callback(@[@"Can't rotate the image.", @""]);
            return;
        }
    }
    
    // Do the resizing
    UIImage * scaledImage = [image scaleToSize:newSize];
    if (scaledImage == nil) {
        callback(@[@"Can't resize the image.", @""]);
        return;
    }
    
    saveImage(fullPath, scaledImage, format, quality, ^(bool result) {
        // Compress and save the image
        if (!result) {
            callback(@[@"Can't save the image. Check your compression format and your output path", @""]);
            return;
        }
        NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:fullPath];
        NSString *fileName = fileUrl.lastPathComponent;
        NSError *attributesError = nil;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&attributesError];
        NSNumber *fileSize = fileAttributes == nil ? 0 : [fileAttributes objectForKey:NSFileSize];
        NSDictionary *response = @{@"path": fullPath,
                                   @"uri": fileUrl.absoluteString,
                                   @"name": fileName,
                                   @"size": fileSize == nil ? @(0) : fileSize
                                   };
        
        callback(@[[NSNull null], response]);
    });
}


RCT_EXPORT_METHOD(createResizedImage:(NSString *)path
                  width:(float)width
                  height:(float)height
                  format:(NSString *)format
                  quality:(float)quality
                  rotation:(float)rotation
                  outputPath:(NSString *)outputPath
                  callback:(RCTResponseSenderBlock)callback)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CGSize newSize = CGSizeMake(width, height);
        
        //Set image extension
        NSString *extension = @"jpg";
        if ([format isEqualToString:@"PNG"]) {
            extension = @"png";
        }
        
        if ([format isEqualToString:@"WEBP"]) {
            extension = @"webp";
        }
        
        NSString* fullPath;
        @try {
            fullPath = generateFilePath(extension, outputPath);
        } @catch (NSException *exception) {
            callback(@[@"Invalid output path.", @""]);
            return;
        }
        
        if ([path hasPrefix:@"rct_image_store"]) {
            [self->_bridge.imageLoader loadImageWithURLRequest:[RCTConvert NSURLRequest:path] callback:^(NSError *error, UIImage *image) {
                if (error) {
                    callback(@[@"Can't retrieve the file from the path.", @""]);
                    return;
                }
                
                transformImage(image, callback, rotation, newSize, fullPath, format, quality);
            }];
        } else if ([path hasPrefix:@"data:"] || [path hasPrefix:@"file:"]) {
            NSURL *imageUrl = [[NSURL alloc] initWithString:path];
            transformImage([UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]], callback, rotation, newSize, fullPath, format, quality);
        } else {
            transformImage([[UIImage alloc] initWithContentsOfFile:path], callback, rotation, newSize, fullPath, format, quality);
        }
    });
}

@end
