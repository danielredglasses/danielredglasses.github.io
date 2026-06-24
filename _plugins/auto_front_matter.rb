module Jekyll
  class AutoFrontMatter < Generator
    safe false
    priority :highest

    ALLOWED_STATUSES = ["draft", "in progress", "completed"].freeze

    STATIC_DEFAULTS = {
      "status"     => "draft",
      "math"       => true,
      "categories" => [],
      "tags"       => [],
      "lang"       => "en"
    }.freeze

    def generate(site)
      site.posts.docs.each do |post|
        inject_defaults(post.path)
        validate_status(post)
      end
    end

    private

    # YAML front matter has no native enum type, so this is the only way
    # to keep `status` restricted to ALLOWED_STATUSES.
    def validate_status(post)
      status = post.data["status"]
      return if status.nil? || ALLOWED_STATUSES.include?(status)

      raise Jekyll::Errors::FatalException, "Invalid status #{status.inspect} in " \
        "#{post.relative_path} — must be one of: #{ALLOWED_STATUSES.join(', ')}"
    end

    def inject_defaults(path)
      content = File.read(path, encoding: "utf-8")
      return unless content.start_with?("---\n")

      missing = STATIC_DEFAULTS.reject { |key, _| content.match?(/^#{Regexp.escape(key)}\s*:/) }
      add_date = !content.match?(/^date\s*:/)
      add_ref  = !content.match?(/^ref\s*:/)

      # A translation (lang explicitly set to something other than the
      # default) is hidden from listings by default — only reachable via
      # the lang-toggle button on its primary-language counterpart.
      existing_lang = content[/^lang\s*:\s*"?([^"\n]+)"?/, 1]&.strip
      is_translation = !existing_lang.nil? && existing_lang != STATIC_DEFAULTS["lang"]
      add_hidden = is_translation && !content.match?(/^hidden\s*:/)
      add_permalink = !content.match?(/^permalink\s*:/)

      return if missing.empty? && !add_date && !add_ref && !add_hidden && !add_permalink

      lines = missing.map { |k, v| "#{k}: #{v}" }

      if add_date
        created = begin
          File.birthtime(path)
        rescue NotImplementedError
          File.mtime(path)
        end
        lines << "date: #{created.strftime('%Y-%m-%d %H:%M:%S %z')}"
      end

      # Shared identifier used to pair an English post with its Korean
      # translation (see lang-toggle.html), and as the URL slug below.
      # Defaults to the post's filename slug; set the translation's `ref`
      # to match the original's manually.
      ref = add_ref ? default_ref(path) : existing_ref(content)
      lines << "ref: #{ref}" if add_ref

      lines << "hidden: true" if add_hidden

      # Canonical URL carries the language as a path prefix, e.g.
      # /en/posts/DUSDi/ and /ko/posts/DUSDi/ — same `ref` slug, so a
      # translation pair lives at the same path under a different prefix.
      lines << "permalink: /#{lang_code(existing_lang)}/posts/#{ref}/" if add_permalink

      fields = lines.join("\n")
      File.write(path, content.sub("---\n", "---\n#{fields}\n"), encoding: "utf-8")
    end

    def default_ref(path)
      File.basename(path, ".*").sub(/\A\d{4}-\d{2}-\d{2}-/, "")
    end

    def existing_ref(content)
      content[/^ref\s*:\s*"?([^"\n]+)"?/, 1]&.strip
    end

    def lang_code(existing_lang)
      lang = existing_lang || STATIC_DEFAULTS["lang"]
      lang.start_with?("ko") ? "ko" : "en"
    end
  end
end
