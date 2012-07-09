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

- (id)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}


+ (id)popOperandOffProgramStack:(NSMutableArray *)stack
{
    NSString * INSUFFICIENT_OPERANDS = @"Insufficient operands!";
    NSString * INVALID_OPERATION = @"Operation not implemented!";
    NSString * INVALID_OPERAND = @"Operand not match!";
    NSString * DIVIDE_ZERO = @"Cannot divide by zero";
    NSString * SQRT_NEGATIVE = @"Cannot do Square Root of negative number";
    
    double result=0;
    
    
        id topOfStack = [stack lastObject];
        if (topOfStack) [stack removeLastObject];else return @"0";
        
        if ([topOfStack isKindOfClass:[NSNumber class]])
        {
            result = [topOfStack doubleValue];
        }
        else if ([topOfStack isKindOfClass:[NSString class]])
        {
           NSString *operation = topOfStack;
           if (![self isOperation:operation]) return INVALID_OPERATION;

           if ([operation isEqualToString:@"+"]){
               id operand1=[self popOperandOffProgramStack:stack];
               id operand2=[self popOperandOffProgramStack:stack];
               if ([operand1 isKindOfClass:[NSNumber class]] && [operand2 isKindOfClass:[NSNumber class]]) {
                   result= [operand1 doubleValue]+[operand2 doubleValue];
               } else return INSUFFICIENT_OPERANDS;
               
           } else if ([@"*" isEqualToString:operation]) {
               id operand1=[self popOperandOffProgramStack:stack];
               id operand2=[self popOperandOffProgramStack:stack];
               if ([operand1 isKindOfClass:[NSNumber class]] && [operand2 isKindOfClass:[NSNumber class]]) {
                   result= [operand1 doubleValue]*[operand2 doubleValue];
               } else return INSUFFICIENT_OPERANDS;
               
           } else if ([@"-" isEqualToString:operation]) {
               id operand1=[self popOperandOffProgramStack:stack];
               id operand2=[self popOperandOffProgramStack:stack];
               if ([operand1 isKindOfClass:[NSNumber class]] && [operand2 isKindOfClass:[NSNumber class]]) {
                   result= [operand2 doubleValue]-[operand1 doubleValue];
               } else return INSUFFICIENT_OPERANDS;
               
           } else if ([@"/" isEqualToString:operation]) {
               id operand1=[self popOperandOffProgramStack:stack];
               id operand2=[self popOperandOffProgramStack:stack];
               if ([operand1 isKindOfClass:[NSNumber class]] && [operand2 isKindOfClass:[NSNumber class]]) {
                   if ([operand1 doubleValue]){
                       result= [operand2 doubleValue]/[operand1 doubleValue];
                   } else return DIVIDE_ZERO;
               } else return INSUFFICIENT_OPERANDS;
               
           } else if ([@"sin" isEqualToString:operation]) {
               id operand=[self popOperandOffProgramStack:stack];
               if ([operand isKindOfClass:[NSNumber class]]) {
                   result=sin([operand doubleValue]/180 * M_PI);         
              } else return INSUFFICIENT_OPERANDS;
               
           } else if ([@"cos" isEqualToString:operation]) {
               id operand=[self popOperandOffProgramStack:stack];
               if ([operand isKindOfClass:[NSNumber class]]) {
                   result=cos([operand doubleValue]/180 * M_PI);         
               } else return INSUFFICIENT_OPERANDS;
               
           } else if ([@"√" isEqualToString:operation]) {
               id operand=[self popOperandOffProgramStack:stack];
               if ([operand isKindOfClass:[NSNumber class]]) {
                   if ([operand doubleValue]>=0){
                        result=sqrt([operand doubleValue]);
                   } else return SQRT_NEGATIVE;     
               } else return INSUFFICIENT_OPERANDS;
               
           } else if ([@"π" isEqualToString:operation]) {
               result=M_PI;         
           } else if ([operation isEqualToString:@"+/-"]) {
               id operand=[self popOperandOffProgramStack:stack];
               if ([operand isKindOfClass:[NSNumber class]]) {
                   result=[operand doubleValue]*-1;         
               } else return INSUFFICIENT_OPERANDS;
           } else return INSUFFICIENT_OPERANDS;
        } else return INVALID_OPERATION;
    if (isnan(result))return INVALID_OPERAND;
       
   return [NSNumber numberWithDouble:result];
}

+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues; 
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

+ (id)runProgram:(id)program
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
