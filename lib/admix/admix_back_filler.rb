#!/usr/bin/env ruby

require_relative '../../lib/admix/admix'

@controller = AdmixController.new
@controller.start_app
@controller.back_fill_cfd_reports