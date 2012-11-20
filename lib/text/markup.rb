module Text
  module Markup

    COLORS = [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white]

    class Tree
      attr_accessor :parent, :tag, :value, :children, :closed, :state

      # read_from_stream : [{:tag => value}] -> Tree
      #
      # To write a new parser, tokenise your input into a list of
      # {:tag => value} hashes and then call Tree.read_from_stream on
      # the list.
      def self.read_from_stream(stream)
        out = Tree.new(:root, nil, nil)
        current = out
        stream.each do |piece|
          current = current.add_all(piece)
        end
        out.prune!
        out
      end

      def initialize(tag, value, parent)
        @parent = parent
        @children = []
        @closed = (tag == :text ? true : false)
        @tag = tag
        @value = value
        @state = parent ? parent.state.dup : {}
      end

      def add_all(elements)
        if elements[:reset]
          close_all
        elsif state.keys.any? {|k| state[k] && elements[k]}
          update_with(elements)
        else
          append_all(elements)
        end
      end

      # remove subtrees with no text
      def prune!
        self.children.each {|c| c.prune!}

        self.children =
          self.children.reject do |c|
            c.tag != :text && c.children.empty?
          end
      end

      def add(tag, value)
        t = Tree.new(tag, value, self)
        t.state = self.state.dup
        t.state[tag] = value
        children.push(t)
        t.closed ? self : t
      end

      def close_all
        self.closed = true
        if self.tag == :root
          self
        else
          self.parent.close_all
        end
      end

      def append_all(elements)
        if elements.empty?
          self
        else
          k = elements.keys.first
          v = elements.delete(k)
          if (v == :off)
            append_all(elements)
          else
            add(k, v).append_all(elements)
          end
        end
      end

      # do not allow two of the same tag to nest, instead close the outer tag
      # and all its children, add the new tag, and reopen all the first tag's
      # children.
      # e.g. [bold:on
      #        [fg:green
      #          [bg:red
      #            [text:hello]
      #            [fg:blue
      #              [text:world]]]]]
      # becomes
      #      [bold:on
      #        [fg:green
      #          [bg:red
      #            [text:hello]]]
      #        [fg:blue
      #          [bg:red
      #            [text:world]]]]
      #
      # this cleans up cases like       <b>text<i>text</b>text</i>
      # to the properly tree-structured <b>text<i>text</i></b><i>text</i>
      #
      # TODO: explore tree rewriting
      def update_with(elements, state = self.state, restore = {})
        if elements.empty? || elements.all? {|k, v| state[k] == v}
          self.append_all(restore)
        else
          restore[self.tag] = elements[self.tag] || self.value
          self.closed = true
          elements.delete(self.tag)
          self.parent.update_with(elements, state, restore)
        end
      end

      def tree_inspect(i)
        " "*2*i +
          "- (#{tag.inspect}, #{value.inspect})\n" +
        children.map {|c| c.tree_inspect(i+1)}.join("")
      end

      def inspect
        self.tree_inspect(0)
      end
    end

  end  # module Markup
end  # module Text
