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

- (void)testGuessXMLRPCURLForSiteForEmptyURLs {
    __block NSError *errorToCheck = nil;
    NSArray *emptyURLs = @[
                               @"",
                               @"   ",
                               @"\t   ",
                               ];
    for (NSString *emptyURL in emptyURLs) {
        XCTestExpectation *expectationEmpty = [self expectationWithDescription:@"Call should fail with error when invoking with empty string"];
        [WordPressXMLRPCApi guessXMLRPCURLForSite:emptyURL success:^(NSURL *xmlrpcURL) {
        } failure:^(NSError *error) {
            NSLog(@"%@", [error localizedDescription]);
            [expectationEmpty fulfill];
            errorToCheck = error;
        }];
        [self waitForExpectationsWithTimeout:2 handler:nil];
        XCTAssertTrue(errorToCheck.domain == WordPressXMLRPCApiErrorDomain, @"Expected to get an WordPressXMLRPCApiErrorDomain error");
        XCTAssertTrue(errorToCheck.code == WordPressXMLRPCApiEmptyURL, @"Expected to get an WordPressXMLRPCApiEmptyURL error");
    }


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
}

- (void)testGuessXMLRPCURLForSiteForMalformedURLs {
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

- (void)testGuessXMLRPCURLForSiteForInvalidSchemes {
    __block NSError *errorToCheck = nil;
    NSArray *incorrectSchemes = @[
                               @"hppt://mywordpresssite.com/test",
                               @"ftp://mywordpresssite.com/test",
                               @"git://mywordpresssite.com/test"
                               ];
    for (NSString *incorrectScheme in incorrectSchemes) {
        XCTestExpectation *expectation = [self expectationWithDescription:@"Call should fail with error when invoking with urls with incorrect schemes"];
        [WordPressXMLRPCApi guessXMLRPCURLForSite:incorrectScheme success:^(NSURL *xmlrpcURL) {
        } failure:^(NSError *error) {
            [expectation fulfill];
            errorToCheck = error;
        }];
        [self waitForExpectationsWithTimeout:2 handler:nil];
        XCTAssertTrue(errorToCheck.domain == WordPressXMLRPCApiErrorDomain, @"Expected to get an WordPressXMLRPCApiErrorDomain error");
        XCTAssertTrue(errorToCheck.code == WordPressXMLRPCApiInvalidScheme, @"Expected to get an WordPressXMLRPCApiInvalidScheme error");
    }
}

- (void)testGuessXMLRPCURLForSiteForCorrectSchemes {

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"mywordpresssite.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSURL *mockDataURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"system_list_methods" withExtension:@"xml"];
        NSData *mockData = [NSData dataWithContentsOfURL:mockDataURL];
        return [[OHHTTPStubsResponse responseWithData:mockData statusCode:200 headers:nil]
                responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];

    NSArray *validSchemes = @[
                                  @"http://mywordpresssite.com",
                                  @"https://mywordpresssite.com",
                                  @"mywordpresssite.com",
                                  ];
    for (NSString *validScheme in validSchemes) {
        XCTestExpectation *expectation = [self expectationWithDescription:@"Call should be successful"];
        [WordPressXMLRPCApi guessXMLRPCURLForSite:validScheme success:^(NSURL *xmlrpcURL) {
            [expectation fulfill];
            XCTAssertTrue([xmlrpcURL.host isEqualToString:@"mywordpresssite.com"], @"Check if we are getting the corrent site in the answer");
            XCTAssertTrue([xmlrpcURL.path isEqualToString:@"/xmlrpc.php"], @"Check if we are getting the corrent path in the answer");
        } failure:^(NSError *error) {
            XCTFail(@"Call to valid site should not enter failure block.");
        }];
        [self waitForExpectationsWithTimeout:2 handler:nil];
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
