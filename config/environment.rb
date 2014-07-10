require 'pg'


def open_connection
    db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/local_alert')

  conn = PGconn.open(:dbname => db.scheme)
  conn = PG.connect(
      :dbname => db.scheme,
      :host => db.host,
      :user => db.user || "reganposton",
      :password => db.password || nil,
      :port => db.port || 5432)
  return conn
end


def queryTable(query)
  @conn.exec( query ) do |result|
    result.each do |row|
      yield row if block_given?
    end
  end
end
