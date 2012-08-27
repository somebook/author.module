class ApiKeyFormPresenter < BasePresenter
  presents :api_key

  def title
    form_field(:title, f.text_field(:title))
  end
  
  def app_id
    form_field(:app_id, f.text_field(:app_id))
  end
  
  def key
    form_field(:key, f.text_field(:key))
  end
  
  def secret
    form_field(:secret, f.text_field(:secret))
  end
  
  def shard_language_id languages
    form_field(:shard_language_id, f.select(:shard_language_id, languages.collect{ |l| [ l.domain, l.id ] }))
  end
end