require 'ruby_picasa'

class Author::SettingsController < Author::SpaceController
  def index
    # api_keys
    @api_keys = @current_shard.shard_languages.map{ |sl| sl.api_keys }.flatten
    
    # social_connections
    @languages = @current_shard.shard_languages
    
    # other_connections - picasa
    picasa_acc = Account.where(provider: "picasa", shard_id: @current_shard.id).first
    picasa = picasa_acc.nil? ? nil : Picasa.new(picasa_acc.token)
    account_url = picasa.nil? ? nil : "https://profiles.google.com/#{picasa.user.user}/photos"
    connect_url = picasa.nil? ? Picasa.authorization_url(authorize_author_albums_url) : nil
    destroy_url = picasa.nil? ? nil : author_picasa_destroy_path
    @connections = [{name: :picasa, account_url: account_url, connect_url: connect_url, destroy_url: destroy_url}]
    
    # other_connections - google analytics
    @current_shard.shard_languages.each{ |sl|
      ga_acc = Account.where(provider: "google_analytics", shard_language_id: sl.id).first
      connect_url = ga_acc.nil? ? author_shard_language_link_service_path({shard_language_id: sl.id, code: :google_analytics}) : nil
      destroy_url = ga_acc.nil? ? nil : author_shard_language_account_path(sl, ga_acc)
      @connections.push(name: :google_analytics, connect_url: connect_url, destroy_url: destroy_url, additional: sl.domain)
    }
    
    # users
    @assignments = @current_shard.assignments
  end
end