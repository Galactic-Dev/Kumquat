#include "KMQCreditsController.h"
@implementation KMQCreditsController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Credits" target:self];
        }
    return _specifiers;
}
@end
