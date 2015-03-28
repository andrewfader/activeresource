require_relative '../lib/active_resource/'
require 'webmock/rspec'
require 'vcr'

class MockClass < ActiveResource::Base
  self.site = 'http://foo.com/'
  self.element_name = 'deal'
end

describe ActiveResource::Connection do
  it 'can create a resource from a webmock json response' do
    stub_request(:get, "http://foo.com/deals/238550.json").
      with(:headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :headers => {}, :body => <<-HEREDOC
  {"id":238550,"dealUrl":"https://www.foo.com/events/238550","smallImageUrl":"http://lp-img-production.foo.com/attachments/391499050/238550-hero.jpg","mediumImageUrl":"http://lp-img-production.foo.com/attachments/391499054/238550-landscape.jpg","largeImageUrl":null,"title":"Brighten Up","pitchHtml":"","announcementTitle":"Plus Size Dresses For Spring","status":"open","expiresAt":1427032800,"startAt":1426604400,"startAtSecondRow":1426608000,"isSoldOut":false}
                HEREDOC
               )
      MockClass.find(238550).id.should == 238550
  end

  it 'can create a resource from a VCR cassette' do
    VCR.configure do |config|
      config.cassette_library_dir = "fixtures/vcr_cassettes"
      config.hook_into :webmock
    end

    WebMock.allow_net_connect!
    VCR.use_cassette(:deal) do
      MockClass.find(238550).event.id.should == 238550
    end
  end
end
