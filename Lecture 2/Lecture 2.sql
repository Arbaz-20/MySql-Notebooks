/*markdown
# Lecture 2: Seeding Data & Filtering with SELECT
Bulk-insert about 120 people, then practice picking columns, paginating with LIMIT/OFFSET, and filtering with WHERE, AND/OR/NOT, IN and LIKE.
Explanations for every query (Q1, Q2, ...) are in this folder's README.md.
*/

/*markdown
## Connect and inspect
*/

-- Q1
SHOW DATABASES;

-- Q2
use maqbool;

-- Q3
show TABLES;

-- Q4
desc maqbool_info;

-- Q5
SELECT * FROM maqbool_info;

/*markdown
## Insert a few rows and pick columns
*/

-- Q6
INSERT INTO maqbool_info(name,age,gender,is_student,phone_number) VALUES("Sameer",23,"male",True,+9125349534545),("Sameeruddin",23,"male",True,+9125349534545),("Sam",23,"male",True,+9125349534545);

-- Q7
SELECT * from maqbool_info;

-- Q8
SELECT name,age FROM maqbool_info;

-- Q9
SELECT name,gender from maqbool_info;

-- Q10
SELECT gender,phone_number from maqbool_info;

-- Q11
SELECT name FROM maqbool_info;

-- Q12
SELECT * from maqbool_info;

/*markdown
## Bulk seed 100 people
*/

