#import <XCTest/XCTest.h>
#import <WordPressApi.h>

@interface WordPressXMLRPCApiTests : XCTestCase

@end

@implementation WordPressXMLRPCApiTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGuessXMLRPCURLForSite {
    __block NSError *errorToCheck = nil;
    XCTestExpectation *expectationEmpty = [self expectationWithDescription:@"Call should fail with error when invoking with empty string"];
    [WordPressXMLRPCApi guessXMLRPCURLForSite:@"" success:^(NSURL *xmlrpcURL) {
    } failure:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
        [expectationEmpty fulfill];
        errorToCheck = error;
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    XCTAssertTrue(errorToCheck.domain == WordPressXMLRPCApiErrorDomain, @"Expected to get an WordPressXMLRPCApiErrorDomain error");
    XCTAssertTrue(errorToCheck.code == WordPressXMLRPCApiEmptyURL, @"Expected to get an WordPressXMLRPCApiEmptyURL error");

    XCTestExpectation *expectationNil = [self expectationWithDescription:@"Call should fail with error when invoking with nil string"];
    [WordPressXMLRPCApi guessXMLRPCURLForSite:nil success:^(NSURL *xmlrpcURL) {
    } failure:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
        [expectationNil fulfill];
        errorToCheck = error;
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    XCTAssertTrue(errorToCheck.domain == WordPressXMLRPCApiErrorDomain, @"Expected to get an WordPressXMLRPCApiErrorDomain error");
    XCTAssertTrue(errorToCheck.code == WordPressXMLRPCApiEmptyURL, @"Expected to get an WordPressXMLRPCApiEmptyURL error");

    XCTestExpectation *expectationJustSpaces = [self expectationWithDescription:@"Call should fail with error when invoking with empty string"];
    [WordPressXMLRPCApi guessXMLRPCURLForSite:@"   " success:^(NSURL *xmlrpcURL) {
    } failure:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
        [expectationJustSpaces fulfill];
        errorToCheck = error;
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    XCTAssertTrue(errorToCheck.domain == WordPressXMLRPCApiErrorDomain, @"Expected to get an WordPressXMLRPCApiErrorDomain error");
    XCTAssertTrue(errorToCheck.code == WordPressXMLRPCApiEmptyURL, @"Expected to get an WordPressXMLRPCApiEmptyURL error");

}

@end
