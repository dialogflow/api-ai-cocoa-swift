# DEPRECATED Cocoa SDK for api.ai

## This library is deprecated. Please use [API.AI's Apple Client library](https://github.com/api-ai/apiai-apple-client)

[![Build Status](https://travis-ci.org/api-ai/api-ai-ios-sdk.svg?branch=master)](https://travis-ci.org/api-ai/api-ai-cocoa-swift)
[![Version](https://img.shields.io/cocoapods/v/AI.svg?style=flat)](http://cocoapods.org/pods/AI)
[![License](https://img.shields.io/cocoapods/l/AI.svg?style=flat)](http://cocoapods.org/pods/AI)
[![Platform](https://img.shields.io/cocoapods/p/AI.svg?style=flat)](http://cocoapods.org/pods/AI)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

* [Overview](#overview)
* [Prerequisites](#prerequisites)
* [Running the Demo app](#runningthedemoapp)
* [Integrating api.ai into your Cocoa app](#integratingintoyourapp)

---------------

## <a name="overview"></a>Overview
The API.AI iOS SDK makes it easy to integrate natural language processing API on Apple devices. API.AI allows using voice commands and integration with dialog scenarios defined for a particular agent in API.AI.

## <a name="prerequisites"></a>Prerequsites
* Create an [API.AI account](http://api.ai)
* Install [CocoaPods](#cocoapods) or [Carthage](#carthage)


## <a name="runningthedemoapp"></a>Running the Demo app (CocoaPods supports only)
* Run ```pod update``` in the AIDemo project folder.
* Open **AIDemo.xworkspace** in Xcode.
* In **AppDelegate** insert API key.
  ```
  AI.configure("YOUR_CLIENT_ACCESS_TOKEN")
  ```

  Note: an agent in **api.ai** should exist. Keys could be obtained on the agent's settings page.

* Define sample intents in the agent.
* Run the app in Xcode.
  Inputs are possible with text and voice (experimental).


## <a name="integratingintoyourapp"></a>Integrating into your app

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Swift and Objective-C Cocoa projects. Installing:

```bash
$ [sudo] gem install cocoapods
```

List "AI" in a text file named `Podfile` in your Xcode project directory:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'AI', '~> 0.7'
end
```

Now you can install the dependencies in your project:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is intended to be the simplest way to add frameworks to your Cocoa application.

You can use [Homebrew](http://brew.sh) and install the `carthage` tool on your system simply by running `brew update` and `brew install carthage`.

Create a `Cartfile` with following text:
```
github "api-ai/AI"
```

Run `carthage update`.
Drag the built `AI.framework` into your Xcode project.

### Create a bridging header
Create a bridging header by choosing File > New > File > (iOS, watchOS, tvOS, or macOS) > Source > Header File and save the header file in your project root directory. 

Paste the following lines in the bridging header file:
```
#ifndef Header_h
#define Header_h
#import <ApiAI/ApiAI.h>
#endif /* Header_h */
```

In XCode, click on your project file -> Build Settings -> Swift Compiler - General -> Objective-C Bridging Header. Specify the location of the header file in the field to the right. For example that might look like: 
```
/Users/user/Documents/MyProject/MyProject/Header.h
```

### Init the SDK.

In the ```AppDelegate.swift```, add AI import:
```Swift
import AI
```

In the AppDelegate.swift, add

```Swift
// Define API.AI configuration here.
AI.configure("YOUR_CLIENT_ACCESS_TOKEN")
```

### Perform request.

```Swift
...
// Request using text (assumes that speech recognition / ASR
// is done using a third-party library, e.g. AT&T)
AI.sharedService.TextRequest("Hello").success { (response) -> Void in
    // Handle success ...
}.failure { (error) -> Void in
    // Handle error ...
}
```
