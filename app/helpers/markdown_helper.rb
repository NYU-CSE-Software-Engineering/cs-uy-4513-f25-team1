module MarkdownHelper
  def render_markdown(content)
    return "" if content.blank?

    renderer = Redcarpet::Render::HTML.new(
      filter_html: true,
      hard_wrap: true,
      no_styles: true,
      safe_links_only: true
    )

    markdown = Redcarpet::Markdown.new(
      renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      highlight: true,
      no_intra_emphasis: true
    )

    markdown.render(content).html_safe
  end
end
