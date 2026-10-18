/*markdown
# Lecture 6: Addresses, Foreign Keys, Indexes & the First View
A third table (`address`), enforced relationships with FOREIGN KEY, multi-table joins, EXPLAIN before and after indexing, composite indexes, and a first VIEW.
Explanations for every query (Q1, Q2, ...) are in this folder's README.md.
*/

/*markdown
## Setup and a join with table aliases
*/

-- Q1
use maqbool;

-- Q2
show tables;

-- Q3
SELECT m.id,m.age,m.gender,o.id,o.item_count,o.order_number,o.status,o.total_amount,o.user_id from maqbool_info as m
JOIN orders as o ON o.user_id=m.id
WHERE o.status="confirmed" LIMIT 10 OFFSET 0;

/*markdown
## The address table
*/

-- Q4
CREATE TABLE IF NOT EXISTS Address(id int UNIQUE PRIMARY KEY AUTO_INCREMENT,user_id int NOT NULL,address VARCHAR(255),pincode BIGINT);

-- Q5
desc Address;

-- Q6
INSERT INTO Address (user_id, address, pincode) VALUES
(1, '12 MG Road, Camp', 411001),
(2, '45 FC Road, Shivajinagar', 411005),
(3, '78 JM Road, Deccan', 411004),
(4, '23 Laxmi Road, Sadashiv Peth', 411030),
(5, '56 Baner Road, Baner', 411045),
(6, '89 SB Road, Erandwane', 411004),
(7, '34 Kothrud Main Road, Kothrud', 411038),
(8, '67 Hinjewadi Phase 1', 411057),
(9, '90 Wakad High Street', 411057),
(10, '11 Viman Nagar Main Road', 411014),
(11, '44 Koregaon Park Lane 5', 411001),
(12, '77 Kalyani Nagar Road', 411006),
(13, '22 Aundh ITI Road', 411007),
(14, '55 Pimple Saudagar Main', 411027),
(15, '88 Hadapsar Industrial Estate', 411013),
(16, '33 Magarpatta City Road', 411028),
(17, '66 Kondhwa Budruk', 411048),
(18, '99 Undri Chowk', 411060),
(19, '14 NIBM Road, Mohammadwadi', 411060),
(20, '47 Sinhagad Road, Vadgaon', 411041),
(21, '80 Warje Malwadi Road', 411058),
(22, '25 Karve Road, Deccan', 411004),
(23, '58 Tilak Road, Sadashiv Peth', 411030),
(24, '91 Nagar Road, Wadgaon Sheri', 411014),
(25, '16 Boat Club Road, Pune', 411001),
(26, '49 Model Colony, Shivajinagar', 411016),
(27, '82 Law College Road', 411004),
(28, '27 Bhandarkar Road', 411004),
(29, '60 Senapati Bapat Road', 411016),
(30, '93 Pashan Sus Road', 411021),
(31, '18 Bavdhan Khurd', 411021),
(32, '51 Ambegaon Pathar', 411046),
(33, '84 Dhankawadi Road', 411043),
(34, '29 Katraj Bypass Road', 411046),
(35, '62 Bibwewadi Main Road', 411037),
(36, '95 Sahakarnagar Lane 3', 411009),
(37, '20 Parvati Darshan Road', 411009),
(38, '53 Mukund Nagar Main', 411037),
(39, '86 Ghorpadi Bazar', 411001),
(40, '31 Wanowrie Camp Road', 411040),
(41, '64 Fatima Nagar Road', 411040),
(42, '97 Mundhwa Village Road', 411036),
(43, '42 Keshav Nagar, Mundhwa', 411036),
(44, '75 Wagholi Main Road', 412207),
(45, '10 Chandan Nagar, Kharadi', 411014),
(46, '43 Dhanori Road', 411015),
(47, '76 Vishrantwadi Main', 411015),
(48, '21 Yerawada Jail Road', 411006),
(49, '54 Sangamwadi Lane 2', 411006),
(50, '87 Tadiwala Road', 411001),
(51, '32 Koregaon Park Lane 1', 411001),
(52, '65 North Main Road, KP', 411001),
(53, '98 South Main Road, KP', 411001),
(54, '13 Ganeshkhind Road', 411007),
(55, '46 University Road, Ganeshkhind', 411007),
(56, '79 Pashan Road', 411008),
(57, '24 Sus Road, Pashan', 411021),
(58, '57 Baner Balewadi Road', 411045),
(59, '30 Mahalunge Balewadi', 411045),
(60, '63 ICC Trade Tower Road', 411045),
(61, '96 Blue Ridge Township, Hinjewadi', 411057),
(62, '41 Wakad Bridge Road', 411057),
(63, '74 Pimple Nilakh Main', 411027),
(64, '19 Sangvi Aundh Road', 411027),
(65, '52 Chinchwad Station Road', 411019),
(66, '85 Nigdi Pradhikaran', 411044),
(67, '38 Akurdi Railway Road', 411035),
(68, '71 Bhosari Industrial Area', 411026),
(69, '26 Dighi Alandi Road', 411015),
(70, '59 Moshi Pradhikaran', 412105),
(71, '92 Charholi Budruk', 412105),
(72, '37 Dehu Alandi Road', 412101),
(73, '70 Talegaon Station Road', 410507),
(74, '15 Lonavala Market Road', 410401),
(75, '48 Kamshet Village Road', 410405),
(76, '81 Maval Taluka Main', 410506),
(77, '36 Pirangut Village Road', 412115),
(78, '69 Lavasa Main Road', 412112),
(79, '12 Mulshi Dam Road', 411042),
(80, '45 Paud Road, Kothrud', 411038),
(81, '78 Chandni Chowk, Bavdhan', 411021),
(82, '23 NDA Road, Khadakwasla', 411024),
(83, '56 Sinhagad Fort Road', 411025),
(84, '89 Donje Village Road', 411025),
(85, '34 Rajiv Gandhi Infotech Park', 411057),
(86, '67 Maan Village, Hinjewadi', 411057),
(87, '90 Tathawade Main Road', 411033),
(88, '11 Kasarwadi Station Road', 411034),
(89, '44 Dapodi Bridge Road', 411012),
(90, '77 Khadki Bazar Road', 411003),
(91, '22 Range Hills Road', 411007),
(92, '55 Vetal Hill Path', 411004),
(93, '88 Hanuman Tekdi Road', 411009),
(94, '33 Saras Baug Lane', 411009),
(95, '66 Peshwe Park Road', 411002),
(96, '99 Shaniwar Wada Road', 411030),
(97, '14 Lal Mahal Road', 411030),
(98, '47 Shukrawar Peth Main', 411002),
(99, '80 Kasba Peth Road', 411011),
(100, '25 Budhwar Peth Lane', 411002),
(1, '58 Raviwar Peth Main', 411002),
(2, '91 Nana Peth Road', 411002),
(3, '16 Ghorpade Peth Lane', 411042),
(4, '49 Swargate Bus Stand Road', 411037),
(5, '82 Pune Station Approach', 411001),
(6, '27 Shivaji Market Road', 411002),
(7, '60 Mandai Market Lane', 411002),
(8, '93 Tulshibaug Lane', 411002),
(9, '18 Bajirao Road', 411002),
(10, '51 Jungli Maharaj Road', 411005),
(11, '84 Fergusson College Road', 411005),
(12, '29 Apte Road, Deccan', 411004),
(13, '62 Prabhat Road, Erandwane', 411004),
(14, '95 Bhandarkar Institute Road', 411004),
(15, '20 MIT College Road, Kothrud', 411038),
(16, '53 Mayur Colony, Kothrud', 411038),
(17, '86 Dahanukar Colony', 411029),
(18, '31 Erandwane Gaothan', 411004),
(19, '64 Ideal Colony, Kothrud', 411038),
(20, '97 Paud Phata, Kothrud', 411038),
(101, '42 Survey No 15, Baner', 411045),
(102, '75 Amanora Park Town, Hadapsar', 411028),
(103, '10 Kumar Pacific, Shankar Sheth Road', 411037),
(104, '43 Phoenix Mall Road, Viman Nagar', 411014),
(105, '76 Eon IT Park, Kharadi', 411014),
(106, '21 World Trade Center, Kharadi', 411014),
(107, '54 Cerebrum IT Park, Kalyani Nagar', 411006),
(108, '87 Commerzone, Yerwada', 411006),
(109, '32 Panchshil Towers, Kharadi', 411014),
(110, '65 Nyati County, Undri', 411060),
(111, '98 Kolte Patil Road, Wakad', 411057),
(112, '13 Godrej Infinity, Keshav Nagar', 411036),
(113, '46 Marvel Fria, Wagholi', 412207),
(114, '79 VTP Township, Undri', 411060),
(115, '24 Bramha Suncity, Wadgaon Sheri', 411014),
(116, '57 Pride World City, Charholi', 412105),
(117, '30 Megapolis, Hinjewadi Phase 3', 411057),
(118, '63 Life Republic, Hinjewadi', 411057),
(119, '96 Lodha Belmondo, Gahunje', 412101),
(120, '41 Shapoorji Pallonji, Bavdhan', 411021),
(121, '74 DSK Vishwa, Dhayari', 411041),
(122, '19 Nanded City, Sinhagad Road', 411041),
(123, '52 Jambhe Village, Pirangut', 412115),
(124, '85 Kiwale Ravet Road', 411033),
(125, '38 Punawale Main Road', 411033),
(126, '71 Tathawade IT Park', 411033),
(21, '26 Sus Gaon Road', 411021),
(22, '59 Lavale Village Road', 411042),
(23, '92 Pirangut Bypass Road', 412115),
(24, '37 Urawade Village Road', 412115),
(25, '70 Hinjewadi Rajiv Gandhi IT Park Phase 2', 411057),
(26, '15 Bhukum Village Road', 411042),
(27, '48 Maan Hinjewadi Road', 411057),
(28, '81 Marunji Village Road', 411057),
(29, '36 Kirkatwadi Village', 411024),
(30, '69 Nanded Phata Road', 411041),
(50, '22 Camp Garden Road', 411001),
(51, '55 East Street, Camp', 411001),
(60, '88 Sopan Baug Lane', 411001),
(70, '33 Salisbury Park Road', 411037),
(80, '66 Market Yard Road', 411037),
(90, '99 Gultekdi Industrial Estate', 411037),
(100, '14 Ganesh Mala Road, Swargate', 411042),
(110, '47 Mitramandal Colony', 411009),
(120, '80 Padmavati Road', 411009),
(35, '25 Narayan Peth Main', 411030),
(45, '58 Sadashiv Peth Lane 4', 411030),
(55, '91 Rasta Peth Road', 411011),
(65, '16 Bhawani Peth Lane', 411042),
(75, '49 Dattawadi Road', 411030),
(85, '82 Hingne Khurd', 411051),
(95, '27 Anand Nagar, Sinhagad Road', 411051),
(105, '60 Wadgaon BK Main', 411041),
(115, '93 Ambegaon BK Road', 411046),
(125, '18 Narhe Village Road', 411041),
(36, '51 Katraj Dairy Road', 411046),
(46, '84 Kondhwa Khurd', 411048),
(56, '29 NIBM Annexe Road', 411048),
(66, '62 Mohammdwadi Undri Road', 411060),
(76, '95 Pisoli Village Road', 411060),
(86, '20 Handewadi Road', 411028),
(96, '53 Sadesatara Nali Road', 411028),
(106, '86 Phursungi Village Road', 412308),
(116, '31 Loni Kalbhor Road', 412201),
(126, '64 Uruli Devachi Road', 412308);

