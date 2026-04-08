class SensorsController < ApplicationController
  # see controllers => concerns => location_fill.rb module
  include LocationFill
  def index
    # from module location_fill
    @locations_fill = locations_with_last_fill

  end
end
