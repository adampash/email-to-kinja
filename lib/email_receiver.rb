require 'incoming'
class EmailReceiver < Incoming::Strategies::SendGrid
  def receive(mail)
    %(Got message from #{mail.to.first} with subject "#{mail.subject} and the text\n#{mail.html or mail.text}")
  end
end
