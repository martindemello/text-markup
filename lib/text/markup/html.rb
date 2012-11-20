require_relative '../markup'

module Text
  module Markup
    module HTML
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

      def self.html_tag(tag, value)
        if t = TAGS[tag]
          value == :on ? "<#{t}>" : "</#{t}>"
        elsif [:fgcolor, :bgcolor].include? tag
          a = ATTRS[tag]
          value == :off ? "</span>" : "<span style='#{a}:#{value}'>"
        else #tag not recognised, ignore
          nil
        end
      end

      def self.html_text(text)
        text.gsub("\n", "<br/>")
      end

      # format : Tree -> string
      def self.format(tree)
        ret = ""
        if tree.tag == :text
          ret += html_text(tree.value)
        elsif tree.tag == :root
          ret += tree.children.map {|c| format(c)}.join("")
        else
          code = html_tag(tree.tag, tree.value)
          if code
            ret += code
            tree.children.each do |c|
              ret += format(c)
            end
            close = html_tag(tree.tag, :off)
            if close
              ret += close
            end
          end
        end
        ret
      end
    end

  end  # module Markup
end  # module Text

if __FILE__ == $0
  require 'term/ansicolor'
  require 'text/markup/ansi'

  c = Term::ANSIColor
  a = ["hello world", c.bold, c.red, c.on_blue, "Red text:\n",
    "\e[21m", c.green, "Green text", c.clear, "\n",
    c.bold, "bold", c.on_blue, c.red, "bold red", "\e[21m", "red", c.reset, "none", "\n"
  ].join("")
  print a


  p a
  b = Text::Markup::ANSI.parse(a)
  p b

  c = Text::Markup::HTML.format(b)
  p c
  print c
end

