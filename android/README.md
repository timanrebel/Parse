# Parse Android Module

## Description

Appcelerator Titanium module for the Parse SDK. This module currently only support Android Push Notifications

## Usage

### Get it [![gitTio](http://gitt.io/badge.png)](http://gitt.io/component/eu.rebelcorp.parse)
Download the latest [distribution ZIP-file](https://github.com/timanrebel/Parse/releases) and consult the [Titanium Documentation](http://docs.appcelerator.com/titanium/latest/#!/guide/Using_a_Module) on how install it, or simply use the [gitTio CLI](http://gitt.io/cli):

`$ gittio install eu.rebelcorp.parse`

### Example

Because the module needs to load and initialize during the startup of your Application to properly support Push Notifications,
we need to put the application id and client key from Parse in your **tiapp.xml** file:

```xml
	<property name="Parse_AppId" type="string">abcdefg</property>
    <property name="Parse_ClientKey" type="string">hijklmnop</property>
```

Put the following code in your app.js (or alloy.js if you are using Alloy) to access the module in Javascript.

```javascript
	var Parse = require('eu.rebelcorp.parse');
```

To enable Android Push Notifications

```javascript
    Parse.enablePush();
```

To handle received notifications

```javascript
    Parse.addEventListener('notification', function(e) {
        Ti.API.log("notification: ", JSON.stringify(e));
```

Subscribe or unsubscribe to Parse Channels

```javascript
    Parse.subscribeChannel('user_123');
    Parse.unsubscribeChannel('user_123');
```


## Known Issues

* Not all of the API is exposed at the moment
* Incoming Push Notifications are not exposed when clicked upon


## Changelog
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
