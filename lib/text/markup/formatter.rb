module Text
  module Markup
    module Formatter
      
      # format : Tree -> string
      #
      # calls
      #   format_node(tag, value)
      #   format_text(text)
      def format(tree)
        ret = ""
        if tree.tag == :root
          ret << tree.children.map {|c| format(c)}.join("")
        elsif tree.tag == :text
          ret << format_text(tree.value)
        else
          if code = format_node(tree.tag, tree.value)
            ret << code
            tree.children.each do |c|
              ret << format(c)
            end
            if close = format_node(tree.tag, :off)
              ret << close
            end
          end
        end
        ret
      end

    end
  end
end