-- Q13
INSERT INTO maqbool_info (name, age, gender, is_student, phone_number) VALUES
('Aarav Sharma', 22, 'Male', TRUE, '9876543210'),
('Priya Patel', 19, 'Female', TRUE, '9876543211'),
('Rohan Gupta', 35, 'Male', FALSE, '9876543212'),
('Sneha Reddy', 28, 'Female', FALSE, '9876543213'),
('Vikram Singh', 20, 'Male', TRUE, '9876543214'),
('Ananya Iyer', 24, 'Female', TRUE, '9876543215'),
('Arjun Nair', 31, 'Male', FALSE, '9876543216'),
('Kavya Menon', 17, 'Female', TRUE, '9876543217'),
('Rahul Verma', 40, 'Male', FALSE, '9876543218'),
('Deepika Joshi', 26, 'Female', FALSE, '9876543219'),
('Amit Kumar', 18, 'Male', TRUE, '9876543220'),
('Fatima Khan', 23, 'Female', TRUE, '9876543221'),
('Suresh Rao', 45, 'Male', FALSE, '9876543222'),
('Meera Das', 21, 'Female', TRUE, '9876543223'),
('Nikhil Chopra', 29, 'Male', FALSE, '9876543224'),
('Pooja Agarwal', 33, 'Female', FALSE, '9876543225'),
('Siddharth Bose', 16, 'Male', TRUE, '9876543226'),
('Ritu Saxena', 27, 'Female', FALSE, '9876543227'),
('Karan Malhotra', 38, 'Male', FALSE, '9876543228'),
('Divya Pillai', 20, 'Female', TRUE, '9876543229'),
('Manish Tiwari', 25, 'Male', TRUE, '9876543230'),
('Swati Mishra', 30, 'Female', FALSE, '9876543231'),
('Ajay Pandey', 42, 'Male', FALSE, '9876543232'),
('Nisha Kulkarni', 19, 'Female', TRUE, '9876543233'),
('Rajesh Bhatt', 34, 'Male', FALSE, '9876543234'),
('Shreya Desai', 22, 'Female', TRUE, '9876543235'),
('Vivek Chauhan', 28, 'Male', FALSE, '9876543236'),
('Anjali Sinha', 15, 'Female', TRUE, '9876543237'),
('Prakash Jain', 50, 'Male', FALSE, '9876543238'),
('Lakshmi Venkat', 23, 'Female', TRUE, '9876543239'),
('Gaurav Dubey', 36, 'Male', FALSE, '9876543240'),
('Sakshi Goyal', 18, 'Female', TRUE, '9876543241'),
('Mohan Prasad', 44, 'Male', FALSE, '9876543242'),
('Tanvi Kapoor', 21, 'Female', TRUE, '9876543243'),
('Aditya Shukla', 27, 'Male', FALSE, '9876543244'),
('Neha Bansal', 32, 'Female', FALSE, '9876543245'),
('Harsh Mehta', 17, 'Male', TRUE, '9876543246'),
('Aparna Nambiar', 26, 'Female', FALSE, '9876543247'),
('Tarun Sethi', 39, 'Male', FALSE, '9876543248'),
('Isha Dutta', 20, 'Female', TRUE, '9876543249'),
('Manoj Hegde', 41, 'Male', FALSE, '9876543250'),
('Pallavi Thakur', 24, 'Female', TRUE, '9876543251'),
('Abhishek Yadav', 29, 'Male', FALSE, '9876543252'),
('Simran Kaur', 18, 'Female', TRUE, '9876543253'),
('Pankaj Rawat', 46, 'Male', FALSE, '9876543254'),
('Charvi Rastogi', 22, 'Female', TRUE, '9876543255'),
('Sanjay Ojha', 37, 'Male', FALSE, '9876543256'),
('Madhuri Patil', 25, 'Female', FALSE, '9876543257'),
('Tushar Bhagat', 16, 'Male', TRUE, '9876543258'),
('Vidya Krishnan', 30, 'Female', FALSE, '9876543259'),
('Akash Soni', 23, 'Male', TRUE, '9876543260'),
('Jaya Rangan', 33, 'Female', FALSE, '9876543261'),
('Dhruv Chandra', 19, 'Male', TRUE, '9876543262'),
('Rekha Mukherjee', 48, 'Female', FALSE, '9876543263'),
('Pranav Lal', 21, 'Male', TRUE, '9876543264'),
('Tara Seshadri', 27, 'Female', FALSE, '9876543265'),
('Yash Mittal', 35, 'Male', FALSE, '9876543266'),
('Kriti Ahuja', 20, 'Female', TRUE, '9876543267'),
('Nilesh Pawar', 43, 'Male', FALSE, '9876543268'),
('Bhavna Arora', 26, 'Female', FALSE, '9876543269'),
('Sahil Grover', 18, 'Male', TRUE, '9876543270'),
('Uma Subramaniam', 31, 'Female', FALSE, '9876543271'),
('Ashwin Narayan', 24, 'Male', TRUE, '9876543272'),
('Suman Ghosh', 38, 'Female', FALSE, '9876543273'),
('Kunal Bhatia', 22, 'Male', TRUE, '9876543274'),
('Rani Choudhury', 29, 'Female', FALSE, '9876543275'),
('Dev Anand Rathi', 15, 'Male', TRUE, '9876543276'),
('Gayatri Mahajan', 34, 'Female', FALSE, '9876543277'),
('Rishabh Tandon', 20, 'Male', TRUE, '9876543278'),
('Sunita Basu', 47, 'Female', FALSE, '9876543279'),
('Varun Kohli', 25, 'Male', TRUE, '9876543280'),
('Chitra Raghavan', 28, 'Female', FALSE, '9876543281'),
('Anand Trivedi', 40, 'Male', FALSE, '9876543282'),
('Falguni Shah', 19, 'Female', TRUE, '9876543283'),
('Hemant Dixit', 36, 'Male', FALSE, '9876543284'),
('Minal Wagh', 23, 'Female', TRUE, '9876543285'),
('Ravi Shankar', 52, 'Male', FALSE, '9876543286'),
('Sarita Nanda', 21, 'Female', TRUE, '9876543287'),
('Jayesh Parikh', 33, 'Male', FALSE, '9876543288'),
('Aditi Samant', 17, 'Female', TRUE, '9876543289'),
('Girish Kale', 44, 'Male', FALSE, '9876543290'),
('Vandana Luthra', 26, 'Female', FALSE, '9876543291'),
('Omkar Deshpande', 20, 'Male', TRUE, '9876543292'),
('Hema Sundaram', 30, 'Female', FALSE, '9876543293'),
('Shyam Ahluwalia', 39, 'Male', FALSE, '9876543294'),
('Preeti Dhawan', 22, 'Female', TRUE, '9876543295'),
('Mahesh Garde', 49, 'Male', FALSE, '9876543296'),
('Nandini Hegde', 24, 'Female', TRUE, '9876543297'),
('Chirag Vora', 28, 'Male', FALSE, '9876543298'),
('Rupal Joglekar', 18, 'Female', TRUE, '9876543299'),
('Dinesh Kashyap', 41, 'Male', FALSE, '9876543300'),
('Shilpa Naik', 25, 'Female', FALSE, '9876543301'),
('Arnav Mistry', 16, 'Male', TRUE, '9876543302'),
('Komal Chawla', 32, 'Female', FALSE, '9876543303'),
('Vijay Sabharwal', 37, 'Male', FALSE, '9876543304'),
('Esha Solanki', 21, 'Female', TRUE, '9876543305'),
('Naveen Rathore', 46, 'Male', FALSE, '9876543306'),
('Zara Sheikh', 19, 'Female', TRUE, '9876543307'),
('Ishan Khurana', 23, 'Male', TRUE, '9876543308'),
('Padma Sundaresan', 55, 'Female', FALSE, '9876543309');

