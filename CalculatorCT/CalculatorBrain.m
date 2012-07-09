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

static NSString *previousOperator;

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

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
{
    NSString *description = @"";
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) 
    {
        description = [topOfStack stringValue];
    } 
    else if ([topOfStack isKindOfClass:[NSString class]]) 
    {
        NSString *operation = topOfStack;
        if ([self isAUnaryOperation:operation]) {
            description = [NSString stringWithFormat:@"%@(%@)", operation, [self descriptionOfTopOfStack:stack]];
            
        } else if ([self isABinaryOperation:operation]) {
            
            NSString *format = @"";             
            if ([self isAdditionOrSubtraction:operation] && [self isMultiplicationOrDivision:previousOperator])  {
                
                format = @"(%@ %@ %@)";
            } else {
                format = @"%@ %@ %@";
            }
            previousOperator = operation;
            NSString *secondOperand = [self descriptionOfTopOfStack:stack];
            NSString *firstOperand = [self descriptionOfTopOfStack:stack];
            
            
            BOOL emptyStack = NO;
            if ([stack lastObject]) {
                emptyStack = YES;
            } 
            
            description = [NSString stringWithFormat:format, firstOperand, operation, secondOperand];
            
            previousOperator = operation; // to be used in the next iteration
        } else {
            // Is a variable
            description = [NSString stringWithFormat:@"%@", topOfStack];
        }
        
    }
    
    return description;
}

+ (NSString *)descriptionOfProgram:(id)program 
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    NSString *description = [self descriptionOfTopOfStack:stack];
    while ([stack count]) {
        previousOperator = @"";
        description = [NSString stringWithFormat:@"%@, %@", [self descriptionOfTopOfStack:stack], description];
    }
    return description;
}

- (NSString *) description 
{
    return [CalculatorBrain descriptionOfProgram:self.program];
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];    
}

- (void)pushVariable:(NSString *) variable {
	[self.programStack addObject:variable];	
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

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues; 
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    // go through stack, replace variables with values in variableValues if they exist
    for (id operand in program)
    {
        if (![operand isKindOfClass:[NSNumber class]])
        {
            if (![self isOperation:operand]) {
                [stack replaceObjectAtIndex:[stack indexOfObject:operand] withObject:[NSNumber numberWithDouble:[[variableValues objectForKey:operand] doubleValue]]];
                
            }
        }
    }
    
    return [self popOperandOffProgramStack:stack];
    
}

+ (double)runProgram:(id)program
{
   return [self runProgram:program usingVariableValues:nil];
}

+ (BOOL)isOperation:(NSString *)operation {
    NSSet *operations = [NSSet setWithObjects:@"+", @"*", @"/", @"-", @"√", @"sin", @"cos", @"π", nil];
    if ([operations containsObject:operation]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isABinaryOperation:(NSString *)operation {
    NSSet *operations = [NSSet setWithObjects:@"+", @"*", @"/", @"-", nil];
    if ([operations containsObject:operation]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isAUnaryOperation:(NSString *)operation {
    NSSet *operations = [NSSet setWithObjects:@"√", @"sin", @"cos", nil];
    if ([operations containsObject:operation]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isMultiplicationOrDivision:(NSString *)operation {
    NSSet *operations = [NSSet setWithObjects:@"*", @"/", nil];
    if ([operations containsObject:operation]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isAdditionOrSubtraction:(NSString *)operation {
    NSSet *operations = [NSSet setWithObjects:@"+", @"-", nil];
    if ([operations containsObject:operation]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSSet *)variablesUsedInProgram:(id)program 
{
    NSMutableSet *variables = [NSMutableSet set];
    
    for (id operand in program) 
    {
        if (![operand isKindOfClass:[NSNumber class]])
        {
            if (![self isOperation:operand]) 
            {
                [variables addObject:operand];
            }
        }
    }
    return [variables copy];
}

- (void)ClearStack
{
    [self.programStack removeAllObjects];  
}

- (void)removeLastItem {
    [self.programStack removeLastObject];
}
@end
