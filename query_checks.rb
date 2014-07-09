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
                      "type"=>"threshold","validator"=>"visitors", "limit"=>3, "frequency"=>"hourly",
                      "distro"=>["regan@milyoni.com","david@milyoni.com","manasi@milyoni.com","dean@milyoni.com","sheila@milyoni.com","john@milyoni.com"]},
                      {"num"=>1,"name"=>"New Pack Created",
                       "query"=> "select p.id as pack_id,
                                  p.name as 'pack Name',
                                  substring(u.name from 1 for 15) as name,
                                  substring(u.studio from 1 for 15) as studio,
                                  p.url,p.add_date created_at
                                  from pack p, people u where p.uid=u.id and p.id > ",
                       "type"=>"new record","validator"=>"pack_id", "frequency"=>"hourly",
                       "distro"=>["regan@milyoni.com"]},
                      {"num"=>2,"name"=>"New Admin Signed Up",
                       "query"=> "select u.id as admin_id,u.name,u.studio,ip_address
                                  from people u where id > ",
                       "type"=>"new record","validator"=>"admin_id", "frequency"=>"hourly",
                       "distro"=>["regan@milyoni.com"]}
  ]
  return list_of_checks
end
