#! /usr/bin/env ruby

root = File.dirname(__FILE__)
$LOAD_PATH.unshift File.join(root, 'lib')

require 'rubygems'
require 'cybozu_schedule'

CybozuSchedle::App.new().run

