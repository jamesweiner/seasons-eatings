require 'sinatra'
require 'open-uri'
require 'multi_json'
require 'date'

def current_month
  Date::MONTHNAMES[Date.today.month][0,3].downcase
end

helpers do
  def to_sentence(list)
    list.map! {|i| "<span class='item'>#{i}</span>" }
    last_ones = list.pop, list.pop
    list.push(last_ones.compact.reverse.join(" and "))
    list.join(", ")
  end
end

get "/" do
  url = "http://api.scraperwiki.com/api/1.0/datastore/sqlite?format=jsondict&name=bbc_seasonal_foods_by_month&query=select%20*%20from%20%60swdata%60"
  data = MultiJson.decode(open(url).read).inject({}) { |h, d| h[d["name"]] = d; h }

  @now_in_season = MultiJson.decode(data[current_month]["now_in_season"])
  @last_chance = MultiJson.decode(data[current_month]["last_chance"])
  @now_out_of_season = MultiJson.decode(data[current_month]["now_out_of_season"])
  
  @featured = @now_in_season.shuffle.first
  @now_in_season.delete(@featured)

  erb :publication
end