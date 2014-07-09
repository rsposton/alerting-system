def format_header(results)
  headers = results.fields
  spacer=(160/headers.count).round
  i=headers.count-1
  table_head = ''
  while i >= 0
    table_head = headers[i] + ' '*(spacer-headers[i].bytesize) + table_head
    i-=1
  end
  puts table_head
end

def format_body(results)
  headers = 8
  spacer=(160/headers).round
  row_content = ''
  results.each(:as => :array) do |row|
    i=headers-1
    value = ''
    row_content = ''
    while i >= 0
      value = row[i].to_s[0..(spacer-2)]
      row_content = value + ' '*(spacer-value.bytesize) + row_content
      i-=1
    end
    puts row_content
  end
end

def format_results(check,results,send_results)
  message_header = "Alert:  " + check["name"] + "\n"
  spacer = (160/results.fields.count).round # create some generic spacing based on the number of columns
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

  email_message = message_header + table_header + message_body
  email_subject = "#{check["type"].capitalize} Alert:  #{check["name"]}"

  return { "mobile" => "SMS message?", "email" => {"subject"=>"#{email_subject}", "body"=>"#{email_message}"}  }
end