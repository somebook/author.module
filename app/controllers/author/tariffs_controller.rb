module Author
  class TariffsController < SpaceController
    include ActiveMerchant::Billing::Integrations
    # load_and_authorize_resource
    # before_filter :shard_languages, except: [:publish, :destroy, :show]
    before_filter :create_notification, except: [:index]
    
    def index
      
    end
    
    def paid
      ap params
    end
    
    def success
      ap params
    end
    
    def fail
      ap params
    end
    
    def create_notification
      @notification = Robokassa::Notification.new(request.raw_post, secret: "qwerty123")
    end
    
  end
end