#import "ImageGalleryViewController.h"
#import "ALPhotoSource.h"
#import "MockPhotoSource.h"

@implementation ImageGalleryViewController

- (void)viewDidLoad {
	[FlurryAPI logEvent:@"Image Gallery"];
	[self performSelectorOnMainThread:@selector(getImageDataByPage:) withObject:nil waitUntilDone:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.navigationController.navigationBar.tintColor = [GlobalMethods getColor:@"dark"];
}

- (void)getImageDataByPage:(id)sender {		
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://urlforapi/images.xml?page=%i&num=24",1]];
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
		
		MockPhoto *photo = [[MockPhoto alloc] initWithURL:originalImage smallURL:thumbnail size:CGSizeMake(width,height) 
											  caption:[NSString stringWithFormat:@"%@|%@",browser_link,caption]];
		[imageRoll addObject:photo];
		[photo release];
	}

	[self.photoSource load:TTURLRequestCachePolicyDefault more:NO];
	self.photoSource = [[MockPhotoSource alloc] initWithType:MockPhotoSourceNormal title:@"Image Gallery" photos:imageRoll photos2:nil];
	
	[imageRoll release];
	[rssParser release];
	[xmlData release];
}

- (NSString*)getValueFromKey:(NSString*)key fromElement:(CXMLElement*)element {
	if([[element elementsForName:key] count] == 0) return nil;
	NSString *value = [[[element elementsForName:key] objectAtIndex:0] stringValue];
	return value == nil ? @"" : value;
}

@end
