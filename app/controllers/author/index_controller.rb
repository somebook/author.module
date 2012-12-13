module Author
class IndexController < SpaceController

  def index
    # Statisctics
    @statistics = {
      blog: @current_shard.posts.with_stream(:personal).count,
      news: @current_shard.posts.with_stream(:official).count,
      events: @current_shard.events.count,
      albums: @current_shard.albums.count,
      videos: @current_shard.videos.count,
      audio_albums: @current_shard.audio_albums.count,
      static_pages: @current_shard.static_pages.count
    }

    # Drafts
    @drafts = @current_shard.posts.drafted.all
    
    # Import
    @streams = []
    @streams << :personal if can?(:blog, Post.new(shard_id: @current_shard.id))
    @streams << :official if can?(:news, Post.new(shard_id: @current_shard.id))
    @accounts_old = []
    Service.find_all_by_import_enabled(true).each{ |service|
      service.accounts.where('shard_id = ?', @current_shard.id).each{ |acc|
        @accounts_old << acc
      }
    }
    @accounts = {}
    @accounts_old.each{ |account|
      @accounts[account.provider] = {} if @accounts[account.provider].nil?
      if account.stream.nil?
        @accounts[account.provider][account.shard_language_id] = account
      else
        @accounts[account.provider][account.shard_language_id] = {} if @accounts[account.provider][account.shard_language_id].nil?
        @accounts[account.provider][account.shard_language_id][account.stream_name] = account
      end
    }

    # Google Analytics
    @domains = []
    begin
      if @current_shard.settings.has_site
        @domains = @current_shard.shard_languages.map{ |shard_language|
          { name: shard_language.domain, account: @current_shard.accounts.find_by_provider(:google_analytics) }
        }

        @domains.each{ |domain|
          next if domain[:account].nil?

          Garb::Session.access_token = domain[:account].google_access_token
          profiles = Rails.cache.fetch("ga_profiles#{domain[:account].id}", expires_in: 5.hours) {
            Garb::Management::Profile.all
          }

          if domain[:account].additional.nil?
            if profiles.count == 1
              domain[:account].update_attribute(:additional, profiles.first.web_property_id)
              profile = profiles.detect { |profile| profile.web_property_id == domain[:account].additional }
              domain[:report] = Rails.cache.fetch("ga_results#{domain[:account].id}", expires_in: 5.hours) {
                ViewsVisits.results(profile)
              }
            else
              domain[:profiles] = profiles.map{ |profile| { name: profile.name, code: profile.web_property_id } }
            end
          else
            profile = profiles.detect { |profile| profile.web_property_id == domain[:account].additional }
            domain[:report] = Rails.cache.fetch("ga_results#{domain[:account].id}", expires_in: 5.hours) {
              ViewsVisits.results(profile)
            }
          end
        }
      rescue
        
      end
    end
  end
  
  private
  
  def set_section_class
    @section_class = "index"
  end

end
end
