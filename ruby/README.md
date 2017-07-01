# DropboxContentHasher

[![Build Status](https://semaphoreci.com/api/v1/igormalinovskiy/dropbox_content_hasher/branches/master/shields_badge.svg)](https://semaphoreci.com/igormalinovskiy/dropbox_content_hasher)
[![Code Climate](https://codeclimate.com/github/psyipm/dropbox_content_hasher/badges/gpa.svg)](https://codeclimate.com/github/psyipm/dropbox_content_hasher)
[![Gem Version](https://badge.fury.io/rb/dropbox_content_hasher.svg)](https://badge.fury.io/rb/dropbox_content_hasher)


In order to allow Dropbox apps to verify uploaded contents or compare remote files to local files without downloading them, the FileMetadata object contains a hash of the file contents in the [content_hash](https://www.dropbox.com/developers/reference/content-hash) property.

This gem computes hash value of the file using dropbox algorithm.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dropbox_content_hasher'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dropbox_content_hasher

## Usage

Here is an example of running the above algorithm on [this image of the Milky Way from NASA.](https://www.dropbox.com/static/images/developers/milky-way-nasa.jpg)

```ruby
file = Pathname.new('milky-way-nasa.jpg')
DropboxContentHasher.calculate(file)
 => "485291fa0ee50c016982abbfa943957bcd231aae0492ccbaa22c58e3997b35e0"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/psyipm/dropbox_content_hasher.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
