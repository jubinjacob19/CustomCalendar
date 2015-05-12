

#import "DefaultCalendarViewController.h"


@interface DefaultCalendarViewController ()

@property (nonatomic, strong) CalendarView * sampleView;

@end


@implementation DefaultCalendarViewController

#pragma mark - Init methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.title = @"Default Calendar";
    
    _sampleView= [[CalendarView alloc]initWithFrame:CGRectMake(0, 40, 320, 360)];
    _sampleView.delegate    = self;
    _sampleView.calendarDate = [NSDate date];
    
    dispatch_async(dispatch_get_main_queue(), ^{        
        [self.view addSubview:_sampleView];
        _sampleView.center = CGPointMake(self.view.center.x, _sampleView.center.y);
    });
}

#pragma mark - CalendarDelegate protocol conformance

-(void)dayChangedToDate:(NSDate *)selectedDate
{
    NSLog(@"dayChangedToDate %@(GMT)",selectedDate);
}

#pragma mark - Action methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
