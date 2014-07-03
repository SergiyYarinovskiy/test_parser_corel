require 'nokogiri'
require "capybara"
require 'capybara/dsl'
# require 'capybara-webkit'

# for debug
require 'benchmark'
require 'capybara-screenshot'
require 'awesome_print'

# TODO: error checker
class ParseCoral
  include Capybara::DSL
  URL = 'http://online.coral.ru/UI/Package/Search.aspx?/SearchHotel.aspx'

  def initialize
    Capybara.default_driver = :selenium
    Capybara.default_wait_time = 5
    Capybara.app_host = URL
    # for debug
    Capybara.save_and_open_page_path = File.join(File.dirname(__FILE__), "screens")
  end

  def look_for_toures
    visit('/')

    fill_form_area_by('Минск')
    fill_to_country_by('Испания')
    submit_product_search_form

    (p "captcha found"; sleep(10)) if captcha_present?

    parse_toures
  end

  def parse_toures
    # screenshot_and_save_page
    # first <tr> is a table headers
    # last <tr> is a pagination
    html_node = Nokogiri::HTML(page.html).css('#searchGridResults table.gridViewTable tr')
    json_node = []
    html_node.each do |tr|
      tmp = []
      tr.css('td').each{ |td| tmp << td.text }
      json_node << tmp
    end
    json_node
  end

  def captcha_present?
    page.has_selector?(:id, '_CaptchaImageWindow__StaticWindow') &&
      page.find('#_CaptchaImageWindow__StaticWindow').visible?
  end

  # def spinner_shown?
  #   page.has_selector?(:id, 'dxcpLoadingPanelWithContent_Coral')
  # end

  def fill_form_area_by(value)
    page.select(value, from: 'ctl00$ContentPlaceHolder1$fromArea_SEL')
  end

  def fill_to_country_by(value)
    page.select(value, from: 'ctl00$ContentPlaceHolder1$toCountry_SEL')
  end

  def submit_product_search_form()
    page.execute_script("eval(_BtnProductSearch.clickFnc);")
  end
end


Benchmark.bm do |x|
  agent = ParseCoral.new

  x.report("run: ") do
    rez = agent.look_for_toures()
    ap rez
  end

end