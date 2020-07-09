class SafariSubscription < ApplicationRecord
  has_many :subscriptions, :dependent => :destroy

  def notify(title, body, url_args)
    app = Rpush::Apns::App.find_by_name("crush_curve")

    Rpush::Apns::Notification.create!(
      app: app,
      device_token: device_token,
      alert: {
        title: title,
        body: body
      },
      url_args: url_args
    )
  end

  def self.generate_package!(auth_token)
    path = "tmp/pushPackage-#{ auth_token }.zip"
    website_params = {
      websiteName: "Plet de Curve",
      websitePushID: "web.nl.pletdecurve",
      allowedDomains: ["https://pletdecurve.nl"],
      urlFormatString: "https://pletdecurve.nl/%@",
      authenticationToken: auth_token,
      webServiceURL: "https://pletdecurve.nl/push"
    }
    iconset_path = 'app/assets/images/safari_iconset'
    certificate = 'certs/crush.p12'
    intermediate_cert = 'certs/AppleWWDRCA.cer'
    package = PushPackage.new(website_params, iconset_path, certificate, ENV['CERT_PWD'], intermediate_cert)
    package.save(path)
    return path
  end
end
