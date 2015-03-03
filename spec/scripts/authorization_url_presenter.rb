require 'json'

require_relative '../../lib/admix/google_drive/google_controller'
require_relative '../../lib/admix/google_drive/google_client_settings'
require_relative '../../spec/admix/spec_helper'

google_settings = GoogleClientSettings.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], ENV['GOOGLE_EMAIL'])
do_not_change_me_file = File.expand_path('../../assets/DO_NOT_OPEN_OR_CHANGE_ME.json',__FILE__)

File.delete(do_not_change_me_file)

controller = GoogleController.new(google_settings, do_not_change_me_file)
controller.setup_controller
controller.access_token

tokens = JSON.parse(File.read(do_not_change_me_file))

refresh = tokens['refresh_token']
print("\n#######################################################################\n")
print("\nRefresh Token: #{refresh}\nCopy this value to ENV['GOOGLE_REFRESH_TOKEN'] in spec_helper.rb\n")
print("\n#######################################################################\n")
