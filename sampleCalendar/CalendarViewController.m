

#import "CalendarViewController.h"


@interface CalendarViewController ()

@property (nonatomic, strong) CalendarView * sampleView;

@property (nonatomic, strong) NSCalendar * gregorian;
@property (nonatomic, assign) NSInteger currentYear;


@end

@implementation CalendarViewController

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
    
    
    _gregorian       = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    _sampleView= [[CalendarView alloc]initWithFrame:CGRectMake(0, 40, 320, 360)];
    _sampleView.delegate    = self;
    _sampleView.datasource  = self;
    _sampleView.calendarDate = [NSDate date];
    [self.view addSubview:_sampleView];
    
    
    NSDateComponents * yearComponent = [_gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
    _currentYear = yearComponent.year;
    
    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [_sampleView addGestureRecognizer:swipeleft];
    UISwipeGestureRecognizer * swipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
    [_sampleView addGestureRecognizer:swipeRight];
    // Do any additional setup after loading the view.
}

#pragma mark - Gesture recognizer

-(void)swipeleft:(id)sender
{
    [_sampleView showNextMonth];
}

-(void)swiperight:(id)sender
{
    [_sampleView showPreviousMonth];
}

#pragma mark - CalendarDelegate protocol conformance

-(void)tappedOnDate:(NSDate *)selectedDate
{
    NSLog(@"tappedOnDate %@(GMT)",selectedDate);
}


#pragma mark - CalendarDataSource protocol conformance

-(BOOL)isDataForDate:(NSDate *)date
{
    if ([date compare:[NSDate date]] == NSOrderedAscending)
        return YES;
    return NO;
}

-(BOOL)canSwipeToDate:(NSDate *)date
{
    NSDateComponents * yearComponent = [_gregorian components:NSYearCalendarUnit fromDate:date];
    return (yearComponent.year == _currentYear);
}

#pragma mark - Action methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