-- Q14
SELECT * from maqbool_info;

/*markdown
## Pagination with LIMIT / OFFSET
*/

-- Q15
SELECT * FROM maqbool_info LIMIT 10 OFFSET 0;

-- Q16
SELECT * FROM maqbool_info LIMIT 10 OFFSET 0;

-- Q17
SELECT * FROM maqbool_info;

-- Q18
SELECT * FROM maqbool_info LIMIT 10 OFFSET 0;

-- Q19
SELECT * FROM maqbool_info LIMIT 10 OFFSET 10;

-- Q20
SELECT * FROM maqbool_info LIMIT 10 OFFSET 20;

-- Q21
SELECT * FROM maqbool_info LIMIT 10 OFFSET 30;

/*markdown
## Filtering by exact name (WHERE =)
*/

-- Q22
SELECT * FROM maqbool_info where name="Arbaz" LIMIT 10 OFFSET 0;

-- Q23
INSERT INTO maqbool_info (name, age, gender, is_student, phone_number) VALUES
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210'),
('Arbaz Khan', 22, 'Male', TRUE, '9876543210');

-- Q24
SELECT * FROM maqbool_info;

-- Q25
SELECT * FROM maqbool_info WHERE name="Arbaz Khan" LIMIT 10 OFFSET 0;

-- Q26
SELECT * FROM maqbool_info WHERE name="Arbaz";

-- Q27
SELECT * FROM maqbool_info;

-- Q28
SELECT * FROM maqbool_info WHERE name="Arbaz Khan" LIMIT 10 OFFSET 0;

-- Q29
SELECT * FROM maqbool_info WHERE name="Arbaz Khan" LIMIT 10 OFFSET 10;

/*markdown
## Combining conditions with AND / OR
*/

-- Q30
SELECT * FROM maqbool_info WHERE name="Arbaz Khan" AND gender="male" LIMIT 10 OFFSET 0;

-- Q31
SELECT * FROM maqbool_info WHERE name="Arbaz Khan" AND gender="female" LIMIT 10 OFFSET 0;

-- Q32
SELECT * FROM maqbool_info WHERE name="Arbaz" OR gender="female" LIMIT 10 OFFSET 0;

/*markdown
## Lookups by id, IN lists and NOT
*/

-- Q33
SELECT * FROM maqbool_info WHERE id=1;

-- Q34
SELECT * FROM maqbool_info WHERE name IN ("Arbaz","Arbaz Khan",'Esha Solanki',"Naveen Rathore");

-- Q35
SELECT * FROM maqbool_info WHERE NOT name="Arbaz Khan" LIMIT 10 OFFSET 100;

-- Q36
SELECT * FROM maqbool_info WHERE NOT name="Arbaz Khan" LIMIT 10 OFFSET 100;

-- Q37
SELECT * FROM maqbool_info WHERE id IN (1,23,3,4,53,2,11,5,67,4);

-- Q38
SELECT * FROM maqbool_info where name="Arbaz Khan";

/*markdown
## Pattern matching with LIKE
*/

-- Q39
SELECT * FROM maqbool_info WHERE name LIKE '%Arbaz%';

-- Q40
SELECT * FROM maqbool_info WHERE name="Arbaz";

-- Q41
SELECT * FROM maqbool_info WHERE name LIKE '%P%';

-- Q42
SELECT * FROM maqbool_info WHERE name NOT LIKE '%Arbaz%';

/*markdown
## Wrap up
*/

-- Q43
show TABLES;

-- Q44
desc maqbool_info;
