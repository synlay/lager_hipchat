Overview
============

This is a HipChat backend for [Lager](https://github.com/basho/lager) which lets you send Lager logs to HipChat rooms and optionally mention users.

[![Build Status](https://travis-ci.org/synlay/lager_hipchat.svg?branch=develop)](https://travis-ci.org/synlay/lager_hipchat) [![Coverage Status](https://coveralls.io/repos/github/synlay/lager_hipchat/badge.svg?branch=develop)](https://coveralls.io/github/synlay/lager_hipchat?branch=develop) [![Hex.pm](https://img.shields.io/hexpm/v/lager_hipchat.svg)](https://hex.pm/packages/lager_hipchat) [![GitHub license](https://img.shields.io/github/license/synlay/lager_hipchat.svg)](https://github.com/synlay/lager_hipchat)

##Configuration
Configure a Lager handler like this:

	{lager_hipchat_backend, [AuthToken, RoomId, Sender, Color, Mentions, Notify, Level, RetryTimes, RetryInterval]}
	
* __AuthToken__ - This is your unique authentication token issued by HipChat to send messages through the HTTP API
* __RoomId__ - The RoomId as specified on the HipChat settings web page
* __Sender__ - The sender's name (e.g. "lager_hipchat")
* __Color__ - The background color for a message. Possible values are "yellow", "red", "green", "purple", "gray", and "random".
* __Mentions__ - The users to mention in messages (e.g. [bob, "alice"])
* __Notify__ - Specifies if the message should trigger a notification for people in the room (true or false)
* __Level__ - The lager level at which the backend accepts messages (e.g. using ‘info’ will send all messages at info level and above to the HipChat room)
* __RetryTimes__ - The maximum number of connection attempts
* __RetryInterval__ - The number of seconds between connection attempts, i.e. RetryTimes 5 and RetryInterval 3 means that it will try a maximum of 5 times with 3 seconds apart

Example:

	{lager_hipchat_backend, ["3a45v433a44...", "ErrorLog", "lager_hipchat", red, [bob, "alice"], true, error, 5, 3]}

See [Lager's documentation](https://github.com/basho/lager/blob/master/README.org#configuration) for futher information on handler configuration.


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/synlay/lager_hipchat/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

