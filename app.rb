$:.unshift File.expand_path(".")   # $: is ruby's $LOAD_PATH
require 'steam-condenser' 
require 'sinatra'
require 'json'
require 'config'
require 'redis'

configure do
    enable :sessions
    set :public_folder, File.dirname(File.expand_path(__FILE__)) + "/public"
    uri = URI.parse(ENV["REDISTOGO_URL"])
    REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
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
    cache = REDIS.get("info-#{id}")
    return cache if cache

    a = SteamId.new(id.to_i, true)
    cache = {:nickname=>a.nickname, :icon_url=>a.icon_url, :friends=>a.friends.map{|x| x.steam_id64.to_s}}.to_json
    # Cache the information for 5 minutes.
    REDIS.setex("info-#{id}", 300, cache)
    return cache
end

post '/ajax/games/' do
    id_list = JSON.parse(params[:ids])
    
    g = {}
    id_list.each do |steam_id|
        begin
            cache = REDIS.get("games-#{steam_id}")
            if cache
                g[steam_id] = JSON.parse(cache)
            else
                a = SteamId.new(steam_id.to_i)
                a.fetch_games
                cache = a.games.map{|k,v| v.name}
                g[steam_id] = cache
                REDIS.setex("games-#{steam_id}", 300, cache.to_json)
            end
        rescue
            g[steam_id] = []
        end
    end
    g.to_json
end
