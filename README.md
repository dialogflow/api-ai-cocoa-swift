iOS SDK for api.ai
==============

<!-- [![Build Status](https://travis-ci.org/api-ai/api-ai-ios-sdk.svg)](https://travis-ci.org/api-ai/api-ai-cocoa-swift) -->
[![Version](https://img.shields.io/cocoapods/v/AI.svg?style=flat)](http://cocoapods.org/pods/AI)
[![License](https://img.shields.io/cocoapods/l/AI.svg?style=flat)](http://cocoapods.org/pods/AI)
[![Platform](https://img.shields.io/cocoapods/p/AI.svg?style=flat)](http://cocoapods.org/pods/AI)

* [Overview](#overview)
* [Prerequisites](#prerequisites)
* [Running the Demo app](#runningthedemoapp)
* [Integrating api.ai into your iOS app](#integratingintoyourapp)

---------------

## <a name="overview"></a>Overview
The API.AI iOS SDK makes it easy to integrate speech recognition with API.AI natural language processing API on iOS devices. API.AI allows using voice commands and integration with dialog scenarios defined for a particular agent in API.AI.

## <a name="prerequisites"></a>Prerequsites
* Create an [API.AI account](http://api.ai)
* Install [CocoaPods](http://cocoapods.org/)


## <a name="runningthedemoapp"></a>Running the Demo app
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
### 1. Initialize CocoaPods
  * Run  ```pod install``` in your project folder.

  * Update **Podfile** to include:
    ```Podfile
    pod 'AI'
    ```

* Run ```pod update```

### 2. Init audio session.
  In the AppDelegate.m, add
  ```Swift
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // code for error handle
            // ...
        }
  ```

### 3. Init the SDK.
  In the ```AppDelegate.swift```, add AI import:
  ```Swift
  import AI
  ```

  In the AppDelegate.swift, add
  ```Swift
    // Define API.AI configuration here.
    AI.configure("YOUR_CLIENT_ACCESS_TOKEN")
  ```

### 4. Perform request using text.
  ```Swift
  ...
    // Request using text (assumes that speech recognition / ASR is done using a third-party library, e.g. AT&T)
    AI.sharedService.TextRequest("Hello").success { (response) -> Void in
        // Handle success ...
    }.failure { (error) -> Void in
        // Handle error ...
    }

  ```

### 5. Or perform request using voice:
  ```Swift
    // Request using voice
    AI.sharedService.VoiceRequest().success { (response) -> Void in
        // Handle success ...
    }.failure { (error) -> Void in
        // Handle error ...
    }
  ```
