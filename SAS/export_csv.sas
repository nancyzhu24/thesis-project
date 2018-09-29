PROC EXPORT DATA= DATA.pharma_2005 
            OUTFILE= "E:\export_R\pharma_2005.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;


PROC EXPORT DATA= DATA.pharma_2010
            OUTFILE= "E:\export_R\pharma_2010.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

PROC EXPORT DATA= DATA.pharma_2011
            OUTFILE= "E:\export_R\pharma_2011.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

PROC EXPORT DATA= DATA.pharma_2008
            OUTFILE= "E:\export_R\pharma_2008.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

PROC EXPORT DATA= DATA.pharma_2009
            OUTFILE= "E:\export_R\pharma_2009.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

proc contents data=data.me_services;
run;
