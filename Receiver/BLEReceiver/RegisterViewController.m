//
//  RegisterViewController.m
//  BLEReceiver
//
//  Created by Mike Williams on 29/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import "RegisterViewController.h"
#import "BeaconLocationManager.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UIButton *buttonRegister;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

- (IBAction)registerPressed:(id)sender;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepopulateFields];
}

- (void)viewDidAppear:(BOOL)animated {
    
    //check the beaconLocationManager isn't running - it might be if we've come back from the Events page.
    //this is fine to do as it won't do anything if it isn't configured/running
    [[BeaconLocationManager sharedInstance] stopMonitoring];

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

- (IBAction)registerPressed:(id)sender {
    
    [self.view endEditing:YES];
    [_loadingIndicator setHidden:NO];
    [_buttonRegister setEnabled:NO];
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
        
        [[UploadManager sharedInstance] retrieveLocationMapWithSuccess:^(UIImage *map) {
            
            NSLog(@"Retrieved Map: %@", map);
            
            [_loadingIndicator setHidden:YES];
            [_buttonRegister setEnabled:YES];
            
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

