#import "AuthContainerViewController.h"
#import "ConcreteAuthViewController.h"
#import "SpeakerAuthViewController.h"
#import "FaceAuthViewController.h"
#import "CompoundAuthViewController.h"
#import "AuthResultViewController.h"

@interface AuthContainerViewController () <ConcreteAuthViewControllerDelegate> {
    BOOL _authFinished;
}

@property (nonatomic, strong) ConcreteAuthViewController *currentAuthViewController;

@end

@implementation AuthContainerViewController

 (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _currentAuthViewController = [storyboard instantiateViewControllerWithIdentifier:self.initialViewControllerIdentifier];
    [self addChildViewController:_currentAuthViewController];
    _currentAuthViewController.view.frame = self.view.bounds;
    [self.view addSubview:_currentAuthViewController.view];
    _currentAuthViewController.delegate = self;
    [_currentAuthViewController didMoveToParentViewController:self];
}

 (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

 (BOOL)prefersStatusBarHidden {
    return YES;
}

 (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark  Navigation

// In a storyboardbased application, you will often want to do a little preparation before navigation
 (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

 (BOOL)shouldAutomaticallyForwardRotationMethods {
    return YES;
}

#pragma mark ConcreteAuthViewController Delegate

 (void)dismissAndPresentNext:(ConcreteAuthViewController *)current {
    NSString *nextViewControllerIdentifier = @"";
    if ([current isKindOfClass:[SpeakerAuthViewController class]]) {
        nextViewControllerIdentifier = @"FaceAuthViewController";
    } else if ([current isKindOfClass:[FaceAuthViewController class]]) {
        if (PRODUCT_TYPE == FOSProductTypeSpeakerAndFace) {
            nextViewControllerIdentifier = @"SpeakerAuthViewController";
        } else {
            nextViewControllerIdentifier = @"CompoundAuthViewController";
        }
    } else if ([current isKindOfClass:[CompoundAuthViewController class]]) {
        nextViewControllerIdentifier = @"SpeakerAuthViewController";
    }
    
    if (!nextViewControllerIdentifier || [nextViewControllerIdentifier length] == 0) {
        return;
    }
    [self dismissAndPresent:nextViewControllerIdentifier];
}

 (void)dismissAndPresent:(NSString *)nextViewControllerIdentifier {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ConcreteAuthViewController *nextAuthViewController = [storyboard instantiateViewControllerWithIdentifier:nextViewControllerIdentifier];
    [nextAuthViewController.view layoutIfNeeded];
    nextAuthViewController.view.frame = self.view.bounds;
    [_currentAuthViewController willMoveToParentViewController:nil];
    [self addChildViewController:nextAuthViewController];
    nextAuthViewController.delegate = self;
    
    __weak __block AuthContainerViewController *weakSelf = self;
    [self transitionFromViewController:_currentAuthViewController toViewController:nextAuthViewController duration:0.3 options:UIViewAnimationOptionTransitionFlipFromRight animations:nil completion:^(BOOL finished) {
        [weakSelf.currentAuthViewController removeFromParentViewController];
        [nextAuthViewController didMoveToParentViewController:weakSelf];
        weakSelf.currentAuthViewController = nextAuthViewController;
    }];
}

 (void)gotoSpeakerSignUp {
    SET_JUMPING(@"SpeakerSignUpViewController", @"DummyShopViewController");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

 (void)gotoFaceSignUp {
    SET_JUMPING(@"FaceSignUpViewController", @"DummyShopViewController");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

 (void)authFinish:(BOOL)passed info:(NSDictionary *)info {
    _authFinished = YES;
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AuthResultViewController *authResultViewController = [storyboard instantiateViewControllerWithIdentifier:@"AuthResultViewController"];
    authResultViewController.passed = passed;
    authResultViewController.info = info;
    [authResultViewController.view layoutIfNeeded];
    authResultViewController.view.frame = self.view.bounds;
    [_currentAuthViewController willMoveToParentViewController:nil];
    [self addChildViewController:authResultViewController];
    
    __weak __block AuthContainerViewController *weakSelf = self;
    [self transitionFromViewController:_currentAuthViewController toViewController:authResultViewController duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        [weakSelf.currentAuthViewController removeFromParentViewController];
        [authResultViewController didMoveToParentViewController:weakSelf];
    }];
}
