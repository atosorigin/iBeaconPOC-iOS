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
    
    [self prepopulateFields];
}

- (void)prepopulateFields {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedEmail = [defaults stringForKey:kSavedEmailKey];
    NSString *savedUsername = [defaults stringForKey:kSavedUsernameKey];
    
    if (savedEmail != nil && [savedEmail length] > 0) {
        _emailTextField.text = savedEmail;
    }
    
    if (savedUsername != nil && [savedUsername length] > 0) {
        _usernameTextField.text = savedUsername;
    }
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
    
    [self registerUser];
    
}

- (void)registerUser {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *email = _emailTextField.text;
    NSString *username = _usernameTextField.text;
    
    //post to URL to register this device but also save the last user to userdefaults
    [[UploadManager sharedInstance] registerUserWithEmail:email username:username success:^{
        NSLog(@"user is registered");
        
        [defaults setObject:email forKey:kSavedEmailKey];
        [defaults setObject:username forKey:kSavedUsernameKey];
        
        [defaults synchronize];
        
        [[UploadManager sharedInstance] retrieveLocationMapSuccess:^(UIImage *map) {
            
            NSLog(@"Retrieved Map: %@", map);
            
            [self performSegueWithIdentifier:@"register" sender:nil];
            
        } failure:^(NSError *error) {
            
            NSLog(@"map download failed %@", error);
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"Failed to download mapping information."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"registration failed %@", error);
       
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Failed to register device."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];

    }];
    
}



@end

