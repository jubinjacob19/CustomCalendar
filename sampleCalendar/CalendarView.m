
#import "CalendarView.h"

@interface CalendarView()

@property (nonatomic, strong) NSCalendar *gregorian;
@property (nonatomic, assign) NSInteger selectedMonth;
@property (nonatomic, assign) NSInteger selectedYear;
@property (nonatomic, strong) UIColor * mainColor;

@property (nonatomic, assign) NSInteger borderWidth;
@property (nonatomic, assign) NSInteger dayWidth;

@property (nonatomic, assign) NSUInteger dayInfoUnits;

@end
@implementation CalendarView

#pragma mark - Init methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _gregorian          = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        _weekNames          = @[@"Mo",@"Tu",@"We",@"Th",@"Fr",@"Sa",@"Su"];
        _mainColor          = RGBCOLOR(0, 174, 255);
        _borderWidth        = 1;
        _dayWidth           = 40;
        _calendarDate       = [NSDate date];
        
        _dayInfoUnits       = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        
        UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
        swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeleft];
        UISwipeGestureRecognizer * swipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
        swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeRight];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.size.height-100, self.bounds.size.width, 44)];
        [label setBackgroundColor:_mainColor];
        [label setTextColor:[UIColor whiteColor]];
        [label setText:@"swipe to change months"];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        
        [UILabel animateWithDuration:2 animations:^{
            label.alpha = 0;
        }];
    }
    return self;
}


#pragma mark - Instance methods

-(UIButton *)dayButtonWithFrame:(CGRect)frame
{
    UIButton *button                = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.borderWidth        = _borderWidth/2.f;
    button.layer.borderColor        = _mainColor.CGColor;
    button.titleLabel.font          = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    button.frame                    = frame;
    
    return button;
}

#pragma mark - Action methods

-(IBAction)tappedDate:(UIButton *)sender
{
    _gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:self.calendarDate];
    if(!(_selectedDate == sender.tag && _selectedMonth == [components month] && _selectedYear == [components year]))
    {
        if(_selectedDate != -1)
        {
            UIButton *previousSelected =(UIButton *) [self viewWithTag:_selectedDate];
            [previousSelected setBackgroundColor:[UIColor clearColor]];
            [previousSelected setTitleColor:_mainColor forState:UIControlStateNormal];
        }
        
        [sender setBackgroundColor:_mainColor];
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _selectedDate = sender.tag;
        NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:self.calendarDate];
        components.day = _selectedDate;
        _selectedMonth = components.month;
        _selectedYear = components.year;
        NSDate *clickedDate = [_gregorian dateFromComponents:components];
        [self.delegate tappedOnDate:clickedDate];
    }
}

#pragma mark - Gesture recognizers

-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self handleSwipeToRightDirection:NO];
}

-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self handleSwipeToRightDirection:YES];
}

-(void)handleSwipeToRightDirection:(BOOL)toRight
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:self.calendarDate];
    components.day = 1;
    components.month += (toRight ? -1:1);
    self.calendarDate = [_gregorian dateFromComponents:components];
    
    [UIView transitionWithView:self
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^ { [self setNeedsDisplay]; }
                    completion:nil];
}


#pragma mark - Drawing methods

