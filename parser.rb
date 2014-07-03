require 'nokogiri'
require "capybara"
require 'capybara/dsl'
require 'selenium/webdriver'

# for debug
require 'benchmark'
require 'capybara-screenshot'
require 'awesome_print'


# TODO: error checker
class ParseCoral
  include Capybara::DSL
  URL = 'http://online.coral.ru/UI/Package/Search.aspx?/SearchHotel.aspx'

  def initialize
    Capybara.run_server = false
    Capybara.current_driver = :selenium
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

  def check_regions_by(value)
    page.check(value)
  end

  def fill_date_from_by(value)
    page.fill_in('txtDateFrom', value)
  end

  def fill_date_to_by(value)
    page.fill_in('txtDateTo', value)
  end

  def fill_adults_by(value)
    page.select(value, from: 'ctl00$ContentPlaceHolder1$cbAdult_SEL')
  end

  def fill_children_by(value)
    page.select(value, from: 'ctl00$ContentPlaceHolder1$cbChild_SEL')
  end

  def fill_nights_begin_by(value)
    page.select(value, from: 'ctl00$ContentPlaceHolder1$cbNightBegin_SEL')
  end

  def fill_nights_end_by(value)
    page.select(value, from: 'ctl00$ContentPlaceHolder1$cbNightEnd_SEL')
  end

  def fill_min_price_by(value)
    page.fill_in('txtMinPrice', value)
  end

  def fill_max_price_by(value)
    page.fill_in('txtMaxPrice', value)
  end

  def fill_currency_by(value)
    page.select(value, from: 'ctl00$ContentPlaceHolder1$cbCurrency_SEL')
  end

  def fill_meal_by(value)
    page.select(value, from: 'ctl00$ContentPlaceHolder1$cbMeal_SEL')
  end

  def fill_category_by(value)
    page.select(value, from: 'ctl00$ContentPlaceHolder1$cbCategory_SEL')
  end

  def fill_room_type_by(value)
    page.select(value, from: 'ctl00$ContentPlaceHolder1$cbRoomType_SEL')
  end

  def check_hotel_con_by(value)
    page.check(value)
  end

  def check_all_hotel
    page.check('all_Hot_Chc')
  end

  def check_hotel_by(value)
    page.check(value)
  end

  def check_stop_sale
    page.check('chcStopSale')
  end

  def check_discount_hotels
    page.check('chcDiscountHotels')
  end

  def check_flights
    page.check('chcFlight')
  end

  def check_confirm
    page.check('chcOnlyConfirm')
  end

  def check_recommended
    page.check('chcRecommended')
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