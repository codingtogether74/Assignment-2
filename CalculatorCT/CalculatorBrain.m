//
//  CalculatorBrain.m
//  CalculatorCT
//
//  Created by Olga Avanesova on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation CalculatorBrain

@synthesize programStack =_programStack ;
- (NSMutableArray *)programStack
{
    if(!_programStack) {
        _programStack=[[NSMutableArray alloc]init];
    }
    return _programStack;
}

- (id)program
{
    return [self.programStack copy];
}

+ (NSString *)descriptionOfProgram:(id)program
{
    return @"Implement this in Homework #2";
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
    
}

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

    + (double)popOperandOffProgramStack:(NSMutableArray *)stack
    {
    double result=0;
    
    
        id topOfStack = [stack lastObject];
        if (topOfStack) [stack removeLastObject];
        
        if ([topOfStack isKindOfClass:[NSNumber class]])
        {
            result = [topOfStack doubleValue];
        }
        else if ([topOfStack isKindOfClass:[NSString class]])
        {
            NSString *operation = topOfStack;
           if ([operation isEqualToString:@"+"]){
    
               result = [self popOperandOffProgramStack:stack] +
               [self popOperandOffProgramStack:stack];
           } else if ([@"*" isEqualToString:operation]) {
               result = [self popOperandOffProgramStack:stack] *
               [self popOperandOffProgramStack:stack];
           } else if ([@"-" isEqualToString:operation]) {
               double subtrahend = [self popOperandOffProgramStack:stack];
               result = [self popOperandOffProgramStack:stack] - subtrahend;
           } else if ([@"/" isEqualToString:operation]) {
               double divisor = [self popOperandOffProgramStack:stack];
               if (divisor) result = [self popOperandOffProgramStack:stack] / divisor;
           } else if ([@"sin" isEqualToString:operation]) {
               result=sin([self popOperandOffProgramStack:stack]/180 * M_PI);         
           } else if ([@"cos" isEqualToString:operation]) {
               result=cos([self popOperandOffProgramStack:stack]/180 *M_PI );         
           } else if ([@"√" isEqualToString:operation]) {
               result=sqrt([self popOperandOffProgramStack:stack]);         
           } else if ([@"π" isEqualToString:operation]) {
               result=M_PI;         
           } else if ([operation isEqualToString:@"+/-"]) {
              result = [self popOperandOffProgramStack:stack] * -1;
        }
        if (isnan(result))result = 0;
      }
        
    return result;
}

        + (double)runProgram:(id)program
        {
            NSMutableArray *stack;
            if ([program isKindOfClass:[NSArray class]]) {
                stack = [program mutableCopy];
            }
            return [self popOperandOffProgramStack:stack];
        }

- (void)ClearStack
{
    [self.programStack removeAllObjects];  
}

@end
