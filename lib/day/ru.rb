# encoding: utf-8

module Day
  class Ru
    attr_accessor :date

    # Initalizing new object
    #
    # @param [String] string natural language date designation
    # @param [Time] now date to count from
    def initialize(string, now = Time.now)
      # getting class variables from 'data' folder contents
      Dir[Pathname(File.dirname(__FILE__)) + '../../data/ru/*.yml'].each do |yml|
        instance_variable_set(
          "@#{File.basename(yml, '.yml')}".to_sym, YAML::load(File.read(yml))
        )
      end

      @string, @now = string.strip.downcase, now
      @week_start = @now - @now.wday.days
    end

    def parse
      case @string
      # вчера, сегодня, завтра
      when /^(позавчера|вчера|сегодня|завтра|послезавтра)$/i then
        yesterday_today_tomorrow

      # через (1 день | 2 дня | 5 дней)
      when /^через\s(\d{1,})?\sд(н(|я|ей)|ень)$/i then
        future_days $1

      # через день (сокращенный вариант пред. метода)
      when /^через\sдень$/i then
        future_days 1

      # через (один день | два дня | пять дней)
      when /^через\s(#{@simple_numerics.keys.join('|')})\sд(н(|я|ей)|ень)$/ then
        future_days @simple_numerics[$1]

      # (1 день | 2 дня | 5 дней) назад
      when /^(\d{1,})\sд(н(|я|ей)|ень)\sназад/i then
        previous_days $1

      # (два дня | пять дней) назад
      when /^(#{@simple_numerics.keys.join('|')})\sд(н(|я|ей)|ень)\sназад$/ then
        previous_days @simple_numerics[$1]

      # в понедельник, во вторник, в воскресенье, в эту среду 
      when /^во?\s(эт(о|от|у)\s)?(#{@week_days.join('|')})$/i then
        in_week_day $3

      # пн (вт ... вс)
      when /^(#{@short_week_days.join('|')})$/i then
        in_week_day_short_notation $1

      # в прошлый понедельник, в прошлую среду, в прошлое воскресенье
      when /^в\sпрошл(ый|ую|ое)\s(#{@week_days.join('|')})/i then
        in_past_week_day $2

      # в следующий понедельник, в следующую пятницу, в следующее воскресенье
      when /^в\sследующ(ий|ую|ее)\s(#{@week_days.join('|')})/i then
        in_next_week_day $2

      # через (неделю | 1 неделю | 2 недели | 5 недель)
      when /^через\s(\d{1,})?\s?недел(и|ю|ь)$/i then
        next_weeks $1

      # через (две недели | десять недель)
      when /^через\s(#{@simple_numerics.keys.join('|')})\sнедел(и|ю|ь)$/ then
        next_weeks @simple_numerics[$1]

      # неделю назад, 1 неделю назад, 2 недели назад, 5 недель назад
      when /^(\d{1,})?\s?недел(и|ю|ь)\sназад$/i then
        previous_weeks $1

      # две недели назад, десять недель назад
      when /^(#{@simple_numerics.keys.join('|')})\sнедел(и|ю|ь)\sназад$/ then
        previous_weeks @simple_numerics[$1]

      # через (месяц | 1 месяц | 2 месяца | 5 месяцев)
      when /^через\s(\d{1,})?\s?месяц(|а|ев)$/i then
        next_month $1

      # через (два месяца | десять месяцев)
      when /^через\s(#{@simple_numerics.keys.join('|')})\sмесяц(|а|ев)$/i then
        next_month @simple_numerics[$1]

      # месяц назад, 1 месяц назад, 2 месяца назад, 5 месяцев назад
      when /^(\d{1,})?\s?месяц(|а|ев)\sназад$/i then
        previous_month $1

      # два месяца назад, десять месяцев назад
      when /^(#{@simple_numerics.keys.join('|')})\sмесяц(|а|ев)\sназад$/i then
        previous_month @simple_numerics[$1]

        # 2 октября, 2 окт, 2 окт 2011
        else
          if @string =~ /\s?(#{@month_vocabulary.keys.join('|')})/
            @string.gsub!($1, @month_vocabulary[$1])
          end

          begin
            tmp_date = Date.parse @string
            @date = Time.mktime(tmp_date.year, tmp_date.mon, tmp_date.day)

          # TODO: raise an error: Date not recognized
          rescue => err
            puts err
          end
      end

      @date
    end

    private

    def yesterday_today_tomorrow
      @date = case @string
        when /^(позавчера)$/ then @now - 2.days
        when /^(вчера)$/ then @now - 1.days
        when /^(завтра)$/ then @now + 1.days
        when /^(послезавтра)$/ then @now + 2.days
        else @now
      end
    end

    def future_days days_num
      @date = @now + days_num.to_i.days
    end

    def previous_days days_num
      @date = @now - days_num.to_i.days
    end

    def in_week_day day
      @date = @week_start + @week_days.index(day).days
    end

    def in_week_day_short_notation day
      @date = @week_start + @short_week_days.index(day).days
    end

    def in_past_week_day day
      @date = in_week_day(day) - 7.days
    end

    def in_next_week_day day
      @date = in_week_day(day) + 7.days
    end

    def next_weeks weeks_num
      weeks = weeks_num.nil? ? 1 : weeks_num.to_i
      @date = @now + (weeks * 7).days
    end

    def previous_weeks weeks_num
      weeks = weeks_num.nil? ? 1 : weeks_num.to_i
      @date = @now - (weeks * 7).days
    end

    def month_proto num
      month = num.nil? ? 1 : num.to_i
      year, mon = yield(month)
      @date = Time.mktime(year, mon, @now.day)
    end

    def next_month num
      month_proto(num) do |month|
        @now.mon + month > 12 ?
          [(@now.year + (@now.mon + month) / 12), ((@now.mon + month) % 12)] : 
          [@now.year, (@now.mon + month)]
      end
    end

    def previous_month num
      month_proto(num) do |month|
        @now.mon - month < 1 ?
          [(@now.year - (@now.mon - month) / 12 * -1), (12 - ((month - @now.mon) % 12))] :
          [@now.year, (@now.mon - month)]
       end
    end
  end
end
