PROC IMPORT OUT= WORK.DIAG_CHARLSON 
            DATAFILE= "C:\Users\Nancy Zhu\OneDrive - McGill University\C
ode for thesis\diag_charlson2.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
