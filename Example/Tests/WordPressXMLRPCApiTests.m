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

- (void)testServerSide301Response
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Call should succeed when server returns 301 and has valid location defined in the response header"];
    NSString *originalHost = @"mywordpresssite.com";
    NSString *redirectedHost = @"mywordpresssiteredirected.com";
    NSString *redirectedHostFull = [NSString stringWithFormat:@"http://%@", redirectedHost];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return ([request.URL.host isEqualToString:originalHost] || [request.URL.host isEqualToString:redirectedHost]);
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        if ([request.URL.host isEqualToString:originalHost]) {
            return [[OHHTTPStubsResponse responseWithData:[NSData data] statusCode:301 headers:@{@"Location":redirectedHostFull}]
                    responseTime:OHHTTPStubsDownloadSpeedWifi];
        } else if ([request.URL.host isEqualToString:redirectedHost]) {
            //TODO: Stub in real response from valid login
            return [[OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil]
                    responseTime:OHHTTPStubsDownloadSpeedWifi];
        } else {
            return nil;
        }
    }];
    
    [WordPressApi signInWithURL:@"mywordpresssite.com"
                       username:@"username"
                       password:@"password"
                        success:^(NSURL *xmlrpcURL) {
                            [expectation fulfill];
                        } failure:^(NSError *error) {
                            XCTFail(@"Call to site returning a 301 should not enter failure block.");
                        }];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];

}

- (void)testServerSide301ResponseWithNoLocation
{
    __block NSError *errorToCheck = nil;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Call should fail with error when server returns 301 and no location response header"];
    NSString *originalHost = @"mywordpresssite.com";
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:originalHost];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [[OHHTTPStubsResponse responseWithData:[NSData data] statusCode:301 headers:nil]
                responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];
    
    [WordPressApi signInWithURL:@"mywordpresssite.com"
                       username:@"username"
                       password:@"password"
                        success:^(NSURL *xmlrpcURL) {
                            XCTFail(@"Call to site returning a 301 should not enter success block.");
                        } failure:^(NSError *error) {
                            [expectation fulfill];
                            errorToCheck = error;
                        }];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
    XCTAssertNotNil(errorToCheck, @"Expected to get a error object");
    XCTAssertNotNil(errorToCheck.userInfo, @"Expected to get a user info object in the error");
    XCTAssertTrue([errorToCheck.userInfo[@"NSLocalizedDescription"] rangeOfString:@"301"].location != NSNotFound, @"Expected to get a 301 in the error description");
    
    NSHTTPURLResponse *httpResponse = errorToCheck.userInfo[@"com.alamofire.serialization.response.error.response"];
    XCTAssertNotNil(httpResponse, @"Expected to receive a HTTP response object in the error");
    XCTAssertEqual(httpResponse.statusCode, 301, @"Expected the status code in the response to be a 301");
    NSURLComponents *httpResponseURLComponents = [NSURLComponents componentsWithURL:httpResponse.URL resolvingAgainstBaseURL:YES];
    XCTAssertNotNil(httpResponseURLComponents, @"Expected to receive a URL object in the response");
    XCTAssertTrue([originalHost isEqualToString:httpResponseURLComponents.host], @"Expected the response hostname and original hostname to match");
    
    NSURLComponents *errorURLComponents = errorToCheck.userInfo[@"NSErrorFailingURLKey"];
    XCTAssertNotNil(errorURLComponents, @"Expected to receive a URL object in the error");
    XCTAssertTrue([originalHost isEqualToString:errorURLComponents.host], @"Expected the error hostname and original hostname to match");
}

@end
