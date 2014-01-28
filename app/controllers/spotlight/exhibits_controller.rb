class Spotlight::ExhibitsController < ::ApplicationController
  before_filter :create_exhibit

  def edit
    authorize! :create, @exhibit
  end

  protected

  def create_exhibit
    @exhibit = Spotlight::Exhibit.first_or_create(name: 'default')
  end
end
