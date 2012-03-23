//
//  ALPhotoSource.m
//

#import "ALPhotoSource.h"
#import "ALPhoto.h"

@implementation ALPhotoSource
@synthesize title = _title;

- (id)init {
	_title = @"Image Gallery";
	page = 1;
	
	NSDictionary *d1 = [NSDictionary dictionaryWithObjectsAndKeys:@"photos",@"imgSource",[NSNumber numberWithInt:1],@"pageNum",nil];	
	[self performSelectorOnMainThread:@selector(getImageDataByPage:) withObject:d1 waitUntilDone:YES];

	total = _photos.count + morePhotos.count;
	DLog(@"photo source should be ready => %d",total);
	[self load:TTURLRequestCachePolicyDefault more:NO];

	return self;
}

- (void)getImageDataByPage:(NSDictionary*)dict {		
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://urlforapi/images.xml?page=%i&num=12",
									   [[dict objectForKey:@"pageNum"] intValue]]];
	NSString *xmlData = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	
	NSMutableArray *imageRoll = [[NSMutableArray alloc] init];
	
    CXMLDocument *rssParser = [[CXMLDocument alloc] initWithXMLString:xmlData options:0 error:nil];
	
    // Create a new Array object to be used with the looping of the results from the rssParser
    NSArray *resultNodes = NULL;
	
    // Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
    resultNodes = [rssParser nodesForXPath:@"//articleimage" error:nil];
	
    // Loop through the resultNodes to access each items actual data
    for (CXMLElement *resultElement in resultNodes) {
		NSString *thumbnail = [self getValueFromKey:@"t_url" fromElement:resultElement];
		NSString *originalImage = [self getValueFromKey:@"t800_url" fromElement:resultElement];
		//		NSString *image_id = [self getValueFromKey:@"content_id" fromElement:resultElement];
		NSString *browser_link = [self getValueFromKey:@"browser_link" fromElement:resultElement];
		
		NSMutableString *caption = [NSMutableString stringWithString:[self getValueFromKey:@"caption" fromElement:resultElement]];
		if([caption isEqualToString:@""]) [caption setString:@"N/A"];
		
		NSInteger width = [[self getValueFromKey:@"width" fromElement:resultElement] intValue];
		NSInteger height = [[self getValueFromKey:@"height" fromElement:resultElement] intValue];
		
		ALPhoto *photo = [[ALPhoto alloc] initWithURL:originalImage smallURL:thumbnail size:CGSizeMake(width,height) 
											  caption:[NSString stringWithFormat:@"%@|%@",browser_link,caption]];
		[imageRoll addObject:photo];
		[photo release];
	}
	
	for (int i = 0; i < imageRoll.count; ++i) {
		id<TTPhoto> photo = [imageRoll objectAtIndex:i];
		if ((NSNull*)photo != [NSNull null]) {
			photo.photoSource = self;
			photo.index = i;
		}
    }
	
	DLog(@"mages ? %@",imageRoll);
	
	NSString *source = [dict objectForKey:@"imgSource"];
	if([source isEqualToString:@"photos"])
		_photos = (NSMutableArray*)[imageRoll copy];
	else
		morePhotos = (NSMutableArray*)[imageRoll copy];
	
	[imageRoll release];
	[rssParser release];
	[xmlData release];
}

- (NSString*)getValueFromKey:(NSString*)key fromElement:(CXMLElement*)element {
	if([[element elementsForName:key] count] == 0) return nil;
	NSString *value = [[[element elementsForName:key] objectAtIndex:0] stringValue];
	return value == nil ? @"" : value;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhotoSource

- (NSInteger)numberOfPhotos {
	return total;
}

- (NSInteger)maxPhotoIndex {
	return _photos.count-1;
}

- (id<TTPhoto>)photoAtIndex:(NSInteger)index {
	if (index < _photos.count) {
		id photo = [_photos objectAtIndex:index];
		if (photo == [NSNull null]) {
			return nil;
		} else {
			return photo;
		}
	} else {
		return nil;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
	NSInteger nextIndex = _photos.count;
	for (int i = 0; i < morePhotos.count; i++) {
		id<TTPhoto> photo = [morePhotos objectAtIndex:i];
		photo.photoSource = self;
		photo.index = nextIndex;
		if ((NSNull*)photo != [NSNull null]) {
			[_photos addObject:photo];
			nextIndex++;
		}
    }
	
	[self didFinishLoad];
}

@end
