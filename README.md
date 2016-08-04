Official iOS SDK to connect to the [User Hook](http://userhook.com) platform.

## Getting Started

To use the demo application or integrate the SDK into your own mobile app, you will first need to [sign up](https://apps.userhook.com/register) for an account and create an Application record in admin webpage.

Once you have created your Application, you will need your Application Id and Application Key found on the Application settings webpage. These values will be used to initialize the SDK inside your mobile application.

## Demo Application

To run the demo application, you will need to initialize the SDK using your Application Id and Application Key.

You may do this either by hard coding your id and key into the AppDelegate.m file:

```
[UserHook setApplicationId:@"YOUR_APP_ID" apiKey:@"YOUR_APP_KEY"];
```

Or you may add a plist file to your project named userhook.plist and store your id and key in that file.

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>UserHookApplicationId</key>
<string>YOUR_APP_ID</string>
<key>UserHookApplicationKey</key>
<string>YOUR_APP_KEY</string>
</dict>
</plist>

```

## Install the SDK in Your Mobile App

Instructions on how to integrate the User Hook SDK into your mobile application can be found in the [documentation](http://userhook.com/docs).


## License

```
Copyright (c) 2015 - present, Cullaboration Media, LLC.
All rights reserved.

This source code is licensed under the BSD-style license found in the
LICENSE file in the root directory of this source tree.
```

