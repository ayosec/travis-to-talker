# Travis - Talker

Proxy between Travis and Talker. This application will receive notifications from Travis, and send a JSON with the data to a Talker room.

The Talkers users can use the [Talker Aentos plugin](https://github.com/ayosec/talkerapp-aentos-plugin) to render the info.

# Configuration

* `TRAVIS_TOKEN` the token used by Travis. This is used to authenticate the messages from Travis
* `TALKER_TOKEN` The token of the Talker user.
* `TALKER_ROOM_ID` The room ID where the messages will be sent

