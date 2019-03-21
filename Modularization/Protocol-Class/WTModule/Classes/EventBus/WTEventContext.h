//
//  WTEventContext.h
//  WTModule
//
//  Created by hongru qi on 16/11/2017.
//

#import <UIKit/UIKit.h>
@class WTEventItem;

@interface WTEventContext : NSObject

@property   (nonatomic, weak)   id poster;
@property   (nonatomic, weak)   UIViewController  *target;
@property   (nonatomic, weak)   WTEventItem  *event;

@end
