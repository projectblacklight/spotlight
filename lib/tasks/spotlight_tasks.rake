namespace :spotlight do
  desc "Create an initial admin user and default exhibit"
  task :initialize => :environment do
    puts "Creating an initial admin user."
    print "Email: "
    email = $stdin.gets.chomp
    begin
      system "stty -echo"
      print "Password: "
      password = $stdin.gets.chomp
      puts "\n"
    ensure
      system "stty echo"
    end

   
    u = User.create!(email: email, password: password)
    Spotlight::Role.create(user: u, exhibit: Spotlight::Exhibit.default, role: 'admin')
    puts "User created."
  end
end
