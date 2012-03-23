//
//  MultimediaViewController.m
//  NYU WSN
//
//  Created by Ricky Cheng on 8/13/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "MultimediaViewController.h"
#import "Constants.h"

@implementation MultimediaViewController
@synthesize multimediaTableView, headerBackground;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,367)];
	contentView.backgroundColor = [UIColor blackColor];
	self.view = contentView;
	[contentView release];
	
	multimediaTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,367)];
	multimediaTableView.dataSource = self;
	multimediaTableView.delegate = self;
	multimediaTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	multimediaTableView.backgroundColor = [UIColor blackColor];
	
	// debug clear the easter egg bool
//	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"EasterEggNYULocal"];
	
	multimediaTableView.scrollEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"EasterEggNYULocal"] == YES ? YES : NO;
	[self.view addSubview:multimediaTableView];
}

- (void)viewDidLoad {
	if(headerBackground == nil) {
		headerBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,44)];
		headerBackground.image = [UIImage imageNamed:@"logo.png"];
		[self.navigationController.navigationBar insertSubview:headerBackground atIndex:0];
	}
	
	self.navigationController.navigationBar.tintColor = [GlobalMethods getColor:@"dark"];}

- (void)viewWillAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.navigationItem.title = @"";
	headerBackground.hidden = NO;
	
	shakeCount = 0;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shook:) name:NOTIFICATION_SHOOK object:nil];	
}

- (void) viewDidAppear:(BOOL)animated {	
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	headerBackground.hidden = YES;
	self.navigationItem.title = @"NYU WSN";
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SHOOK object:nil];
}

- (void)shook:(NSNotification *)notification {
	shakeCount += 1;

	if(shakeCount >= 5) {
		[FlurryAPI logEvent:@"NYU Local Easter Egg"];
		UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Easter Egg!" message:@"Congratulations, you've enabled the easter egg."
														delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[message show];
		[message release];
		
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		[prefs setBool:YES forKey:@"EasterEggNYULocal"];
		[prefs synchronize];
		
		multimediaTableView.scrollEnabled = YES;
		[multimediaTableView reloadData];
	}
	
	if(easterEggTimer == nil)
		easterEggTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:5] interval:5 
													target:self selector:@selector(resetEasterEggCounter:) userInfo:nil repeats:NO];
						 else {
		[easterEggTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:5]];
	}
}

- (void)resetEasterEggCounter:(id)sender {
	shakeCount = 0;
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"EasterEggNYULocal"] == YES)
		return 5;
	
    return 4;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSInteger row = indexPath.row;

	NSString *type;

	if(row == 0) {
		type = @"images";
	} else if(row == 1) {
		type = @"videos";
	} else if(row == 2) {
		type = @"crimelogs";
	} else if(row == 3) {
		type = @"qrcode";
	} else if(row == 4) {
		type = @"nyulocal";
	}
	
	NSString *beaconName = [NSString stringWithFormat:@"Multimedia - %@",type];
	[FlurryAPI logEvent:beaconName];
	
	NSString *normal = [NSString stringWithFormat:@"%@_button.png",type];
	NSString *selected = [NSString stringWithFormat:@"%@_selected_button.png",type];
	
	cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:normal]];
	cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:selected]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSInteger row = indexPath.row;
	
	if(row == 0) {
		ImageGalleryViewController *igvc = [[ImageGalleryViewController alloc] init];
		[self.navigationController pushViewController:igvc animated:YES];
		[igvc release];
	} else if(row == 1) {
		VideoFeedsViewController *vid = [[VideoFeedsViewController alloc] init];
		vid.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:vid animated:YES];
		[vid release];
	} else if(row == 2) {
		CrimeLogViewController * clvc = [[CrimeLogViewController alloc] init];
		clvc.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:clvc animated:YES];
		[clvc release];
	} else if(row == 3) {
		DecoderViewController *dvc = [[DecoderViewController alloc] initWithNibName:@"DecoderView" bundle:[NSBundle mainBundle]];
		dvc.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:dvc animated:YES];
		
		#define N_SOURCE_TYPES 3
		UIImagePickerControllerSourceType sourceTypes[N_SOURCE_TYPES] = {
			UIImagePickerControllerSourceTypeCamera,
			UIImagePickerControllerSourceTypeSavedPhotosAlbum,
			UIImagePickerControllerSourceTypePhotoLibrary
		};
		
		for (int i = 0; i < N_SOURCE_TYPES; i++) {
			if ([UIImagePickerController isSourceTypeAvailable:sourceTypes[i]]) {
				[dvc pickAndDecodeFromSource:sourceTypes[i]];
				break;
			}
		}
		#undef N_SOURCE_TYPES
		[dvc release];
	} else if(row == 4) {
		NYULocalViewController *nyulvc = [[NYULocalViewController alloc] init];
		[self.navigationController pushViewController:nyulvc animated:YES];
		[nyulvc release];
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 92;
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


- (void)dealloc {
	[multimediaTableView release];
	[headerBackground release];
    [super dealloc];
}

@end
