class Author::ShardUsersController < Author::SpaceController
  load_and_authorize_resource :class => 'Assignment'
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @current_shard }
    end
  end
  def add
    note='User not found or already exists'
    if(u=User.find_by_email(params[:user_email]))
      if(!u.has_role_for_shard?(:author,@current_shard))
        note = 'User added'
        a=u.assignments.build(:role_id => Role.find_by_name('author').id,
                              :shard_id => @current_shard.id)
        a.save!
      end
    end
    respond_to do |format|
      format.html { redirect_to author_shard_users_path, notice: note }
    end
  end
  def revoke
    assignment=@current_shard.assignments.for_role(:author).find(params[:id]) || not_found
    if(assignment.destroy)
      note = 'Assignment revoked'
    end
    respond_to do |format|
      format.html { redirect_to author_shard_users_path, notice: note }
    end
  end
end
