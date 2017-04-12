class ShowsViewController < ApplicationController
  def getshows
  	shows = Show.where(["time > ?", DateTime.current])
    showsResponse = []
    for show in shows
      showsResponse << {:id => show['id'], :name => show['title'], :time => show['time'].to_i, 
        :location => show['location'], :group => show['group'], 
        :image => show['img'],
        :buyreq => 0,
        :sellreq => 1,
        :price => 0}
    end
    response = { :status => "ok", :shows => showsResponse}
    render json: response
  end
end
