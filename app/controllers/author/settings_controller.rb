require 'ruby_picasa'

module Author
  class SettingsController < SpaceController
    def index
      # Api Keys
      @api_keys = @current_shard.shard_languages.map{ |shard_language| shard_language.api_keys }.flatten

      # Social Connections
      @streams = []
      @streams << :personal if can? :blog, Post.new(shard_id: @current_shard.id)
      @streams << :official if can? :news, Post.new(shard_id: @current_shard.id)
      @languages = @current_shard.shard_languages

      # Other Connections - Picasa, YouTube
      @connections = []
      [:picasa, :youtube].each{ |provider|
        account_url = connect_url = destroy_url = nil
        acc = Account.where(provider: provider, shard_id: @current_shard.id).first
        if !acc.nil?
          account_url = acc.ext_url
          destroy_url = settings_shard_language_account_path(@current_shard.shard_languages.first, acc)
        elsif provider == :picasa
          connect_url = Picasa.authorization_url(authorize_albums_url)
        else
          connect_url = settings_shard_language_link_service_path(shard_language_id: @current_shard.shard_languages.first.id, code: provider)
        end
        @connections << {
          name: provider,
          account_url: account_url,
          connect_url: connect_url,
          destroy_url: destroy_url
        }
      }

      # Other Connections - Google Analytics
      [:google_analytics].each{ |provider|
        @current_shard.shard_languages.each{ |shard_language|
          acc = Account.where(provider: provider, shard_language_id: shard_language.id).first
          connect_url = destroy_url = nil
          if acc.nil?
            connect_url = settings_shard_language_link_service_path(shard_language_id: shard_language.id, code: provider)
          else
            destroy_url = settings_shard_language_account_path(shard_language, acc)
          end
          @connections << {
            name: provider,
            connect_url: connect_url,
            destroy_url: destroy_url,
            additional: shard_language.name
          }
        }
      }
      
      # Other Connections - Amazon
      @amazon_settings = @current_shard.amazon_setting
      @connections << {
        name: :amazon
      }

      # Users
      @assignments = @current_shard.assignments
    end

  end
end
