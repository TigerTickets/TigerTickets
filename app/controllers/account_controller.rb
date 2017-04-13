class AccountController < ApplicationController
  before_action CASClient::Frameworks::Rails::Filter
  def mytix
    netid = session[:cas_user]
    buyRequests = BuyRequest.where(netid: netid).where(:status => ["waiting-for-match", "pending", "completed"]).joins("INNER JOIN shows ON shows.id = buy_requests.show_id")
    sellRequests = SellRequest.where(netid: netid).where(:status => ["waiting-for-match", "pending", "completed"]).joins("INNER JOIN shows ON shows.id = sell_requests.show_id")

    # This should not cause duplicate show IDs because you cannot have a buy and a sell request for the same show.
    showIDs = buyRequests.distinct.pluck(:show_id) + sellRequests.distinct.pluck(:show_id)
    shows = Show.where(:id => showIDs)
    response = { :status => "ok", :netid => netid, :buyrequests => buyRequests, :sellrequests => sellRequests, :shows => shows}
    render json: response
  end
end