-- Q7
show TABLES;

-- Q8
SELECT * from orders;

-- Q9
SELECT * FROM address;

/*markdown
## A first three-table join
*/

-- Q10
SELECT m.id,m.age,m.gender,o.status,o.total_amount,o.id,o.user_id,a.address as address_data,a.id as address_id,a.user_id as address_user_id from maqbool_info as m
INNER JOIN orders as o ON m.id = o.id
INNER JOIN address as a ON a.user_id = m.id;

/*markdown
## Foreign keys
*/

-- Q11
desc maqbool_info;

-- Q12
desc orders;

-- Q13
desc address;

-- Q14
ALTER TABLE address MODIFY user_id INT NOT NULL;

-- Q15
ALTER TABLE orders MODIFY user_id INT NOT NULL;

-- Q16
desc orders;

-- Q17
desc maqbool_info;

-- Q18
desc address;

-- Q19
ALTER TABLE orders ADD CONSTRAINT fk_user_orders FOREIGN KEY (user_id) REFERENCES maqbool_info(id);

-- Q20
ALTER TABLE address ADD CONSTRAINT fk_users_address FOREIGN KEY (user_id) REFERENCES maqbool_info(id);

-- Q21
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME IS NOT NULL
AND TABLE_SCHEMA = 'maqbool';

