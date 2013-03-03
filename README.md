# Warped

Warped is an I/O library for crazies. It provides an asynchronous I/O interface so that single threaded applications can issue multiple I/O operations simultaneously. Depending on the OS, type of I/O endpoint, and the underlying implementation, the I/O operations themselves may be executed asynchronously by the OS, in another thread, or in a non-blocking manner. Some care has been taken with the API to minimize the number of memory copies and context switches needed to satisfy any given request. 

## You may want to use Warped if: 

1. You're writing a non-blocking I/O framework (i.e. webserver)
2. You want to simulate blocking I/O in userspace
3. You want performance AND concurrency simultaneously (…which is all relative since this is still Ruby)

## FAQ

### Why would I use Warped over EventMachine?

* You want to use your own event loop or integrate with another system's event loop
* Your application reads or writes files
* You don't want data pushed at you through a callback-based API

### Why would I use Warped over Nio4r?

* You want an API performs complete I/O operations (not just alerts you when a socket is readable/writable)
* Your application reads or writes files
* You want an API that potentially shuffles fewer bytes around

### What currently works? 

There's a simple thread pool that executes blocks asynchronously. I don't know why I had to write this, but existing Ruby thread pool libraries are terrible for a variety of reasons. 

### What doesn't work?

Basically everything. 

## Installation

Add this line to your application's Gemfile:

    gem 'warped'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install warped

## Usage

There is no API yet

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
