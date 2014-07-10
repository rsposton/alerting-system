CREATE TABLE max_values (id serial NOT NULL, check_number integer, field_name character varying(255), value integer,
                    CONSTRAINT max_value_pkey PRIMARY KEY (id));
insert into max_values (check_number,field_name,value) values (1,'pack_id',770);
insert into max_values (check_number,field_name,value) values (2,'admin_id',473);