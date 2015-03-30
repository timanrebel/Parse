var Parse = require('eu.rebelcorp.parse');

Parse.start();

// Subscribe of unsubscribe to Parse Channels
Parse.subscribeChannel('user_123');

Parse.unsubscribeChannel('user_123');

// Set value on the installation object
Parse.putValue('foo', 'bar');
