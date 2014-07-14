def format_results(check,results,send_results)
  message_header_text_only = check["name"] + "\n"
  message_header_html = "<h2>#{check["name"]}</h2>\n"
  spacer = (120/results.fields.count).round # create some generic spacing based on the number of columns

  # Setup table header
  table_header_text_only = ''
  table_header_html = '<table style="padding:10px"><tr>'
  i=0
  while i < results.fields.count
    table_header_text_only += results.fields[i].capitalize + ' '*(spacer-results.fields[i].bytesize>1?(spacer-results.fields[i].bytesize):1)
    table_header_html += '<th>'+results.fields[i].capitalize+'</th>'
    i+=1
  end
  table_header_html += "</tr>\n"

  # Setup table content
  message_body_text_only = ''
  message_body_html = ''
  send_results.each do |row|
    row_content = ''
    row_content_html = '<tr>'
    j=0
    while j < results.fields.count
      # Unique formatting for IP address, if it is from a known list... this needs to be cleaned up!!
      milyoni_flag = (['108.227.100.152','173.164.182.62','203.196.159.34','24.5.251.254','61.16.241.214','76.103.249.126','173.164.182.61','216.70.158.117','71.233.236.125'].include? row[results.fields[j]].to_s) ? '(Mily)' : ''
      field_value_for_text_only = row[results.fields[j]].to_s[0..(spacer-2)]
      row_content += field_value_for_text_only + milyoni_flag + ' '*(spacer-field_value_for_text_only.length)
      # Unique formatting for IP addresses
      # TODO: figure out how to make formatting exceptions more robust
      row_content_html += results.fields[j] == "ip_address" ? '<td><a href="http://www.iplocation.net/index.php?query='+row[results.fields[j]].to_s+'">'+row[results.fields[j]].to_s+'</a>'+ milyoni_flag +'</td>' : '<td>'+row[results.fields[j]].to_s+'</td>'
      j+=1
    end
    message_body_text_only += "\n#{row_content}"
    message_body_html += row_content_html+"</tr>\n"
  end
  message_body_html += '</table>'

  email_subject = "#{check["type"].capitalize} Alert:  #{check["name"]} - #{Time.now.strftime("%Y-%m-%d %I:%M %Z")}"
  email_message_text_only = message_header_text_only + table_header_text_only + message_body_text_only
  email_message_html = message_header_html + table_header_html + message_body_html

  return { "mobile" => "SMS message?", "email" => {"subject"=>"#{email_subject}", "body_text_only"=>"#{email_message_text_only}",
           "body_html"=>"#{email_message_html}"} }
end