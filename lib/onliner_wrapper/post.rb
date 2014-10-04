module OnlinerWrapper
  class Post

    def initialize(node)
      @node = node
    end

    def post_id
      @post_id ||= Integer(@node.attr('id').scan(/p(\d+)/)[0][0])
    end

    def author
      @_author ||= @node.search('.mtauthor-nickname a._name')[0].content
    end

    def content_text
      @_content ||= @node.search('.content')[0].content
    end

    def time_text
      @_time_text ||= @node.search('.msgpost-date span')[0].content
    end

    def inspect
      "#<#{self.class.name} id: #{post_id.inspect} author: #{author.inspect}>"
    end
  end
end
