def init_query
  list_of_checks =  [{"num"=>0,"name"=>"ALERT:  Traffic Exceeds Hourly Threshold",
                      "query"=>"select substring(u.name from 1 for 15) as name,
                                substring(u.studio from 1 for 15) as studio,
                                substring(concat(p.id,'-',p.name) from 1 for 46) as pack,
                                p.url,count(distinct g.session_id) as visitors
                                from pack p, people u, generate_report g
                                where p.uid=u.id and g.pack_id=p.id and p.id not in (732)
                                and timestampdiff(MINUTE,date_of_event,now()) < -240
                                group by 1,2,3,4
                                having count(distinct g.session_id) > 0",
                      "type"=>"threshold","validator"=>"visitors", "limit"=>20, "frequency"=>"hourly",
                      "database_connection"=>"mysql://vcread:LTAty3CH6dcHXReB@69.162.175.147/videocards",
                      "distro"=>["regan@milyoni.com","david@milyoni.com","manasi@milyoni.com","dean@milyoni.com","sheila@milyoni.com","john@milyoni.com","joe@milyoni.com","emily@milyoni.com","barry@milyoni.com","kent@milyoni.com"]},
                      {"num"=>1,"name"=>"New Pack Created",
                       "query"=> "select p.id as pack_id,
                                  p.name as 'pack Name',
                                  substring(u.name from 1 for 15) as 'user name',
                                  u.ip_address,
                                  p.url,p.add_date created_at
                                  from pack p, people u where p.uid=u.id and p.id > FIELD1",
                       "type"=>"new record","validator"=>"pack_id", "frequency"=>"minutely",
                       "database_connection"=>"mysql://vcread:LTAty3CH6dcHXReB@69.162.175.147/videocards",
                       "distro"=>["regan@milyoni.com","david@milyoni.com","manasi@milyoni.com","dean@milyoni.com","sheila@milyoni.com","joe@milyoni.com","emily@milyoni.com","barry@milyoni.com"]},
                      {"num"=>2,"name"=>"New Admin Signed Up",
                       "query"=> "select u.id as admin_id,u.name,ip_address,addDate
                                  from people u where id > FIELD1",
                       "type"=>"new record","validator"=>"admin_id", "frequency"=>"minutely",
                       "database_connection"=>"mysql://vcread:LTAty3CH6dcHXReB@69.162.175.147/videocards",
                       "distro"=>["regan@milyoni.com","david@milyoni.com","manasi@milyoni.com","dean@milyoni.com","sheila@milyoni.com","john@milyoni.com","joe@milyoni.com","emily@milyoni.com","barry@milyoni.com","kent@milyoni.com"]},
                      {"num"=>3,"name"=>"Refresh Materialized View view_pack_stats",
                       "query"=> "refresh materialized view view_pack_stats",
                       "type"=>"update", "frequency"=>"minutely",
                       "database_connection"=>"postgres://milyoni:milyoni2014@dw-staging.c7zsulqfsfjz.us-west-2.rds.amazonaws.com:5432/data_warehouse_staging",
                       "distro"=>["regan@milyoni.com"]},
                      {"num"=>4,"name"=>"Refresh Materialized View view_rankings",
                       "query"=> "refresh materialized view view_rankings",
                       "type"=>"update", "frequency"=>"minutely",
                       "database_connection"=>"postgres://milyoni:milyoni2014@dw-staging.c7zsulqfsfjz.us-west-2.rds.amazonaws.com:5432/data_warehouse_staging",
                       "distro"=>["regan@milyoni.com"]},
                      {"num"=>5,"name"=>"Daily Report - New Packs Created Today",
                       "query"=> "select p.id as pack_id,
                                  p.name as 'pack Name',
                                  substring(u.name from 1 for 15) as 'user name',
                                  u.ip_address,
                                  p.url,p.add_date created_at
                                  from pack p, people u where p.uid=u.id and p.id > FIELD1",
                       "type"=>"new record","validator"=>"pack_id", "frequency"=>"daily",
                       "database_connection"=>"mysql://vcread:LTAty3CH6dcHXReB@69.162.175.147/videocards",
                       "distro"=>["regan@milyoni.com","david@milyoni.com","manasi@milyoni.com","dean@milyoni.com","sheila@milyoni.com","joe@milyoni.com","emily@milyoni.com","barry@milyoni.com","john@milyoni.com","kent@milyoni.com"]},
                      {"num"=>6,"name"=>"Daily Report - Pack Rankings",
                       "query"=> "select r.rank,pack_id,p.name pack_name, a.name admin_name,r.points,r.visitors,r.click_through_rate,p.url
                                  from view_rankings r, vc_pack p, vc_people a
                                  where r.pack_id=p.id and r.admin_id=a.id limit 10",
                       "type"=>"threshold","validator"=>"rank", "limit"=>0, "frequency"=>"daily",
                       "database_connection"=>"postgres://milyoni:milyoni2014@dw-staging.c7zsulqfsfjz.us-west-2.rds.amazonaws.com:5432/data_warehouse_staging",
                       "distro"=>["regan@milyoni.com","david@milyoni.com","manasi@milyoni.com","dean@milyoni.com","sheila@milyoni.com","kent@milyoni.com"]},
                      {"num"=>7,"name"=>"Drop and Create Temporary Email Table for Tableau Admin Follow Up report",
                       "query"=> "drop table tmp_auth_users; create table tmp_auth_users as select id,email,last_sign_in_at,created_at
                                  from dblink('postgres://qzetlttsenwlss:SBAsTK1oK7ad2Mi6fBWClbWUcr@ec2-23-21-170-57.compute-1.amazonaws.com:5432/dbu7lirug8msem',
                                  'select id,email,last_sign_in_at,created_at from users')
                                  as p(id integer, email varchar(255), last_sign_in_at timestamp, created_at timestamp)",
                       "type"=>"update", "frequency"=>"hourly",
                       "database_connection"=>"postgres://milyoni:milyoni2014@dw-staging.c7zsulqfsfjz.us-west-2.rds.amazonaws.com:5432/data_warehouse_staging",
                       "distro"=>["regan@milyoni.com"]}
                      ]
  return list_of_checks
end
