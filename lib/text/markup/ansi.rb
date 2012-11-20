require_relative '../markup'
require_relative 'formatter'

module Text
  module Markup
    module ANSI
      extend Formatter

      CODE_RE = /(\e\[(?:\d{1,2};?)+\w)/
      CODE_TEMPLATE = "\e[%dm"

      # Subset of ANSI codes supported by Text::Markup
      # don't use boolean values because tests of the form `if modes[:bold]` do
      # the wrong thing for the false case
      FROM_CODE = {
         1 => [ :bold          , :on      ],
         2 => [ :bold          , :off     ],
         3 => [ :italic        , :on      ],
         4 => [ :underline     , :on      ],
         9 => [ :strikethrough , :on      ],
        21 => [ :bold          , :off     ],
        23 => [ :italic        , :on      ],
        24 => [ :underline     , :off     ],
        29 => [ :strikethrough , :off     ],
        30 => [ :fgcolor       , :black   ],
        31 => [ :fgcolor       , :red     ],
        32 => [ :fgcolor       , :green   ],
        33 => [ :fgcolor       , :yellow  ],
        34 => [ :fgcolor       , :blue    ],
        35 => [ :fgcolor       , :magenta ],
        36 => [ :fgcolor       , :cyan    ],
        37 => [ :fgcolor       , :white   ],
        39 => [ :fgcolor       , :off     ],
        40 => [ :bgcolor       , :black   ],
        41 => [ :bgcolor       , :red     ],
        42 => [ :bgcolor       , :green   ],
        43 => [ :bgcolor       , :yellow  ],
        44 => [ :bgcolor       , :blue    ],
        45 => [ :bgcolor       , :magenta ],
        46 => [ :bgcolor       , :cyan    ],
        47 => [ :bgcolor       , :white   ],
        49 => [ :bgcolor       , :off     ],
      }

      TO_CODE = FROM_CODE.invert

      # get_mode : piece -> {:tag => value}
      def self.get_modes(piece)
        modes = piece.scan(/\d+/).map(&:to_i)
        t = {}
        modes.each do |m|
          if m == 0
            # reset ignores everything else
            return {:reset => true}
          elsif FROM_CODE[m]
            k, v = FROM_CODE[m]
            t[k] = v
          end
        end
        return t
      end

      # parse : string -> Tree
      def self.parse(text)
        pieces = text.split(CODE_RE, -1).reject {|i| i.empty?}
        pieces = pieces.map do |piece|
          if piece[0] != "\e"
            {:text => piece}
          elsif piece[-1] != 'm'
            # just strip out non-markup ansi sequences
            nil
          else
            get_modes(piece)
          end
        end
        pieces = pieces.compact
        Tree.read_from_stream(pieces)
      end

      def self.format_text(text)
        text
      end

      # format_node : (tag, value) -> string
      def self.format_node(tag, value)
        code = TO_CODE[[tag, value]]
        code ? CODE_TEMPLATE % code : nil
      end

    end  # module ANSI
  end  # module Markup
end  # module Text

if __FILE__ == $0
  require 'term/ansicolor'

  c = Term::ANSIColor
  a = ["hello world", c.bold, c.red, c.on_blue, "Red text:\n",
    "\e[21m", c.green, "Green text", c.clear, "\n",
    c.bold, "bold", c.on_blue, c.red, "bold red", "\e[21m", "red", c.reset, "none", "\n"
  ].join("")
  print a

  p a
  b = Text::Markup::ANSI.parse(a)
  p b

  c = Text::Markup::ANSI.format(b)
  p c
  print c
end
