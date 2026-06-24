module Jekyll
  module LangArchives
    LANG_PREFIX = { "en" => "en", "ko-KR" => "ko" }.freeze

    # Finds the post that should represent `post` when viewed on a page in
    # `lang` — its translation if one exists with a matching `ref`,
    # otherwise `post` itself.
    #
    # `post` may be a raw Jekyll::Document (called from the generator below)
    # or a Jekyll::Drops::DocumentDrop (called from Liquid via the
    # `resolve_lang` filter, since collections are exposed to templates as
    # drops) — `[]` works on both, unlike the private `#data`.
    def self.resolve(site, post, lang)
      post_lang = post["lang"] || "en"
      return post if post_lang == lang

      ref = post["ref"]
      return post unless ref

      translation = site.posts.docs.find do |p|
        p["ref"] == ref && p["lang"] == lang
      end
      translation || post
    end

    # The display name for a category/tag `term` in `lang`, looked up from
    # _data/term_translations.yml (keyed by the term's English spelling, as
    # written in post front matter — posts and URLs never change). Falls
    # back to the term itself when there's no translation registered yet.
    #
    # `segment` is "categories" or "tags" (matching the YAML's top-level
    # keys and the URL path segment).
    def self.translate_term(site, term, segment, lang)
      return term unless lang == "ko-KR"

      translations = (site.data["term_translations"] || {})[segment] || {}
      translations[term] || term
    end

    # A synthetic page for a single category or tag archive, generated once
    # per language. Mirrors what the jekyll-archives gem does for
    # `Jekyll::Archives::Archive`, but scoped to one language's resolved
    # posts instead of a single global list.
    class ArchivePage < Jekyll::Page
      def initialize(site, type, lang, slug, title, posts)
        @site = site
        @base = site.source
        @dir  = ""
        @name = "index.html"
        @ext  = ".html"
        @basename = "index"

        segment = type == "category" ? "categories" : "tags"

        @data = {
          "layout"    => type,
          # The slug (and so the URL and the `ref` pairing with the other
          # language's page) always comes from the untranslated `title` —
          # only the displayed name changes per language.
          "title"     => LangArchives.translate_term(site, title, segment, lang),
          "lang"      => lang,
          "ref"       => "#{type}-#{slug}",
          "permalink" => "/#{LANG_PREFIX[lang]}/#{segment}/#{slug}/",
          "posts"     => posts,
        }
        @content = ""
      end
    end

    class Generator < Jekyll::Generator
      safe true
      priority :low

      def generate(site)
        LANG_PREFIX.each_key do |lang|
          resolved = resolved_posts(site, lang)
          build_archives(site, "category", lang, group_by(resolved, "categories"))
          build_archives(site, "tag", lang, group_by(resolved, "tags"))
        end
      end

      private

      # Every visible (non-hidden) post, swapped for its `lang` translation
      # wherever one exists.
      def resolved_posts(site, lang)
        site.posts.docs
          .reject { |post| post.data["hidden"] }
          .map { |post| LangArchives.resolve(site, post, lang) }
      end

      def group_by(posts, field)
        grouped = Hash.new { |hash, key| hash[key] = [] }
        posts.each do |post|
          Array(post.data[field]).each { |term| grouped[term] << post }
        end
        grouped.each_value { |list| list.sort_by!(&:date).reverse! }
        grouped
      end

      def build_archives(site, type, lang, grouped)
        grouped.each do |term, posts|
          slug = Jekyll::Utils.slugify(term)
          site.pages << ArchivePage.new(site, type, lang, slug, term, posts)
        end
      end
    end
  end

  module LangResolveFilter
    # Usage in Liquid: {{ post | resolve_lang: page.lang }}
    def resolve_lang(post, lang)
      Jekyll::LangArchives.resolve(@context.registers[:site], post, lang)
    end

    # Usage in Liquid: {{ category_name | translate_term: 'categories', page.lang }}
    def translate_term(term, segment, lang)
      Jekyll::LangArchives.translate_term(@context.registers[:site], term, segment, lang)
    end
  end
end

Liquid::Template.register_filter(Jekyll::LangResolveFilter)
