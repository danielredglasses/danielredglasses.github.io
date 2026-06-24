module Jekyll
  module StripHeadingsFilter
    # Removes whole heading elements (tag + their text), not just the tags,
    # so a heading like "## Summary" doesn't bleed into post previews as
    # "Summary <next paragraph text>" once strip_html removes the markup.
    def strip_headings(html)
      html.to_s.gsub(%r{<h[1-6][^>]*>.*?</h[1-6]>}im, "")
    end
  end
end

Liquid::Template.register_filter(Jekyll::StripHeadingsFilter)
