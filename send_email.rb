require_relative 'utils.rb'

def send_email(message_payload)
  ses = AWS::SimpleEmailService.new

  ses.send_email(
      :subject => message_payload["email"]["subject"],
      :from => 'regan@bilyoni.com',
      :to => 'regan@milyoni.com',
      :body_text => message_payload["email"]["body"])
      #:body_html => '<h1>Sample Email</h1>')

  puts "Sent email: #{message_payload["email"]["subject"]}"

end
