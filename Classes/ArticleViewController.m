//
//  ArticleViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/4/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "ArticleViewController.h"
#import "TwitterLoginViewController.h"
#import "FacebookSession.h"
#import "TwitterPostViewController.h"
#import "BrowserViewController.h"
#import "Three20/Three20.h"
#import "NYUWSNAppDelegate.h"
#import "SnoopWindow.h"
#import "Constants.h"
#import "TwitterEngine.h"

#define BAR_FADE_ALPHA 0.8f

BOOL singleTap;

@implementation ArticleViewController
@synthesize webArticleView, toolbar, articleToolbar, networkToolbar, articles, articleID, bitly, textSize, activityIndicator, saveBtn;

- (void)viewWillAppear:(BOOL)animated {
	self.navigationController.navigationBar.alpha = BAR_FADE_ALPHA;
}

- (void)viewWillDisappear:(BOOL)animated {
	self.navigationController.navigationBar.alpha = 1.0;	
}

- (void)viewDidAppear:(BOOL)animated {
	[self showLoader:@selector(generateArticle)];
	
	// this method is not inside the generateArticle method because there is a lag
	[self generateTitle];
}	

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,-44,320,460)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	webArticleView = [[UIWebView alloc] initWithFrame:CGRectMake(0,-44,320,460)];
	webArticleView.delegate = self;
	webArticleView.scalesPageToFit = YES;
	webArticleView.userInteractionEnabled = YES;
	webArticleView.multipleTouchEnabled = YES;
	[self.view addSubview:webArticleView];
	
	UIBarButtonItem *tweetBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"twitter.png"] style:UIBarButtonItemStylePlain target:self action:@selector(tweetArticle:)];
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem *safariBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"safari.png"] style:UIBarButtonItemStylePlain target:self action:@selector(launchArticleInBrowser:)];
	UIBarButtonItem *emailBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mail.png"] style:UIBarButtonItemStylePlain target:self action:@selector(emailArticle:)];
	UIBarButtonItem *facebookBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"facebook.png"] style:UIBarButtonItemStylePlain target:self action:@selector(postToFacebook:)];
	UIBarButtonItem *zoomInBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"zoom_in.png"] style:UIBarButtonItemStylePlain target:self action:@selector(increaseTextSize:)];
	UIBarButtonItem *zoomOutBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"zoom_out.png"] style:UIBarButtonItemStylePlain target:self action:@selector(decreaseTextSize:)];
	
	// init saved articles toolbar icon
	NSString *path = [GlobalMethods getWritablePath];
	NSMutableDictionary *savedArticlesDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	
	NSDictionary *article = [[[articles objectAtIndex:articleID.section] objectForKey:@"articles"] objectAtIndex:articleID.row];
	if([savedArticlesDictionary objectForKey:[article valueForKey:@"id"]] != nil)
		saveBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"favorite_filled.png"] style:UIBarButtonItemStylePlain target:self action:@selector(removeSavedArticle:)];
	else
		saveBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"favorite.png"] style:UIBarButtonItemStylePlain target:self action:@selector(saveArticle:)];
	// end init saved articles toolbar icon
	
	UIBarButtonItem *networkBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"network.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleSocialBar:)];
	UIBarButtonItem *articleBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"article_controls.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleArticleBar:)];
	
	articleToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,372,320,44)];
	articleToolbar.tintColor = [UIColor blackColor]; 
	articleToolbar.alpha = BAR_FADE_ALPHA;
	[articleToolbar setItems:[NSArray arrayWithObjects:networkBtn,flexibleSpace,zoomOutBtn,zoomInBtn,flexibleSpace,saveBtn,nil]];

	// init social networking toolbar
	networkToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,372,320,44)];
	networkToolbar.tintColor = [UIColor blackColor]; 
	networkToolbar.alpha = BAR_FADE_ALPHA;
	[networkToolbar setItems:[NSArray arrayWithObjects:articleBtn,flexibleSpace,tweetBtn,flexibleSpace,facebookBtn,flexibleSpace,safariBtn,flexibleSpace,emailBtn,nil]];

	//[toolbar setItems:[NSArray arrayWithObjects:tweetBtn,flexibleSpace,zoomOutBtn,zoomInBtn,flexibleSpace,emailBtn,nil]];
	toolbar = articleToolbar;
	[self.view addSubview:toolbar];
	
	// init the left and right buttons
	NSArray *segmentItems = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"left.png"],[UIImage imageNamed:@"right.png"],nil];
	
	UISegmentedControl *nextPrevArticle = [[UISegmentedControl alloc] initWithItems:segmentItems];
	[nextPrevArticle addTarget:self action:@selector(changeArticle:) forControlEvents:UIControlEventValueChanged];
	nextPrevArticle.frame = CGRectMake(0, 0, 90, 30);
	nextPrevArticle.segmentedControlStyle = UISegmentedControlStyleBar;
	nextPrevArticle.momentary = YES;
	[nextPrevArticle setTintColor:[UIColor blackColor]];
	[segmentItems release];

	UIBarButtonItem *navigationRightItem = [[UIBarButtonItem alloc] initWithCustomView:nextPrevArticle];
	navigationRightItem.target = self;
	self.navigationItem.rightBarButtonItem = navigationRightItem;
	[nextPrevArticle release];
	[navigationRightItem release];
	
	// releases bar button items
	[tweetBtn release];
	[flexibleSpace release];
	[emailBtn release];
	[facebookBtn release];
	[zoomInBtn release];
	[zoomOutBtn release];
	[networkBtn release];
	[articleBtn release];
	
	// activity indicator
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(320/2-11,416/2-35,25,25)];
	activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	[activityIndicator sizeToFit];
	[activityIndicator startAnimating];

	DLog(@"CS,CR => (%i,%i)",articleID.section,articleID.row);
	
	NYUWSNAppDelegate *applicationDelegate = (NYUWSNAppDelegate *)[[UIApplication sharedApplication] delegate];
	SnoopWindow *snoopWindow = (SnoopWindow *)applicationDelegate.window;
	snoopWindow.webView = webArticleView;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(started:) name:NOTIFICATION_STARTED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ended:) name:NOTIFICATION_ENDED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moved:) name:NOTIFICATION_MOVED object:nil];
}

