//
//  PostsViewController.m
//  WordPressApiExample
//
//  Created by Jorge Bernal on 12/20/11.
//  Copyright (c) 2011 Automattic. All rights reserved.
//

#import "PostsViewController.h"
#import "PostViewController.h"

@interface PostsViewController ()
@property (readwrite, nonatomic, retain) WordPressApi *api;
@property (readwrite, nonatomic, retain) NSArray *posts;
@end

@implementation PostsViewController
@synthesize api = _api;
@synthesize posts = _posts;

- (void)awakeFromNib
{
    // TODO: show login view
    // Meanwhile, change this parameters on the PCH file
    self.api = [WordPressApi apiWithXMLRPCEndpoint:[NSURL URLWithString:WPAPI_URL] username:WPAPI_USER password:WPAPI_PASS];
    self.posts = [NSArray array];
    [super awakeFromNib];
}

- (void)dealloc
{
    [_api release];
    [_posts release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self refreshPosts:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];    
    NSDictionary *post = [self.posts objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [post objectForKey:@"title"];
    cell.detailTextLabel.text = [post objectForKey:@"description"];
    return cell;
}

#pragma mark - Table delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showPost" sender:self];
}

#pragma mark - Storyboards

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSDictionary *post = [self.posts objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    PostViewController *postViewController = (PostViewController *)segue.destinationViewController;
    postViewController.post = post;
}

#pragma mark - Custom methods

- (IBAction)refreshPosts:(id)sender {
    [self.api getPosts:10 success:^(NSArray *posts) {
        self.posts = posts;
        NSLog(@"We have %d posts", [self.posts count]);
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"Error fetching posts: %@", [error localizedDescription]);
    }];
}

@end
