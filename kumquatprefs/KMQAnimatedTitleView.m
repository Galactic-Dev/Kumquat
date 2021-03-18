#import "KMQAnimatedTitleView.h"
#include <RemoteLog.h>

@implementation KMQAnimatedTitleView {
  UILabel *_titleLabel;
  NSLayoutConstraint *_yConstraint;
  CGFloat _minimumOffsetRequired;
}

  -(instancetype)initWithTitle:(NSString *)title minimumScrollOffsetRequired:(CGFloat)minimumOffset {
    if([super init]) {
      _titleLabel = [[UILabel alloc] init];
      _titleLabel.text = title;
      _titleLabel.textAlignment = NSTextAlignmentCenter;
      _titleLabel.textColor = [UIColor whiteColor];
      _titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightHeavy];
      _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
      [_titleLabel sizeToFit];

      [self addSubview:_titleLabel];

      [NSLayoutConstraint activateConstraints:@[
        [self.widthAnchor constraintEqualToAnchor:_titleLabel.widthAnchor],
        [self.heightAnchor constraintEqualToAnchor:_titleLabel.heightAnchor],

        [_titleLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        _yConstraint = [_titleLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:50],
      ]];

      _minimumOffsetRequired = minimumOffset;
    }

    return self;
  }

  -(void)adjustLabelPositionToScrollOffset:(CGFloat)offset {
    if(_minimumOffsetRequired == 0) {
        _minimumOffsetRequired = offset - (offset / 2);
    }
    CGFloat adjustment = 50 - (offset - _minimumOffsetRequired);
    if(offset >= _minimumOffsetRequired) {
      if(adjustment <= 0) {
        _yConstraint.constant = 0;
      } else {
        _yConstraint.constant = adjustment;
      }

    } else {
      _yConstraint.constant = -100;
    }
  }
@end