/*markdown
## Multi-table joins: INNER, LEFT, RIGHT, CROSS
*/

-- Q22
SELECT * FROM maqbool_info
JOIN orders ON maqbool_info.id=orders.user_id
JOIN address ON maqbool_info.id=address.user_id
WHERE orders.status="delivered" AND maqbool_info.age=23;

-- Q23
SELECT * FROM maqbool_info
LEFT JOIN address ON maqbool_info.id=address.user_id
LEFT JOIN orders ON maqbool_info.id=orders.user_id
LIMIT 100 OFFSET 0;

-- Q24
SELECT * FROM maqbool_info
RIGHT JOIN address ON maqbool_info.id=address.user_id
RIGHT JOIN orders ON maqbool_info.id=orders.user_id
LIMIT 100 OFFSET 0;

-- Q25
SELECT * FROM maqbool_info
CROSS JOIN orders
CROSS JOIN address;

-- Q26
SELECT COUNT(*) from orders;

-- Q27
SELECT COUNT(*) from maqbool_info;

/*markdown
## EXPLAIN and single-column indexes
*/

-- Q28
select * from maqbool_info WHERE name like 'Arbaz%';

-- Q29
EXPLAIN SELECT * from maqbool_info WHERE name like 'Arbaz%';

-- Q30
CREATE INDEX idx_user_name on maqbool_info(name);

