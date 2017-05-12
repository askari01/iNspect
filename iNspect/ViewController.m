//
//  ViewController.m
//  iNspect
//
//  Created by Marut Paiboontanasin1 on 5/2/2560 BE.
//  Copyright © 2560 Remy Infosource. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_webView setDelegate:self];
    NSURL *url = [NSURL URLWithString:@"https://inspect.tenderwiz.com"];//NSURL *url = [NSURL URLWithString:@"https://inspect.tenderwiz.com"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    // Do any additional setup after loading the view, typically from a nib.
    [self addPullToRefreshToWebView];
    self.webView.scalesPageToFit = YES;
    _webView.frame = self.view.frame;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Failed to load with error :%@",[error debugDescription]);
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)HandleClick:(id)sender {
    [self.webView goBack];
}
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *url = request.URL.absoluteString;
    NSLog(@"%@",url);
    
    if([url.lowercaseString containsString:@"getfile"])//if ([request.URL.scheme isEqualToString:@"getfile"])
    {
        NSURL *URL = [NSURL URLWithString:url];
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:URL options:@{} completionHandler:nil];
        return NO;
    }
    else
        return YES;
}

- (void)addPullToRefreshToWebView{
    UIColor *whiteColor = [UIColor whiteColor];
    UIRefreshControl *refreshController = [UIRefreshControl new];
    NSString *string = @"Pull down to refresh...";
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : whiteColor };
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    refreshController.bounds = CGRectMake(0, 0, refreshController.bounds.size.width, refreshController.bounds.size.height);
    refreshController.attributedTitle = attributedString;
    [refreshController addTarget:self action:@selector(refreshWebView:) forControlEvents:UIControlEventValueChanged];
    [refreshController setTintColor:whiteColor];
    [self.webView.scrollView addSubview:refreshController];
}

- (void)refreshWebView:(UIRefreshControl*)refreshController{
    [self.webView reload];
    [refreshController endRefreshing];
}

@end
