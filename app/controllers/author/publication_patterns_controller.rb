module Author
  class PublicationPatternsController < SpaceController
    load_and_authorize_resource
    layout false
    
    def index
      @patterns = @current_shard.publication_patterns
    end
    
    def new
      
    end
    
    def edit
      
    end
    
    def update
      params[:publication_pattern][:terminals] = params[:publication_pattern][:terminals].split(",").map{ |i| i.to_i }
      @pattern = @current_shard.publication_patterns.find(params[:id])
      @pattern.update_attributes(params[:publication_pattern])
      respond_to do |format|
        format.html
        format.js
      end
    end
    
    def create
      params[:publication_pattern][:terminals] = params[:publication_pattern][:terminals].split(",").map{ |i| i.to_i }
      @pattern = PublicationPattern.new(params[:publication_pattern])
      @pattern.shard = @current_shard
      @pattern.save
      respond_to do |format|
        format.html
        format.js
      end
    end
    
    def destroy
      
    end
  end
end