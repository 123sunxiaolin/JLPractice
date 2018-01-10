//
//  JLAssociatedObjectUtils.h
//  JLAssociatedObjectUtilsDemo
//
//  Created by Jacklin on 2018/1/10.
//  Copyright © 2018年 JackLin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JLAssociationPolicy) {
    
    /**
     OBJC_ASSOCIATION_ASSIGN < Specifies a weak reference to the associated object>
     */
    JLAssociationPolicyAssign = 1,
    
    /**
     OBJC_ASSOCIATION_RETAIN_NONATOMIC <Specifies a strong reference to the associated object.
     *   The association is not made atomically>
     */
    JLAssociationPolicyRetainNonatomic = 2,
    
    /**
     OBJC_ASSOCIATION_COPY_NONATOMIC < Specifies that the associated object is copied.
     *   The association is not made atomically.>
     */
    JLAssociationPolicyCopyNonatomic = 3,
    
    /**
     OBJC_ASSOCIATION_RETAIN < Specifies a strong reference to the associated object.
     *   The association is made atomically.>
     */
    JLAssociationPolicyRetain = 4,
    
    /**
     OBJC_ASSOCIATION_COPY < Specifies that the associated object is copied.
     *   The association is made atomically.>
     */
    JLAssociationPolicyCopy = 5
};

/**
 Set Associated Object Utils
 */
@interface JLAssociatedObjectUtils : NSObject

/**
 Set AssociatedObject
 
 @param object Be Associated Object
 @param key associted Key
 @param value associated value or object
 @param policy policy
 */
+ (void)JL_setAssociatedObject:(id _Nonnull)object key:(NSString *_Nullable)key value:(id _Nullable)value policy:(JLAssociationPolicy)policy;

/**
 Get AssociatedObject
 
 @param object Be Associated Object
 @param key associted Key
 @return associated value or object
 */
+ (id _Nullable)JL_getAssociatedObject:(id _Nonnull)object key:(NSString *_Nullable)key;

/**
 Remove AssociatedObject
 
 @param object associated value or object
 */
+ (void)JL_removeAssociatedObject:(id _Nonnull)object;

@end
