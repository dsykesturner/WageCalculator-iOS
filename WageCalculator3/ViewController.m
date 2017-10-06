//
//  ViewController.m
//  WageCalculator3
//
//  Created by Daniel Sykes-Turner on 6/10/17.
//  Copyright © 2017 UniverseApps. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,weak) IBOutlet UILabel *lblHourlyRate;
@property (nonatomic,weak) IBOutlet UILabel *lblHoursWorked;
@property (nonatomic,weak) IBOutlet UILabel *lblMinutesWorked;
@property (nonatomic,weak) IBOutlet UILabel *lblTotalPay;
@property (nonatomic,weak) IBOutlet UIView *vwHourlyRate;
@property (nonatomic,weak) IBOutlet UIView *vwHoursWorked;
@property (nonatomic,weak) IBOutlet UIView *vwMinutesWorked;
@property (nonatomic,weak) IBOutlet UIView *vwTotalPay;

@property (nonatomic) enum {HourlyRateType,HoursWorkedType,MinutesWorkedType,TotalPayType} currentTypeFocus; // which label is keyboard active (default = hourly rate)
@property (nonatomic) enum {NoneCalc,HourlyRateCalc,WorkedCalc,TotalPayCalc} currentCalculationFocus; // which label is being calculated active (default = total rate)

@property (nonatomic) BOOL decimalToggle; // we are before or after the decimal place
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkAndDisplayHelp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkAndDisplayHelp {
    
    BOOL isSetup = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSetup"];
    if (!isSetup) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Hey There 👋" message:@"\nThanks for downloading Wage Calculator ❤️💰\n\nTo calculate a value, leave any row as 0 and enter values for the other two.\n\nTap a row to clear and edit it." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"isSetup"];
        }]];
        [self presentViewController:alert animated:true completion:nil];
    }
}

- (void)performAutoCalculate {
    
    double hourlyRate = [self getHourlyRate];
    double hoursWorked = [self getHoursWorked];
    double minutesWorked = [self getMinutesWorked];
    double totalPay = [self getTotalPay];
    
    switch (self.currentCalculationFocus) {
        case HourlyRateCalc:
            self.vwHourlyRate.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            break;
        case WorkedCalc:
            self.vwHoursWorked.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            self.vwMinutesWorked.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            break;
        case TotalPayCalc:
            self.vwTotalPay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            break;
        default:
            break;
    }
    
    if ((totalPay == 0 && (hoursWorked != 0 || minutesWorked != 0)) || self.currentCalculationFocus == TotalPayCalc) {
        self.currentCalculationFocus = TotalPayCalc;
        totalPay = hourlyRate * (hoursWorked + minutesWorked/60);
        self.lblTotalPay.text = [NSString stringWithFormat:@"%0.2lf", totalPay];
        self.vwTotalPay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
    } else if (((hoursWorked == 0 && minutesWorked == 0) || self.currentCalculationFocus == WorkedCalc) && hourlyRate != 0) {
        self.currentCalculationFocus = WorkedCalc;
        hoursWorked = (int)(totalPay / hourlyRate);
        minutesWorked = (totalPay / hourlyRate - hoursWorked) * 60;
        self.lblHoursWorked.text = [NSString stringWithFormat:@"%0.0lf", hoursWorked];
        self.lblMinutesWorked.text = [NSString stringWithFormat:@"%0.0lf", minutesWorked];
        self.vwHoursWorked.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
        self.vwMinutesWorked.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
    } else if ((hourlyRate == 0 || self.currentCalculationFocus == HourlyRateCalc) && (hoursWorked != 0 || minutesWorked != 0)) {
        self.currentCalculationFocus = HourlyRateCalc;
        hourlyRate = totalPay / (hoursWorked + minutesWorked/60);
        self.lblHourlyRate.text = [NSString stringWithFormat:@"%0.2lf", hourlyRate];
        self.vwHourlyRate.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
    }
}

#pragma - Label Value Getters

- (double)getHourlyRate {
    return self.lblHourlyRate.text.doubleValue;
}

- (double)getHoursWorked {
    return self.lblHoursWorked.text.doubleValue;
}

- (double)getMinutesWorked {
    return self.lblMinutesWorked.text.doubleValue;
}

- (double)getTotalPay {
    return self.lblTotalPay.text.doubleValue;
}

#pragma - Button Actions

