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

- (void)testGuessXMLRPCURLForSiteForMalformedURLS {
    __block NSError *errorToCheck = nil;
    NSArray *malformedURLs = @[
                               @"mywordpresssite.com\test",
                               @"mywordpres ssite.com/test",
                               @"http:\\mywordpresssite.com/test"
                               ];
    for (NSString *malformedURL in malformedURLs) {
        XCTestExpectation *expectationMalFormedURL = [self expectationWithDescription:@"Call should fail with error when invoking with malformed urls"];
        [WordPressXMLRPCApi guessXMLRPCURLForSite:malformedURL success:^(NSURL *xmlrpcURL) {
        } failure:^(NSError *error) {
            [expectationMalFormedURL fulfill];
            errorToCheck = error;
        }];
        [self waitForExpectationsWithTimeout:2 handler:nil];
        XCTAssertTrue(errorToCheck.domain == WordPressXMLRPCApiErrorDomain, @"Expected to get an WordPressXMLRPCApiErrorDomain error");
        XCTAssertTrue(errorToCheck.code == WordPressXMLRPCApiInvalidURL, @"Expected to get an WordPressXMLRPCApiInvalidURL error");
    }
}

- (void)testServerSide404Response
{
    __block NSError *errorToCheck = nil;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Call should fail with error when server returns 404"];
    NSString *originalHost = @"mywordpresssite.com";
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:originalHost];
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
                            [expectation fulfill];
                            errorToCheck = error;
                        }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
    XCTAssertNotNil(errorToCheck, @"Expected to get a error object");
    XCTAssertNotNil(errorToCheck.userInfo, @"Expected to get a user info object in the error");
    XCTAssertTrue([errorToCheck.userInfo[@"NSLocalizedDescription"] rangeOfString:@"404"].location != NSNotFound, @"Expected to get a 404 in the error description");
    
    NSHTTPURLResponse *httpResponse = errorToCheck.userInfo[@"com.alamofire.serialization.response.error.response"];
    XCTAssertNotNil(httpResponse, @"Expected to receive a HTTP response object in the error");
    XCTAssertEqual(httpResponse.statusCode, 404, @"Expected the status code in the response to be a 404");
    NSURLComponents *httpResponseURLComponents = [NSURLComponents componentsWithURL:httpResponse.URL resolvingAgainstBaseURL:YES];
    XCTAssertNotNil(httpResponseURLComponents, @"Expected to receive a URL object in the response");
    XCTAssertTrue([originalHost isEqualToString:httpResponseURLComponents.host], @"Expected the response hostname and original hostname to match");
    
    NSURLComponents *errorURLComponents = errorToCheck.userInfo[@"NSErrorFailingURLKey"];
    XCTAssertNotNil(errorURLComponents, @"Expected to receive a URL object in the error");
    XCTAssertTrue([originalHost isEqualToString:errorURLComponents.host], @"Expected the error hostname and original hostname to match");
}

@end
