//
//  main.m
//  NYU WSN
//
//  Created by Ricky Cheng on 7/27/09.
//  Copyright 2009 Washington Squaure News. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <iostream>

class Exception {
public:
	Exception() {}
	virtual ~Exception() { }
};

using namespace std;

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}