require 'steam-condenser' 
require 'sinatra'
require 'json'

configure do
    enable :sessions
    set :public_folder, File.dirname(File.expand_path(__FILE__)) + "/public"
end

get '/' do 
    haml :first if not session[:steam_id]
end

post '/' do
    a = SteamId.new(params[:steam_id])
    a.fetch_games
    a.fetch
    @username = a.nickname
    @games = a.games
    @friends = a.friends

    haml :gamelist
end

get '/ajax/:id' do |id|
    a = SteamId.new(id.to_i, true)
    
    {:nickname=>a.nickname, :icon_url=>a.icon_url}.to_json
end
