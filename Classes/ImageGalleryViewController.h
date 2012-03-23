#import <Three20/Three20.h>
#import "TouchXML.h"

@interface ImageGalleryViewController : TTThumbsViewController {

}

- (NSString*)getValueFromKey:(NSString*)key fromElement:(CXMLElement*)element;

@end