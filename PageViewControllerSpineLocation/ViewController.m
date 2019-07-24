//
//  ViewController.m
//  MyPageViewController
//
//  Created by tanli on 16/5/28.
//  Copyright © 2016年 tanli. All rights reserved.
//

#import "ViewController.h"
#import "MyContentViewController.h"

@interface ViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>
{
    UIPageViewController *_pageViewController;
    NSArray *_titles;
    NSArray *_images;
    BOOL _is2pView;
}
@property BOOL isAnimating;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _is2pView = YES;
    
    _pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pageViewController"];
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    
    _titles = @[@"lighthouse",@"weather",@"dewdrop",@"lighthouse",@"weather",@"dewdrop"];
    _images = @[@"001.jpg",@"002.jpg",@"004.jpg",@"001.jpg",@"002.jpg",@"004.jpg"];
    
    MyContentViewController *viewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[viewController];
    [_pageViewController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:true
                                 completion:nil];
    _pageViewController.view.frame = CGRectMake(0, 30, self.view.frame.size.width, self.view.frame.size.height-60);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview: _pageViewController.view];
    [_pageViewController didMoveToParentViewController:self];
    [self.view sendSubviewToBack:_pageViewController.view];

    //tapGestureを無効にする
    for(UIGestureRecognizer* gesture in _pageViewController.gestureRecognizers){
        if([[[gesture class] description ] isEqual:@"UITapGestureRecognizer"]){
            [gesture.view removeGestureRecognizer:gesture];
        }
    }

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTappped:)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTappped:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];

    [singleTap requireGestureRecognizerToFail:doubleTap];
}

-(void)doubleTappped:(UITapGestureRecognizer*)doubleTapRecognizer {
    NSLog(@"Double tappepd deteceted");
}

- (void)singleTappped:(UITapGestureRecognizer*)recognizer {
    NSLog(@"Single tappepd deteceted");
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint coords = [recognizer locationInView:recognizer.view];
        NSLog(@" coords %@",NSStringFromCGPoint(coords));
        int posX = coords.x;
        int posY = coords.y;

        int screenW = self.view.bounds.size.width;
        int screenH = self.view.bounds.size.height;

        int LRtapAreaWidth;
        //portrait
        if(screenH > screenW){
            LRtapAreaWidth = screenW / 4;
        }
        //landscape
        else{
            LRtapAreaWidth = screenH / 4;
        }
        NSLog(@"posX %d",posX);
        NSLog(@"LRtapAreaWidth %d",LRtapAreaWidth);
        NSLog(@"posY %d",posY);
        if(((posX > LRtapAreaWidth) && (posX < screenW - LRtapAreaWidth)) || (posY < screenH / 6)){
            NSLog(@" show overlay ");
        }
        else{
            //left page turn area
            if(posX < screenW / 2){
                NSLog(@" goToLeftPage ");
            }
            //right page turn area
            else{
                NSLog(@" goToRightPage ");
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIPageViewController delegate
- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation{
    //1p view
    if(orientation == UIInterfaceOrientationPortrait){
        _pageViewController.doubleSided = NO;
        _isAnimating = NO;

        if(_pageViewController.viewControllers.count != 1){

            MyContentViewController* firstPage = [self viewControllerAtIndex:0];
            [_pageViewController setViewControllers:@[firstPage] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        }

        return UIPageViewControllerSpineLocationMin;

    }
    //2p view
    else{

        if(_pageViewController.viewControllers.count != 2){
            _pageViewController.doubleSided = YES;

           MyContentViewController* leftSidePage = [self viewControllerAtIndex:0];
            leftSidePage.pageIndex = 0;

            MyContentViewController* rightSidePage = [self viewControllerAtIndex:1];
            rightSidePage.pageIndex = 1;

            [_pageViewController setViewControllers:@[leftSidePage, rightSidePage] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            _isAnimating = NO;
        }

        return UIPageViewControllerSpineLocationMid;
    }
}

#pragma mark - dataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = ((MyContentViewController *)viewController).pageIndex;
    if (index == NSNotFound || index == 0  )
    {
        return nil;
    }

    MyContentViewController* prevPage = ((MyContentViewController *)viewController);
    MyContentViewController* nextPage = [self.storyboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    nextPage.pageIndex = prevPage.pageIndex - 1;
    nextPage.pageTitle = _titles[prevPage.pageIndex - 1];
    nextPage.imagefile = _images[prevPage.pageIndex - 1];
    return nextPage;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(nonnull UIViewController *)viewController
{
    NSInteger index = ((MyContentViewController *)viewController).pageIndex;
    if (index == NSNotFound)
    {
        return nil;
    }

    if (index == _titles.count - 1)
    {
        return nil;
    }
    MyContentViewController* prevPage = ((MyContentViewController *)viewController);
    MyContentViewController* nextPage = [self.storyboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    nextPage.pageIndex = prevPage.pageIndex + 1;
    nextPage.pageTitle = _titles[prevPage.pageIndex + 1];
    nextPage.imagefile = _images[prevPage.pageIndex + 1];
    return nextPage;

}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [_titles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (MyContentViewController*)viewControllerAtIndex:(NSInteger)index
{
    if (_titles.count == 0 || index > _titles.count)
    {
        return nil;
    }
    MyContentViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    viewController.pageTitle = _titles[index];
    viewController.imagefile = _images[index];
    viewController.pageIndex = index;
    
    return viewController;
}
@end
