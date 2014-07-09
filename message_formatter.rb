def format_results(check,results,send_results)
  message_header = "Alert:  " + check["name"] + "\n"
  spacer = (120/results.fields.count).round # create some generic spacing based on the number of columns
  table_header = ''
  i=0
  while i < results.fields.count
    table_header += results.fields[i].capitalize + ' '*(spacer-results.fields[i].bytesize)
    i+=1
  end

  message_body = ''
  send_results.each do |row|
    row_content = ''
    j=0
    while j < results.fields.count
      field_value = row[results.fields[j]].to_s[0..(spacer-2)]
      row_content += field_value + ' '*(spacer-field_value.length)
      j+=1
    end
    message_body += "\n#{row_content}"
  end

  email_subject = "#{check["type"].capitalize} Alert:  #{check["name"]}"
  email_message = message_header + table_header + message_body

  return { "mobile" => "SMS message?", "email" => {"subject"=>"#{email_subject}", "body"=>"#{email_message}"}  }
end