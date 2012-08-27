class StaticPageFormPresenter < BasePresenter
  presents :static_page
  def section sections
    form_field(:section, f.select(:section, sections))
  end
end
