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
- (double)calculateProgram;
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
//    self.userIsInTheMiddleOfEnteringANumber=NO;
    self.userAlreadyEnteredADecimalPoint=NO; 
//    self.inputDisplay.text = [self.brain description];
    [self synchronizeView];      
     
}
- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *operation=sender.currentTitle;
    double result=[self.brain performOperation:operation];
   self.display.text=[NSString stringWithFormat:@"%g",result];     
   self.inputDisplay.text = [self.brain description];
 //   [self synchronizeView];      

}
- (IBAction)variablePressed:(UIButton *)sender {
	[self.brain pushVariable:sender.currentTitle];
    [self synchronizeView];      
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
        self.testVariablesValue = [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"x", @"7.26", @"a", @"-1", @"b", nil];
    } else if ([testNumber isEqualToString:@"3"]) {
        self.testVariablesValue = nil;
    }
    [self synchronizeView];      
}


- (IBAction)itestPressed:(id)sender {
    CalculatorBrain *testBrain = [self brain];
/*    
    // Setup the brain
    [testBrain pushVariable:@"a"];
    [testBrain pushVariable:@"a"];
    [testBrain pushOperation:@"*"];
    [testBrain pushVariable:@"b"];
    [testBrain pushVariable:@"b"];
    [testBrain pushOperation:@"*"];
    [testBrain pushOperation:@"+"];
    [testBrain pushOperation:@"√"];  
    
    // Retrieve the program
    NSArray *program = testBrain.program;
    
    // Setup the dictionary
    NSDictionary *dictionary = 
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithDouble:3], @"a",
     [NSNumber numberWithDouble:4], @"b", nil];
    
    // Run the program with variables

    double res=[CalculatorBrain runProgram:program usingVariableValues:dictionary];
    NSLog(@"Running the program with variables returns the value %g",res);
    // List the variables in program 
    NSLog(@"Variables in program are %@", 
          [[CalculatorBrain variablesUsedInProgram:program] description]);        

    // Test a
    [testBrain pushOperand:3];
    [testBrain pushOperand:5];
    [testBrain pushOperand:6];
    [testBrain pushOperand:7];
    [testBrain pushOperation:@"+"];
    [testBrain pushOperation:@"*"];
    [testBrain pushOperation:@"-"];
*/    
   // Test b
    [testBrain pushOperand:3];
    [testBrain pushOperand:5];
    [testBrain pushOperation:@"+"];
    [testBrain pushOperation:@"√"];
    
/*    // Test c
    //[testBrain empty];
    [testBrain pushOperand:3];
    [testBrain pushOperation:@"sqrt"];
    [testBrain pushOperation:@"sqrt"];
    
    // Test d
    [testBrain pushOperand:3];
    [testBrain pushOperand:5];
    [testBrain pushOperation:@"sqrt"];
    [testBrain pushOperation:@"+"];
    
    // Test e
    [testBrain pushOperation:@"?"];
    [testBrain pushVariable:@"r"];
    [testBrain pushVariable:@"r"];
    [testBrain pushOperation:@"*"];
    [testBrain pushOperation:@"*"];
    
    // Test f
    [testBrain pushVariable:@"a"];
    [testBrain pushVariable:@"a"];
    [testBrain pushOperation:@"*"];
    [testBrain pushVariable:@"b"];
    [testBrain pushVariable:@"b"];
    [testBrain pushOperation:@"*"];
    [testBrain pushOperation:@"+"];
    [testBrain pushOperation:@"sqrt"];
 */   
    //Print the description
    NSLog(@"Program is :%@",[CalculatorBrain descriptionOfProgram:[testBrain program]]);

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

- (double)calculateProgram {
    if (!self.testVariablesValue) {
        return [[self.brain class] runProgram:self.brain.program];
    } else {
        return [[self.brain class] runProgram:self.brain.program usingVariableValues:self.testVariablesValue];
    }
    
}

-(void)synchronizeView {   
 
    self.display.text = [NSString stringWithFormat:@"%g", [self calculateProgram]];
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
