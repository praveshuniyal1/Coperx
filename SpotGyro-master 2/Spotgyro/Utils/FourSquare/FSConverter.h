//
//  FSConverter.h
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 2/7/13.
//
//

#import <Foundation/Foundation.h>

@interface FSConverter : NSObject
- (NSArray *)convertToObjects:(NSArray *)venues;
@property (nonatomic, strong) NSMutableArray * arr_VanueID;
@property (nonatomic,strong) NSMutableArray * arr_parseID;
@property (nonatomic,strong) NSMutableArray * arr_ServiceData;




@end