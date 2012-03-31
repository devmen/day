# encoding: utf-8

require 'date'
require 'yaml'
require 'day/ru'

class Numeric
  def days
    self * 60 * 60 * 24
  end
end

# API simplifier
module Day
  def self.Ru(string)
    Day::Ru.new(string).parse
  end
end
