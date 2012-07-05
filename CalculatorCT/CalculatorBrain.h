//
//  CalculatorBrain.h
//  CalculatorCT
//
//  Created by Tatiana Kornilova on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject
- (void)pushOperand:(double)operand;
- (double)performOperation:(NSString *)operation;
- (void)ClearStack;
@end
