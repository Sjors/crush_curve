Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    resource '*',
             headers: :any,
             expose: ['Authorization'],
             methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end

Rails.application.config.hosts << "pletdecurve.nl"

Rails.application.config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-XSS-Protection' => '1; mode=block',
  'X-Content-Type-Options' => 'nosniff',
  'X-Download-Options' => 'noopen',
  'X-Permitted-Cross-Domain-Policies' => 'none',
  'Referrer-Policy' => 'strict-origin-when-cross-origin'
}
