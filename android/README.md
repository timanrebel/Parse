# Parse Android Module

## Description

Appcelerator Titanium module for the Parse SDK. This module currently only support Android Push Notifications

## Usage

### Get it [![gitTio](http://gitt.io/badge.png)](http://gitt.io/component/eu.rebelcorp.parse)
Download the latest [distribution ZIP-file](https://github.com/timanrebel/Parse/releases) and consult the [Titanium Documentation](http://docs.appcelerator.com/titanium/latest/#!/guide/Using_a_Module) on how install it, or simply use the [gitTio CLI](http://gitt.io/cli):

`$ gittio install eu.rebelcorp.parse`

### Example

Because the module needs to load and initialize during the startup of your Application to properly support Push Notifications,
we need to put the application id and client key from Parse in your `tiapp.xml` file:

```xml
	<property name="Parse_AppId" type="string">abcdefg</property>
	<property name="Parse_ClientKey" type="string">hijklmnop</property>
```

**Please note:** You should not add any other Parse tags to your `manifest` section in your `tiapp.xml` file, this module does this all for you. If you do, it will result in displaying Push Notifications multiple times.

Put the following code in your app.js (or alloy.js if you are using Alloy) to access the module in Javascript.

```javascript
	var Parse = require('eu.rebelcorp.parse');

	// only authenticate if you have a session token from Parse already
	Parse.authenticate('<your session token>');

	Parse.start();
```

To handle received notifications the moment it arrives at the Android phone

```javascript
	Parse.addEventListener('notificationreceive', function(e) {
		Ti.API.log("notification: ", JSON.stringify(e));
	});
```

To handle a click on a notification

```javascript
	Parse.addEventListener('notificationopen', function(e) {
		Ti.API.log("notification: ", JSON.stringify(e));
	});
```

These events are only fired when the app is running. When the app is not running and a notification is clicked, the app is started and the notification data is added to the launching intent. It can be accessed with the following code:

```
	var data = Ti.App.Android.launchIntent.getStringExtra('com.parse.Data');

	if(data) {
		try {
			var json = JSON.parse(data);

			// Now handle the click on the notification
		}
			catch(e) {}
	}
```

Subscribe or unsubscribe to Parse Channels

```javascript
    Parse.subscribeChannel('user_123');
    Parse.unsubscribeChannel('user_123');
```

Get the installation id

```javascript
    Parse.getCurrentInstallationId();
```

Get the object id of the installation

```javascript
    Parse.getObjectId();
```

## Parse CloudCode

Android by design has no deviceToken like iOS has. Everytime you install an app on Android the deviceToken will change. This means that when a user re-installs an app, a duplicate Parse installation will be registered and the user will get 2 push notifications if no measures have been taken.
See for reference this [StackOverflow](http://stackoverflow.com/questions/2785485/is-there-a-unique-android-device-id) thread.

This can be easily overcome since version 0.9 of this module using the strategy found on [Parse questions](https://www.parse.com/questions/check-for-duplicate-installations-of-same-user-on-re-installation-of-app).

### Deploy Parse Cloudcode

First install the CLI tool:
```
    curl -s https://www.parse.com/downloads/cloud_code/installer.sh | sudo /bin/bash
```
Go the Cloudcode directory in this repo and issue the following commands:
```
    echo "{}" > config/local.json
    parse add --local
    parse default "your parse app name"
```

If you've set your application as default you can now deploy:
```
    parse deploy
```

This will create your CloudCode application which resolves the duplicate Android installs by inspecting the AndroidID.

Checkout the [Parse Manual](https://www.parse.com/docs/js/guide#cloud-code) for further information.

## Notification image and color

By default the app icon is used, however on Lollipop and above this icon is converted to a white mask. Often this isn't suitable.

Parse allow you to customise this icon by adding a meta tag to the android manifest inside of your tiapp.xml file. More details can be found here: [https://parse.com/tutorials/android-push-notifications](https://parse.com/tutorials/android-push-notifications)

The basic format is
```
<meta-data android:name="com.parse.push.notification_icon" android:resource="@drawable/push_icon"/>
```

Next add an image `push_icon.png` of 72x72px in white and transparent pixels, to your platform dir `platform/android/res/drawable/push_icon.png`.

If you want to change the background color of the notification circle, override the value `parse_notification_color` in your `platform/android/res/values/colors.xml`.

## Known Issues

* The current implementation does __NOT__ work in combination with the [Facebook module](https://github.com/appcelerator-modules/ti.facebook) provided by [Appcelerator](https://github.com/appcelerator). The Facebook module has a dependency onto the Boltz framework version 1.1.2, whereas Parse Android SDK 1.9.4 has a dependency onto version 1.2.0.

## Changelog
**[v0.10](https://github.com/timanrebel/Parse/releases/tag/0.10)**
- Fix minor typo in cloud code
- Trigger 'notificationreceive' when the app is in background but not killed.

**[v0.9](https://github.com/timanrebel/Parse/releases/tag/0.9)**
- Upgrade to latest Parse SDK version 1.9.4
- Add AndroidID to installation registration to be able to detect duplicate installs
- Add optional Parse CloudCode installation

**[v0.8](https://github.com/timanrebel/Parse/releases/tag/0.8)**
- Resume the app on notification click if it was in background.

**[v0.7](https://github.com/timanrebel/Parse/releases/tag/0.7)**
- Add support for Appcelerator SDK 4.0.0
- Add support for retreiving objectId and installation id

**[v0.6](https://github.com/timanrebel/Parse/releases/tag/0.6)**
- Added support for `authenticate(String sessionToken)` to authenticate the saving of the Parse Installation.

**[v0.5](https://github.com/timanrebel/Parse/releases/tag/0.5)**
- Upgraded to latest Parse SDK
- Changed events from `notification` to `notificationreceive` and `notificationopen`
- Added `com.parse.Data` to launching intent

**[v0.3](https://github.com/timanrebel/Parse/releases/tag/0.3)**
- Fire `notification` event when new notification is received.

**[v0.2](https://github.com/timanrebel/Parse/releases/tag/0.2)**
- Moved the app id and client key to tiapp.xml and moved initialization of the module during startup of your Application. To fix [#1](https://github.com/timanrebel/Parse/issues/1)

**[v0.1](https://github.com/timanrebel/Parse/releases/tag/0.1)**
- Initial release supporting Android push notifications

## Author

**Timan Rebel**
twitter: @timanrebel


## License

The MIT License (MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
