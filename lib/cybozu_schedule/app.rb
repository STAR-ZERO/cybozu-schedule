# -*- coding: utf-8 -*-
require 'growl'

module CybozuSchedle
  class App
    def initialize
      @option = Option.new
    end

    def run
      unless @option.url
        return
      end

      con = Connection.new(@option)

      #ログイン
      user = con.login
      unless user
        notify(con.error)
        return
      end

      #スケジュール取得
      schedule_arr = con.schedule
      unless schedule_arr
        notify(con.error)
        return
      end
      schedule_arr.each do |schedule|
        notify("#{schedule.title}\n#{schedule.start_time} 〜 #{schedule.end_time}")
      end
    end

    def notify(message)
        Growl.notify(message, :title => 'サイボウズ スケジュール', :icon => @option.icon, :sticky => @option.sticky)
    end
  end
end

