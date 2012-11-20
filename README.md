# Text::Markup : A library for parsing and emitting marked-up text

## Description

Text::Markup defines a common tree-structured format for marked-up text, and a
series of modules that convert other forms of text markup to/from this format.

Currently implemented:
* ANSI text parser and formatter
* HTML formatter

## Installation

    $ rake install

## Usage

    require 'text/markup/ansi'
    require 'text/markup/html'

    ansi = "\e[1m\e[31mBold red text\e[44mon blue\n\e[21m\e[32mGreen text\e[0mnone\n"
    tree = Text::Markup::ANSI.parse(ansi)
    html = Text::Markup::HTML.format(tree)
    puts html

    <b><span style='color:red'>Bold red text<span style='background-color:blue'>on blue<br/></span></span></b><span style='background-color:blue'><span style='color:green'>Green text</span></span>none<br/>


## Extending

To write your own parsers and formatters:

* To write a new parser, tokenise your input into a list of `{:tag => value}`
  hashes. A hash can have multiple entries, but the special tags
  `{:text => value}` and `{:reset => nil}` should be in their own hashes.
  Call `Tree.read_from_stream(list)` on the resulting list.

* To write a new formatter, implement `format_text(text)` and `format_node(tag, value)`, and include
`Text::Markup::Formatter`

See `text/markup/ansi.rb` for an example.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
