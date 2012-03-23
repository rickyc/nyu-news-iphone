//
//  ALPhotoSource.h
//

#import <Three20/Three20.h>
#import "TouchXML.h"

@interface ALPhotoSource : TTModel <TTPhotoSource> {
    NSString* _title;
	NSMutableArray* _photos;
	NSMutableArray* morePhotos;
	NSUInteger page;
	NSInteger total;
}

- (NSString*)getValueFromKey:(NSString*)key fromElement:(CXMLElement*)element;

@end