- (void)showLoader:(SEL)task {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    HUD = [[MBProgressHUD alloc] initWithWindow:window];
	[window addSubview:HUD];
	
    HUD.delegate = self;
    HUD.labelText = @"Loading";
	
    [HUD showWhileExecuting:task onTarget:self withObject:nil animated:YES];
}

#pragma mark -
- (void)started:(NSNotification *)notification {
	singleTap = YES;
}

- (void)ended:(NSNotification *)notification {
	if(singleTap) {
		NSString *filter = toolbar.alpha == BAR_FADE_ALPHA ? @"fadeOut" : @"fadeIn";
		
		int scrollPosition = [[webArticleView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
		if(scrollPosition < 44 && [filter isEqualToString:@"fadeOut"]) {
			[webArticleView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"window.scrollTo(0, %d);",44]];
		} else if(scrollPosition <= 44 && [filter isEqualToString:@"fadeIn"]) {
			[webArticleView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"window.scrollTo(0, %d);",0]];
		}
		
		[self fadeView:toolbar withFilter:filter];
		[self fadeView:self.navigationController.navigationBar withFilter:filter];
		[webArticleView setNeedsDisplay];
	}
}

- (void)moved:(NSNotification *)notification {
	singleTap = NO;
}

#pragma mark -
- (void)saveArticle:(id)sender {
	saveBtn.image = [UIImage imageNamed:@"favorite_filled.png"];
	saveBtn.action = @selector(removeSavedArticle:);	
	
	NSString *path = [GlobalMethods getWritablePath];
	NSMutableDictionary *savedArticlesDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	
	NSDictionary *article = [[[articles objectAtIndex:articleID.section] objectForKey:@"articles"] objectAtIndex:articleID.row];
	[savedArticlesDictionary setObject:article forKey:[article valueForKey:@"id"]];
	[savedArticlesDictionary writeToFile:path atomically:YES];
	[savedArticlesDictionary release];
}

