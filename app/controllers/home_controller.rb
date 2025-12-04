class HomeController < ApplicationController
  allow_unauthenticated_access only: [ :index, :features ]

  def index
  end

  def features
  end
end
