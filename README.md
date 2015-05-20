# Ares

Load information about employers from Czech ARES service.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ares'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ares

## Usage

```ruby
record = Ares.standard(ico: '27169278')
record.business_name     # => "Účetnictví on-line, s.r.o."
record.address.to_s      # => "Pekařská 14/628, 15500 Praha-Jinonice, okres: Hlavní město Praha"
record.address.street           # => "Pekařská"
record.address.sequence_number  # => "14"
record.address.building_number  # => "628"
record.address.postcode         # => "15500"
record.address.town             # => "Praha"
record.address.residential_area # => "Jinonice"
record.address.district         # => "Hlavní město Praha"
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ares/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
