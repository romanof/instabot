#!/usr/bin/ruby
require_relative "../common/selenium"
require_relative "../common/db"

def set_follower_types
  get_untyped_followers(100).each do |follower|
    name = follower["name"]

    begin
      driver.navigate.to "https://www.instagram.com/#{name}/"
    rescue Net::ReadTimeout
      next
    end

    Selenium::WebDriver::Wait.new(timeout: 5).until { driver.find_element(xpath: "//footer//nav") }

    type = "public"
    begin
      element = driver.find_element(xpath: "//main/article/div/div/h2")
      type = "private" if element.text() == "This Account is Private"
    rescue Selenium::WebDriver::Error::NoSuchElementError
      begin
        element = driver.find_element(xpath: "//div/h2")
        type = "deleted" if element.text() == "Sorry, this page isn't available."
      rescue Selenium::WebDriver::Error::NoSuchElementError
      end
    end

    puts " #{name} - #{type}"

    if type
      update_follower_type name, type
    end
  end

  driver.close
end
