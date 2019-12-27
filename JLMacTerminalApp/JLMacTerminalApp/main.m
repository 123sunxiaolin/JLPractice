//
//  main.m
//  JLMacTerminalApp
//
//  Created by Jacklin on 2019/11/20.
//  Copyright © 2019 Jacklin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

//#pragma pack(1) /*1字节对齐*/
struct object {
    int a; // 4
    char b; // 1
    char b1[3];
    int c; // 4
};
//#pragma pack() /*还原默认对齐*/

@interface Animal : NSObject {
    @public
    int _age; // 4
    int _weight; // 4
}

- (void)eat;

@end

@implementation Animal

@end

@interface Dog : Animal {
    @public
    int _height;
}
@end

@implementation Dog

@end


struct NSObject_IMPL {
    Class isa; // 8
};

struct Animal_IMPL {
    struct NSObject_IMPL NSObject_IVARS; // 8个字节
    int _age; //4
    int _weight; // 4
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSObject *obj = [[NSObject alloc] init];
        NSLog(@"class_getInstanceSize = %zd", class_getInstanceSize([NSObject class]));
        NSLog(@"malloc_size = %zd", malloc_size((__bridge const void *)(obj)));
        NSLog(@"sizeOf = %zd", sizeof(obj));
        
        
        // ----------------------------------------
        // Animal对象占用的内存大小
        Animal *animal = [[Animal alloc] init];
//        animal->_age = 10;
//        animal->_weight = 20;
        
        NSLog(@"Animal -- class_getInstanceSize = %zd", class_getInstanceSize([animal class]));
        NSLog(@"Animal -- malloc_size = %zd", malloc_size((__bridge const void *)(animal)));
        NSLog(@"Animal -- sizeOf = %zd", sizeof(animal));
        
        // ----------------------------------------
        Dog *dog = [[Dog alloc] init];
        NSLog(@"Dog -- class_getInstanceSize = %zd", class_getInstanceSize([dog class]));
        NSLog(@"Dog -- malloc_size = %zd", malloc_size((__bridge const void *)(dog)));
        NSLog(@"Dog -- sizeOf = %zd", sizeof(dog));
        
       // NSLog(@"123  _age = %p, _weight = %p", animal->_age, animal->_weight);
        
        
        // iskindOf 、isM=emberOf
        
        NSLog(@"1-----%hhd", [animal isKindOfClass:[NSObject class]]);
        NSLog(@"2-----%hhd", [animal isMemberOfClass:[Animal class]]); // 0(1)
        NSLog(@"3-----%hhd", [dog isKindOfClass:[Animal class]]);
        NSLog(@"4-----%hhd", [dog isMemberOfClass:[NSObject class]]);
        
        NSLog(@"Align------%zd", sizeof(struct object));
        
        Method method = class_getInstanceMethod([animal class], @selector(eat));
        NSLog(@"types = %s", method_getTypeEncoding(method));
        
        
    }
    return 0;
}
