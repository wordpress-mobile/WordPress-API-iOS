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
    XCTestExpectation *expectation = [self expectationWithDescription:@"Call should fail with erro when invoking with empty string"];
    [WordPressXMLRPCApi guessXMLRPCURLForSite:@"" success:^(NSURL *xmlrpcURL) {
    } failure:^(NSError *error) {
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

@end
