//
//  JLAssociatedObjectUtils.m
//  JLAssociatedObjectUtilsDemo
//
//  Created by Jacklin on 2018/1/10.
//  Copyright © 2018年 JackLin. All rights reserved.
//

#import "JLAssociatedObjectUtils.h"
#import <objc/runtime.h>

@implementation JLAssociatedObjectUtils

+ (void)JL_setAssociatedObject:(id _Nonnull)object key:(NSString *_Nullable)key value:(id _Nullable)value policy:(JLAssociationPolicy)policy{
    objc_setAssociatedObject(object, [key UTF8String], value, convertPolicy(policy));
}

+ (id _Nullable)JL_getAssociatedObject:(id _Nonnull)object key:(NSString *_Nullable)key{
    return objc_getAssociatedObject(object, [key UTF8String]);
}

+ (void)JL_removeAssociatedObject:(id _Nonnull)object{
    objc_removeAssociatedObjects(object);
}

#pragma mark - Private
objc_AssociationPolicy convertPolicy(JLAssociationPolicy policy){
    objc_AssociationPolicy targetPolicy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
    switch (policy) {
        case JLAssociationPolicyAssign:
            targetPolicy = OBJC_ASSOCIATION_ASSIGN;
            break;
        case JLAssociationPolicyRetainNonatomic:
            targetPolicy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
            break;
        case JLAssociationPolicyCopyNonatomic:
            targetPolicy = OBJC_ASSOCIATION_COPY_NONATOMIC;
            break;
        case JLAssociationPolicyRetain:
            targetPolicy = OBJC_ASSOCIATION_RETAIN;
            break;
        case JLAssociationPolicyCopy:
            targetPolicy = OBJC_ASSOCIATION_COPY;
            break;
        default:
            break;
    }
    return targetPolicy;
}

@end
