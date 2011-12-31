require 'steam-condenser' 
require 'sinatra'

get '/' do 
    haml :index
end

post '/' do
    a = SteamId.new(params[:steam_id])
    a.fetch_games
    str = haml :index 
    str << "<h1>What #{params[:steam_id]} owns:</h1>"
    a.games.each do |k,e|
        str << e.name + "<br />"
    end

    str 
end
