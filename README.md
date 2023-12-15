# ComThetrainline

## Usage

To test it, clone this project and type:
```
bin/setup

bin/console
```

Then within the console:
```
ComThetrainline.find("3358", "5097", DateTime.now)

# or using cities names

ComThetrainline.find_by_name("Berlin", "Munich", DateTime.now)

# or if the fetch is blocked by the website security you can see an example of the result with:

ComThetrainline.find_example
```

## Description of the Test

dbrady_trainline
================

Build a bot that triggers searches on http://thetrainline.com and returns the results in a specific format.

### Input

* The bot should respond to `ComThetrainline.find(from, to, departure_at)`.
* Assume that the parameters `from` and `to` will be EXACTLY what you need.
* `departure_at` will be a Ruby DateTime object.

### Output

`find()` should return an array.
Each element of the array should be an option for a trip.
E.g. If you search for London to Paris, and they give you 10 "segments" leaving each hour on the hour, the array size should be 10.
Each "segment" should be in this format and should include all data:

```ruby
# Segment
{
      :departure_station => "Ashchurch For Tewkesbury",
           :departure_at => #<DateTime: 2023-04-26T06:09:00+00:00 ((2456774j,22140s,0n),+0s,2299161j)>,
        :arrival_station => "Ash",
             :arrival_at => #<DateTime: 2023-04-26T09:37:00+00:00 ((2456774j,34620s,0n),+0s,2299161j)>,
       :service_agencies => ["thetrainline"],
    :duration_in_minutes => 208,
            :changeovers => 2,
               :products => ["train"],
                  :fares => ["See below"],
}
# Fare
{
                       :name => "Advance Single",
             :price_in_cents => 1939,
                   :currency => "GBP",
              :comfort_class => 1,
 },
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
