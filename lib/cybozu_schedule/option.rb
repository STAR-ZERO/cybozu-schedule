# -*- coding: utf-8 -*-
require 'yaml'

module CybozuSchedle
  class Option
    attr_reader :url, :username, :password, :interval, :sticky, :icon, :start_over

    def initialize
      @url = nil
      @username = nil
      @password = nil
      @interval = nil
      @icon = nil
      load_yaml
    end

    def load_yaml
      path = File.expand_path('../../data/setting.yaml', File.dirname(__FILE__))
      return if !File.exist?(path)

      setting = YAML.load_file(path)

      @url = setting['url'] + '?page=PApi'
      @username = setting['username']
      @password = setting['password']
      @interval = setting['interval'].to_i
      @sticky = !!setting['sticky']
      @start_over = !!setting['start_over']
      image_path = File.expand_path('../../data/', File.dirname(__FILE__))
      Dir.glob(image_path + '/icon.{jpeg,jpg,png}') do |f|
        @icon = f
      end
    end
  end
end