- (void)removeSavedArticle:(id)sender {
	saveBtn.image = [UIImage imageNamed:@"favorite.png"];
	saveBtn.action = @selector(saveArticle:);
	
	NSString *path = [GlobalMethods getWritablePath];
	NSMutableDictionary *savedArticlesDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	
	NSDictionary *article = [[[articles objectAtIndex:articleID.section] objectForKey:@"articles"] objectAtIndex:articleID.row];
	[savedArticlesDictionary removeObjectForKey:[article valueForKey:@"id"]]; 
	[savedArticlesDictionary writeToFile:path atomically:YES];
	[savedArticlesDictionary release];
}

#pragma mark -
- (void)increaseTextSize:(id)sender {
	textSize += 1;
	[webArticleView stringByEvaluatingJavaScriptFromString:@"increase();"];
}

- (void)decreaseTextSize:(id)sender {
	textSize -= 1;
	[webArticleView stringByEvaluatingJavaScriptFromString:@"decrease();"];
}

- (void)changeArticle:(id)sender {	
	NSInteger section = articleID.section;
	NSInteger row = articleID.row;
	
	if([sender selectedSegmentIndex] == 0) {
		DLog(@"left");
		row -= 1;
		
		// if there are no more articles in the section, go to the previous section
		if(row == -1) {
			section -= 1;
			
			// if it is already at the first article
			if(section == -1) {
				section = 0;
				row = 0;
			} else {
				row = [[[articles objectAtIndex:section] objectForKey:@"articles"] count] - 1;	
			}
		}
	} else {
		// if we go to the next article, we increment the row by one
		DLog(@"right");
		row += 1;
		
		NSInteger maxRows = [[[articles objectAtIndex:section] objectForKey:@"articles"] count];
		NSInteger maxSections = [articles count];
		
		// if we were on the last article in the section, then we move onto the next section
		if(row == maxRows) {
			// if we were not on the last article in the section & row, then we move on
			// otherwise we stay in the same article
			if(section+1 < maxSections) {
				section += 1;
				row = 0;
			} else {
				row -= 1;
			}
		}
	}
	
	DLog(@"S,R => (%i,%i)",section,row);
	
	// new article ID
	articleID = [NSIndexPath indexPathForRow:row inSection:section];
	[self enableControls:NO];
	[self showLoader:@selector(generateArticle)];
}

#pragma mark -
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSInteger tempTextSide = textSize;
	
	for(int i=0;i<abs(tempTextSide);i++) {
		if(textSize < 0) 
			[self decreaseTextSize:nil];
		else 
			[self increaseTextSize:nil];
	}
	textSize = tempTextSide;
	
	[self generateTitle];
	[self enableControls:YES];
}

- (void)enableControls:(BOOL)_bool {
	for(UIBarButtonItem *btn in [toolbar items])
		btn.enabled = _bool;
	
	UISegmentedControl *control = (UISegmentedControl*)self.navigationItem.rightBarButtonItem.customView;
	[control setEnabled:_bool forSegmentAtIndex:0];
	[control setEnabled:_bool forSegmentAtIndex:1];
}

- (void)fadeView:(UIView*)viewToFade withFilter:(NSString*)filter {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	
	BOOL fadeOut = [filter isEqualToString:@"fadeOut"];
	NSInteger y;
	
	if(viewToFade == toolbar)
		y = fadeOut ? 416 : 372;
	else
		y = fadeOut ? -44 : 20;
	
	viewToFade.frame = CGRectMake(0,y,320,44);
	viewToFade.alpha = fadeOut ? 0 : BAR_FADE_ALPHA;
	[UIView commitAnimations];	
}

