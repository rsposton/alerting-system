def init_query
  list_of_checks =  [{"num"=>0,"name"=>"Traffic Exceeds Hourly Threshold",
                      "query"=>"select substring(u.name from 1 for 15) as name,
                                substring(u.studio from 1 for 15) as studio,
                                substring(concat(p.id,'-',p.name) from 1 for 46) as pack,
                                p.url,count(distinct g.session_id) as visitors
                                from pack p, people u, generate_report g
                                where p.uid=u.id and g.pack_id=p.id
                                and timestampdiff(MINUTE,date_of_event,now()) < -240
                                group by 1,2,3,4
                                having count(distinct g.session_id) > 0",
                      "type"=>"threshold","validator"=>"visitors", "limit"=>2, "frequency"=>"hourly",
                      "database_connection"=>"mysql://vcread:LTAty3CH6dcHXReB@69.162.175.147/videocards",
                      "distro"=>["regan@milyoni.com","david@milyoni.com","manasi@milyoni.com","dean@milyoni.com","sheila@milyoni.com","john@milyoni.com"]},
                      {"num"=>1,"name"=>"New Pack Created",
                       "query"=> "select p.id as pack_id,
                                  p.name as 'pack Name',
                                  substring(u.name from 1 for 15) as name,
                                  substring(u.studio from 1 for 15) as studio,
                                  p.url,p.add_date created_at
                                  from pack p, people u where p.uid=u.id and p.id > ",
                       "type"=>"new record","validator"=>"pack_id", "frequency"=>"minutely",
                       "database_connection"=>"mysql://vcread:LTAty3CH6dcHXReB@69.162.175.147/videocards",
                       "distro"=>["regan@milyoni.com","david@milyoni.com","manasi@milyoni.com","dean@milyoni.com","sheila@milyoni.com"]},
                      {"num"=>2,"name"=>"New Admin Signed Up",
                       "query"=> "select u.id as admin_id,u.name,u.studio,ip_address
                                  from people u where id > ",
                       "type"=>"new record","validator"=>"admin_id", "frequency"=>"minutely",
                       "database_connection"=>"mysql://vcread:LTAty3CH6dcHXReB@69.162.175.147/videocards",
                       "distro"=>["regan@milyoni.com","david@milyoni.com","manasi@milyoni.com","dean@milyoni.com","sheila@milyoni.com","john@milyoni.com"]},
                      {"num"=>3,"name"=>"Refresh Materialized View view_pack_stats",
                       "query"=> "refresh materialized view view_pack_stats",
                       "type"=>"update", "frequency"=>"minutely",
                       "database_connection"=>"postgres://milyoni:milyoni2014@dw-staging.c7zsulqfsfjz.us-west-2.rds.amazonaws.com:5432/data_warehouse_production",
                       "distro"=>["regan@milyoni.com"]},
                      {"num"=>3,"name"=>"Refresh Materialized View view_rankings",
                       "query"=> "refresh materialized view view_rankings",
                       "type"=>"update", "frequency"=>"minutely",
                       "database_connection"=>"postgres://milyoni:milyoni2014@dw-staging.c7zsulqfsfjz.us-west-2.rds.amazonaws.com:5432/data_warehouse_production",
                       "distro"=>["regan@milyoni.com"]}
                      ]
  return list_of_checks
end
