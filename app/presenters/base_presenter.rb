class BasePresenter
  def initialize(object, template, form = nil)
    @object = object
    @template = template
    @form = form
    @av = ActionView::Base.new(Rails.root.join('app', 'views', 'form_presenter'))
  end

  def actions params
    render partial: "form_actions", locals: {
      title: @object.class.to_s.underscore.titleize,
      back_path: params[:back]
    }
  end

  def errors
    render partial: "form_errors", locals: {
      errors: @object.errors,
      title: @object.class.to_s.underscore.titleize.downcase
    }
  end

private

  def self.presents(name)
    define_method(name) do
      @object
    end
  end

  def h
    @template
  end

  def f
    @form
  end

  def render params
    @av.render params
  end

  def method_missing(*args, &block)
    @template.send(*args, &block)
  end

  def markdown(text)
    Redcarpet.new(text, :hard_wrap, :filter_html, :autolink).to_html.html_safe
  end

  def form_field(method, input)
    if method.is_a?(String)
      label = label_tag(method, class: %w(control-label))
      ap "#{method} - #{label}"
    else
      begin
        label = t("activerecord.attributes.#{@object.class.to_s.underscore}.#{method}", raise: true)
        label = @form.label(method, label, class: %w[ control-label ])
      rescue
        label = label_tag(method, class: %w(control-label))
      end
    end

    render partial: "form_field", locals: {
      input: input,
      label: label,
      errors: @object.errors.get(method)
    }
  end

  def form_multiple(method, elements)
    render partial: "form_multiple", locals: {
      elements: elements,
      label: (method.is_a?(String) ? label_tag(method, class: %w(control-label)) : @form.label(method, class: %w(control-label))),
      errors: @object.errors.get(method)
    }
  end
end
