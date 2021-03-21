#import "KMQCreditsCell.h"

@implementation KMQCreditsCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier specifier:specifier];
    if (self){
        self.textLabel.text = specifier.properties[@"label"];
        self.detailTextLabel.text = specifier.properties[@"detailLabel"];
    }
    return self;
}
-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
  if(selected) {
    [self openLink];
  } else {
    [super setSelected:selected animated:animated];
  }
}
-(void)openLink {
    NSURL *url = [NSURL URLWithString:self.specifier.properties[@"link"]];
    if([self.specifier.properties[@"isTwitter"] boolValue]) {
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
        else {
            NSString *username = [url.query stringByReplacingOccurrencesOfString:@"screen_name=" withString:@""];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@", username]] options:@{} completionHandler:nil];
        }
    }
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}
@end
