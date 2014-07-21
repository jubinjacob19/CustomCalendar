
#import "CalendarView.h"

@interface CalendarView()

@property (nonatomic, strong) NSCalendar *gregorian;
@property (nonatomic, assign) NSInteger selectedMonth;
@property (nonatomic, assign) NSInteger selectedYear;

@property (nonatomic, assign) NSInteger dayWidth;

@property (nonatomic, assign) NSInteger originX;
@property (nonatomic, assign) NSInteger originY;

@property (nonatomic, assign) NSUInteger dayInfoUnits;
@property (nonatomic, strong) NSArray * weekDayNames;

@property (nonatomic, assign) NSInteger selectedDate;

// View shake
@property (nonatomic, assign) NSInteger shakes;
@property (nonatomic, assign) NSInteger shakeDirection;

// Gesture recognizers
@property (nonatomic, strong) UISwipeGestureRecognizer * swipeleft;
@property (nonatomic, strong) UISwipeGestureRecognizer * swipeRight;


@end
@implementation CalendarView

#pragma mark - Init methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _dayWidth                   = frame.size.width/8;
        _originX                    = (frame.size.width - 7*_dayWidth)/2;
        _gregorian                  = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        _borderWidth                = 4;
        _originY                    = _dayWidth;
        _calendarDate               = [NSDate date];
        _dayInfoUnits               = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        
        _monthAndDayTextColor       = [UIColor brownColor];
        _dayBgColorWithoutData      = [UIColor whiteColor];
        _dayBgColorWithData         = [UIColor whiteColor];
        _dayBgColorSelected         = [UIColor brownColor];
        
        _dayTxtColorWithoutData     = [UIColor brownColor];;
        _dayTxtColorWithData        = [UIColor brownColor];
        _dayTxtColorSelected        = [UIColor whiteColor];
        
        _borderColor                = [UIColor brownColor];
        _allowsChangeMonthByDayTap  = NO;
        _allowsChangeMonthByButtons = NO;
        _allowsChangeMonthBySwipe   = YES;
        
        
        _swipeleft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showNextMonth)];
        _swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:_swipeleft];
        _swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showPreviousMonth)];
        _swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:_swipeRight];
        
        NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:[NSDate date]];
        
        _selectedDate       = components.day;
        _selectedMonth      = components.month;
        _selectedYear       = components.year;
        
        
        NSArray * shortWeekdaySymbols = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
        _weekDayNames  = @[shortWeekdaySymbols[1], shortWeekdaySymbols[2], shortWeekdaySymbols[3], shortWeekdaySymbols[4],
                           shortWeekdaySymbols[5], shortWeekdaySymbols[6], shortWeekdaySymbols[0]];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(id)init
{
    self = [self initWithFrame:CGRectMake(0, 0, 320, 400)];
    if (self)
    {
        
    }
    return self;
}

#pragma mark - Custom setters

-(void)setAllowsChangeMonthByButtons:(BOOL)allows
{
    _allowsChangeMonthByButtons = allows;
    [self setNeedsDisplay];
}

-(void)setAllowsChangeMonthBySwipe:(BOOL)allows
{
    _allowsChangeMonthBySwipe   = allows;
    _swipeleft.enabled          = allows;
    _swipeRight.enabled         = allows;
}

#pragma mark - Public methods

-(void)showNextMonth
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:self.calendarDate];
    components.day = 1;
    components.month ++;
    NSDate * nextMonthDate =[_gregorian dateFromComponents:components];
    
    if ([self canSwipeToDate:nextMonthDate])
    {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.calendarDate = nextMonthDate;
        components = [_gregorian components:_dayInfoUnits fromDate:self.calendarDate];
        _selectedDate       = components.day;
        _selectedMonth      = components.month;
        _selectedYear       = components.year;
        [self performViewTransition];
    }
    else
    {
        [self performViewNoSwipeAnimation];
    }
}

