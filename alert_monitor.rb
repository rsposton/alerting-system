#!/usr/bin/ruby

require 'mysql2'
require 'pg'
require 'URI'
require_relative 'utils.rb'
#require_relative 'config/environment.rb'
require_relative 'query_checks.rb'
require_relative 'message_formatter.rb'
require_relative 'send_email.rb'



begin
  period = ARGV[0]
  no_email = ARGV[1]
  if ARGV.count < 1
    puts "Usage: #{__FILE__} <PERIOD> [hourly|daily|weekly]"
    puts "  You had #{ARGV.count} parameters. One only please."
    exit 1
  elsif  !['hourly','daily','weekly'].include? period
    puts "Usage: #{__FILE__} <PERIOD> [hourly|daily|weekly]"
    puts "  You had #{period} as an input parameter. Hourly, daily, weekly, only."
    exit 1
  end


  ## Connect to database
  client = Mysql2::Client.new(:host => "69.162.175.147", :username => "vcread", :password => "LTAty3CH6dcHXReB",
                              :database => "videocards")

  list_of_checks = init_query

  list_of_checks = list_of_checks.select {|r| r["frequency"] == period}

  if list_of_checks.count == 0
    puts "Nothing valid in the list of checks for the period: #{period}"
    exit 1
  end
  puts "Running through a list of checks"

  ## Load checks that should be validated
  list_of_checks.each do |check|
    puts "======================================="
    puts "##{check["num"]} - #{check["name"]} results"
    puts "======================================="
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
        # Get the max value for the primary key the last time this was run
        db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/local_alert')

        conn = PG.connect(
            :dbname => db.path[1..100],
            :host => db.host,
            :user => db.user || "reganposton",
            :password => db.password || nil,
            :port => db.port || 5432)

        results = conn.exec( "SELECT value FROM max_values where check_number=#{check['num']} and field_name='#{check['validator']}'" )
        if results.count == 1
          check_value=results[0]["value"]
        else
          puts "ABORT: multiple values found for new record check: #{check['name']}"
          exit 1
        end

        # Update "new record" query check for most recent value from persist.yml
        full_query = check["query"].to_s + check_value.to_s

        # Run full query with the value from persist.yml
        results = client.query(full_query)

        # Check if there are any results and format the message
        if results.count > 0
          message_payload = format_results(check,results,results)

          max = check_value.to_i
          results.each do |row|
            max = row[check["validator"]].to_i > max ? row[check["validator"]] : max
          end

          # Update database with new max
          conn.exec( "update max_values set value=#{max} where check_number=#{check['num']} and field_name='#{check['validator']}'" )
          conn.close
        end
        # Format the message for email and SMS

      else
        puts "Unknown validation type"
    end

    if !message_payload.nil?
      # write message to stdout
      puts message_payload["email"]["subject"]
      puts message_payload["email"]["body_text_only"]
      puts check["distro"]

      # check argument to see if we should suppress the email, or fire away
      (no_email == "noemail" ? "Suppressing email send" : send_email(message_payload,check["distro"]) )
    elsif
      puts "no records found"
    end

  end


end
