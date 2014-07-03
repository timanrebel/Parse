var Parse = require('eu.rebelcorp.parse');
    Parse.start('<PARSE-APPLICATION-ID>', '<PARSE-CLIENT-ID>');

	// To enable Android Push Notifications
	Parse.enablePush();

	// Subscribe of unsubscribe to Parse Channels
    Parse.subscribeChannel('user_123');

    Parse.unsubscribeChannel('user_123');
