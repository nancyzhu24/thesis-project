
**************************************************************************;
* program for Jay Brophy incidence of heart disease
*
* date: 2015-01-15;
*
*  comorbidity charlson for dr Brophy request 12-10-2015.sas
*
**************************************************************************;

*CHARLSON AND PREVIOUS HX OF and diag of HEART DISEASE;
*1. keep nam and dt_&va ie the date where you want to start and go backward ;
*2. merge with medecho sejour dataset and keep only dtadm<=date of selection
*3. merge with medecho diag dataset by no_seq and nam ;
*4. go to comorbidity charlson.sas program;

*find the hospitalization for the cohort;
*dt_&va and nam should be in yourdataset your variable name should start with dt_ 
   and you define &va as what you have add for your date all here yourextensiondate;

*change in the macro yourextensiondate for the name you have put at date that will be used, using this format dt_yourextensiondate;
*call your dataset that have nam and date that will be used yourdataset;

*import data;

PROC IMPORT OUT= WORK.DIAG_CHARLSON 
            DATAFILE= "C:\Users\Nancy Zhu\OneDrive - McGill University\C
ode for thesis\diag_charlson.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

data work.me_diag;
   set "E:\me_diag.sas7bdat"; 
  run;

data work.sejour;
   set "E:\me_sejour.sas7bdat"; 
  run;

proc sort data=diag_charlson;by nam;run;
proc sort data=sejour;by nam;run;

%macro com(va);

data sej_&va;
merge diag_charlson(in=q keep=nam dt_&va ) sejour(in=p keep=nam no_seq dtadm dtsort);
by nam;
if q ;
if dt_&va=. then delete;
if dtadm>dt_&va then delete;
*if dtsort<dt_&va-365 then delete;
if dtadm=dt_&va then same=1;else same=0;
run;

proc sort data=sej_&va;by nam no_seq;run;
proc sort data=me_diag;by nam no_seq;run;


*Find hospitalizations 1 year prior or equal index date for AMI;
data comor_&va;merge sej_&va(in=q) me_diag;
by nam no_seq;
if q;

diag4_diag=substr(diag_diag,1,4);

array ch(17) ch1-ch17;
do i=1 to 17;
ch(i)=0;
*list of heart disease;
end;

crheum_hd=0;hypertens=0;isch_hd=0;pulm_hd=0; other_hd=0; cerebro=0;artery_disease=0;



if noseq_cime='4'  then do;

   if diag3_diag in  ('410','412') then ch1=1;

            else if diag3_diag = '428' then ch2=1;

            else if diag3_diag in ('441') or diag4_diag in ('4439','V434','7854') then ch3=1;

            else if diag3_diag in ('430','431','432','433','434',
                                '435','436','437','438') then ch4=1;

            else if diag3_diag = '290' then ch5=1;

            else if diag3_diag in ('490','491','492','493','494','495',
                                '496','500','501','502','503','504',
                                '505') or diag4_diag='5064' then ch6=1;

            else if diag3_diag='725' or 
                         diag4_diag in ('7100','7101','7104','7140','7141','7142','7148') then ch7=1;

            else if diag3_diag in ('531','532','533','534') then ch8=1;

            else if diag4_diag in ('5712','5714','5715','5716') then ch9=1;

            else if diag4_diag in ('2500','2501','2502','2503','2507') 
				then ch10=1;

            else if diag4_diag in ('2504','2505','2506') then ch11=1;

            else if diag3_diag='342' or diag4_diag='3441' then ch12=1;

            else if diag3_diag in ('582','585','586','588') or
diag4_diag in ('5830','5831','5832','5833','5834','5835','5836','5837') then ch13=1;

            else if diag3_diag in ('140','141','142','143','144','145','146','147','148'
,'149','150'
,'151','152','153','154','155','156','157','158','159','160'
,'161','162','163','164','165','166','167','168','169','170'
,'171','172','174','175','176','177','178','179','180','181','182','183'
,'184','185','186','187','188','189','190','191','192','193','194','195'
,'200','201','202','203','204','205','206','207','208')
 then ch14=1;

