namespace :spotlight do
  desc "Initialize"
  task :initialize => :environment do
    exhibit = Spotlight::Exhibit.first_or_create(name: 'default')
    # TODO setup user with access to the exhibit
  end
end
