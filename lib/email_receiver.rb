require 'incoming'
class EmailReceiver < Incoming::Strategies::SendGrid
  def receive(mail)
    puts %(Got message from #{mail.to.first} with subject "#{mail.subject} and the text\n#{mail.body.decoded}")
    mail
  end
end
