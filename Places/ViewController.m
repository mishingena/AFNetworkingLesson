//
//  ViewController.m
//  Places
//
//  Created by azat on 28/11/15.
//  Copyright © 2015 azat. All rights reserved.
//

#import "ViewController.h"
#import "PLCGoogleMapService.h"
#import <MBProgressHUD.h>
#import "PLCPlace.h"
#import "PLCPlaceCell.h"

@interface ViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) PLCGoogleMapService *mapService;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 80.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.searchBar.delegate = self;
    self.mapService = [[PLCGoogleMapService alloc] init];
}

- (void)showAlertWithText:(NSString *)text {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Ошибка" message:text preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"Закрыть" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    self.items = nil;
    [self.tableView reloadData];
    [self loadPlacesWithText:searchBar.text];
}

- (void)loadPlacesWithText:(NSString *)text {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.mapService getPlacesByTextSearch:text success:^(NSArray *result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.items = result;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self showAlertWithText:error.localizedDescription];
    }];
}

- (void)loadImageForPlace:(PLCPlace *)place {
    if (place.imageURL) {
        [self.mapService getPlacePhotoWithReference:place.imageURL success:^(UIImage *image) {
            place.image = image;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            [self showAlertWithText:error.localizedDescription];
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLCPlaceCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PlaceCell"];
    
    PLCPlace *place = self.items[indexPath.row];
    cell.placeTextLabel.text = place.name;
    
    if (!place.image) {
        [self loadImageForPlace:place];
    } else {
        cell.placeImageView.image = place.image;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

@end