else if diag4_diag in ('5722','5723','5724','5725','5726',
                                 '5727','5728','4560','4561','4562') 
				then ch15=1;

            else if diag3_diag in: ('196','197','198','199') then ch16=1;

            else if diag3_diag in: ('042','043','044') then ch17=1;


 *heart disease;

			if '393'<=diag3_diag<='398' then crheum_hd=1; 
			if '401'<=diag3_diag<='405' then hypertens=1; 
			if '410'<=diag3_diag<='414' then isch_hd=1; 
			if '415'<=diag3_diag<='417' then pulm_hd=1; 
			if '420'<=diag3_diag<='429' then other_hd=1; 
			if '430'<=diag3_diag<='438' then cerebro=1; 
			if '440'<=diag3_diag<='448' then artery_disease=1; 

end;

if noseq_cime='1'   then do;

 if diag3_diag in  ('I21','I22') 
     or diag4_diag in ('I252')
 then ch1=1;

 else if diag3_diag in  ('I43','I50')
     or diag4_diag in ('I099','I110','I130','I132','I255','I420','I425','I426','I427','I428','I429','P290')
 then ch2=1;

 else if diag3_diag in ('I70','I71') 
   or diag4_diag in ('I731','I738','I739','I771','I790','I792','K551','K558','K559','Z958','Z959') 
 then ch3=1;

 else if diag3_diag in ('G45','G46','I60','I61','I62','I63','I64','I65','I66','I67','I68','I69') 
   or diag4_diag in ('H340')
 then ch4=1;

 else if diag3_diag IN ('F00','F01','F02','F03','G30') 
   or diag4_diag in ('F051','G311')
 then ch5=1;

 else if diag3_diag in ('J40','J41','J42','J43','J44','J45','J46','J47','J60','J61','J62','J63','J64','J65','J66','J67') 
   or diag4_diag in ('I278','I279','J684','J701','J703') 
 then ch6=1;

 else if diag3_diag in ('M05','M06','M32','M33','M34') 
   or  diag4_diag in ('M315','M351','M353','M360') 
 then ch7=1;

  else if diag3_diag in ('K25','K26','K27','K28') 
  then ch8=1;

  else if diag3_diag in ('B18','K73','K74') 
    or  diag4_diag in ('K700','K701','K702','K703','K709','K713','K714','K715','K717','K760','K762','K763','K764','K768','K769','Z944') 
  then ch9=1;

  else if diag4_diag in ('E100','E101','E106','E108','E109','E110','E111','E116','E118','E119','E120','E121','E126','E128','E129'
                          ,'E130','E131','E136','E138','E139','E140','E141','E146','E148','E149') 
  then ch10=1;
    
  else if diag4_diag in ('E102','E103','E104','E105','E107','E112','E113','E114','E115','E117',
                         'E122','E123','E124','E125','E127','E132','E133','E134','E135','E137','E142','E143','E144','E145','E147') 
  then ch11=1;

  else if diag3_diag in ( 'G81','G82') or
          diag4_diag in ('G041','G114','G801','G802','G830','G831','G832','G833','G834','G839')  
  then ch12=1;

  else if diag3_diag in ('N18','N19') or
           diag4_diag in ('I120','I131','N032','N033','N034','N035','N036','N037','N052','N053','N054','N055','N056','N057','N250',
                         'Z490','Z491','Z492','Z940','Z992') 
  then ch13=1;

  else if diag3_diag in ('C00','C01','C02','C03','C04','C05','C06','C07','C08','C09'
                         ,'C10','C11','C12','C13','C14','C15','C16','C17','C18','C19'
                         ,'C20','C21','C22','C23','C24','C25','C26'
                         ,'C30','C31','C32','C33','C34','C37','C38','C39'
                         ,'C40','C41','C43','C45','C46','C47','C48','C49'
                         ,'C50','C51','C52','C53','C54','C55','C56','C57','C58'
                         ,'C60','C61','C62','C63','C64','C65','C66','C67','C68','C69'
                         ,'C70','C71','C72','C73','C74','C75','C76'
                         ,'C81','C82','C83','C84','C85','C88'
                         ,'C90','C91','C92','C93','C94','C95','C96','C97')
  then ch14=1;

  else if diag4_diag in ('I850','I859','I864','I982','K704','K711','K721','K729','K765','K766','K767') 
  then ch15=1;

  else if diag3_diag in ('C77','C78','C79','C80') 
  then ch16=1;

  else if diag3_diag in ('B20','B21','B22','B24') 
  then ch17=1;


   *heart disease;
  			if 'I05'<=diag3_diag<='I09' then crheum_hd=1; 
			if 'I10'<=diag3_diag<='I15' then hypertens=1; 
			if 'I20'<=diag3_diag<='I25' then isch_hd=1; 
			if 'I26'<=diag3_diag<='I28' then pulm_hd=1; 
			if 'I30'<=diag3_diag<='I52' then other_hd=1; 
			if 'I60'<=diag3_diag<='I69' or diag3_diag in ('G45','G46') then cerebro=1; 
			if 'I80'<=diag3_diag<='I89' then artery_disease=1; 