- (void)generateTitle {
	NSInteger totalArticles = 0;
	NSInteger currentArticle = 0;
	
	for(int i=0;i<[articles count];i++) {
		if(articleID.section == i)
			currentArticle = totalArticles + articleID.row + 1;
		
		NSArray *ary = [[articles objectAtIndex:i] objectForKey:@"articles"];
		totalArticles += [ary count];		
	}
	
	self.navigationItem.title = [NSString stringWithFormat:@"(%i of %i)",currentArticle,totalArticles];
}

- (void)generateArticle {
	NSDictionary *article = [[[articles objectAtIndex:articleID.section] objectForKey:@"articles"] objectAtIndex:articleID.row];
	
	// javascript files to load from NSBundle
	NSArray *scripts = [[NSArray alloc] initWithObjects:@"jquery-1.4.min.js", @"jquery.cycle.all.min.js", @"jquery.document.ready.js", nil];

	NSMutableString *javascript = [[NSMutableString alloc] init];
	for(NSString *js in scripts) {
		NSString *path = [[NSBundle mainBundle] bundlePath];
		NSURL *baseURL = [NSURL fileURLWithPath:path];
		
		NSString *src = [[NSString alloc] initWithFormat:@"<script type='text/javascript' src='%@%@'></script>",baseURL,js];
		[javascript appendString:src];
		[src release];
	}	
	
	
	NSArray *images = [article objectForKey:@"images"];
	NSMutableString *imageStr = [[NSMutableString alloc] initWithString:@"<p id='slideshow' style='float:right;'>"];
	if([GlobalMethods isNetworkAvailable]) {
		for(NSDictionary *image in images) {
			[imageStr appendString:[NSString stringWithFormat:@"<img style='float:right; top:0; left:0;' src='%@'/>",[image objectForKey:@"url"]]];
		}
	}
	[imageStr appendString:@"</p>"];

	// generate published date
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSDate *cDate = [dateFormatter dateFromString:[article valueForKey:@"published"]];
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	
    NSString *publishedDate = [dateFormatter stringFromDate:cDate];
	publishedDate = publishedDate == nil ? @"N/A" : publishedDate;
	[dateFormatter release];
	
	// generate html code
	NSString *htmlString = [[NSString alloc] initWithFormat:@"<meta name='viewport' content='width=320'/>"
							"%@<div class='fixed' style='height:44px'>&nbsp;</div><div style='font-size:1.2em; color:#26678C; font-weight:bold; padding-bottom: 5px'>%@</div>"
							"<div style='font-size:0.8em; color:#555555;'>Byline: %@</div>"
							"<div style='font-size:0.8em; color:#555555;'>Published: %@</div>%@<p id='content'>%@</p><div class='fixed' style='height:44px'>&nbsp;</div>",
							javascript,[article valueForKey:@"header"],[article valueForKey:@"byline"],
							publishedDate,imageStr,[article valueForKey:@"content"]];

	//	DLog(@"html => %@",htmlString);
	[webArticleView loadHTMLString:htmlString baseURL:nil];
	
	// release object
	[scripts release];
	[javascript release];
	[imageStr release];
	[htmlString release];

	[activityIndicator stopAnimating];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		DebugLog(@"left or right");
		return YES;
	}
	
	// Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tweetArticle:(id)sender {
	if ([GlobalMethods isNetworkAvailable]) {
		[FlurryAPI logEvent:@"Article Tweeted"];

		TwitterEngine* _engine = [[TwitterEngine alloc] init];
		BOOL _b = [_engine authenticate:self withDelegate:nil andCallback:nil];

		if (_b) {
			NSDictionary *article = [[[articles objectAtIndex:articleID.section] objectForKey:@"articles"] objectAtIndex:articleID.row];
		
			bitly = [[BitlyRequest alloc] init];
			NSString *bitlyURL = [bitly shortenURL:[article objectForKey:@"browser_link"]];
		
			NSString *tweet = [[NSString alloc] initWithFormat:@"%@ %@ (via @nyunews)",[article valueForKey:@"header"], bitlyURL];
		
			[_engine postMessage:tweet];
			[bitly release];
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:@"Your message has been posted to twitter!" 
														   delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[alert show];
			[alert release];			
		}
		
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Connectivity" message:@"An error has occurred. Please check your network settings and try again." 
													   delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}	
}