- (void)drawRect:(CGRect)rect
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:self.calendarDate];
    
    _selectedDate       = components.day;
    _selectedMonth      = components.month;
    _selectedYear       = components.year;
    
    components.day = 1;
    NSDate *firstDayOfMonth         = [_gregorian dateFromComponents:components];
    NSDateComponents *comps         = [_gregorian components:NSWeekdayCalendarUnit fromDate:firstDayOfMonth];
    
    NSInteger weekdayBeginning      = [comps weekday];  // Starts at 1 on Sunday
    weekdayBeginning -=2;
    if(weekdayBeginning < 0)
        weekdayBeginning += 7;                          // Starts now at 0 on Monday
    
    NSRange days = [_gregorian rangeOfUnit:NSDayCalendarUnit
                                    inUnit:NSMonthCalendarUnit
                                   forDate:self.calendarDate];
    NSInteger originX = 20;
    NSInteger originY = 60;
    NSInteger monthLength = days.length;
    NSInteger remainingDays = (monthLength + weekdayBeginning) % 7;
    
    // Frame drawing
    NSInteger minY = originY + _dayWidth;
    NSInteger maxY = originY + _dayWidth * (NSInteger)(1+(monthLength+weekdayBeginning)/7) + ((remainingDays !=0)? _dayWidth:0);
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, _mainColor.CGColor);
    CGContextAddRect(context, CGRectMake(originX - _borderWidth/2.f, minY - _borderWidth/2.f, 7*_dayWidth + _borderWidth, _borderWidth));
    CGContextAddRect(context, CGRectMake(originX - _borderWidth/2.f, maxY - _borderWidth/2.f, 7*_dayWidth + _borderWidth, _borderWidth));
    CGContextAddRect(context, CGRectMake(originX - _borderWidth/2.f, minY - _borderWidth/2.f, _borderWidth, maxY - minY));
    CGContextAddRect(context, CGRectMake(originX + 7*_dayWidth - _borderWidth/2.f, minY - _borderWidth/2.f, _borderWidth, maxY - minY));
    CGContextFillPath(context);
    
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    
    NSDateFormatter *format         = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMMM yyyy"];
    NSString *dateString            = [[format stringFromDate:self.calendarDate] uppercaseString];
    UILabel *titleText              = [[UILabel alloc]initWithFrame:CGRectMake(0,20, self.bounds.size.width, 40)];
    titleText.textAlignment         = NSTextAlignmentCenter;
    titleText.text                  = dateString;
    titleText.font                  = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    titleText.textColor             = _mainColor;
    [self addSubview:titleText];
    
    __block CGRect frameWeekLabel = CGRectMake(0, originY, _dayWidth, _dayWidth);
    [_weekNames enumerateObjectsUsingBlock:^(NSString * dayOfWeekString, NSUInteger idx, BOOL *stop)
    {
        frameWeekLabel.origin.x         = originX+(_dayWidth*idx);
        UILabel *weekNameLabel          = [[UILabel alloc] initWithFrame:frameWeekLabel];
        weekNameLabel.text              = dayOfWeekString;
        weekNameLabel.textColor         = _mainColor;
        weekNameLabel.font              = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        weekNameLabel.backgroundColor   = [UIColor clearColor];
        weekNameLabel.textAlignment     = NSTextAlignmentCenter;
        [self addSubview:weekNameLabel];
    }];
    
    for (NSInteger i= 0; i<monthLength; i++)
    {
        NSInteger offsetX   = (_dayWidth*((i+weekdayBeginning)%7));
        NSInteger offsetY   = (_dayWidth *((i+weekdayBeginning)/7));
        UIButton *button    = [self dayButtonWithFrame:CGRectMake(originX+offsetX, originY+40+offsetY, _dayWidth, _dayWidth)];
        
        [button     setTag:i+1];
        [button     setTitle:[NSString stringWithFormat:@"%ld",i+1] forState:UIControlStateNormal];
        [button     setTitleColor:_mainColor forState:UIControlStateNormal];
        [button     addTarget:self action:@selector(tappedDate:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        if(i+1 ==_selectedDate && components.month == _selectedMonth && components.year == _selectedYear)
        {
            [button setBackgroundColor:_mainColor];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
    
    NSDateComponents *previousMonthComponents = [_gregorian components:_dayInfoUnits fromDate:self.calendarDate];
    previousMonthComponents.month -=1;
    NSDate *previousMonthDate = [_gregorian dateFromComponents:previousMonthComponents];
    NSRange previousMonthDays = [_gregorian rangeOfUnit:NSDayCalendarUnit
                   inUnit:NSMonthCalendarUnit
                  forDate:previousMonthDate];
    NSInteger maxDate = previousMonthDays.length - weekdayBeginning;
    
    for (int i=0; i<weekdayBeginning; i++)
    {
        NSInteger offsetX   = (_dayWidth*(i%7));
        NSInteger offsetY   = (_dayWidth *(i/7));
        UIButton *button    = [self dayButtonWithFrame:CGRectMake(originX+offsetX, originY+40+offsetY, _dayWidth, _dayWidth)];
        
        [button     setTitle:[NSString stringWithFormat:@"%ld",maxDate+i+1] forState:UIControlStateNormal];
        [button     setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button     setEnabled:NO];
        [self addSubview:button];
    }
    
    if(remainingDays == 0)
        return;

    for (NSInteger i=remainingDays; i<7; i++)
    {
        NSInteger offsetX   = (_dayWidth*((i) %7));
        NSInteger offsetY   = (_dayWidth *((monthLength+weekdayBeginning)/7));
        UIButton *button    = [self dayButtonWithFrame:CGRectMake(originX+offsetX, originY+40+offsetY, _dayWidth, _dayWidth)];
        [button     setTitle:[NSString stringWithFormat:@"%ld",(i+1)-remainingDays] forState:UIControlStateNormal];
        [button     setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button     setEnabled:NO];
        [self addSubview:button];
    }
}

@end
