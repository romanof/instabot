#!/usr/bin/ruby
require_relative "../common/selenium"
require_relative "../common/db"
require_relative "../helper/common"

def comment lang, num
  if @comments.nil?
    @comments = {
      :eng => ["nice pic!","awesome!!!","great pic!"],
      :rus => ["круто!","прикольно!","класс!"]
    }
  end
  @comments[lang.to_sym][num]
end

def publicengage user, lang
  login user

  get_public_non_engaged(user, 10).each do |record|
    name = record["name"]

    driver.navigate.to "https://www.instagram.com/#{name}/"

    random = rand(2..8)

    photos = nil
    Selenium::WebDriver::Wait.new(timeout: 26).until {
      photos = driver.find_elements(xpath: "//main//article/div//a[//img]")
    }

    links = []
    links.push photos[0].attribute("href").to_s if !photos[0].nil?
    links.push photos[1].attribute("href").to_s if !photos[1].nil?
    links.push photos[random].attribute("href").to_s if !photos[random].nil?

    links.each do |link|
      puts link
      driver.navigate.to link

      like = nil
      Selenium::WebDriver::Wait.new(timeout: 60).until {
        begin
          like = driver.find_element(xpath: "//article//span[contains(@class, \"coreSpriteHeartOpen\")]")
        rescue Selenium::WebDriver::Error::NoSuchElementError
        end
      }
      like.click unless like.nil?
    end

    begin
      text = driver.find_element(xpath: "//form/textarea")
      text.send_keys comment(lang, rand(0..2))
      text.submit
    rescue Selenium::WebDriver::Error::NoSuchElementError
    end

    record_public_engagement user, name
  end

  driver.close
end