//
//  ArticleXMLParser.h
//  NYU WSN
//
//  Created by Ricky Cheng on 8/5/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchXML.h"

@interface ArticleXMLParser : NSObject {
	
}

- (NSMutableArray*)getArrayFromRSSFeed:(NSString*)feedURL;
- (NSString*)getValueFromKey:(NSString*)key fromElement:(CXMLElement*)element;

@end