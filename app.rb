$:.unshift File.expand_path(".")   # $: is ruby's $LOAD_PATH
require 'steam-condenser' 
require 'sinatra'
require 'json'
require 'config'

configure do
    enable :sessions
    set :public_folder, File.dirname(File.expand_path(__FILE__)) + "/public"
end

get '/' do 
    haml :first if not session[:steam_id]
end

post '/' do
    a = SteamId.new(params[:steam_id], true)
    @steam_id = a.steam_id64
    #a.fetch_games
    #a.fetch
    #@username = a.nickname
    #@games = a.games
    @username = "tdooner"
    @games = []
    @friends = []

    haml :gamelist
end

get '/ajax/info/:id' do |id|
    a = SteamId.new(id.to_i, true)
    
    {:nickname=>a.nickname, :icon_url=>a.icon_url, :friends=>a.friends.map{|x| x.steam_id64.to_s}}.to_json
end

post '/ajax/games/' do
    id_list = JSON.parse(params[:ids])
    
    g = {}
    id_list.each do |steam_id|
        begin
            a = SteamId.new(steam_id.to_i)
            a.fetch_games
            g[steam_id] = a.games.map{|k,v| v.name}
        rescue
            g[steam_id] = []
        end
    end
    g.to_json
end
