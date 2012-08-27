class TerminalFormPresenter < BasePresenter
  presents :terminal

  def name
    form_field(:name, f.text_field(:name))
  end

  def identifier
    form_field(:identifier, f.text_field(:identifier))
  end
end
