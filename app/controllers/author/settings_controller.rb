require 'ruby_picasa'

module Author
class SettingsController < SpaceController

  def index
    # Api Keys
    @api_keys = @current_shard.shard_languages.map{ |shard_language| shard_language.api_keys }.flatten

    # Social Connections
    @languages = @current_shard.shard_languages

    # Other Connections - Picasa
    account_url = connect_url = destroy_url = nil
    picasa_account = Account.where(provider: "picasa", shard_id: @current_shard.id).first
    if !picasa_account.nil?
      picasa = Picasa.new(picasa_account.token)
      unless picasa.nil?
        account_url = "https://profiles.google.com/#{picasa.user.user}/photos"
        destroy_url = picasa_destroy_path
      end
    else
      connect_url = Picasa.authorization_url(authorize_albums_url)
    end
    @connections = [{
      name: :picasa,
      account_url: account_url,
      connect_url: connect_url,
      destroy_url: destroy_url
    }]

    # Other Connections - Google Analytics
    @current_shard.shard_languages.each{ |shard_language|
      ga_account = Account.where(provider: "google_analytics", shard_language_id: shard_language.id).first
      connect_url = destroy_url = nil
      if ga_account.nil?
        connect_url = shard_language_link_service_path(shard_language_id: shard_language.id, code: :google_analytics)
      else
        destroy_url = shard_language_account_path(shard_language, ga_account)
      end
      @connections << {
        name: :google_analytics,
        connect_url: connect_url,
        destroy_url: destroy_url,
        additional: shard_language.domain
      }
    }

    # Users
    @assignments = @current_shard.assignments
  end

end
end
