%let path=C:\Users\Nancy Zhu\Google Drive\My SAS Files\ecprg193;
libname orion "&path";

proc contents data=orion._ALL_ nods;
run;

proc print data=orion.country;
run;

proc contents data=orion.charities;
run;

proc contents data=orion.sales;
run;

proc print data=orion.sales;
run;

data work.donations;
   infile "&path/donation.dat"; 
   input Employee_ID Qtr1 Qtr2 Qtr3 Qtr4;
   Total=sum(Qtr1,Qtr2,Qtr3,Qtr4);
run;

proc print data=donations;
run;

data work.newpacks;
   input Supplier_Name $ 1-20 Supplier_Country $ 23-24 
         Product_Name $ 28-70;
   datalines;
Top Sports            DK   Black/Black
Top Sports            DK   X-Large Bottlegreen/Black
Top Sports            DK   Comanche Women's 6000 Q Backpack. Bark
Miller Trading Inc    US   Expedition Camp Duffle Medium Backpack
Toto Outdoor Gear     AU   Feelgood 55-75 Litre Black Women's Backpack
Toto Outdoor Gear     AU   Jaguar 50-75 Liter Blue Women's Backpack
Top Sports            DK   Medium Black/Bark Backpack
Top Sports            DK   Medium Gold Black/Gold Backpack
Top Sports            DK   Medium Olive Olive/Black Backpack
Toto Outdoor Gear     AU   Trekker 65 Royal Men's Backpack
Top Sports            DK   Victor Grey/Olive Women's Backpack
Luna sastreria S.A.   ES   Hammock Sports Bag
Miller Trading Inc    US   Sioux Men's Backpack 26 Litre.
;

proc contents data=work.newpacks;

run;



proc print data=orion.sales noobs;
   var Last_Name First_Name Country Job_Title;
   where Country='AU' and 
   Job_Title contains 'Rep';
run;


proc print data=orion.order_fact noobs;
where Total_Retail_Price>500;
id Customer_ID;
var Customer_ID Order_ID Order_Type Quantity Total_Retail_Price;
sum Total_Retail_Price;

run;

proc print data=orion.order_fact noobs;
   where Total_Retail_Price>500;
   id Customer_ID;
   var Order_ID Order_Type Quantity
       Total_Retail_Price;
   sum Total_Retail_Price;
run;
proc contents data=orion.customer_dim;
run;
proc print data=orion.customer_dim noobs;
where Customer_Age>=30 &Customer_Age<=40;
id Customer_ID;
var Customer_ID
    Customer_Name
	Customer_Age
	Customer_Type;
run;

proc sort data=orion.sales
     out=work.sales_sort;
	 by Country descending Salary;
	 run;

proc print data=sales_sort;
by Country;
run;

proc sort data=orion.sales
          out=work.sorted;
   by Country Gender;
run;

proc print data=work.sorted; 
   by Gender;
run;

proc sort data=orion.employee_payroll
          out=work.sort_salary;
by Salary;
run;

proc print data=sort_salary;
run;

proc sort data=orion.employee_payroll
          out=work.sort_sal;
by Employee_Gender descending Salary;
run;
title1 "Orion Star sales report";
footnote1 'Confidential';


proc print data=sort_sal noobs;
by Employee_Gender;
sum Salary;
where Employee_Term_Date is missing & Salary>65000;
var Employee_ID Salary Marital_Status;
run;

title;
footnote;


title1 'Australian Sales Employees';
title2 'Senior Sales Representatives';
footnote1'Job_Title:Sales Rep.IV';
proc print data=orion.sales noobs;
where Country='AU' and Job_Title contains 'Rep. IV';
var Employee_ID First_Name Last_Name Gender Salary;
run;
title;
footnote;

proc print data=orion.employee_payroll;
var Employee_ID Salary Birth_Date Employee_Hire_Date;
format Salary dollar8. Birth_Date mmddyy10. Employee_Hire_Date Date9.;
run;


title1 'US Sales Employees';
title2 'Earning Under $26,000';
proc print data=orion.sales noobs;
where Salary<26000;
var Employee_ID First_Name Last_Name Job_Title Salary Hire_Date;
label First_Name='First Name' 
      Last_Name='Last Name'
      Job_Title='Title' 
      Hire_Date='Date Hired';
format Salary dollar8. Hire_Date Date9.;
run;
title;

proc print data=orion.sales;
run;

data q1birthdays;
set orion.employee_payroll;
BirthMonth=month(Birth_Date);
if BirthMonth le 3;
run;

proc format;
value $gender
'F'='Female'
'M'='Male';
value MNAME
1='January'
2='February'
3='March';
run;

proc print data=q1birthdays;
format Employee_Gender $gender.
       BirthMonth MNAME.;
run;
proc format;
value $gender 'F'='Female'
              'M'='Male'
			  other='Invalid code';
value salrange 20000-<100000='Below $100,000'
               100000-500000='$100,000 or more'
               .='Missing salary'
			   other='Invalid salary';
			   run;


proc print data=orion.nonsales;
format Gender $gender.
       Salary salrange.;
run;

proc print data=orion.sales;
run;

