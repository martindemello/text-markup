module Text
  module Markup

    COLORS = [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white]

    class Tree
      attr_accessor :parent, :tag, :value, :children, :closed, :state

      def initialize(tag, value, parent)
        @parent = parent
        @children = []
        @closed = (tag == :text ? true : false)
        @tag = tag
        @value = value
        @state = parent ? parent.state.dup : {}
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

      def append_all(modes)
        if modes.empty?
          self
        else
          k = modes.keys.first
          v = modes.delete(k)
          if (v == :off)
            append_all(modes)
          else
            add(k, v).append_all(modes)
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
      # TODO: consider only doing this for on/off tags
      # TODO: explore tree rewriting
      def update_with(modes, state = self.state, restore = {})
        if modes.empty? || modes.all? {|k, v| state[k] == v}
          self.append_all(restore)
        else
          restore[self.tag] = modes[self.tag] || self.value
          self.closed = true
          modes.delete(self.tag)
          self.parent.update_with(modes, state, restore)
        end
      end

      def add_modes(modes)
        if modes[:reset]
          close_all
        elsif state.keys.any? {|k| state[k] && modes[k]}
          update_with(modes)
        else
          append_all(modes)
        end
      end

      # remove tags with no text
      def prune!
        self.children.each {|c| c.prune!}

        self.children =
          self.children.reject do |c|
            c.tag != :text && c.children.empty?
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
