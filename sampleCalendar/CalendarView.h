

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]


#import <UIKit/UIKit.h>
@protocol CalendarDelegate <NSObject>

-(void)tappedOnDate:(NSDate *)selectedDate;

@end

@interface CalendarView : UIView
{
    NSInteger _selectedDate;
    NSArray *_weekNames;
}

@property (nonatomic,strong) NSDate *calendarDate;
@property (nonatomic,weak) id<CalendarDelegate> delegate;

@end
