//
//  RKModel.m
//  Reader
//
//  Created by Rzk on 2019/4/22.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKModel.h"

@implementation RKModel

/**
 描述对象
 
 @return 对象的描述
 */
- (NSString *)description {
    //得到当前class的所有属性
    uint count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableString *str = [NSMutableString string];
    
    //循环并用KVC得到每个属性的值
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *name = @(property_getName(property));
        id value = [self valueForKey:name] ? : @"nil";//默认值为nil字符串
        [str appendString:[NSString stringWithFormat:@" <%@:%@> ",name,value]];
    }
    
    //释放
    free(properties);
    
    //return
    return [NSString stringWithFormat:@"<%@ : %p> %@",[self class],self,str];
}

@end
