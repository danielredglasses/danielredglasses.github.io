module Jekyll
  class HideTranslationsFromListings < Generator
    priority :low

    # Removes hidden posts (translations) from category/tag archive pages.
    # Does NOT touch site.posts.docs, so the post's own page is still
    # written and reachable via the lang-toggle button.
    def generate(site)
      hidden = site.posts.docs.select { |post| post.data["hidden"] }
      return if hidden.empty?

      site.tags.each_value { |posts| posts.reject! { |post| hidden.include?(post) } }
      site.categories.each_value { |posts| posts.reject! { |post| hidden.include?(post) } }
    end
  end
end
