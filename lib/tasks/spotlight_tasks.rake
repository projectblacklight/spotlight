namespace :spotlight do
  desc "Create an initial admin user and default exhibit"
  task :initialize => :environment do
    puts "Creating an initial admin user."
    print "Email: "
    email = $stdin.gets.chomp
    password = prompt_password
    u = User.create!(email: email, password: password)
    Spotlight::Role.create(user: u, exhibit: nil, role: 'admin')
    puts "User created."
  end

  desc "Create a new exhibit"
  task :exhibit => :environment do
    print "Exhibit title: "
    title = $stdin.gets.chomp

    exhibit = Spotlight::Exhibit.create!(title: title)

    puts "Who can admin this exhibit?"
    print "Email: "
    email = $stdin.gets.chomp
   
    u = User.find_by(email: email)
    unless u
      puts "User not found."
      password = prompt_password
      u = User.create!(email: email, password: password)
    end
    Spotlight::Role.create(user: u, exhibit: exhibit, role: 'admin')
    puts "Exhibit created."
  end

  desc "Import an exhibit"
  task import: :environment do
    exhibit = Spotlight::Exhibit.create title: "Imported Exhibit"
    exhibit.import(JSON.parse(STDIN.read))
    puts Spotlight::ExhibitExportSerializer.new(exhibit).to_json
  end

  def prompt_password
    begin
      system "stty -echo"
      print "Password: "
      password = $stdin.gets.chomp
      puts "\n"
    ensure
      system "stty echo"
    end
    password
  end

  namespace :check do
    desc "Check the Solr connection and controller configuration"
    task :solr, [:model_name] => ['blacklight:check:solr', :environment] do |_, args|
      errors = 0
      verbose = ENV.fetch('VERBOSE', false).present?

      puts "[#{Blacklight.solr.uri}]"

      print " - atomic updates:"
      begin
        id = 'test123'
        field = "test_#{Spotlight::Engine.config.solr_fields.string_suffix}"
        Blacklight.solr.add blacklight_config.solr_document_model.unique_key.to_sym => id, field => 'some-string'
        Blacklight.solr.update data: [{blacklight_config.solr_document_model.unique_key => id, field => { set: 'a-new-string' }}].to_json, headers: { 'Content-Type' => 'application/json' }
        Blacklight.solr.delete_by_id id
        print " OK\n"
      rescue Exception => e
        errors += 1
        puts e.to_s
      end

      exit 1 if errors > 0
    end
end

end