end;


label ch1='AMI'
        ch2='CHF'
        ch3='PVD'
        ch4='CVD'
        ch5='Dementia'
        ch6='COPD / Other Resp Dis'
        ch7='Rheumatologic Dis'
        ch8='Digestive Ulcer'
        ch9='Mild Liver Dis'
        ch10='Diabetes'
        ch11='Diabetes w/ Chronic Compl'
        ch12='Hemi or Paraplegia'
        ch13='Renal Dis'
        ch14='Primary Cancer'
        ch15='Moderate/Severe Liver Dis'
        ch16='Metastatic Cancer'
        ch17='HIV Infection';

  label crheum_hd='chronic rheumatic heart disease'
hypertens='hypertensive disease'
isch_hd='ischemic heart disease'
pulm_hd='diseases of pulmonary circulation'
other_hd='other form of heart disease'
cerebro='cerebrovascular disease'
artery_disease='diseases of arteries, arterioles, and capillaries';


drop i;
run;


***********************************************;
*take out diagnosis due to complication or infection
* when date of diagnosis is at index date;
*
*for heart disease, keep only those in the year
*  prior to index date;
***********************************************;


data nocomp_comor_&va;set comor_&va;

array ch(17) ch1-ch17;
array ncch(17) ncch1-ncch17;

array cd(7) crheum_hd hypertens isch_hd pulm_hd other_hd cerebro artery_disease;
array pcd(7) p_crheum_hd p_hypertens p_isch_hd p_pulm_hd p_other_hd p_cerebro p_artery_disease;
array tcd(7) t_crheum_hd t_hypertens t_isch_hd t_pulm_hd t_other_hd t_cerebro t_artery_disease;

do m=1 to 7;
pcd(m)=cd(m);
tcd(m)=cd(m);
end;


do i=1 to 17;
ncch(i)=ch(i);
*if the date of the diagnosis is at index date and the caracteridtic of the diagnosis
    is a complication or infection bring the comorbidity code to 0;
if dtadm=dt_&va and
code_cdiag ne '0' then ncch(i)=0;
end;

*For HX with diag of Heart disease in the year prior to index date
  bring back to zero if date=index_date ;
do j=1 to 7;
if dtsort=dt_&va then do; cd(j)=0;  pcd(j)=0;  tcd(j)=0;end;

*if hd diag in an hospitalization that cross diag410 put previous hd diag at 0;
if dtadm<dt_&va and dtsort>=dt_&va then pcd(j)=0;
*if hd diag in an hospitalization of hd is completely before diag410 put transfert hd diag at 0;
if dtadm<dt_&va and dtsort<dt_&va then tcd(j)=0;

end;
drop i j m;

if dtadm<dt_&va then do;diff=dt_&va-dtsort;end;
if diff<0 then neg=1; else neg=0;

sum_comor=sum(of ch1-ch17) ;
sum_hd=crheum_hd +hypertens+ isch_hd+ pulm_hd+ other_hd+ cerebro +artery_disease ;