- (void)postToFacebook:(id)sender {
	if ([GlobalMethods isNetworkAvailable]) {
		NSDictionary *article = [[[articles objectAtIndex:articleID.section] objectForKey:@"articles"] objectAtIndex:articleID.row];
		//facebookRequest = [[FacebookSession alloc] init];
		//facebookRequest.article = article;
		
		NSString *articleURL = [article valueForKey:@"browser_link"];
		BrowserViewController *facebookConnect = [[BrowserViewController alloc] init];
		facebookConnect.url = [NSString stringWithFormat:@"http://www.facebook.com/sharer.php?u=%@", articleURL];
		[self.navigationController pushViewController:facebookConnect animated:YES];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Connectivity" message:@"An error has occurred. Please check your network settings and try again." 
													   delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)emailArticle:(id)sender {
	[FlurryAPI logEvent:@"Article Emailed"];

	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	
	if (mailClass != nil) {
		if ([mailClass canSendMail])
			[self displayComposerSheet];
	}
}

- (void)launchArticleInBrowser:(id)sender {
	DLog(@"article launched");
	[FlurryAPI logEvent:@"Safari Launched"];
	NSDictionary *article = [[[articles objectAtIndex:articleID.section] objectForKey:@"articles"] objectAtIndex:articleID.row];
	BrowserViewController *browser = [[BrowserViewController alloc] init];
	browser.url = [article valueForKey:@"browser_link"];
	[self.navigationController pushViewController:browser animated:YES];
	browser.browser.frame = CGRectMake(0,0,320,416);
	[browser release];
}

#pragma mark -
- (void)toggleSocialBar:(id)sender {
	[toolbar removeFromSuperview];
	toolbar = networkToolbar;
	[self.view addSubview:toolbar];
}

- (void)toggleArticleBar:(id)sender {
	[toolbar removeFromSuperview];
	toolbar = articleToolbar;
	[self.view addSubview:toolbar];
}

#pragma mark -
#pragma mark Compose Mail
// Displays an email composition interface inside the application. Populates all the Mail fields. 
- (void)displayComposerSheet {
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	NSDictionary *article = [[[articles objectAtIndex:articleID.section] objectForKey:@"articles"] objectAtIndex:articleID.row];
	
	NSString *subject = [[NSString alloc] initWithFormat:@"Washington Square News - %@",[article objectForKey:@"header"]];
	[picker setSubject:subject];
	[subject release];
	
	// Set up recipients
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *defaultEmail = [prefs valueForKey:@"email"];
	
	if(defaultEmail != nil && ![defaultEmail isEqualToString:@""]) {
		NSArray *toRecipients = [NSArray arrayWithObject:defaultEmail];	
		[picker setToRecipients:toRecipients];
	}
	
	// Fill out the email body text
	NSString *url = [article objectForKey:@"browser_link"];
	NSString *emailBody = [[NSString alloc] initWithFormat:@"<p><a href='%@'>%@</a></p><p>%@</p><a href='%@'>View Full Story</a>",url,[article objectForKey:@"header"],
						   [article objectForKey:@"teaser"],url];
	[picker setMessageBody:emailBody isHTML:YES];
	[emailBody release];
	
	[self presentModalViewController:picker animated:YES];
    [picker release];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error  {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
}

- (void)dealloc {
	[saveBtn release];
	[activityIndicator release];
	[facebookRequest release];
	[bitly release];
	[articleID release];
	[articles release];
	[webArticleView release];
    [super dealloc];
}

@end
