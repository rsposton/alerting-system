#!/usr/bin/ruby

require 'mysql2'
require 'yaml'
require_relative 'utils.rb'
require_relative 'query_checks.rb'
require_relative 'message_formatter.rb'
require_relative 'send_email.rb'



begin
  client = Mysql2::Client.new(:host => "69.162.175.147", :username => "vcread", :password => "LTAty3CH6dcHXReB",
                              :database => "videocards")
  checkpoint = YAML::load_file('persist.yml')

  list_of_checks = init_query

  puts "Running through a list of checks"

  ## Load checks that should be validated
  list_of_checks.each do |check|
    puts "##{check["num"]} - #{check["name"]} results"
    puts "============="
    case check["type"]
      when "threshold"      ## Checks for anything that crosses a threshold   (e.g., traffic above a specified level)

        results = client.query(check["query"])

        # Check if any records cross the threshold
        # Remove any records that are below the threshold
        send_results = results.reject {|r| r[check["validator"]] < check["limit"]}

        # Send to formatter if we have more than one record
        if send_results.count > 0
          message_payload = format_results(check,results,send_results)
        end

      when "new record"     ## Checks for new records since the last run
        checkpoint = YAML::load_file('persist.yml')

        # Update "new record" query check for most recent value from persist.yml
        full_query = check["query"].to_s + checkpoint['threshold_value'][check["validator"]].to_s

        # Run full query with the value from persist.yml
        results = client.query(full_query)

        # Check if there are any results and format the message
        if results.count > 0
          message_payload = format_results(check,results,results)

          max = checkpoint['threshold_value'][check["validator"]].to_i
          results.each do |row|
            max = row[check["validator"]].to_i > max ? row[check["validator"]] : max
          end

          # Update persist.yml with new max
          checkpoint['threshold_value'][check["validator"]] = max
          File.open('persist.yml','w') {|f| f.write checkpoint.to_yaml }
        end
        # Format the message for email and SMS

      else
        puts "Unknown validation type"
    end

    if !message_payload.nil?
      send_email(message_payload)
    elsif
      puts "no records found"
    end

  end


end
