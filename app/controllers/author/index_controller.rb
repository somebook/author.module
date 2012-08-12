class Author::IndexController < Author::SpaceController
  def index
    #statisctics
    @statistics = {
      blog: @current_shard.posts.with_stream(:personal).count,
      news: @current_shard.posts.with_stream(:official).count,
      events: @current_shard.events.count,
      albums: @current_shard.albums.count,
      videos: @current_shard.videos.count,
      audio_albums: @current_shard.audio_albums.count,
      static_pages: @current_shard.static_pages.count
    }
    
    #drafts
    @drafts = @current_shard.posts.drafted.all
    
    #google analytics
    @domains = []
    @current_shard.shard_languages.each{ |sl|
      @domains.push(name: sl.domain, account: sl.accounts.find_by_provider(:google_analytics))
    }
    
    @domains.each{ |domain|
      next if domain[:account].nil?
      Garb::Session.access_token = domain[:account].ga_access_token
      profiles = Rails.cache.fetch("ga_profiles#{domain[:account].id}", expires_in: 5.hours) { Garb::Management::Profile.all }
      if domain[:account].additional.nil?
        if profiles.count == 1
          domain[:account].update_attribute(:additional, profiles.first.web_property_id)
          profile = profiles.detect { |p| p.web_property_id == domain[:account].additional }
          domain[:report] = Rails.cache.fetch("ga_results#{domain[:account].id}", expires_in: 5.hours) { ViewsVisits.results(profile) }
        else
          domain[:profiles] = profiles.map{ |p| { name: p.name, code: p.web_property_id } }
        end
      else
        profile = profiles.detect { |p| p.web_property_id == domain[:account].additional }
        domain[:report] = Rails.cache.fetch("ga_results#{domain[:account].id}", expires_in: 5.hours) { ViewsVisits.results(profile) }
      end
    }
  end
end