# -*- coding: utf-8 -*-

module CybozuSchedle
  class Schedule
    attr_reader :title, :start_time, :end_time
    def initialize(title, start_time, end_time)
      @title = title
      @start_time = start_time
      @end_time = end_time
    end
  end
end
