module OnlinerWrapper
  class TopicPage
    attr_reader :agent, :page

    def initialize(topic_id, page: 1, agent: nil)
      @agent = agent || Mechanize.new
      @agent.user_agent_alias = 'Mac Safari'

      url = generate_url(topic_id, page)
      load(url)
    end


    def posts_count
      @page.search('.msgpost').count
    end

    def last_page_number
      Integer(@page.search('.h-btmtopic .pages-fastnav li a')[-2].content)
    end

    def last_post_id
      posts.last.post_id
    end

    private

      def generate_url(topic_id, page)
        start = (page - 1) * 20
        "http://forum.onliner.by/viewtopic.php?t=#{topic_id}&start=#{start}"
      end

      def load(url)
        @page = agent.get(url)
      end

      def posts
        @_posts ||= page.search('.msgpost:not(.msgfirst)').map do |node|
          Post.new(node)
        end
      end

      def raw_messages
      end
  end
end
