class SafariSubscription < ApplicationRecord
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
