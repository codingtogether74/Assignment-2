//
//  CalculatorViewController.m
//  CalculatorCT
//
//  Created by Tatiana Kornilovaon 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#define MAX_COUNT (30)

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL userAlreadyEnteredADecimalPoint;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic,strong)  NSDictionary *testVariablesValue;

- (NSString *)variablesDescription;
- (id)calculateProgram;
@end

@implementation CalculatorViewController
@synthesize display = _display;
@synthesize inputDisplay = _inputDisplay;
@synthesize variablesDisplay = _variablesDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber=_userIsInTheMiddleOfEnteringANumber;
@synthesize userAlreadyEnteredADecimalPoint=_userAlreadyEnteredADecimalPoint;
@synthesize testVariablesValue=_testVariablesValue;

@synthesize brain=_brain;
- (CalculatorBrain *)brain
{
    if (!_brain) _brain=[[CalculatorBrain alloc] init];
    return _brain;
}
//----------------------------------------------------------------------------
- (IBAction)digitPress:(UIButton *)sender {
    
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber){
        self.display.text = [self.display.text stringByAppendingString:digit];
        
    } else {
            self.display.text=digit;
        if (![self.display.text isEqualToString:@"0"]) { 
            self.userIsInTheMiddleOfEnteringANumber= YES;
        }    
    }
}
//----------------------------------------------------------------------------
- (IBAction)enterPressed 
{
    [self.brain pushOperand:[self.display.text doubleValue]];    
    self.userIsInTheMiddleOfEnteringANumber=NO;
    self.userAlreadyEnteredADecimalPoint=NO; 
    self.inputDisplay.text = [self.brain description];
//    [self synchronizeView];      
     
}
- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *operation=sender.currentTitle;
    id result=[self.brain performOperation:operation];
    if ([result isKindOfClass:[NSString class]]) self.display.text = result;
    else self.display.text = [NSString stringWithFormat:@"%g", [result doubleValue]];
    self.inputDisplay.text = [self.brain description];
 //   [self synchronizeView];      

}
- (IBAction)variablePressed:(UIButton *)sender {
	[self.brain pushVariable:sender.currentTitle];
    self.userIsInTheMiddleOfEnteringANumber=NO;
    self.userAlreadyEnteredADecimalPoint=NO; 
    self.inputDisplay.text = [self.brain description];
//    [self synchronizeView];      
}

- (IBAction)decimalPointPressed {
    if (!self.userAlreadyEnteredADecimalPoint) {
        if (self.userIsInTheMiddleOfEnteringANumber) {
            self.display.text = [self.display.text stringByAppendingString:@"."];

        } else {
            // in case the decimal point is first 
            self.display.text = @"0.";
            self.userIsInTheMiddleOfEnteringANumber = YES;
        }
        self.userAlreadyEnteredADecimalPoint = YES;
    }
}

- (IBAction)CleanAll {
    self.display.text = @"0";
    self.inputDisplay.text = @"";
    [self.brain ClearStack];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userAlreadyEnteredADecimalPoint = NO;
}

- (IBAction)undoPress:(id)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self delDigit];
    } else {
        [self.brain removeLastItem];
//        self.display.text = [NSString stringWithFormat:@"%g", [self calculateProgram]];
//        self.inputDisplay.text = [self.brain description];
        [self synchronizeView];      
    }
}
- (IBAction)setTestVariables:(UIButton *)sender {
    NSString * testNumber;
    testNumber=[sender.currentTitle substringWithRange:NSMakeRange(5, 1)];
    if ([testNumber isEqualToString:@"1"]) {
        self.testVariablesValue = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"x", @"3", @"a", @"4", @"b", nil];
    } else if ([testNumber isEqualToString:@"2"]) {
        self.testVariablesValue = [NSDictionary dictionaryWithObjectsAndKeys:@"-4", @"x", @"3", @"a", @"3", @"b", nil];
    } else if ([testNumber isEqualToString:@"3"]) {
        self.testVariablesValue = nil;
    }
    [self synchronizeView];      
}



- (IBAction)delDigit {
    //----------------------------- It is working only in entering a number-------
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([self.display.text length]>0) {
            self.display.text = [self.display.text substringToIndex:[self.display.text length] - 1];
    
    //------------------------------ check "." after deleted ---------------------
            NSRange range= [self.display.text rangeOfString:@"."];
            if (range.location == NSNotFound) self.userAlreadyEnteredADecimalPoint = NO;
   
    //------------------------------ if all numbers have been deleted, stay display with 0
            if ([self.display.text length]==0) {
                self.display.text = @"0";
                self.userAlreadyEnteredADecimalPoint = NO;
            }
   
        }
    }
}

- (NSString *)variablesDescription {
    // for tests
    NSString *descriptionOfVariablesUsed = @"";
    NSSet *variablesBeingUsed = [[self.brain class] variablesUsedInProgram:self.brain.program];
    for (NSString *variable in variablesBeingUsed) {
        if ([self.testVariablesValue objectForKey:variable]) {
            descriptionOfVariablesUsed = [descriptionOfVariablesUsed stringByAppendingString:[NSString stringWithFormat:@"%@= %@  ", variable, [self.testVariablesValue objectForKey:variable]]];
        }
    }
    return descriptionOfVariablesUsed;
}

- (id)calculateProgram {
    if (!self.testVariablesValue) {
        return [[self.brain class] runProgram:self.brain.program];
    } else {
        return [[self.brain class] runProgram:self.brain.program usingVariableValues:self.testVariablesValue];
    }
    
}

-(void)synchronizeView {   
    id result =[self calculateProgram]; 
    if ([result isKindOfClass:[NSString class]]) self.display.text = result;
    else self.display.text = [NSString stringWithFormat:@"%g", [result doubleValue]];

    // Now the inputDisplay from the latest description of program 
    self.inputDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    self.variablesDisplay.text = [self variablesDescription];
    // And the user isn't in the middle of entering a number
    self.userIsInTheMiddleOfEnteringANumber = NO;
}
- (void)viewDidUnload {
    [self setInputDisplay:nil];
    [self setVariablesDisplay:nil];
    [super viewDidUnload];
}
@end
