['3.2.20', '4.0.13', '4.1.10', '4.2.1'].each do |version_number|
  clean_number = version_number.gsub(/[<>~=]*/, '')

  appraise "rails#{ clean_number }" do
    gem "rails", version_number
    gem "rspec-rails"
  end

  appraise "active#{ clean_number }" do
    gem "activesupport", version_number
    gem "activerecord", version_number
  end
end

appraise 'mongoid3.1.6' do
  gem 'mongoid', '3.1.6'
end

appraise 'data_mapper1.2.0' do
  gem 'data_mapper', '1.2.0'
  gem 'dm-sqlite-adapter', '1.2.0'
end
