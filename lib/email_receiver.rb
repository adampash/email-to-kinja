require 'incoming'
class EmailReceiver < Incoming::Strategies::SendGrid
  def receive(mail)
    puts %(Got message from #{mail.to.first} with subject "#{mail.subject} and the text\n#{mail.body.decoded}")
    mail
  end

  def self.scrub_fwd(text)
    text.gsub(/^Fwd?: /i, '')
  end

  def self.scrub_space(text)
    text.gsub("%20", " ")
  end
end