run;


/*
proc freq data=nocomp_comor(where=(sum_hd>0));tables neg;run;
proc freq data=nocomp_comor(where=(sum_comor>0 and dtadm >dt_diag410));tables neg;run;
proc univariate data=nocomp_comor(where=(isch_hd>0));var diff;run;
proc print data=nocomp_comor(where=(isch_hd>0 and diff<-1000));run;

proc print data=nocomp_comor(where=(isch_hd>0 and diff<-1000));run;
*/
proc means noprint data=nocomp_comor_&va nway;
var ch1-ch17 ncch1-ncch17
    crheum_hd hypertens isch_hd pulm_hd other_hd cerebro artery_disease
p_crheum_hd p_hypertens p_isch_hd p_pulm_hd p_other_hd p_cerebro p_artery_disease
 t_crheum_hd t_hypertens t_isch_hd t_pulm_hd t_other_hd t_cerebro t_artery_disease;
class nam;
output out=nocomp_comor_&va.1 sum=sch1-sch17 sncch1-sncch17 
      scrheum_hd shypertens sisch_hd spulm_hd sother_hd scerebro sartery_disease
      sp_crheum_hd sp_hypertens sp_isch_hd sp_pulm_hd sp_other_hd sp_cerebro sp_artery_disease
      st_crheum_hd st_hypertens st_isch_hd st_pulm_hd st_other_hd st_cerebro st_artery_disease;
run;


data nocomp_comor_&va.2;set nocomp_comor_&va.1;
array sc(17) sch1-sch17;
array ch(17) ch1-ch17;

array sncc(17) sncch1-sncch17;
array ncch(17) ncch1-ncch17;



array scd(7) scrheum_hd shypertens sisch_hd spulm_hd sother_hd scerebro sartery_disease;
array cd(7)  crheum_hd hypertens isch_hd pulm_hd other_hd cerebro artery_disease;

array spcd(7)   sp_crheum_hd sp_hypertens sp_isch_hd sp_pulm_hd sp_other_hd sp_cerebro sp_artery_disease;
array pcd(7) p_crheum_hd p_hypertens p_isch_hd p_pulm_hd p_other_hd p_cerebro p_artery_disease;

array stcd(7) st_crheum_hd st_hypertens st_isch_hd st_pulm_hd st_other_hd st_cerebro st_artery_disease;
array tcd(7) t_crheum_hd t_hypertens t_isch_hd t_pulm_hd t_other_hd t_cerebro t_artery_disease;



do i=1 to 17;
if sc(i)>0 then ch(i)=1;else ch(i)=0;
if sncc(i)>0 then ncch(i)=1;else ncch(i)=0;
end;

do j=1 to 7;
if scd(j)>0 then cd(j)=1;else cd(j)=0;
if spcd(j)>0 then pcd(j)=1;else pcd(j)=0;
if stcd(j)>0 then tcd(j)=1;else tcd(j)=0;

end;

  label ch1='AMI'
        ch2='CHF'
        ch3='PVD'
        ch4='CVD'
        ch5='Dementia'
        ch6='COPD / Other Resp Dis'
        ch7='Rheumatologic Dis'
        ch8='Digestive Ulcer'
        ch9='Mild Liver Dis'
        ch10='Diabetes'
        ch11='Diabetes w/ Chronic Compl'
        ch12='Hemi or Paraplegia'
        ch13='Renal Dis'
        ch14='Primary Cancer'
        ch15='Moderate/Severe Liver Dis'
        ch16='Metastatic Cancer'
        ch17='HIV Infection';
label
		ncch1='AMI non compl at index'
        ncch2='CHF non compl at index'
        ncch3='PVD non compl at index'
        ncch4='CVD non compl at index'
        ncch5='Dementia non compl at index'
        ncch6='COPD / Other Resp Dis non compl at index'
        ncch7='Rheumatologic Dis non compl at index'
        ncch8='Digestive Ulcer non compl at index'
        ncch9='Mild Liver Dis non compl at index'
        ncch10='Diabetes non compl at index'
        ncch11='Diabetes w/ Chronic Compl non compl at index'
        ncch12='Hemi or Paraplegia non compl at index'
        ncch13='Renal Dis non compl at index'
        ncch14='Primary Cancer non compl at index'
        ncch15='Moderate/Severe Liver Dis non compl at index'
        ncch16='Metastatic Cancer non compl at index'
        ncch17='HIV Infection non compl at index';

  label crheum_hd='chronic rheumatic heart disease'