-(void)showPreviousMonth
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:self.calendarDate];
    components.day = 1;
    components.month --;
    NSDate * prevMonthDate = [_gregorian dateFromComponents:components];
    
    if ([self canSwipeToDate:prevMonthDate])
    {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.calendarDate = prevMonthDate;
        components = [_gregorian components:_dayInfoUnits fromDate:self.calendarDate];
        _selectedDate       = components.day;
        _selectedMonth      = components.month;
        _selectedYear       = components.year;
        [self performViewTransition];
    }
    else
    {
        [self performViewNoSwipeAnimation];
    }
}

#pragma mark - Various methods

-(BOOL)canSwipeToDate:(NSDate *)date
{
    if (_datasource == nil)
        return YES;
    return [_datasource canSwipeToDate:date];
}

-(void)performViewTransition
{
    [UIView transitionWithView:self
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^ { [self setNeedsDisplay]; }
                    completion:nil];
}

-(void)performViewNoSwipeAnimation
{
    _shakeDirection = 1;
    _shakes = 0;
    [self shakeView:self];
}

// Taken from PinPad
-(void)shakeView:(UIView *)theOneYouWannaShake
{
    [UIView animateWithDuration:0.05 animations:^
     {
         theOneYouWannaShake.transform = CGAffineTransformMakeTranslation(5*_shakeDirection, 0);
         
     } completion:^(BOOL finished)
     {
         if(_shakes >= 4)
         {
             theOneYouWannaShake.transform = CGAffineTransformIdentity;
             return;
         }
         _shakes++;
         _shakeDirection = _shakeDirection * -1;
         [self shakeView:theOneYouWannaShake];
     }];
}

#pragma mark - Button creation and configuration

-(UIButton *)dayButtonWithFrame:(CGRect)frame
{
    UIButton *button                = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.borderWidth        = _borderWidth/2.f;
    button.layer.borderColor        = _borderColor.CGColor;
    button.titleLabel.font          = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    button.frame                    = frame;
    [button     addTarget:self action:@selector(tappedDate:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

-(void)configureDayButton:(UIButton *)button withDate:(NSDate*)date
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:date];
    [button setTitle:[NSString stringWithFormat:@"%ld",components.day] forState:UIControlStateNormal];
    
    if(components.day ==_selectedDate && components.month == _selectedMonth && components.year == _selectedYear)
    {
        button.layer.borderWidth = 0;
        [button setTitleColor:_dayTxtColorSelected forState:UIControlStateNormal];
        [button setBackgroundColor:_dayBgColorSelected];
        return;
    }
    
    [button setTitleColor:_dayTxtColorWithoutData forState:UIControlStateNormal];
    [button setBackgroundColor:_dayBgColorWithoutData];
    if (self.datasource != nil)
    {
        if ([self.datasource isDataForDate:date])
        {
            [button setTitleColor:_dayTxtColorWithData forState:UIControlStateNormal];
            [button setBackgroundColor:_dayBgColorWithData];
        }
    }
    
    if (components.month != _selectedMonth)
        button.alpha = 0.5f;
}

#pragma mark - Action methods

-(IBAction)tappedDate:(UIButton *)sender
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:self.calendarDate];
    
    if (sender.tag < 0 || sender.tag >= 40)
    {
        if (!_allowsChangeMonthByDayTap)
            return;
        
        NSInteger offsetMonth   = (sender.tag < 0)?-1:1;
        NSInteger offsetTag     = (sender.tag < 0)?40:-40;
        
        NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:self.calendarDate];
        components.day = 1;
        components.month += offsetMonth;
        NSDate * otherMonthDate =[_gregorian dateFromComponents:components];
        
        if ([self canSwipeToDate:otherMonthDate])
        {
            [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            self.calendarDate = otherMonthDate;
            components = [_gregorian components:_dayInfoUnits fromDate:self.calendarDate];
            
            _selectedYear       = components.year;
            _selectedMonth      = components.month;
            _selectedDate       = sender.tag + offsetTag;
            [self performViewTransition];
        }
        else
        {
            [self performViewNoSwipeAnimation];
        }
        return;
    }
    
    if(!(_selectedDate == sender.tag && _selectedMonth == [components month] && _selectedYear == [components year]))
    {
        if(_selectedDate != -1)
        {
            components.day = _selectedDate;
            _selectedDate = sender.tag;
            
            UIButton *previousSelected =(UIButton *) [self viewWithTag:components.day];
            previousSelected.layer.borderWidth = _borderWidth/2.f;
            [self configureDayButton:previousSelected withDate:[_gregorian dateFromComponents:components]];
        }
        
        components.day = _selectedDate;
        
        sender.layer.borderWidth = 0;
        [sender setBackgroundColor:_dayBgColorSelected];
        [sender setTitleColor:_dayTxtColorSelected forState:UIControlStateNormal];
        _selectedDate = sender.tag;
        _selectedMonth = components.month;
        _selectedYear = components.year;
        NSDate *clickedDate = [_gregorian dateFromComponents:components];
        [self.delegate tappedOnDate:clickedDate];
    }
}

