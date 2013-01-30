module Author::BreadcrumbsHelper
  def bc(elements, oh = false)
    haml_tag(:ul, class: (oh ? %w(breadcrumb over-header) : %w(breadcrumb) )) do
      elements.each do |el|
        ap el
        if el.count > 1
          haml_tag(:li) do
            haml_tag(:a, href: el[1]) do
              haml_concat el[0]
              haml_tag(:span, class: :divider) do
                haml_concat "/"
              end
            end
          end
        else
          haml_tag(:li, class: :active) do
            haml_concat el[0]
          end
        end
      end
    end
  end
end