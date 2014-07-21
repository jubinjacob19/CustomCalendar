

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]


#import <UIKit/UIKit.h>


@protocol CalendarDelegate;
@protocol CalendarDataSource;


@interface CalendarView : UIView

-(void)showNextMonth;
-(void)showPreviousMonth;

@property (nonatomic,strong) NSDate *calendarDate;
@property (nonatomic,weak) id<CalendarDelegate> delegate;
@property (nonatomic,weak) id<CalendarDataSource> datasource;

// Border

@property (nonatomic, strong) UIColor * borderColor;
@property (nonatomic, assign) NSInteger borderWidth;

// Button color

@property (nonatomic, strong) UIColor * dayBgColorWithoutData;
@property (nonatomic, strong) UIColor * dayBgColorWithData;
@property (nonatomic, strong) UIColor * dayBgColorSelected;

@property (nonatomic, strong) UIColor * dayTxtColorWithoutData;
@property (nonatomic, strong) UIColor * dayTxtColorWithData;
@property (nonatomic, strong) UIColor * dayTxtColorSelected;


@end



@protocol CalendarDelegate <NSObject>

-(void)tappedOnDate:(NSDate *)selectedDate;

@end


@protocol CalendarDataSource <NSObject>

-(BOOL)isDataForDate:(NSDate *)date;
-(BOOL)canSwipeToDate:(NSDate *)date;

@end