#!/usr/bin/env ruby

require_relative '../../lib/admix/admix'

app = AdmixApp.new(InstalledApplication::AuthenticationManager)
app.start_from_settings
app.print_statistics