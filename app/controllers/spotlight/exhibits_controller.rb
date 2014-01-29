class Spotlight::ExhibitsController < ApplicationController
  before_filter :default_exhibit

  def edit
    authorize! :create, @exhibit
  end

  protected

  def default_exhibit
    @exhibit = Spotlight::Exhibit.default
  end
end
