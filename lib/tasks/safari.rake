require 'push_package'
namespace 'safari' do :env
  desc "Register app"
  task :register_app => [:environment] do
    app = Rpush::Apns::App.new
    app.name = "crush_curve"
    app.certificate = File.read("certs/crush.pem")
    app.environment = "production"
    app.password = ENV['CERT_PWD']
    app.connections = 1
    app.save!
  end
end
