#! /usr/bin/ruby
# coding: utf-8

require 'mail'
require 'csv'
require 'time'

class TextProcess
  def initialize
    @@from_mail = 'FROMのメールアドレス'
    @@to_mail = 'TOのメールアドレス'
    @csv = "csvファイルパス"
  end

  def mailProcess
    student_info = {}
    flg_3 = i = 0
    CSV.foreach(@csv) do |cs|
      
      date = Time.strptime(cs[7].to_s,'%Y-%m-%d')
      today = Time.now
      three_date_before = date - 259200
      two_date_before = date - 172800
      one_date_before = date - 86400
      if three_date_before <= today && today < two_date_before
        flg_3 = 1
	student_info[i] = cs
	i += 1 
      elsif one_date_before <= today && today < date
	sendMail(2,cs)
      end
    end
    if flg_3 == 1
      processed_text = textProcess(student_info)
      sendMail(1,processed_text)
    end
  end

  def textProcess(tmp)
    i = 0
    info = ""
    for j in 0...tmp.length  do
      info << "氏名:#{tmp[j][0].to_s}\nメールアドレス:#{tmp[j][5].to_s}\n会場:#{tmp[j][6].to_s}\n日程:#{tmp[j][7].to_s}\n時間#{tmp[j][8].to_s}\n\n\n"
      i += 1
    end
    return info
  end

  def sendMail(flg,tmp)
    if flg == 2
      mail = Mail.new do
        from      @@from_mail
        to        @@to_mail
        subject   "前日のお知らせです"
        body      "氏名:#{tmp[0].to_s}\nメールアドレス:#{tmp[5].to_s}\n会場:#{tmp[6].to_s}\n日程:#{tmp[7].to_s}時間#{tmp[8].to_s}"
      end
    elsif flg == 1
      mail = Mail.new do
        from      @@from_mail
        to        @@to_mail
        subject   "3日前のお知らせです"
        body      tmp
      end
    end  
    mail.charset = 'utf-8'
    mail.delivery_method(:smtp,
      address:        "サーバ名",
      port:           ポート番号,
      domain:         "ドメイン名",
      authentication: :login,
      user_name:      "ユーザ名",
      password:       "パスワード",
      enable_starttls_auto: false
    )
    mail.deliver
  end
end

exit unless $0 == __FILE__
TextProcess.new.mailProcess
