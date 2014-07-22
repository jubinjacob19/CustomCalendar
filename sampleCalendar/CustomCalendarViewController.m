//
//  CustomCalendarViewController.h
//  sampleCalendar
//
//  Created by Michael Azevedo on 21/07/2014.
//  Copyright (c) 2014 Michael Azevedo All rights reserved.
//

#import "CustomCalendarViewController.h"

@interface CustomCalendarViewController ()

@property (nonatomic, strong) CalendarView * customCalendarView;
@property (nonatomic, strong) NSCalendar * gregorian;
@property (nonatomic, assign) NSInteger currentYear;

@end

@implementation CustomCalendarViewController

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
    
    self.title = @"Custom Calendar";
    
    _gregorian       = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    _customCalendarView                             = [[CalendarView alloc]initWithFrame:CGRectMake(0, 40, 320, 360)];
    _customCalendarView.delegate                    = self;
    _customCalendarView.datasource                  = self;
    _customCalendarView.calendarDate                = [NSDate date];
    _customCalendarView.monthAndDayTextColor        = RGBCOLOR(0, 174, 255);
    _customCalendarView.dayBgColorWithData          = RGBCOLOR(21, 124, 229);
    _customCalendarView.dayBgColorWithoutData       = RGBCOLOR(208, 208, 214);
    _customCalendarView.dayBgColorSelected          = RGBCOLOR(94, 94, 94);
    _customCalendarView.dayTxtColorWithoutData      = RGBCOLOR(57, 69, 84);
    _customCalendarView.dayTxtColorWithData         = [UIColor whiteColor];
    _customCalendarView.dayTxtColorSelected         = [UIColor whiteColor];    
    _customCalendarView.borderColor                 = RGBCOLOR(159, 162, 172);
    _customCalendarView.borderWidth                 = 1;
    _customCalendarView.allowsChangeMonthByDayTap   = YES;
    _customCalendarView.allowsChangeMonthByButtons  = YES;
    _customCalendarView.keepSelDayWhenMonthChange   = YES;
    _customCalendarView.nextMonthAnimation          = UIViewAnimationOptionTransitionFlipFromRight;
    _customCalendarView.prevMonthAnimation          = UIViewAnimationOptionTransitionFlipFromLeft;
    
    [self.view addSubview:_customCalendarView];
    
    NSDateComponents * yearComponent = [_gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
    _currentYear = yearComponent.year;

}

#pragma mark - Gesture recognizer

-(void)swipeleft:(id)sender
{
    [_customCalendarView showNextMonth];
}

-(void)swiperight:(id)sender
{
    [_customCalendarView showPreviousMonth];
}

#pragma mark - CalendarDelegate protocol conformance

-(void)dayChangedToDate:(NSDate *)selectedDate
{
    NSLog(@"dayChangedToDate %@(GMT)",selectedDate);
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
    return (yearComponent.year == _currentYear || yearComponent.year == _currentYear+1);
}

#pragma mark - Action methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
