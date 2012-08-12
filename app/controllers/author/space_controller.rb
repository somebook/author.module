class Author::SpaceController < ApplicationController
  force_ssl if Rails.env.production?
  layout "author"
  before_filter :authenticate_user!, :set_shard, :authenticate_author!, :check_pending_social_contents, :set_accessible_shards

  def set_my_shard
    s=Shard.find(params[:shard_id])
    if(current_user.has_role_for_shard?(:author, s) ||
       current_user.has_role_for_shard?(:master, s))
      cookies[:current_shard_id]=s.id
    end
    redirect_to author_root_path
  end

private

  def authenticate_author!
    unless (user_signed_in? and
      @current_shard and
      (current_user.has_role_for_shard?(:author, @current_shard) or
       current_user.has_role_for_shard?(:master, @current_shard)))
       ap "REDIRECTING CAUSE #{current_user.email} "+
         "has #{current_user.has_role_for_shard?(:author, @current_shard)} or"+
         " #{current_user.has_role_for_shard?(:author, @current_shard)} "+
         "on #{@current_shard.name}" if current_user && @current_shard
       redirect_to new_user_session_path
    end
  end

  def set_shard
    @current_shard=catch(:cookie_shard) do
      if(cookies[:current_shard_id])
        s=Shard.find(cookies[:current_shard_id])
        if(s)
          if (current_user.has_role_for_shard?(:author, s) ||
              current_user.has_role_for_shard?(:master, s))
            throw :cookie_shard, s
          end
        end
      end
      if(s=current_user.all_shards_for_roles([:master,:author]))
        throw :cookie_shard, s[0]
      end
      if(current_user.has_role?(:admin))
        throw :cookie_shard, Shard.first
      end
      nil
    end
  end


  def check_pending_social_contents
    @pending_social_contents=@current_shard.social_contents.with_status(:pending) if current_user.has_role_for_shard?(:master, @current_shard)
  end

  def set_accessible_shards
    @accessible_shards=current_user.all_shards_for_roles([:author,:master])
  end
end