- (IBAction)setFocus:(UIButton *)button {
    NSString *btnTitle = button.titleLabel.text;
    
    switch (self.currentTypeFocus) {
        case HourlyRateType:
            self.vwHourlyRate.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            break;
        case HoursWorkedType:
            self.vwHoursWorked.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            break;
        case MinutesWorkedType:
            self.vwMinutesWorked.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            break;
        case TotalPayType:
            self.vwTotalPay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            break;
        default:
            break;
    }
    
    if ([btnTitle isEqualToString:@"hourly rate"]) {
        self.currentTypeFocus = HourlyRateType;
        self.lblHourlyRate.text = @"0.00";
        self.vwHourlyRate.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        if (self.currentCalculationFocus == HourlyRateCalc) self.currentCalculationFocus = NoneCalc;
    } else if ([btnTitle isEqualToString:@"hours worked"]) {
        self.currentTypeFocus = HoursWorkedType;
        self.lblHoursWorked.text = @"0";
        self.vwHoursWorked.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        self.vwMinutesWorked.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        if (self.currentCalculationFocus == WorkedCalc) self.currentCalculationFocus = NoneCalc;
    } else if ([btnTitle isEqualToString:@"minutes worked"]) {
        self.currentTypeFocus = MinutesWorkedType;
        self.lblMinutesWorked.text = @"0";
        self.vwHoursWorked.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.vwMinutesWorked.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        if (self.currentCalculationFocus == WorkedCalc) self.currentCalculationFocus = NoneCalc;
    } else if ([btnTitle isEqualToString:@"total pay"]) {
        self.currentTypeFocus = TotalPayType;
        self.lblTotalPay.text = @"0.00";
        self.vwTotalPay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        if (self.currentCalculationFocus == TotalPayCalc) self.currentCalculationFocus = NoneCalc;
    }
}

- (IBAction)numberTapped:(UIButton *)button {
    
    double tappedValue = button.titleLabel.text.doubleValue;
    
    // Validate the maximum number of characters (soft limit) of 17
    switch (self.currentTypeFocus) {
        case HourlyRateType:
            if (self.lblHourlyRate.text.length >= 12) return;
            break;
        case HoursWorkedType:
            if (self.lblHoursWorked.text.length >= 6) return;
            break;
        case MinutesWorkedType:
            if (self.lblMinutesWorked.text.length >= 6) return;
            break;
        case TotalPayType:
            if (self.lblTotalPay.text.length >= 12) return;
            break;
        default:
            break;
    }
    
    // Handle decimal vs standard digit insertion
    if (self.decimalToggle) {
        switch (self.currentTypeFocus) {
            case HourlyRateType:
                self.lblHourlyRate.text = [NSString stringWithFormat:@"%0.2lf", (int)[self getHourlyRate] + ([self getHourlyRate] - (int)[self getHourlyRate])*10 + tappedValue/100];
                break;
            case HoursWorkedType:
                self.lblHoursWorked.text = [NSString stringWithFormat:@"%g", (int)[self getHoursWorked] + ([self getHoursWorked] - (int)[self getHoursWorked])*10 + tappedValue/100];
                break;
            case MinutesWorkedType:
                self.lblMinutesWorked.text = [NSString stringWithFormat:@"%g", (int)[self getMinutesWorked] + ([self getMinutesWorked] - (int)[self getMinutesWorked])*10 + tappedValue/100];
                break;
            case TotalPayType:
                self.lblTotalPay.text = [NSString stringWithFormat:@"%0.2lf", (int)[self getTotalPay] + ([self getTotalPay] - (int)[self getTotalPay])*10 + tappedValue/100];
                break;
            default:
                break;
        }
    } else {
        switch (self.currentTypeFocus) {
            case HourlyRateType:
                self.lblHourlyRate.text = [NSString stringWithFormat:@"%0.2lf", (int)[self getHourlyRate]*10 + ([self getHourlyRate] - (int)[self getHourlyRate]) + tappedValue];
                break;
            case HoursWorkedType:
                self.lblHoursWorked.text = [NSString stringWithFormat:@"%g", (int)[self getHoursWorked]*10 + ([self getHoursWorked] - (int)[self getHoursWorked]) + tappedValue];
                break;
            case MinutesWorkedType:
                self.lblMinutesWorked.text = [NSString stringWithFormat:@"%g", (int)[self getMinutesWorked]*10 + ([self getMinutesWorked] - (int)[self getMinutesWorked]) + tappedValue];
                break;
            case TotalPayType:
                self.lblTotalPay.text = [NSString stringWithFormat:@"%0.2lf", (int)[self getTotalPay]*10 + ([self getTotalPay] - (int)[self getTotalPay]) + tappedValue];
                break;
            default:
                break;
        }
    }
    
    [self performAutoCalculate];
}

- (IBAction)decimal:(UIButton *)button {
    self.decimalToggle = !self.decimalToggle;
    
    if (self.decimalToggle) {
        button.alpha = 0.5;
    } else {
        button.alpha = 1;
    }
}

@end
