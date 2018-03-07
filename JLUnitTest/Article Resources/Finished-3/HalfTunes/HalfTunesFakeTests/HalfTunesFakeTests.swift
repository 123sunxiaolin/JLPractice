/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import XCTest
@testable import HalfTunes

class HalfTunesFakeTests: XCTestCase {
  var controllerUnderTest: SearchViewController!
  
  override func setUp() {
    super.setUp()
    controllerUnderTest = UIStoryboard(name: "Main",
        bundle: nil).instantiateInitialViewController() as! SearchViewController!
    
    let testBundle = Bundle(for: type(of: self))
    let path = testBundle.path(forResource: "abbaData", ofType: "json")
    let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .alwaysMapped)
    
    let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=abba")
    let urlResponse = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
    
    let sessionMock = URLSessionMock(data: data, response: urlResponse, error: nil)
    controllerUnderTest.defaultSession = sessionMock
  }
  
  override func tearDown() {
    controllerUnderTest = nil
    super.tearDown()
  }
  
  // Fake URLSession with DHURLSession protocol and stubs
  func test_UpdateSearchResults_ParsesData() {
    // given
    let promise = expectation(description: "Status code: 200")
    
    // when
    XCTAssertEqual(controllerUnderTest?.searchResults.count, 0, "searchResults should be empty before the data task runs")
    let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=abba")
    let dataTask = controllerUnderTest?.defaultSession.dataTask(with: url!) {
      data, response, error in
      // if HTTP request is successful, call updateSearchResults(_:) which parses the response data into Tracks
      if let error = error {
        print(error.localizedDescription)
      } else if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
          promise.fulfill()
          self.controllerUnderTest?.updateSearchResults(data)
        }
      }
    }
    dataTask?.resume()
    waitForExpectations(timeout: 5, handler: nil)
    
    // then
    XCTAssertEqual(controllerUnderTest?.searchResults.count, 3, "Didn't parse 3 items from fake response")
  }
  
  // Performance
  func test_StartDownload_Performance() {
    let track = Track(name: "Waterloo", artist: "ABBA", previewUrl: "http://a821.phobos.apple.com/us/r30/Music/d7/ba/ce/mzm.vsyjlsff.aac.p.m4a")
    measure {
      self.controllerUnderTest?.startDownload(track)
    }
  }
  
}
