# ComThetrainline

To test it, clone this project and open a console:
```
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

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
