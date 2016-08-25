# livechat.cr

Simple little Livechat written in [crystal](crystal-lang.org). It uses [kemal](http://kemalcr.com/), [events](github.com/kcreate/events) and WebSockets.

## Installation

Clone the repo and run `src/main.cr`. You may need to update your firewall settings for the server to be able to listen on port 3000.

This project is developed and tested on OS X El Capitan on a Retina Macbook Pro late 2013.

## Usage

This is only the backend, you'd have to write your own front-end to really use this. Sorry.

## Development

Launch the server and navigate to `localhost:3000/index.html`

This will do some initialization work in the background via Javascript. It just connects to the socket. You can then send your own commands to the livechat via the global `socket` variable in the Javascript console.

This looks something like that:
```javascript
socket.send(JSON.stringify({
    type: 'change_name',
    name: 'Leonard Schuetz'
}));
```

A list of all available commands is inside the `src/commands` directory.

## Contributing

1. Fork it ( https://github.com/KCreate/livechat.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [KCreate](https://github.com/KCreate) Leonard Schuetz - creator, maintainer
