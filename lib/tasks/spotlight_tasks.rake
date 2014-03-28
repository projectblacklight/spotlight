namespace :spotlight do
  desc "Create an initial admin user and default exhibit"
  task :initialize => :environment do
    puts "Creating an initial admin user."
    print "Email: "
    email = $stdin.gets.chomp
    password = prompt_password
    u = User.create!(email: email, password: password)
    Spotlight::Role.create(user: u, exhibit: nil, role: 'admin')
    Spotlight::Role.create(user: u, exhibit: Spotlight::Exhibit.default, role: 'admin')
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
end
