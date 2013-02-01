# encoding: utf-8
require 'digest/md5'
require 'mechanize'

class GfanReplier
  def initialize(username,password)
    @@url='http://bbs.gfan.com/'
    @username=username
    @password=password.length==32 ? password : Digest::MD5.hexdigest(password)
    @agent=Mechanize.new
    @@replies= File.new('content.txt','r').readlines
  end

  def login
    @agent.get('http://bbs.gfan.com/forum.php') do |page|
      return page.form do |login|
        login.username=@username
        login.password=@password
      end.submit
    end
  rescue
    false
  end

  def topics(forums,pages)
    forums.each do |forum|
      ((pages.respond_to? :each) ? pages : [pages]) .each do |page|
        url = "http://bbs.gfan.com/forum-#{forum}-#{page}.html"
        @agent.get url do |page|
          page.search('tbody[id^=normalthread] a.xst').each do |a|
            yield a
          end
        end
      end
    end
  end

  def reply(topic,msg)
      @agent.get topic do |page|
        return page.form_with(:id => 'fastpostform') do |form|
          form.message=msg
        end.submit
      end
  rescue
    false
  end

  def start(*forum)
    check(login) { |c| c ? 'login success!' : "#{exit!}" }
    topics(forum,yield) do |topic|
      puts topic.text
      check reply(@@url + topic.attr('href'),@@replies.sample) do |c|
        c ? 'success!' : ''
      end
      sleep 4
    end
  end

  private
  def check(action)
    msg=action.search('#messagetext') if action
    if msg and msg.empty?
      puts yield true
    else
      puts msg.search('p').text.split("\n").first if msg
      puts '网络异常' unless action
      print yield false
    end
  end
end

#forum to reply,274 if http://bbs.gfan.com/forum-274-1.html
GfanReplier.new('valentine1992','059b350777373250532337960bddede0').start 13,274 do
  1  #page to reply into this forum,something like 1 , 2..9 , [1,3,5,7] available
end