#pragma mark - Drawing methods

- (void)drawRect:(CGRect)rect
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:self.calendarDate];
    
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

    NSInteger monthLength = days.length;
    NSInteger remainingDays = (monthLength + weekdayBeginning) % 7;
    
    
    // Frame drawing
    NSInteger minY = _originY + _dayWidth;
    NSInteger maxY = _originY + _dayWidth * (NSInteger)(1+(monthLength+weekdayBeginning)/7) + ((remainingDays !=0)? _dayWidth:0);
    
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, _borderColor.CGColor);
    CGContextAddRect(context, CGRectMake(_originX - _borderWidth/2.f, minY - _borderWidth/2.f, 7*_dayWidth + _borderWidth, _borderWidth));
    CGContextAddRect(context, CGRectMake(_originX - _borderWidth/2.f, maxY - _borderWidth/2.f, 7*_dayWidth + _borderWidth, _borderWidth));
    CGContextAddRect(context, CGRectMake(_originX - _borderWidth/2.f, minY - _borderWidth/2.f, _borderWidth, maxY - minY));
    CGContextAddRect(context, CGRectMake(_originX + 7*_dayWidth - _borderWidth/2.f, minY - _borderWidth/2.f, _borderWidth, maxY - minY));
    CGContextFillPath(context);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    if (_allowsChangeMonthByButtons)
    {
        // Previous and next button
        UIButton * buttonPrev          = [[UIButton alloc] initWithFrame:CGRectMake(_originX, 0, _dayWidth, _dayWidth)];
        [buttonPrev setTitle:@"<" forState:UIControlStateNormal];
        [buttonPrev setTitleColor:_monthAndDayTextColor forState:UIControlStateNormal];
        [buttonPrev addTarget:self action:@selector(showPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
        buttonPrev.titleLabel.font          = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
        [self addSubview:buttonPrev];
        
        UIButton * buttonNext          = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - _dayWidth - _originX, 0, _dayWidth, _dayWidth)];
        [buttonNext setTitle:@">" forState:UIControlStateNormal];
        [buttonNext setTitleColor:_monthAndDayTextColor forState:UIControlStateNormal];
        [buttonNext addTarget:self action:@selector(showNextMonth) forControlEvents:UIControlEventTouchUpInside];
        buttonNext.titleLabel.font          = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
        [self addSubview:buttonNext];
        
        NSDateComponents *componentsTmp = [_gregorian components:_dayInfoUnits fromDate:self.calendarDate];
        componentsTmp.day = 1;
        componentsTmp.month --;
        NSDate * prevMonthDate =[_gregorian dateFromComponents:componentsTmp];
        if (![self canSwipeToDate:prevMonthDate])
        {
            buttonPrev.alpha    = 0.5f;
            buttonPrev.enabled  = NO;
        }
        componentsTmp.month +=2;
        NSDate * nextMonthDate =[_gregorian dateFromComponents:componentsTmp];
        if (![self canSwipeToDate:nextMonthDate])
        {
            buttonNext.alpha    = 0.5f;
            buttonNext.enabled  = NO;
        }
    }    
    
    // Month label
    NSDateFormatter *format         = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMMM yyyy"];
    NSString *dateString            = [[format stringFromDate:self.calendarDate] uppercaseString];
    UILabel *titleText              = [[UILabel alloc]initWithFrame:CGRectMake(0,0, self.bounds.size.width, _dayWidth)];
    titleText.textAlignment         = NSTextAlignmentCenter;
    titleText.text                  = dateString;
    titleText.font                  = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    titleText.textColor             = _monthAndDayTextColor;
    [self addSubview:titleText];
    
    // Day labels
    __block CGRect frameWeekLabel = CGRectMake(0, _originY, _dayWidth, _dayWidth);
    [_weekDayNames  enumerateObjectsUsingBlock:^(NSString * dayOfWeekString, NSUInteger idx, BOOL *stop)
    {
        frameWeekLabel.origin.x         = _originX+(_dayWidth*idx);
        UILabel *weekNameLabel          = [[UILabel alloc] initWithFrame:frameWeekLabel];
        weekNameLabel.text              = dayOfWeekString;
        weekNameLabel.textColor         = _monthAndDayTextColor;
        weekNameLabel.font              = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        weekNameLabel.backgroundColor   = [UIColor clearColor];
        weekNameLabel.textAlignment     = NSTextAlignmentCenter;
        [self addSubview:weekNameLabel];
    }];
    
    // Current month
    for (NSInteger i= 0; i<monthLength; i++)
    {
        NSInteger offsetX   = (_dayWidth*((i+weekdayBeginning)%7));
        NSInteger offsetY   = (_dayWidth *((i+weekdayBeginning)/7));
        UIButton *button    = [self dayButtonWithFrame:CGRectMake(_originX+offsetX, _originY+_dayWidth+offsetY, _dayWidth, _dayWidth)];
        button.tag          = i+1;
        components.day      = i+1;
        
    
        [self configureDayButton:button withDate:[_gregorian dateFromComponents:components]];
        [self addSubview:button];
    }
    
    // Previous month
    NSDateComponents *previousMonthComponents = [_gregorian components:_dayInfoUnits fromDate:self.calendarDate];
    previousMonthComponents.month --;
    NSDate *previousMonthDate = [_gregorian dateFromComponents:previousMonthComponents];
    NSRange previousMonthDays = [_gregorian rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:previousMonthDate];
    NSInteger maxDate = previousMonthDays.length - weekdayBeginning;
    for (int i=0; i<weekdayBeginning; i++)
    {
        previousMonthComponents.day     = maxDate+i+1;
        NSInteger offsetX               = (_dayWidth*(i%7));
        NSInteger offsetY               = (_dayWidth *(i/7));
        UIButton *button                = [self dayButtonWithFrame:CGRectMake(_originX+offsetX, _originY + _dayWidth + offsetY, _dayWidth, _dayWidth)];
        button.tag                      = -40 + maxDate+i+1;
        
        [self configureDayButton:button withDate:[_gregorian dateFromComponents:previousMonthComponents]];
        [self addSubview:button];
    }
    
    // Next month
    if(remainingDays == 0)
        return ;
    
    NSDateComponents *nextMonthComponents = [_gregorian components:_dayInfoUnits fromDate:self.calendarDate];
    nextMonthComponents.month ++;
    
    for (NSInteger i=remainingDays; i<7; i++)
    {
        nextMonthComponents.day         = (i+1)-remainingDays;
        NSInteger offsetX               = (_dayWidth*((i) %7));
        NSInteger offsetY               = (_dayWidth *((monthLength+weekdayBeginning)/7));
        UIButton *button                = [self dayButtonWithFrame:CGRectMake(_originX+offsetX, _originY + _dayWidth + offsetY, _dayWidth, _dayWidth)];
        button.tag                      = 40 + (i+1)-remainingDays;
        
        [self configureDayButton:button withDate:[_gregorian dateFromComponents:nextMonthComponents]];
        [self addSubview:button];
    }
}

@end
