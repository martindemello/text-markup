require_relative '../markup'
require_relative 'formatter'
require 'tk'

module Text
  module Markup
    class TkMarkupText  < TkText
      attr_accessor :parser

      TAGS = {
        :fgcolor => :foreground,
        :bgcolor => :background,
        :underline => :underline,
        :strikethrough => :overstrike
      }

      FONT = {
        :bold => :bold,
        :italic => :italic
      }

      def initialize(container)
        super(container)
        @atags = []
      end

      def insert_formatted(pos, text)
        if parser
          tree = @parser.parse(text)
          insert(pos, *format(tree))
        else
          insert(pos, text)
        end
      end

      def insert_markup_tree(pos, tree)
        a = format(tree)
        #insert(pos, *a)
        a.each_slice(2) {|i, j| insert(pos, i, j)}
      end

      def format(tree) 
        ret = []
        if tree.tag == :text
          ret += format_text(tree.value, tree.state)
        else
          ret += tree.children.map {|c| format(c)}
        end
        ret.flatten
      end

      def format_text(text, state)
        tag = {}
        state.each_pair do |k, v|
          if t = TAGS[k]
            tag[t] = v
          elsif t = FONT[k]
            tag[:font] ||= []
            tag[:font] << t
          end
        end
        t = TkTextTag.new(self, tag)
        @atags << t
        [text, t]
      end
    end  # class TkMarkupText
  end  # module Markup
end  # module Text

if __FILE__ == $0
  # set up tk display
  root = TkRoot.new() { title "TkMarkupText" }
  frame = TkFrame.new(root).pack("side"=>"right")
  buttons = TkFrame.new(frame).pack("side"=>"bottom")
  quit = TkButton.new(buttons) {
    text "Exit"
    command lambda { exit }
  }
  TkGrid.configure(quit)
  display = TkFrame.new(root).pack("side"=>"left")
  text = Text::Markup::TkMarkupText.new(display).pack()  # top
  frame.pack("fill"=>"y")
  display.pack("fill"=>"both", "expand"=>true)
  text.pack("fill"=>"both", "expand"=>true)
  text.focus

  # insert formatted text
  a = [{:text => "hello world"}, {:bold => :on, :fgcolor => 'red', :bgcolor => 'blue'},
    {:text => "Bold red text on blue:\n"}, {:bold => :off, :fgcolor => 'green'},
    {:text => 'Green text on blue'}, {:reset => nil}, {:text => "none\n"}]

  p a
  b = Text::Markup::Tree.read_from_stream(a)
  p b

  text.insert_markup_tree('end', b)

  Tk.mainloop
end
