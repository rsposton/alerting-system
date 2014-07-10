require 'mysql2'
require 'pg'
require 'open-uri'

class ExecuteQuery
  def parse_uri(uri)
    URI.parse(uri)
  end
  def open_connection(db)
    if db.scheme == 'postgres'
      client = PG.connect(
          :dbname => db.path[1..100],
          :host => db.host,
          :user => db.user || "reganposton",
          :password => db.password || nil,
          :port => db.port || 5432)
    else db.scheme == 'mysql'
      client = Mysql2::Client.new(
        :host => db.host,
        :username => db.user,
        :password => db.password,
        :database => db.path[1..100])
    end
    client
  end

  def query_this (db,conn,query)
    if db.scheme == 'postgres'
      conn.query (query)
    else db.scheme == 'mysql'
      conn.query (query)
    end
  end

  def connection_close (conn)
    conn.close
  end

  def main(uri,query)
    db=parse_uri(uri)
    conn=open_connection(db)
    results = query_this(db,conn,query)
    conn.close
    results
  end

end

p=ExecuteQuery.new
results = p.main("mysql://vcread:LTAty3CH6dcHXReB@69.162.175.147/videocards","select count(*) from pack")
results.each do |row|
  puts row
end

r=ExecuteQuery.new
results = r.main("postgres://localhost/local_alert","select count(*) from max_values")
results.each do |row|
  puts row
end


#'postgres://localhost/local_alert')
#'mysql://vcread:LTAty3CH6dcHXReB@69.162.175.147/videocards'


