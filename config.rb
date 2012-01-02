# Configure this for your own environment:
if not ENV["REDISTOGO_URL"]
    ENV["REDISTOGO_URL"] = 'redis://username:password@my.host:6789'
end
