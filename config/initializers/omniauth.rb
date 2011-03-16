Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '142787879122425', '041a7ccf9376410a21dba26cdaf715f1'
end
