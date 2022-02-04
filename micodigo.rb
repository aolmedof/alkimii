require 'rest-client'
require 'json'
require 'csv'
require 'net/http'
require 'uri'

response = RestClient.get('https://dog-facts-api.herokuapp.com/api/v1/resources/dogs/all')

results = JSON.parse(response.to_str)

$i = 0
$noFacts = 200
$numWords = 0
$dogTimes = 0

CSV.open("output.csv", "a+") do |csv|

# Firts loop for Summary Table:
while $i < $noFacts do
  fact = results[$i]['fact']

  $numWords = $numWords + fact.split.size

  $dogTimes = $dogTimes + fact.scan(/dog/).count

  $i +=1
end

csv << ["Number of Facts",$noFacts]
csv << ["Number of Words in all facts", $numWords]
csv << ["Number of Times Dog is Mentioned", $dogTimes]

# second loop for Dog facts Table
$i = 0
while $i < $noFacts do

  fact = results[$i]['fact']

  res = Net::HTTP.post URI('https://api.codeq.com/v1'), {"user_id" => "38a858ab" , "user_key" => "f64ea502-d8ec-477b-8e28-258a2fd4aa2a", "text" => fact}.to_json, "Content-Type" => "application/json"

  resJson = JSON.parse(res.body.to_str)

  # get the sentiment
  #print resJson['sentences'][0]['sentiments'][0]
  #get the number of words
  $num = fact.split.size
  csv << [$i+1,$num,resJson['sentences'][0]['sentiments'][0], resJson['sentences'][0]['sarcasm'][0], resJson['sentences'][0]['speech_acts']]

  $i +=1
end

end