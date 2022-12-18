CREATE TABLE Branch (
  	b_ifsc varchar(10) NOT NULL,
    b_name varchar(30),
  	b_city varchar(30),
  	PRIMARY KEY (b_ifsc)
);



CREATE TABLE Account (
  	acc_no int NOT NULL,
    acc_balance int,
  	b_ifsc varchar(30),
  	PRIMARY KEY (acc_no),
  	FOREIGN KEY (b_ifsc) REFERENCES Branch(b_ifsc)
);


CREATE TABLE Loan (
  	l_id int NOT NULL,
    l_amt int,
  	b_ifsc varchar(30),
  	PRIMARY KEY (l_id),
  	FOREIGN KEY (b_ifsc) REFERENCES Branch(b_ifsc)
);


CREATE TABLE Customer (
    cust_id int NOT NULL,
    cust_lName varchar(30),
    cust_fName varchar(30),
    cust_street varchar(50),
    cust_city varchar(30),
  	cust_phone int,
  	cust_email varchar(30),
  	acc_no int,
  	l_id int,
  	PRIMARY KEY (cust_id),
  	FOREIGN KEY (acc_no) REFERENCES Account(acc_no),
  	FOREIGN KEY (l_id) REFERENCES Loan(l_id)
);



CREATE TABLE Employee (
  	emp_id int NOT NULL,
    emp_lName varchar(30),
    emp_fName varchar(30),
    emp_street varchar(30),
    emp_city  varchar(50),
  	emp_phone int,
  	emp_email varchar(30),
  	b_ifsc varchar(30),
  	PRIMARY KEY (emp_id),
  	FOREIGN KEY (b_ifsc) REFERENCES Branch(b_ifsc)
);



CREATE TABLE Transaction (
  	acc_no int,
    tr_id int NOT NULL AUTO_INCREMENT,
  	tr_description varchar(30),
  	tr_amt int,
  	tr_updatedBalance int,
  	tr_date DateTime,
  	PRIMARY KEY (tr_id),
    FOREIGN KEY (acc_no) REFERENCES Account(acc_no)
);



# Queries -
# a. Generate customers complete profile information, mentioning the current balance and loan info if any.
# b. Fund transfer from one account to another account.
# c. Retrieve the last month statements of any account number.
# d. Withdraw money from account.
# e. Deposit money to account

#-- QUERY 1
SELECT cust_id,cust_fname,cust_street,cust_city,cust_phone,cust_email,Account.acc_no,acc_balance,Account.b_ifsc,Loan.l_id,l_amt,Loan.b_ifsc FROM Customer 
LEFT JOIN Account ON Customer.acc_no = Account.acc_no
LEFT JOIN Loan ON Customer.l_id = Loan.l_id;
 
#-- QUERY 2
CREATE PROCEDURE transfer (IN Acc_No1 INT ,IN Acc_No2 INT, In amt INT)  
BEGIN  
	DECLARE a, b INT;
    DECLARE res VARCHAR(30);
	SELECT acc_balance into a from Account WHERE acc_no = Acc_No1; 
    SELECT acc_balance into b from Account WHERE acc_no = Acc_No2;
   	
IF a >= amt THEN
    SET a = a - amt;
    SET b = b + amt;
    UPDATE Account SET acc_balance = a WHERE acc_no = Acc_No1;
    UPDATE Account SET acc_balance = b WHERE acc_no = Acc_No2;
	SET res = CONCAT("Transferred successfully ",amt);
    SELECT res;
    INSERT INTO Transaction (acc_no,tr_description,tr_amt,tr_updatedBalance,tr_Date) Values(Acc_No1, CONCAT("Amount Transferred to ",Acc_No2), amt, a, NOW());  
    INSERT INTO Transaction (acc_no,tr_description,tr_amt,tr_updatedBalance,tr_Date) Values(Acc_No2,CONCAT("Amount Received From ",Acc_No1), amt, b, NOW());    
ELSE
    SET res = "Insufficient Balance";
    SELECT res;
END IF;
END;


#--Query 3
SELECT * FROM Transaction WHERE Transaction.acc_no = ? && tr_Date >= CURRENT_TIMESTAMP - INTERVAL 1 MONTH ORDER BY tr_date DESC;


#--Query 4

CREATE PROCEDURE withdrawAmount (IN Acc_No INT, In amt INT)  
BEGIN
	DECLARE bal INT;
    DECLARE output VARCHAR(30);
	SELECT acc_balance from Account WHERE Account.acc_no = Acc_No INTO bal; 
IF bal >= amt THEN
    SET bal = bal - amt;
    UPDATE Account SET Account.acc_balance = bal WHERE Account.acc_no = Acc_No;
    INSERT INTO Transaction (acc_no,tr_description,tr_amt,tr_updatedBalance,tr_Date) Values(Acc_No,CONCAT("Withdraw ",amt), amt, bal, NOW());
    SET output = CONCAT("Withdraw successfully ",amt);
    SELECT output;
ELSE 
	SET output = "Insufficient Balance";
    SELECT output;
END IF;
END;


#--Query 5

CREATE PROCEDURE deposit (IN Acc_No INT, In amt INT)  
BEGIN
	DECLARE bal INT;
    DECLARE output VARCHAR(30);
	SELECT acc_balance from Account WHERE Account.acc_no = Acc_No INTO bal; 
    SET bal = bal + amt;
    UPDATE Account SET Account.acc_balance = bal WHERE Account.acc_no = Acc_No;
    INSERT INTO Transaction (acc_no,tr_description,tr_amt,tr_updatedBalance,tr_Date) Values(Acc_No,0,CONCAT("Deposit ",amt), amt, bal, NOW());
    SET output = CONCAT("Deposit Successfully ",amt);
    SELECT output;
END;