data work.subset1;
set orion.sales;
where Country='AU' and 
      Job_Title contains 'Rep';
run;

proc print data=subset1;
run;

data work.subset1;
set orion.sales;
where Country='AU' and 
      Job_Title contains 'Rep' and 
	  Hire_Date<'01jan2000'd;
      Bonus=Salary*0.1;
run;

proc print data=subset1;
var First_name Last_Name Salary
    Job_Title Bonus Hire_Date;
format Hire_Date date9.;
run;

data work.youngadult;
set orion.customer_dim;
where Customer_Gender='F' and 
      Customer_Age between 18 and 36 and 
      Customer_Group contains 'Gold';
Discount=0.25;
run;

proc print data=youngadult;
id Customer_ID;
run;

proc print data=orion.customer_dim;
run;

data work.subset1;
   set orion.sales;
   Bonus=Salary*.10;
   where Country='AU' and
         Bonus>=3000;
run;

proc print data=work.subset1;
run;

data work.auemps;
set orion.sales;
where Country='AU';
Bonus=Salary*0.1;
if Bonus>=3000;
run;

proc print data=auemps;
run;

data work.auemps;
   set orion.sales;
   Bonus=Salary*.10;
   if Country='AU' and Bonus>=3000;
run;

proc print data=work.auemps;
run;


data work.increase;
   set orion.staff;
   where Emp_Hire_Date >='01jul2010'd;    
   Increase=Salary*0.10;
   if Increase>3000;
   NewSalary=Salary+Increase;
   keep Employee_ID Emp_Hire_Date Salary
        Increase NewSalary;
   label Emp_Hire_Date='Hire Date'
         Employee_ID='Employee ID'
		 NewSalary='New Annual Salary'
         Salary='Annual Salary';
	format Salary dollar12.2
	       NewSalary comma5.;
run;

proc print data=increase split='';
run;

proc contents data=work.increase;
run;

data work.delays;
set orion.orders;
Order_Month=month(Order_Date);
where Delivery_Date>4+Order_Date and
      Employee_ID=99999999;
if    Order_Month=8;
keep Employee_ID Customer_ID Order_Date
     Delivery_Date Order_Month;
format Order_Date Delivery_Date mmddyy10.;
run;

proc contents data=delays;
run;

proc print data=delays;
run;


proc print data=orion.employee_donations;
run;
data work.bigdonations;
set orion.employee_donations;
Total=sum(Qtr1,Qtr2,Qtr3,Qtr4);
NumQtrs=N(Qtr1,Qtr2,Qtr3,Qtr4);
if Total>=50 and 
   NumQtrs = 4;
label Employee_ID='Employee ID'
      Qtr1='First Quarter'
	  Qtr2='Second Quarter'
	  Qtr3='Third Quarter'
	  Qtr4='Fourth Quarter';

drop Recipients Paid_by;
run;

proc print data=bigdonations label noobs;
run;

proc setinit;
run;


proc import datafile="&path/sales.xls"
            out=work.sales;
			getnames=no;
			run;


data work.thirdqtr;
set orion.mnth7_2011
    orion.mnth8_2011
	orion.mnth9_2011;
run;



proc print data=work.thirdqtr;
run;

proc contents data=orion.sales;
proc contents data=orion.nonsales;
run;

data work.allemployees;
set orion.sales
    orion.nonsales(rename=(First=First_Name Last=Last_Name));
keep Employee_ID First_Name Last_Name Job_Title Salary;
run;

proc contents data=orion.charities;
proc contents data=orion.us_suppliers;
proc contents data=orion.consultants;
run;

data work.contacts;
set orion.charities orion.us_suppliers;
run;

proc contents data=contacts;
run;

proc sort data=orion.employee_payroll
          out=work.payroll; 
   by Employee_ID;
run;

proc sort data=orion.employee_addresses
          out=work.addresses;
   by Employee_ID;
run;

data work.payadd;
   merge  ;
   by  ;
run;

proc print data=work.payadd;
   var Employee_ID Employee_Name
       Birth_Date Salary;
   format Birth_Date weekdate.;
run;


proc sort data=orion.employee_payroll
          out=work.payroll;
   by Employee_ID;
run;

proc sort data=orion.employee_addresses
          out=work.addresses;
   by Employee_ID;
run;

data work.payadd;
merge work.payroll work.addresses;
by Employee_ID;
run;

proc print data=payadd;
format Birth_Date WEEKDATE.;
run;

proc contents data=orion.orders;
proc contents data=orion.order_item;
run;

data work.allorders;
merge orion.orders orion.order_item;
keep Order_ID Order_Item_Num Order_Type Order_Date Quantity
     Total_Retail_Price;
run;

proc print data=allorders;
where Order_Date>='01Oct2011'd and 
      Order_Date<='31Dec2011'd;
run;

proc sort data=orion.product_list
          out=work.product_list_sort;
by Product_Level;
run;

proc contents data=orion.product_list;
proc contents data=orion.product_level;
run;

data work.listlevel;
merge orion_product_level work.product_list_sort;
by Product_Level;
keep Product_ID Product_Name Product_Level Product_Level_Name;
run;



proc print data=work.listlevel;
where Product_Level=3;
run;

