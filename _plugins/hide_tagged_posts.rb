module Jekyll
  class HideTaggedPosts < Generator
    priority :high

    HIDDEN_TAGS = ['test'].freeze

    def generate(site)
      return unless Jekyll.env == 'production'

      hidden = site.posts.docs.select do |post|
        tags   = Array(post.data['tags'])
        status = post.data['status']

        # Hide if tagged 'test'
        (tags & HIDDEN_TAGS).any? ||
          # Hide if status is explicitly set to anything other than 'completed'
          (!status.nil? && status != 'completed')
      end

      return if hidden.empty?

      site.posts.docs.reject! { |post| hidden.include?(post) }

      # Remove from site.tags so tag archive pages are not generated
      HIDDEN_TAGS.each { |tag| site.tags.delete(tag) }
      site.tags.each_value { |posts| posts.reject! { |post| hidden.include?(post) } }

      # Remove from site.categories so category counts stay accurate
      site.categories.each_value { |posts| posts.reject! { |post| hidden.include?(post) } }
    end
  end
end
