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
                                  @"http://mywordpresssite.com/xmlrpc.php",
                                  @"https://mywordpresssite.com/xmlrpc.php",
                                  @"mywordpresssite.com/xmlrpc.php",
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

- (void)testGuessXMLRPCURLForSiteForAdditionOfXMLRPC {

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"mywordpresssite.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSURL *mockDataURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"system_list_methods" withExtension:@"xml"];
        NSData *mockData = [NSData dataWithContentsOfURL:mockDataURL];
        return [[OHHTTPStubsResponse responseWithData:mockData statusCode:200 headers:nil]
                responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];

    NSArray *URLs = @[
                              @"http://mywordpresssite.com",
                              @"https://mywordpresssite.com",
                              @"mywordpresssite.com",
                              @"mywordpresssite.com/blog1",
                              @"mywordpresssite.com/xmlrpc.php",
                              @"mywordpresssite.com/xmlrpc.php?test=test"
                              ];
    for (NSString *url in URLs) {
        XCTestExpectation *expectation = [self expectationWithDescription:@"Call should be successful"];
        [WordPressXMLRPCApi guessXMLRPCURLForSite:url success:^(NSURL *xmlrpcURL) {
            [expectation fulfill];
            XCTAssertTrue([xmlrpcURL.host isEqualToString:@"mywordpresssite.com"], @"Resolved host doens't match original url: %@", url);
            XCTAssertTrue([[xmlrpcURL lastPathComponent] isEqualToString:@"xmlrpc.php"], @"Resolved last path component doens't match original url: %@", url);
            XCTAssertTrue([xmlrpcURL query] == nil || [[xmlrpcURL query] isEqualToString:@"test=test"], @"Resolved query components doens't match original url: %@", url);
        } failure:^(NSError *error) {
            XCTFail(@"Call to valid site should not enter failure block.");
        }];
        [self waitForExpectationsWithTimeout:2 handler:nil];
    }

}

- (void)testGuessXMLRPCURLForSiteForFallbackToOriginalURL {
    NSString *originalURL = @"http://mywordpresssite.com/rpc";
    NSString *appendedURL = [originalURL stringByAppendingString:@"/xmlrpc.php"];

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString isEqualToString:originalURL];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSURL *mockDataURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"system_list_methods" withExtension:@"xml"];
        NSData *mockData = [NSData dataWithContentsOfURL:mockDataURL];
        return [[OHHTTPStubsResponse responseWithData:mockData statusCode:200 headers:nil]
                responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [[request.URL absoluteString] isEqualToString:appendedURL];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [[OHHTTPStubsResponse responseWithData:[NSData data] statusCode:403 headers:nil]
                responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];


    XCTestExpectation *expectation = [self expectationWithDescription:@"Call should be successful"];
    [WordPressXMLRPCApi guessXMLRPCURLForSite:originalURL success:^(NSURL *xmlrpcURL) {
        [expectation fulfill];
        XCTAssertTrue([xmlrpcURL.absoluteString isEqualToString:originalURL], @"Resolved url doens't match original url: %@", originalURL);
    } failure:^(NSError *error) {
        XCTFail(@"Call to valid site should not enter failure block.");
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testGuessXMLRPCURLForSiteForFallbackToStandardRSD {
    NSString *baseURL = @"http://mywordpresssite.com";
    NSString *htmlURL = [baseURL stringByAppendingString:@"wp-login"];
    NSString *appendedURL = [htmlURL stringByAppendingString:@"/xmlrpc.php"];
    NSString *xmlRPCURL = [baseURL stringByAppendingString:@"/xmlrpc.php"];
    NSString *rsdURL = [xmlRPCURL stringByAppendingString:@"?rsd"];

    // Fail first request with 403
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [[request.URL absoluteString] isEqualToString:appendedURL];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [[OHHTTPStubsResponse responseWithData:[NSData data] statusCode:403 headers:nil]
                responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];

    // Return html page for original url
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString isEqualToString:htmlURL];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSURL *mockDataURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"html_page_with_link_to_rsd" withExtension:@"html"];
        NSData *mockData = [NSData dataWithContentsOfURL:mockDataURL];
        return [[OHHTTPStubsResponse responseWithData:mockData statusCode:200 headers:nil]
                responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];

    // Return rsd xml
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString isEqualToString:rsdURL];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSURL *mockDataURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"rsd" withExtension:@"xml"];
        NSData *mockData = [NSData dataWithContentsOfURL:mockDataURL];
        return [[OHHTTPStubsResponse responseWithData:mockData statusCode:200 headers:nil]
                responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString isEqualToString:xmlRPCURL];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSURL *mockDataURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"system_list_methods" withExtension:@"xml"];
        NSData *mockData = [NSData dataWithContentsOfURL:mockDataURL];
        return [[OHHTTPStubsResponse responseWithData:mockData statusCode:200 headers:nil]
                responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Call should be successful"];
    [WordPressXMLRPCApi guessXMLRPCURLForSite:htmlURL success:^(NSURL *xmlrpcURL) {
        [expectation fulfill];
        XCTAssertTrue([xmlrpcURL.absoluteString isEqualToString:xmlRPCURL], @"Resolved url doens't match original url: %@", xmlRPCURL);
    } failure:^(NSError *error) {
        XCTFail(@"Call to valid site should not enter failure block.");
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testGuessXMLRPCURLForSiteForFallbackToNonStandardRSD {
    NSString *baseURL = @"http://mywordpresssite.com";
    NSString *htmlURL = [baseURL stringByAppendingString:@"wp-login"];
    NSString *appendedURL = [htmlURL stringByAppendingString:@"/xmlrpc.php"];
    NSString *xmlRPCURL = [baseURL stringByAppendingString:@"/xmlrpc.php"];
    NSString *rsdURL = [baseURL stringByAppendingString:@"/rsd.php"];

    // Fail first request with 403
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [[request.URL absoluteString] isEqualToString:appendedURL];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [[OHHTTPStubsResponse responseWithData:[NSData data] statusCode:403 headers:nil]
                responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];

    // Return html page for original url
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString isEqualToString:htmlURL];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSURL *mockDataURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"html_page_with_link_to_rsd_non_standard" withExtension:@"html"];
        NSData *mockData = [NSData dataWithContentsOfURL:mockDataURL];
        return [[OHHTTPStubsResponse responseWithData:mockData statusCode:200 headers:nil]
                responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];

    // Return rsd xml
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString isEqualToString:rsdURL];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSURL *mockDataURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"rsd" withExtension:@"xml"];
        NSData *mockData = [NSData dataWithContentsOfURL:mockDataURL];
        return [[OHHTTPStubsResponse responseWithData:mockData statusCode:200 headers:nil]
                responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString isEqualToString:xmlRPCURL];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSURL *mockDataURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"system_list_methods" withExtension:@"xml"];
        NSData *mockData = [NSData dataWithContentsOfURL:mockDataURL];
        return [[OHHTTPStubsResponse responseWithData:mockData statusCode:200 headers:nil]
                responseTime:OHHTTPStubsDownloadSpeedWifi];
    }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Call should be successful"];
    [WordPressXMLRPCApi guessXMLRPCURLForSite:htmlURL success:^(NSURL *xmlrpcURL) {
        [expectation fulfill];
        XCTAssertTrue([xmlrpcURL.absoluteString isEqualToString:xmlRPCURL], @"Resolved url doens't match original url: %@", xmlRPCURL);
    } failure:^(NSError *error) {
        XCTFail(@"Call to valid site should not enter failure block.");
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
