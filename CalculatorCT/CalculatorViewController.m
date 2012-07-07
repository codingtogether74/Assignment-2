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

@property (nonatomic)BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic)BOOL userAlreadyEnteredADecimalPoint;
- (void)appendStringToHistroyDisplay:(NSString *)stringToAppend :(BOOL)isOperation;
@end

@implementation CalculatorViewController
@synthesize display = _display;
@synthesize displayStack = _displayStack;
@synthesize userIsInTheMiddleOfEnteringANumber=_userIsInTheMiddleOfEnteringANumber;
@synthesize userAlreadyEnteredADecimalPoint=_userAlreadyEnteredADecimalPoint;

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
    //  ---------- task " . "--------------   
    self.userAlreadyEnteredADecimalPoint=NO;                  
    //  -----------display Stack-----------
    [self appendStringToHistroyDisplay:self.display.text :NO];
     
}
- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *operation=sender.currentTitle;
    double result=[self.brain performOperation:operation];
    self.display.text=[NSString stringWithFormat:@"%g",result];
     
//  ----------------------task "Display stack" ----------------------------------
    NSString *stringToAdd=@"";
    stringToAdd = [stringToAdd stringByAppendingString:operation]; 
//    stringToAdd = [stringToAdd stringByAppendingString:@" "];  
//    stringToAdd = [stringToAdd stringByAppendingString:self.display.text];       

    [self appendStringToHistroyDisplay:stringToAdd :YES];
//--------------------------------------------------------------------------------
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
    self.displayStack.text = @"";
    [self.brain ClearStack];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userAlreadyEnteredADecimalPoint = NO;
}
- (IBAction)plusMinusPressed:(id)sender {
    // -------- change sign on display-----------------
    self.display.text = [NSString stringWithFormat:@"%g", 
                         -[self.display.text doubleValue]];
    
    //--------------- if user not entering a number, send to stack
    if (!self.userIsInTheMiddleOfEnteringANumber) {
        [self operationPressed:sender];
    }

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
- (void)appendStringToHistroyDisplay:(NSString *)stringToAppend :(BOOL) isOperation {
    
    NSString *history = self.displayStack.text;
    int       histlen = [history length];
    int       delta   = histlen+[stringToAppend length]-MAX_COUNT;
    if (delta>0){
        history=[history substringFromIndex:(delta+1)];
        self.displayStack.text=history;
    }
    
    self.displayStack.text = [self.displayStack.text stringByAppendingString:stringToAppend];        
    if (isOperation) {
    // -----------------  Remove "=" in displayStack --------------
        self.displayStack.text = [self.displayStack.text stringByReplacingOccurrencesOfString:@"=" withString:@" "];   
        self.displayStack.text = [self.displayStack.text stringByAppendingString:@"= "]; 
    } else {
        self.displayStack.text = [self.displayStack.text stringByAppendingString:@" "]; 
    }
    
}


@end
