require 'eventmachine'
require 'em-websocket'
require 'watir'

CONNECTION = []

class EM::WebSocket::Connection
  def remote_addr
    get_peername[2,6].unpack('nC4')[1..4].join('.')
  end
end

class TargetConnection < EventMachine::WebSocket::Connection
  def initialize(opt={})
    super
    onopen {on_open}
    onmessage {|message| on_message(message)}
    onclose {on_close}
  end

  def on_open
    Target.add_connection self
    puts "#{Time.now} #{self.remote_addr} connection"
  end

  def on_message(message)
    puts "#{Time.now} #{message}"

    message_split = message.split()
    target_username = message_split[0]
    target_password = message_split[1]
    target_link = message_split[2]

    # Connect targer.my.com
    browser = Watir::Browser.new :phantomjs
    browser.goto 'https://target-sandbox.my.com'

    # Click "Войти"
    browser.span(class: "ph-button__inner_profilemenu_signin").click

    # Enter sign parameters and click submit button
    browser.text_field(:name, 'login').set target_username
    browser.text_field(:name, 'password').set target_password
    browser.button(class: "button_submit").click
    sleep 10

    if browser.link(class: 'pad-groups-control-panel__button_create').exists?
        browser.link(class: 'pad-groups-control-panel__button_create').click
        sleep 20
        browser.text_field(class: 'js-setting-pad-url').set target_link
        sleep 10
        browser.screenshot.save "#{self.remote_addr} #{Time.now} screenshot.png"
        browser.span(text: 'LEADERBOARD').click if browser.span(text: 'LEADERBOARD').exists?
        sleep 10
        browser.span(class: "js-form-element" ).click if browser.span(class: "js-form-element" ).exists?
        sleep 20

        browser.screenshot.save "#{self.remote_addr} #{Time.now} screenshot.png"
        browser.close
    else
      puts "#{Time.now} #{self.remote_addr} ERROR wrong name or password"
    end
  end

  def on_close
    Target.delete_connection self
  end
end


module Target
  module_function
  def add_connection(connection)
    puts "#{Time.now} #{connection.remote_addr} new connection"
    CONNECTION.push connection
  end

  def delete_connection(connection)
    puts "#{Time.now} connection closed"
    CONNECTION.delete connection
  end
end

PHANTOMJS_PATH  = ENV['PHANTOMJS_PATH']
if PHANTOMJS_PATH.nil?
    puts "PHANTOMJS_PATH enviroment variable must be setted!"
    exit
end

Selenium::WebDriver::PhantomJS.path = PHANTOMJS_PATH 

EM.run do
  EM.start_server '0.0.0.0', '8080', TargetConnection
end