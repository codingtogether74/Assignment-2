//
//  CalculatorBrain.m
//  CalculatorCT
//
//  Created by Olga Avanesova on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *operandStack;
@end

@implementation CalculatorBrain

@synthesize operandStack =_operandStack ;
- (NSMutableArray *)operandStack
{
    if(!_operandStack) {
        _operandStack=[[NSMutableArray alloc]init];
    }
    return _operandStack;
}

- (void)pushOperand:(double)operand
{
    NSNumber *operandObject=[NSNumber numberWithDouble:operand];
    [self.operandStack addObject:operandObject];
    
}

- (double)popOperand
{
    NSNumber *operandObject=[self.operandStack lastObject];
    if (operandObject) [self.operandStack removeLastObject];
    return [operandObject doubleValue];    
}

- (double)performOperation:(NSString *)operation
{
    double result=0;
    
   // perform the operation here
    
    if ([operation isEqualToString:@"+"]){
        result= [self popOperand]+[self popOperand];
    
    } else if ([@"*" isEqualToString:operation]) {
        result= [self popOperand]*[self popOperand];
    
    } else if ([@"-" isEqualToString:operation]) {
        double subtrahent =[self popOperand];
        result= [self popOperand]-subtrahent;
    
    } else if ([@"/" isEqualToString:operation]) {
        double divisor =[self popOperand];
        if (divisor)result=[self popOperand]/divisor; 
    
    } else if ([@"sin" isEqualToString:operation]) {
        result=sin([self popOperand]/180 * M_PI);         
    
    } else if ([@"cos" isEqualToString:operation]) {
        result=cos([self popOperand]/180 *M_PI );         
    
    } else if ([@"√" isEqualToString:operation]) {
        result=sqrt([self popOperand]);         
    
    } else if ([@"π" isEqualToString:operation]) {
        result=M_PI;         
     
    } else if ([operation isEqualToString:@"+/-"]) {
        result = [self popOperand] * -1;
    }
    if (isnan(result)) {
        result = 0;
    }
    
    [self pushOperand:result];
    
    return result;
}

- (void)ClearStack
{
    [self.operandStack removeAllObjects];  
}

@end
