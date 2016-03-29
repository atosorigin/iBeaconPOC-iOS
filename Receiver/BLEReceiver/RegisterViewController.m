//
//  RegisterViewController.m
//  BLEReceiver
//
//  Created by Mike Williams on 29/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

- (IBAction)registerPressed:(id)sender;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)registerPressed:(id)sender {
    
    [self performSegueWithIdentifier:@"register" sender:nil];
}



@end

