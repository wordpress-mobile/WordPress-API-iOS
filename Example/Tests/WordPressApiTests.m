#import <XCTest/XCTest.h>
#import <WordPressApi.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHHTTPStubsResponse.h>

@interface WordPressApiTests : XCTestCase

@end


@implementation WordPressApiTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [OHHTTPStubs removeAllStubs];
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
    
    [self waitForExpectationsWithTimeout:3 handler:nil];
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
    __block NSURL *urlToCheck = nil;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Call should succeed when server returns 301 and has valid location defined in the response header"];
    NSString *hostName = @"mywordpresssite.com";
    NSString *originalURL = [@"http://" stringByAppendingString:hostName];
    NSString *redirectedURL = [@"https://" stringByAppendingString:hostName];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [[request.URL absoluteString] isEqualToString:originalURL];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSURL *mockDataURL = [bundle URLForResource:@"redirect" withExtension:@"html"];
        NSData *mockData = [NSData dataWithContentsOfURL:mockDataURL];
        return [[OHHTTPStubsResponse responseWithData:mockData statusCode:301 headers:@{@"Location": redirectedURL}]
                responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString isEqualToString:redirectedURL];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSURL *mockDataURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"system_list_methods" withExtension:@"xml"];
        NSData *mockData = [NSData dataWithContentsOfURL:mockDataURL];
        return [[OHHTTPStubsResponse responseWithData:mockData statusCode:200 headers:nil]
                responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];
    
    [WordPressApi signInWithURL:originalURL
                       username:@"username"
                       password:@"password"
                        success:^(NSURL *xmlrpcURL) {
                            [expectation fulfill];
                            urlToCheck = xmlrpcURL;                            
                        } failure:^(NSError *error) {
                            XCTFail(@"Call to site returning a valid 301 should not enter failure block.");
                        }];
    
    [self waitForExpectationsWithTimeout:3 handler:nil];
    XCTAssertNotNil(urlToCheck, @"Expected to receive a URL object in the success block.");
    XCTAssertFalse([[urlToCheck absoluteString] isEqualToString:originalURL], @"Did not expect the success block URL and original URL to match");
    XCTAssertTrue([[urlToCheck absoluteString] isEqualToString:redirectedURL], @"Expected the success block URL and redirected URL to match");
}

- (void)testServerSide301ResponseWithNoLocation
{
    __block NSError *errorToCheck = nil;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Call should fail with error when server returns 301 and no location response header"];
    NSString *hostName = @"mywordpresssite.com";
    NSString *baseURL = [@"http://" stringByAppendingString:hostName];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [[request.URL absoluteString] isEqualToString:baseURL];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [[OHHTTPStubsResponse responseWithData:[NSData data] statusCode:301 headers:nil]
                responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];
    
    [WordPressApi signInWithURL:baseURL
                       username:@"username"
                       password:@"password"
                        success:^(NSURL *xmlrpcURL) {
                            XCTFail(@"Call to site returning a 301 should not enter success block.");
                        } failure:^(NSError *error) {
                            [expectation fulfill];
                            errorToCheck = error;
                        }];
    
    [self waitForExpectationsWithTimeout:3 handler:nil];
    XCTAssertNotNil(errorToCheck, @"Expected to get a error object");
    XCTAssertNotNil(errorToCheck.userInfo, @"Expected to get a user info object in the error");
    XCTAssertTrue([errorToCheck.userInfo[@"NSLocalizedDescription"] rangeOfString:@"301"].location != NSNotFound, @"Expected to get a 301 in the error description");
    
    NSHTTPURLResponse *httpResponse = errorToCheck.userInfo[@"com.alamofire.serialization.response.error.response"];
    XCTAssertNotNil(httpResponse, @"Expected to receive a HTTP response object in the error");
    XCTAssertEqual(httpResponse.statusCode, 301, @"Expected the status code in the response to be a 301");
    NSURLComponents *httpResponseURLComponents = [NSURLComponents componentsWithURL:httpResponse.URL resolvingAgainstBaseURL:YES];
    XCTAssertNotNil(httpResponseURLComponents, @"Expected to receive a URL object in the response");
    XCTAssertTrue([[httpResponseURLComponents.URL absoluteString] isEqualToString:baseURL], @"Expected the response hostname and original hostname to match");
    
    NSURLComponents *errorURLComponents = errorToCheck.userInfo[@"NSErrorFailingURLKey"];
    XCTAssertNotNil(errorURLComponents, @"Expected to receive a URL object in the error");
    XCTAssertTrue([errorURLComponents.host isEqualToString:hostName], @"Expected the error hostname and original hostname to match");
}

@end