hypertens='hypertensive disease'
isch_hd='ischemic heart disease'
pulm_hd='diseases of pulmonary circulation'
other_hd='other form of heart disease'
cerebro='cerebrovascular disease'
artery_disease='diseases of arteries, arterioles, and capillaries';

label p_crheum_hd='complete prev index_dt chronic rheumatic heart disease'
p_hypertens='complete prev index_dt hypertensive disease'
p_isch_hd='complete prev index_dt ischemic heart disease'
p_pulm_hd='complete prev index_dt diseases of pulmonary circulation'
p_other_hd='complete prev index_dt other form of heart disease'
p_cerebro='complete prev index_dt cerebrovascular disease'
p_artery_disease='complete prev index_dt diseases of arteries, arterioles, and capillaries';

label t_crheum_hd='crossing index_dt chronic rheumatic heart disease'
t_hypertens='crossing index_dt hypertensive disease'
t_isch_hd='crossing index_dt ischemic heart disease'
t_pulm_hd='crossing index_dt diseases of pulmonary circulation'
t_other_hd='crossing index_dt other form of heart disease'
t_cerebro='crossing index_dt cerebrovascular disease'
t_artery_disease='crossing index_dt diseases of arteries, arterioles, and capillaries';

drop i j _type_ _freq_ sch1-sch17
scrheum_hd shypertens sisch_hd spulm_hd sother_hd scerebro sartery_disease
sp_crheum_hd sp_hypertens sp_isch_hd sp_pulm_hd sp_other_hd sp_cerebro sp_artery_disease
 st_crheum_hd st_hypertens st_isch_hd st_pulm_hd st_other_hd st_cerebro st_artery_disease 

;
run;

%mend;

%com(entry);

PROC EXPORT DATA= work.nocomp_comor_entry2 
            OUTFILE= "C:\Users\Nancy Zhu\OneDrive - McGill University\Code for thesis\charlson_365.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;



%macro comm(va);
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&;
*a changer pour le bon nom de data base;
data nocomp_comor_&va.3;set nocomp_comor_&va.2;
keep nam ch1-ch17 ncch1-ncch17
 p_crheum_hd p_hypertens p_isch_hd p_pulm_hd p_other_hd p_cerebro p_artery_disease
 t_crheum_hd t_hypertens t_isch_hd t_pulm_hd t_other_hd t_cerebro t_artery_disease;
run;

%mend;
%comm(entry)


/*
    *** impose a hierarchy ***;
 if ch15=1 and ch9=1 then ch9= 0;
  if ch11=1 and ch10=1 then ch10= 0;
  if ch16=1 and ch14=1 then ch14= 0;

  label ch1='AMI'
        ch2='CHF'
        ch3='PVD'
        ch4='CVD'
        ch5='Dementia'
        ch6='COPD / Other Resp Dis'
        ch7='Rheumatologic Dis'
        ch8='Digestive Ulcer'
        ch9='Mild Liver Dis'
        ch10='Diabetes'
        ch11='Diabetes w/ Chronic Compl'
        ch12='Hemi or Paraplegia'
        ch13='Renal Dis'
        ch14='Primary Cancer'
        ch15='Moderate/Severe Liver Dis'
        ch16='Metastatic Cancer'
        ch17='HIV Infection';


  *** if not reducing across records, create the charlson index ***;
  
    length charl 3;
    charl= sum( ch1, ch2, ch3, ch4, ch5, ch6, ch7, ch8, ch9, ch10, 2*ch11,
              2*ch12, 2*ch13, 2*ch14, 3*ch15, 6*ch16, 6*ch17 );
    label charl='Charlson Index';

  run;
*/

