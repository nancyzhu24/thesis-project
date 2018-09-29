%let path=E:\for Nancy;
libname data "&path";

proc contents data=data.demo;
run;

data work.demo_filter;
set data.demo;
index_age=year_index-year_born;
if index_age>=67;
keep nam index_age sexe cohort dt_index;
run;

proc contents data=demo_filter;
run;

/*proc print data=demo_filter(obs=40);
run*/;

proc sort data=data.me_diag;
by nam;
run;

proc sort data=work.demo_filter;
by nam;
run;

* merge nam from filtered demo table to me_diag table;
data work.diag_merge;
merge work.demo_filter(in=F)
      data.me_diag(in=P);
by nam;
if P and F;
run;

proc contents data=data.me_diag;
run;

proc print data=diag_merge(obs=30);
run;

data work.diag_merge;
set work.diag_merge;
format dt_index yymmdd10.;
run;

*filter diagnostic codes;

data data.case;
set work.diag_merge;
where diag_diag in ('4242','I360','I361','I362','I368','I369','I392');
keep nam diag_diag type_diag no_seq index_age;
run;

*filter intervention code;
proc contents data=data.me_interv;
run;

data work.interv_merge;
merge work.demo_filter(in=F)
      data.me_interv(in=P);
by nam;
if P and F;
format dt_index yymmdd10.;
run;

data data.case2;
set work.interv_merge;
where code_interv in ('1HV80STBP','1HV80LA','1HV80LAFE','1HV80LAXXA','1HV80GPBD','1HV80GPBP','1HV80GPFE',
'1HV90GPXXL','1HV90LAXXA','1HV90LAXXK','1HV90LAXXL','1HV90LAXXQ','1HV90STXXL','1HV90WJXXA','1HV90WJXXD','1HV90WJXXK','1HV90WJXXL',
'1HV90LACF', '1HV90LACFA','1HV90LACFL','1HV90LACFN','1HV90WJCFN','4703','4713','4797','4724','4725');
format dt_interv yymmdd10.;
keep nam sexe dt_index dt_interv code_interv no_seq index_age;
run;

/*proc print data=interv_merge(obs=40);
run;


proc print data=work.demo_filter(obs=30);
run;*/
*link to hospital admission date in me_sejour;

proc contents data=data.me_sejour;
run;

data work.sejour;
set data.me_sejour;
keep nam no_seq dtadm dtsort typ_deces;
format dtadm dtsort yymmdd10.;
run;

/*proc print data=sejour(obs=30);
run;*/

proc sort data=work.sejour;
by nam;
run;

proc sort data=data.case;
by nam;
run;

data work.diag_sejour;
merge work.sejour(in=S)
      data.case(in=C);
by nam;
if S and C;
run;
       
/*proc print data=work.diag_sejour(obs=30);
run;*/

proc sort data=data.case2;
by nam;
run;

data work.interv_sejour;
merge work.sejour(in=S)
      data.case2(in=C);
by nam;
if S and C;
run;

data work.diag_sejour;
merge work.diag_sejour work.interv_sejour;
by nam;
run;

/* proc print data=work.diag_sejour(obs=30);
run;*/

*de-duplicate patients with both diagnosis and procedure, find unique number of nam=case number;

data data.diag_sejour;
set work.diag_sejour;
where dtadm>=dt_index ; *exclude Patients with history of aortic stenosis before cohort index date;
run;


ods select nlevels;
proc freq data=data.diag_sejour nlevels;
tables nam diag_diag;
run;

*Exclude cases according to pre-specified conditions;

data unique;
set data.diag_sejour;
by nam;
if first.nam;
keep nam;
run;

data diag_exclude;
merge unique(in=U)
      data.me_diag(in=D);
by nam;
if U and D;
if diag_diag in ('3950','I060','39699','IO080','I083','7463','Q230','7464','Q231',
                    '7465','Q232','7466','Q233','3910','I010','7140','M058','M059','M060', 
                    'M061','M062','M063','M068','M069');
keep nam diag_diag;
run;


/*check if the merge worked
ods select nlevels;
proc freq data=diag_exclude nlevels;
tables nam;
run; */

/*merge diag_exclude table to me_sejour to look at admission date, if admission date<index date, delete the observation*/

data data.diag_sejour_exclude;
merge diag_exclude(in=E)
      data.me_sejour(in=S)
      work.demo_filter(in=F);
by nam;
if E and S and F;
run;

