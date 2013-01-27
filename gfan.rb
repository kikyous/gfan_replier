# encoding: utf-8
require 'digest/md5'
require 'mechanize'

class Gfan
  def initialize(username,password)
    @@url='http://bbs.gfan.com/'
    @username=username
    @password=Digest::MD5.hexdigest password
    @agent=Mechanize.new
    @@replies=DATA.readlines
  end

  def login
    @agent.get('http://bbs.gfan.com/forum.php') do |page|
      return page.form do |login|
        login.username=@username
        login.password=@password
      end.submit
    end
  end

  def topics(forum,pages)
    pages do |page|
      url = "http://bbs.gfan.com/forum-#{forum}-#{page}.html"
      @agent.get url do |page|
        page.search('tbody[id^=normalthread] a.xst').each do |a|
          yield a
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
  end

  def start(forum)
    check login do |c|
      c ? 'login success!' : "#{exit!}"
    end 
    topics forum,yield do |topic|
      puts topic.text
      check reply(@@url + topic.attr('href'),@@replies.sample) do |c|
        c ? 'success!' : ''
      end 
      sleep 3
    end
  end

  private
  def check(action)
    msg=action.search('#messagetext')
    if msg.empty?
      puts yield true
    else
      puts msg.search('p').text
      print yield false
    end
  end
end

#forum to reply,274 if http://bbs.gfan.com/forum-274-1.html
Gfan.new('valentine1992','11352355').start 274 do
  1..2   #page to reply into this forum
end

__END__
感谢分享。。。。
看看怎么样
我是来拿经验的
虽然不知道楼主在说什么,但是好像很厉害的样子
