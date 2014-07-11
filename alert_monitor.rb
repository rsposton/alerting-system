#!/usr/bin/ruby

require 'open-uri'
require_relative 'manage_database_connections.rb'
require_relative 'aws_utils.rb'
require_relative 'query_checks.rb'
require_relative 'message_formatter.rb'
require_relative 'send_email.rb'



begin
  period = ARGV[0]
  no_email = ARGV[1]
  if ARGV.count < 1
    puts "Usage: #{__FILE__} <PERIOD> [minutely|hourly|daily|weekly|all]"
    puts "  You had #{ARGV.count} parameters. One only please."
    exit 1
  elsif  !['minutely','hourly','daily','weekly','all'].include? period
    puts "Usage: #{__FILE__} <PERIOD> [minutely|hourly|daily|weekly|all]"
    puts "  You had #{period} as an input parameter. minutely, hourly, daily, weekly, all only."
    exit 1
  end


  ## Set database connection to driver database (this contains reference values for anything driving this app)
  driver_db_uri = ENV["DATABASE_URL"] || 'postgres://localhost/local_alert'

  list_of_checks = init_query

  # Filter checks for the period passed into command line, abort if nothing is found
  list_of_checks = period == "all" ? list_of_checks : list_of_checks.select {|r| r["frequency"] == period}

  if list_of_checks.count == 0
    puts "Nothing valid in the list of checks for the period: #{period}"
    exit 1
  end
  puts "Running through a list of checks"

  ## Load checks that should be validated
  list_of_checks.each do |check|
    puts "==========================================================="
    puts "##{check["num"]} - #{check["name"]} results"
    puts "==========================================================="

    # Set URI for the active check
    check_uri = check["database_connection"]

    case check["type"]
      when "threshold"      ## Checks for anything that crosses a threshold   (e.g., traffic above a specified level)
        p=ExecuteQuery.new
        results = p.main(check_uri,check["query"])

        # Check if any records cross the threshold
        # Remove any records that are below the threshold
        send_results = results.reject {|r| r[check["validator"]] < check["limit"]}

        # Send to formatter if we have more than one record
        if send_results.count > 0
          message_payload = format_results(check,results,send_results)
        end

      when "new record"     ## Checks for new records since the last run
        full_query = ''
        check_value = 0
        # Get the max value for the primary key the last time this was run
        p=ExecuteQuery.new
        results = p.main(driver_db_uri,"SELECT value FROM max_values where check_number=#{check['num']} and field_name='#{check['validator']}'")

        # Update query with the max value from the last execution of this query
        if results.count == 1
          check_value = results[0]["value"]
          full_query = check["query"].to_s.sub! 'FIELD1', check_value.to_s
        else
          puts "ABORT: multiple values found for new record check: #{check['name']}"
          exit 1
        end

        # Update "new record" query check for most recent value from persist.yml


        # Run full query with the value from persist.yml
        r=ExecuteQuery.new
        results = r.main(check_uri,full_query)

        # Check if there are any results and format the message
        if results.count > 0
          message_payload = format_results(check,results,results)

          max = check_value.to_i
          results.each do |row|
            max = row[check["validator"]].to_i > max ? row[check["validator"]] : max
          end

          # Update database with new max
          p=ExecuteQuery.new
          results = p.main(driver_db_uri,"update max_values set value=#{max} where check_number=#{check['num']} and field_name='#{check['validator']}'")
        end
        # Format the message for email and SMS

      when "update"    # simple periodic updates (like refreshing a materialized view)
        if ENV["ENVIRONMENT"] != "test" # don't run this in test
          r=ExecuteQuery.new
          results = r.main(check_uri,check["query"])
        end
      else
        puts "Unknown validation type"
    end

    # Write message payload to stdout, or no records found
    if message_payload
      puts message_payload["email"]["subject"]
      puts message_payload["email"]["body_text_only"]
      puts check["distro"]

      # check argument to see if we should suppress the email, or fire away
      (no_email == "noemail" ? "Suppressing email send" : send_email(message_payload,check["distro"]) )
    elsif check["type"] == "update"   # updates don't return no records
      puts "query ran successfully"
    else
      puts "no records found"
    end
  end
end
