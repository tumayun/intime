class PingController < ApiBaseController
  before_filter :auth_api
  def mock
    render :json=>{:isSuccessful=>true,
      :message =>'success',
      :statusCode =>'200',
      :data=>{      
      }
     }
  end
end
