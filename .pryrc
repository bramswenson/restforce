require 'dotenv'
Dotenv.load
require 'restforce'
require 'restforce/middleware'

@client = Restforce.new({
  host: ENV['SALESFORCE_HOST'],
  username: ENV['SALESFORCE_USERNAME'],
  password: ENV['SALESFORCE_PASSWORD']
})
