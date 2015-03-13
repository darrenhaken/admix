#!/usr/bin/env ruby

require_relative '../../lib/admix/admix'

app = AdmixApp.new()
app.start_app
app.print_statistics