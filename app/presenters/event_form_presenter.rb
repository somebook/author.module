class EventFormPresenter < BasePresenter
  presents :event

  def city
    ap "city"
    form_field(:city, f.text_field(:city))
  end

  def place
    form_field(:place, f.text_field(:place))
  end

  def starts_at
    val = @object.starts_at.strftime("%d.%m.%Y %H:%M") unless @object.starts_at.nil?
    form_field(:starts_at, f.text_field(:starts_at, value: val, class: "datetime-input"))
  end
end