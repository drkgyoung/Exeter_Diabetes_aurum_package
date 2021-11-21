## Making valid_date_lookup

set role 'role_full_admin';

# drop table if exists cprd_data.r_valid_date_lookup;

create table cprd_data.r_valid_date_lookup as select c.patid, min_dob,
least(if(gp_end_date is null,str_to_date('1/1/2050','%d/%m/%Y'),gp_end_date), 
if(ons_death is null,str_to_date('1/1/2050','%d/%m/%Y'),ons_death)) as gp_ons_end_date,
least(if(gp_end_date is null,str_to_date('1/1/2050','%d/%m/%Y'),gp_end_date), 
if(ons_death is null,str_to_date('1/1/2050','%d/%m/%Y'),ons_death),
if(hes_death_all is null,str_to_date('1/1/2050','%d/%m/%Y'),hes_death_all)) as gp_ons_hes_all_end_date,
least(if(gp_end_date is null,str_to_date('1/1/2050','%d/%m/%Y'),gp_end_date), 
if(ons_death is null,str_to_date('1/1/2050','%d/%m/%Y'),ons_death),
if(hes_death_filter1 is null,str_to_date('1/1/2050','%d/%m/%Y'),hes_death_filter1)) as gp_ons_hes_filter1_end_date,
least(if(gp_end_date is null,str_to_date('1/1/2050','%d/%m/%Y'),gp_end_date), 
if(ons_death is null,str_to_date('1/1/2050','%d/%m/%Y'),ons_death),
if(hes_death_filter2 is null,str_to_date('1/1/2050','%d/%m/%Y'),hes_death_filter2)) as gp_ons_hes_filter2_end_date from
(select patid, min_dob, least(if(cprd_ddate is null,str_to_date('1/1/2050','%d/%m/%Y'),cprd_ddate), 
if(regenddate is null,str_to_date('1/1/2050','%d/%m/%Y'),regenddate), 
if(lcd is null,str_to_date('1/1/2050','%d/%m/%Y'),lcd)) as gp_end_date from 
(select a.patid, if(a.mob is NULL, str_to_date(concat('1/1/',a.yob),'%d/%m/%Y'), str_to_date(concat('1/',a.mob,'/',a.yob),'%d/%m/%Y')) as min_dob, a.cprd_ddate, a.regenddate, b.lcd from cprd_data.patient a left join cprd_data.practice b on a.pracid=b.pracid)
as T1)
as c left join (select patid, if(dod is null, dor, dod) as ons_death from cprd_data.ons_death) d on c.patid=d.patid left join 
(select patid, min(discharged) as hes_death_all from cprd_data.hes_hospital where dismeth=4 and disdest=79 group by patid)
e on c.patid=e.patid left join
(select patid, min(hes_death) as hes_death_filter1 from
(select f.patid, n_patid_hes, hes_death from cprd_data.hes_patient f inner join
(select patid, discharged as hes_death from cprd_data.hes_hospital where dismeth=4 and disdest=79)
g on f.patid=g.patid where n_patid_hes<20)
as T2 group by patid)
h on c.patid=h.patid left join
(select patid, min(hes_death) as hes_death_filter2 from
(select i.patid, n_patid_hes, hes_death from cprd_data.hes_patient i inner join
(select patid, discharged as hes_death from cprd_data.hes_hospital where dismeth=4 and disdest=79)
j on i.patid=j.patid where n_patid_hes=1)
as T3 group by patid)
k on c.patid=k.patid;

select * from cprd_data.r_valid_date_lookup where year(gp_ons_end_date)=2050 or year(gp_ons_hes_all_end_date)=2050 or year(gp_ons_hes_filter1_end_date)=2050 or year(gp_ons_hes_filter2_end_date)=2050;
# None

select max(gp_ons_end_date), max(gp_ons_hes_all_end_date), max(gp_ons_hes_filter1_end_date), max(gp_ons_hes_filter2_end_date) from cprd_data.r_valid_date_lookup;
# All are 15/10/2020