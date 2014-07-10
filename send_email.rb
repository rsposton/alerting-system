require_relative 'aws_utils.rb'

def send_email(message_payload,email_list)
  ses = AWS::SimpleEmailService.new

  ses.send_email(
      :subject => message_payload["email"]["subject"],
      :from => 'regan@bilyoni.com',
      :to => email_list,
      :body_text => message_payload["email"]["body_text_only"],
      :body_html => message_payload["email"]["body_html"])

  puts "Sent email: #{message_payload["email"]["subject"]}"

end
