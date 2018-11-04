#! /usr/bin/ruby
#coding: utf-8

require 'mail'
require 'csv'

class GetMail
  def initialize
    @out_csv = "csvファイルパス"
  end

  def execute
    CSV.open(@out_csv,"a") do |f|
      mail = Mail.new($stdin.read.gsub(/\r?\n/,"\r\n"))
      mail_subject = mail.subject.to_s
      mail_body = mail.body.to_s
      mail_body = mail_body.force_encoding("utf-8")
      mail_array = mail_body.scan(/:\s*([^\r]*)/)
      if mail_array.length >= 9 && !mail_subject.scan("メールタイトル").empty?
        f << mail_array.flatten
      end
    end
  rescue => e
    $stderr.puts "[#{e.class}] #{e.message}"
    e.backtrace.each{|trace| $stderr.puts "\t#{trace}"}
    exit 1
  end
end

exit unless $0 == __FILE__
GetMail.new.execute
