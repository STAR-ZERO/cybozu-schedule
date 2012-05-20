# -*- coding: utf-8 -*-
require 'rest_client'
require 'rexml/document'
require 'time'

module CybozuSchedle
  class Connection
    LOGIN_SERVICE = 'Base'
    LOGIN_METHOD = 'BaseGetUsersByLoginName'
    SCHEDULE_SERVICE = 'Schedule'
    SCHEDULE_METHOD = 'ScheduleGetEventsByTarget'

    attr_reader :error
    def initialize(option)
      @option = option
      @user = nil
      @error = nil
    end

    def login
      params = "<parameters xmlns=\"\"><login_name>#{@option.username}</login_name></parameters>"
      response = get(LOGIN_SERVICE, LOGIN_METHOD, params)

      if response
        doc = REXML::Document.new(response)
        elem = doc.elements['soap:Envelope/soap:Body/base:BaseGetUsersByLoginNameResponse/returns/user']
        id = elem.attributes['key']
        name = elem.attributes['name']
        @user = User.new(id, name)
      end

      return @user
    end

    def schedule
      time = Time.now
      start_time = time.strftime('%Y-%m-%dT%H:%M:%S')
      time = time + 60 * (@option.interval + 1)
      end_time = time.strftime('%Y-%m-%dT%H:%M:%S')

      params = "<parameters xmlns=\"\" start=\"#{start_time}\" end=\"#{end_time}\"><user id=\"#{@user.id}\"></user></parameters>"
      response = get(SCHEDULE_SERVICE, SCHEDULE_METHOD, params)

      schedule_arr = nil
      if response
        schedule_arr = []

        doc = REXML::Document.new response

        elems = doc.elements
        elems.each('soap:Envelope/soap:Body/schedule:ScheduleGetEventsByTargetResponse/returns/schedule_event') do |elem|
          #タイトル
          title = elem.attributes["detail"]

          #開始時間
          time = Time.parse(elem.get_elements('when/datetime')[0].attributes['start'])
          if !@option.start_over && (time <=> Time.now) < 0
            next
          end
          time = time + 60 * 60 * 9
          start_time = time.strftime('%H:%M')

          #終了時間
          time = Time.parse(elem.get_elements('when/datetime')[0].attributes['end'])
          time = time + 60 * 60 * 9
          end_time = time.strftime('%H:%M')

          schedule = Schedule.new(title, start_time, end_time)
          schedule_arr << schedule
        end
      end

      return schedule_arr
    end

    def get(service, method, params)
      time = Time.now
      created = time.strftime('%Y-%m-%dT%H:%M:%SZ')
      time = time + 1
      expires = time.strftime('%Y-%m-%dT%H:%M:%SZ')

      xml = <<-EOS
      <?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <soap:Header>
            <Action soap:mustUnderstand="1" xmlns="http://schemas.xmlsoap.org/ws/2003/03/addressing">#{method}</Action>
            <Timestamp soap:mustUnderstande="1" xmlns="http://schemas.xmlsoap.org/ws/2002/07/utility">
                  <Created>#{created}</Created>
                  <Expires>#{expires}</Expires>
            </Timestamp><Security xmlns:wsu="http://schemas.xmlsoap.org/ws/2002/07/utility" soap:mustUnderstand="1" xmlns="http://schemas.xmlsoap.org/ws/2002/12/secext">
            <UsernameToken>
              <Username>#{@option.username}</Username>
              <Password>#{@option.password}</Password>
            </UsernameToken>
          </Security>
      </soap:Header>
        <soap:Body>
          <#{method} xmlns="http://wsdl.cybozu.co.jp/base/2008">
            #{params}
          </#{method}>
        </soap:Body>
      </soap:Envelope>
      EOS

      #前に空白があるとエラーになる
      xml.strip!

      response = nil
      begin
        response = RestClient.post @option.url + service, xml, :content_type => "application/soap+xml; charset=utf-8; action=\"#{method}\""
        response = check_err(response)
      rescue
        @error = '通信エラーが発生しました'
      end

      return response
    end

    def check_err(response)
      doc = REXML::Document.new(response)
      elem = doc.elements['soap:Envelope/soap:Body/soap:Fault']
      unless elem
        return response
      end

      @error = doc.elements['soap:Envelope/soap:Body/soap:Fault/soap:Reason/soap:Text'].text
      return nil
    end
  end
end
