//
//  AwCornerDetector.h
//  AwCornerDetection
//
//  Created by Qingquan Zhao on 5/21/20.
//  Copyright © 2020 Aware. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifndef AwCornerDetector_h
#define AwCornerDetector_h


#endif /* AwCornerDetector_h */

@interface AwCornerDetector : NSObject

- (NSArray<NSValue *> *)detect:(UIImage*)uiimage;
+ (BOOL) isExpired;
@end
