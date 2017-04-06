class BuyController < ApplicationController
  # Disables a poerful security feature but is needed for debugging. With this line, this controller is voulnerable to XSRF attcks.
  skip_before_action :verify_authenticity_token
  before_filter CASClient::Frameworks::Rails::Filter
  def buyrequest
    # This is the action exposed with POST /buy
    show_id = params[:show_id]
    netid = session[:cas_user]
    if not show_id
      response = { :status => "bad request", :netid => netid, :reason => 'missing show_id'}
      render json: response
      return
    end
    buyRequest = BuyRequest.create(netid: netid, status: 'waiting-for-match', show_id: show_id)
    MatchRequestsJob.perform_later
    response = { :status => "ok", :netid => netid, :show_id => show_id, :buy_request_id => buyRequest.id}
    render json: response
  end

  def cancelbuy
    # This is the action exposed with POST /cancelbuy
    buy_request_id = params[:buy_request_id]
    netid = session[:cas_user]
    if not buy_request_id
      response = { :status => "bad request", :netid => netid, :reason => 'missing buy_request_id'}
      render json: response
      return
    end
    # This should stop someone from deleting someone else's buy request.
    deletedNumber = BuyRequest.where(netid: netid).where(id: buy_request_id).where(:status => ["waiting-for-match", "pending"]).destroy_all.length
    MatchRequestsJob.perform_later
    if deletedNumber == 0
      response = {:status => "bad request", :netid => netid, :reason => 'no buy requests found'}
      render json: response
    else
      response = {:status => "ok", :netid => netid, :buy_request_id => buy_request_id}
      render json: response
    end
  end

end