-- Q31
SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' ORDER BY id ASC;

-- Q32
EXPLAIN SELECT * FROM maqbool_info WHERE name LIKE 'Arbaz%' ORDER BY id ASC;

-- Q33
EXPLAIN SELECT * FROM maqbool_info WHERE age=21;

-- Q34
CREATE INDEX idx_user_age on maqbool_info(age);

-- Q35
SELECT * FROM maqbool_info WHERE age=21;

-- Q36
EXPLAIN SELECT * FROM maqbool_info WHERE age=21;

/*markdown
## Composite index
*/

-- Q37
CREATE INDEX multiIDX_user_gender_is_student_phone_number ON maqbool_info(gender,is_student,phone_number);

-- Q38
SELECT * from
maqbool_info WHERE gender LIKE 'male%';

-- Q39
EXPLAIN SELECT * from
maqbool_info WHERE gender LIKE 'male%' AND age=21;

/*markdown
## Inspecting and managing indexes
*/

-- Q40
SELECT
    TABLE_NAME,
    INDEX_NAME,
    NON_UNIQUE,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'maqbool'
AND INDEX_NAME != 'PRIMARY'
ORDER BY TABLE_NAME;

-- Q41
SHOW INDEX FROM maqbool_info;

-- Q42
SHOW INDEX FROM orders;

-- Q43
DROP INDEX idx_user_name on maqbool_info;

-- Q44
SHOW INDEX FROM maqbool_info;

-- Q45
CREATE INDEX idx_user_name on maqbool_info(name);

-- Q46
SHOW INDEX FROM maqbool_info;

/*markdown
## The first view
*/

-- Q47
CREATE VIEW maqbool_order AS
SELECT m.id,m.age,m.is_student,m.gender,m.name,o.status,o.id as order_id,o.user_id,o.total_amount FROM maqbool_info as m
JOIN orders as o
ON m.id=o.user_id
WHERE o.status="confirmed";

-- Q48
SELECT * From maqbool_order LIMIT 10 OFFSET 0;

-- Q49
SHOW CREATE VIEW maqbool_order;

-- Q50
SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';

-- Q51
SELECT
    TABLE_NAME AS view_name,
    VIEW_DEFINITION
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'maqbool';
