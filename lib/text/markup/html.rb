require_relative '../markup'
require_relative 'formatter'

module Text
  module Markup
    module HTML
      extend Formatter

      TAGS = {
        :bold => "b",
        :italic => "i",
        :underline => "u",
        :strikethrough => "strike"
      }

      # set colors via inline css
      ATTRS = {
        :fgcolor => 'color',
        :bgcolor => 'background-color'
      }

      def self.format_node(tag, value)
        if t = TAGS[tag]
          value == :on ? "<#{t}>" : "</#{t}>"
        elsif [:fgcolor, :bgcolor].include? tag
          a = ATTRS[tag]
          value == :off ? "</span>" : "<span style='#{a}:#{value}'>"
        else #tag not recognised, ignore
          nil
        end
      end

      def self.format_text(text)
        text.gsub("\n", "<br/>")
      end

    end  # module HTML
  end  # module Markup
end  # module Text

if __FILE__ == $0
  a = [{:text => "hello world"}, {:bold => :on, :fgcolor => 'red', :bgcolor => 'blue'},
    {:text => "Red text:\n"}, {:bold => :off, :fgcolor => 'green'},
    {:text => 'Green text'}, {:reset => nil}, {:text => "none\n"}]


  p a
  b = Text::Markup::Tree.read_from_stream(a)
  p b

  c = Text::Markup::HTML.format(b)
  print c
end

