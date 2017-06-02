//
//  ViewController.m
//  iNspect
//
//  Created by Marut Paiboontanasin1 on 5/2/2560 BE.
//  Copyright © 2560 Remy Infosource. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"

@interface ViewController ()

@end

@implementation ViewController

NSTimer *myTimer, *newTimer;
BOOL theBool;

- (void)viewDidLoad {
    [super viewDidLoad];
    [_webView setDelegate:self];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self addPullToRefreshToWebView];
    self.webView.scalesPageToFit = YES;
    _webView.frame = self.view.frame;
    
    // left swipe and right swipe
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on WebView
    [_webView addGestureRecognizer:swipeLeft];
    [_webView addGestureRecognizer:swipeRight];
    
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"Left Swipe");
        _webView.goForward;
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"Right Swipe");
        _webView.goBack;
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.checkForNetwork) {
        NSURL *url = [NSURL URLWithString:@"https://inspect.tenderwiz.com"];//NSURL *url = [NSURL URLWithString:@"https://inspect.tenderwiz.com"];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    } else {
        [self alertBox];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    _myProgressView.progress = 0;
    theBool = false;

    //0.01667 is roughly 1/60, so it will update at 60 FPS
    myTimer = [NSTimer scheduledTimerWithTimeInterval:0.01667 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    theBool = true;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [newTimer invalidate];
    theBool = true;
    NSLog(@"Failed to load with error :%@",[error debugDescription]);
    [self alertBox];
    
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
    
//    if (navigationType == UIWebViewNavigationTypeLinkClicked ) {
//        UIApplication *application = [UIApplication sharedApplication];
//        [application openURL:[request URL] options:@{} completionHandler:nil];
//        return NO;
//    }
    
//    if([url.lowercaseString containsString:@"getfile"])//if ([request.URL.scheme isEqualToString:@"getfile"])
//    {
//        NSURL *URL = [NSURL URLWithString:url];
//        UIApplication *application = [UIApplication sharedApplication];
//        [application openURL:URL options:@{} completionHandler:nil];
//        return NO;
//    }
//    else
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
    if (self.checkForNetwork) {
        [self.webView reload];
        [refreshController endRefreshing];
    } else {
        [refreshController endRefreshing];
        [self alertBox];
    }
}

-(void)timerCallback {
    if (theBool) {
        if (_myProgressView.progress >= 1) {
            _myProgressView.hidden = true;
            [myTimer invalidate];
        }
        else {
            _myProgressView.progress += 0.1;
        }
    }
    else {
        if (_myProgressView.hidden) {
            _myProgressView.hidden = false;
            NSLog(@"I am not hiding");
        }
        _myProgressView.progress += 0.05;
        if (_myProgressView.progress >= 0.95) {
            _myProgressView.progress = 0.95;
            static dispatch_once_t onceToken;
//            dispatch_once(&onceToken, ^{
//                //timeOut
//                newTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timeout) userInfo:nil repeats:NO];
//            });
        }
    }
}

- (BOOL)checkForNetwork {
    // check if we've got network connectivity
    Reachability *myNetwork = [Reachability reachabilityWithHostName:@"https://inspect.tenderwiz.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    
    switch (myStatus) {
        case NotReachable:
            NSLog(@"There's no internet connection at all.");
            return NO;
            break;
            
        case ReachableViaWWAN:
            NSLog(@"We have a 3G connection");
            return YES;
            break;
            
        case ReachableViaWiFi:
            NSLog(@"We have WiFi.");
            return YES;
            break;
            
        default:
            return YES;
            break;
    }
    return YES;
}

-(void)alertBox {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Issue"
                                 message:@"There is no internet connection or iNspect is down. Please try again later with better internet connectivity or contact iNspect office for further instructions"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)timeout{
    if (![self.webView isLoading]) {
        [self.webView stopLoading];//fire in didFailLoadWithError
        theBool = YES;
    }
}

@end
