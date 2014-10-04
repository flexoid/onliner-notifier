class CrawlerJob

  def perform
    begin
      Topic.all.each do |topic|
        process_topic(topic)
      end
    rescue => e
      log "ERROR: #{e.inspect}"
    ensure
      self.class.enqueue
    end
  end

  def self.enqueue
    Delayed::Job.enqueue(self.new, run_at: 3.minutes.from_now)
    # Delayed::Job.enqueue(self.new)
  end

  private

    def process_topic(topic)
      if topic.last_post_id && topic.last_page_number
        look_for_new_posts(topic)
      else
        process_topic_first_time(topic)
      end
    end

    def process_topic_first_time(topic)
      first_page = OnlinerWrapper::TopicPage.new(topic.topic_id)

      last_page_number = first_page.last_page_number
      last_page = OnlinerWrapper::TopicPage.new(topic.topic_id, page: first_page.last_page_number)

      topic.last_post_id = last_page.last_post_id
      topic.last_page_number = last_page_number
      topic.save!

      log("New topic: #{topic.inspect}")
    end

    def look_for_new_posts(topic)
      page = OnlinerWrapper::TopicPage.new(topic.topic_id, page: topic.last_page_number)
      new_posts = page.new_posts(topic.last_post_id)

      last_page_number = page.last_page_number

      ((topic.last_page_number + 1)..last_page_number).each do |page_number|
        page = OnlinerWrapper::TopicPage.new(topic.topic_id, page: page_number)
        new_posts += page.new_posts(topic.last_post_id)
      end

      topic.last_page_number = last_page_number
      topic.last_post_id = page.last_post_id
      topic.save!

      log("Existing: #{topic.inspect}")
      log("New posts: #{new_posts.inspect}")

      new_posts.each do |new_post|
        save_to_file(topic, new_post)
      end
    end

    def new_posts_from_page(page, last_post_id)
      page.posts.select { |post| post.post_id > last_post_id }
    end

    def log(text)
      Rails.logger.info "\n========== #{self.class.name} =========="
      Rails.logger.info text
      Rails.logger.info "========== ============ ==========\n"
    end

    def save_to_file(topic, post)
      dir_path = File.join(Dir.home, 'onliner_notifier/posts', topic.topic_id.to_s)
      FileUtils.mkdir_p dir_path

      file_path = File.join(dir_path, post.post_id.to_s)

      File.open(file_path, 'w') do |file|
        file.write("#{post.author}\n")
        file.write("#{post.time_text}\n\n")
        file.write("#{post.content_text}\n")
      end
    end
end
