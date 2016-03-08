#import <XCTest/XCTest.h>
#import <WordPressApi.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHHTTPStubsResponse.h>

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
    [OHHTTPStubs removeAllStubs];
}

- (void)testGuessXMLRPCURLForSite {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Call should fail with erro when invoking with empty string"];
    [WordPressXMLRPCApi guessXMLRPCURLForSite:@"" success:^(NSURL *xmlrpcURL) {
    } failure:^(NSError *error) {
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testServerSide404Response
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Call should fail with error when server returns 404"];
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"mywordpresssite.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [[OHHTTPStubsResponse responseWithData:[NSData data] statusCode:404 headers:nil]
         responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];
    
    [WordPressApi signInWithURL:@"mywordpresssite.com"
                       username:@"username"
                       password:@"password"
                        success:^(NSURL *xmlrpcURL) {
                            XCTFail(@"Call to site returning a 404 should not enter success block.");
                        } failure:^(NSError *error) {
                            XCTAssertNotNil(error);
                            XCTAssertTrue([error.userInfo[@"NSLocalizedDescription"] rangeOfString:@"404"].location != NSNotFound);
                            [expectation fulfill];
                        }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
