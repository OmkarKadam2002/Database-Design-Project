-- GROUP 12 DEMO

-- GLOBALEATS DATABASE QUERIES

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';   --to alter the default date format of Oracle SQL

-- I] SCHEMA CREATION

-- USERS TABLE

CREATE TABLE USERS (
    UserID                  NUMBER PRIMARY KEY,
    First_Name              VARCHAR2(50) NOT NULL,
    Middle_Name             VARCHAR2(50),
    Last_Name               VARCHAR2(50) NOT NULL,
    Gender                  VARCHAR2(10),
    DateofBirth             DATE,
    SignupDate              DATE NOT NULL,
    Is_Customer             NUMBER(1) DEFAULT 0 NOT NULL,
    Is_Restaurantowner      NUMBER(1) DEFAULT 0 NOT NULL,
    CONSTRAINT check_boolean_values 
    CHECK (Is_Customer IN (0,1) AND Is_Restaurantowner IN (0,1))
);

-- ADDRESS TABLE

CREATE TABLE ADDRESS (
    UserID                  NUMBER,
    Street                  Varchar2(100)    NOT NULL,
    Apartment               Varchar2(50)     NOT NULL,
    City                    Varchar2(100)    NOT NULL,
    State                   Varchar2(100)    NOT NULL,
    Country                 Varchar2(100)    NOT NULL,
    Zipcode                 Varchar2(50)     NOT NULL,
    PRIMARY KEY (UserID,Street,Apartment,City,State,Country,Zipcode),
    FOREIGN KEY (UserID) REFERENCES USERS(UserID) ON DELETE CASCADE
);

-- PHONE_NUMBER TABLE

CREATE TABLE PHONE_NUMBER (
    UserID                  NUMBER,
    Phone_Number            VARCHAR2(20) NOT NULL,
    PRIMARY KEY (UserID, Phone_Number),
    FOREIGN KEY (UserID) REFERENCES USERS(UserID) ON DELETE CASCADE
);

-- RESTAURANT TABLE

CREATE TABLE RESTAURANT (
    RestaurantID            NUMBER PRIMARY KEY,
    RestaurantName          VARCHAR2(50) NOT NULL,
    OwnerID                 NUMBER,
    FOREIGN KEY (OwnerID) REFERENCES USERS(UserID) ON DELETE CASCADE,
    CONSTRAINT unique_restaurant_name UNIQUE (RestaurantName)
    --so that no restaurant can have multiple entries in this table.
);

--CUISINE TABLE

CREATE TABLE CUISINE(
    CuisineID               NUMBER PRIMARY KEY,
    CuisineName             VARCHAR2(50) NOT NULL
);

--FEATURES TABLE => junction table to link restaurants with the cuisines that they feature

CREATE TABLE FEATURES (
    RestaurantID            NUMBER,
    CuisineID               NUMBER,
    PRIMARY KEY (RestaurantID,CuisineID),
    FOREIGN KEY (RestaurantID) REFERENCES RESTAURANT(RestaurantID) ON DELETE CASCADE,
    FOREIGN KEY (CuisineID) REFERENCES CUISINE(CuisineID) ON DELETE CASCADE
);

--PROMOTIONS TABLE

CREATE TABLE PROMOTIONS (
    RestaurantID            NUMBER,
    PromoID                 NUMBER NOT NULL,
    PromoDesc               VARCHAR2(200) NOT NULL,
    PromoFrom               DATE NOT NULL,
    PromoEnd                DATE NOT NULL,
    PRIMARY KEY (RestaurantID,PromoID),
    FOREIGN KEY (RestaurantID) REFERENCES RESTAURANT(RestaurantID) ON DELETE CASCADE,
    CONSTRAINT promo_dur CHECK (PromoFrom < PromoEnd)
);

--LOCATIONS TABLE

CREATE TABLE LOCATIONS (
    LocationID              NUMBER PRIMARY KEY,
    Street                  VARCHAR2(100)    NOT NULL,
    City                    VARCHAR2(100)    NOT NULL,
    State                   VARCHAR2(100)    NOT NULL,
    Country                 VARCHAR2(100)    NOT NULL,
    Zipcode                 VARCHAR2(50)     NOT NULL,
    RestaurantID            NUMBER,
    FOREIGN KEY (RestaurantID) REFERENCES RESTAURANT(RestaurantID) ON DELETE CASCADE
);

--OPERATIONAL_HOURS TABLE

CREATE TABLE OPERATIONAL_HOURS (
    RestaurantID            NUMBER,
    LocationID              NUMBER,
    Dayoftheweek            NUMBER CHECK (Dayoftheweek BETWEEN 1 AND 7) NOT NULL,
    Openingtime             DATE,
    Closingtime             DATE,
    PRIMARY KEY (RestaurantID, LocationID, Dayoftheweek, Openingtime),
    FOREIGN KEY (RestaurantID) REFERENCES RESTAURANT(RestaurantID) ON DELETE CASCADE,
    FOREIGN KEY (LocationID) REFERENCES LOCATIONS(LocationID) ON DELETE CASCADE
);

-- ORDER TABLE

CREATE TABLE ORDERS (
    OrderID                 NUMBER PRIMARY KEY,
    DateofOrder             DATE NOT NULL,
    TotalAmount             NUMBER NOT NULL,
    DeliveryStatus          VARCHAR2(20) NOT NULL CHECK (DeliveryStatus IN ('Pending', 'Delivered', 'In Progress','Canceled')),
    UserID                  NUMBER,
    RestaurantID            NUMBER,
    FOREIGN KEY (UserID) REFERENCES USERS(UserID) ON DELETE CASCADE,
    FOREIGN KEY (RestaurantID) REFERENCES RESTAURANT(RestaurantID) ON DELETE CASCADE
);

-- MENU ITEMS TABLE

CREATE TABLE MENU_ITEM (
    MenuItemID              NUMBER PRIMARY KEY, 
    Name                    VARCHAR(50) NOT NULL,
    Description             VARCHAR(200) NOT NULL,
    Price                   NUMBER NOT NULL,
    RestaurantID            NUMBER,
    FOREIGN KEY (RestaurantID) REFERENCES RESTAURANT(RestaurantID) ON DELETE CASCADE
);

-- ORDER_QUANTITY TABLE

CREATE TABLE ORDER_QUANTITY(
    MenuItemID              NUMBER,
    OrderID                 NUMBER,
    Quantity                NUMBER NOT NULL,
    PRIMARY KEY (MenuItemID,OrderID),
    FOREIGN KEY (MenuItemID) REFERENCES MENU_ITEM(MenuItemID) ON DELETE CASCADE,
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID) ON DELETE CASCADE
);

-- REVIEW TABLE

CREATE TABLE REVIEW (
    ReviewID                NUMBER PRIMARY KEY,
    ReviewText              VARCHAR(500) NOT NULL,
    Rating                  NUMBER  NOT NULL,
    DateofReview            DATE,
    UserID                  NUMBER,
    MenuItemID              NUMBER,
    FOREIGN KEY (MenuItemID) REFERENCES MENU_ITEM(MenuItemID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES USERS(UserID) ON DELETE CASCADE
);

-- PAYMENTS TABLE

CREATE TABLE PAYMENTS (
    PaymentID               NUMBER PRIMARY KEY,
    PMethod                 VARCHAR(50) NOT NULL,
    Status                  VARCHAR2(20) NOT NULL,
    OrderID                 NUMBER,
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID) ON DELETE CASCADE,
    CONSTRAINT payment_status CHECK (Status IN ('PENDING', 'COMPLETED', 'FAILED', 'CANCELED'))
);

-- CATEGORY TYPE

CREATE TABLE CATEGORIES(
    CategoryID               NUMBER PRIMARY KEY,
    CategoryName             VARCHAR2(50) NOT NULL
);

-- MENU_ITEM_CATEGORIES TABLE

CREATE TABLE MENU_ITEM_CATEGORIES (
    MenuItemID               NUMBER,
    CategoryID               NUMBER,
    PRIMARY KEY (MenuItemID,CategoryID),
    FOREIGN KEY (MenuItemID) REFERENCES MENU_ITEM(MenuItemID) ON DELETE CASCADE,
    FOREIGN KEY (CategoryID) REFERENCES CATEGORIES(CategoryID) ON DELETE CASCADE
);

-- Favorites

CREATE TABLE FAVORITE (
    MenuItemID      NUMBER,
    UserID          NUMBER,
    PRIMARY KEY (MenuItemID, UserID),
    FOREIGN KEY (MenuItemID) REFERENCES MENU_ITEM(MenuItemID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES USERS(UserID) ON DELETE CASCADE
)

-- EMPLOYEE TABLE

CREATE TABLE EMPLOYEES (
    EmployeeID      VARCHAR(4) PRIMARY KEY,
    Emp_FName       VARCHAR2(50) NOT NULL,
    Emp_MName       VARCHAR2(50) NOT NULL,
    Emp_LName       VARCHAR2(50) NOT NULL,
    Date_of_Birth   DATE NOT NULL,
    Start_Date      DATE NOT NULL,
    Department      VARCHAR2(50) NOT NULL,
    EmpRole         VARCHAR2(50) NOT NULL,
    CONSTRAINT EmployeeID_Format CHECK (REGEXP_LIKE(EmployeeID, '^E[0-9]{3}$')),
    CONSTRAINT Role_Constraint CHECK (EmpRole IN ('PLATFORM MANAGER', 'DELIVERY COORDINATOR', 'SUPPORT AGENT', 'DELIVERY DRIVER')),
    CONSTRAINT Dept_Constraint CHECK (Department IN ('MANAGEMENT', 'DELIVERY COORDINATION', 'SUPPORT', 'DELIVERY'))
);

-- DELIVERY TABLE

CREATE TABLE DELIVERY (
    DeliveryID      NUMBER PRIMARY KEY,
    PickupTime      TIMESTAMP DEFAULT NULL,
    DropoffTime     TIMESTAMP DEFAULT NULL,
    Is_Completed    NUMBER(1) DEFAULT 0 NOT NULL,
    OrderID         NUMBER,
    DelcoorID       VARCHAR(4),
    DeldrivID       VARCHAR(4),
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (DelcoorID) REFERENCES EMPLOYEES(EmployeeID) ON DELETE CASCADE,
    FOREIGN KEY (DeldrivID) REFERENCES EMPLOYEES(EmployeeID) ON DELETE CASCADE
);

-- Training Table

CREATE TABLE TRAINING (
    TrainingID      NUMBER PRIMARY KEY,
    TrainingDesc    VARCHAR(200) DEFAULT 'NONE' NOT NULL,
    TrainingFromDate    DATE NOT NULL,
    TrainingToDate      DATE NOT NULL,
    EmployeeID      VARCHAR(4),
    FOREIGN KEY (EmployeeID) REFERENCES EMPLOYEES(EmployeeID) ON DELETE CASCADE
);

-- CERTIFICATE TABLE

CREATE TABLE CERTIFICATE(
    CertificateID   VARCHAR(30) PRIMARY KEY,
    Issuing_Date    DATE NOT NULL,
    CertificateName VARCHAR(100),
    EmployeeID      VARCHAR(4),
    FOREIGN KEY (EmployeeID) REFERENCES EMPLOYEES(EmployeeID) ON DELETE CASCADE
);

-- INQUIRY TABLE

CREATE TABLE INQUIRY(
    InquiryID       NUMBER PRIMARY KEY, 
    InquiryDesc     VARCHAR(255) NOT NULL,
    InquiryDate     DATE NOT NULL,
    InquiryStatus   VARCHAR(20),
    UserID          NUMBER,
    EmployeeID      VARCHAR(4),
    FOREIGN KEY (EmployeeID) REFERENCES EMPLOYEES(EmployeeID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES USERS(UserID) ON DELETE CASCADE,
    CONSTRAINT inquiry_status CHECK (InquiryStatus IN ('PENDING', 'RESOLVED'))
);

-- DELIVERY_DRIVER TABLE

CREATE TABLE DELIVERY_DRIVER(
    EmployeeID      VARCHAR(4),
    DriverVehicle   VARCHAR(30),
    DriverContact   VARCHAR(20),
    PRIMARY KEY(EmployeeID),
    FOREIGN KEY (EmployeeID) REFERENCES EMPLOYEES(EmployeeID) ON DELETE CASCADE
);

-- PLATFORM_MANAGER TABLE 

CREATE TABLE PLATFORM_MANAGER( 
    PlatManID       VARCHAR(4), 
    PRIMARY KEY(PlatManID), 
    FOREIGN KEY (PlatManID) REFERENCES EMPLOYEES(EmployeeID) ON DELETE CASCADE 
); 

-- DELIVERY_COORDINATOR TABLE 

CREATE TABLE DELIVERY_COORDINATOR ( 
    DelCoorID       VARCHAR(4), 
    PRIMARY KEY(DelCoorID), 
    FOREIGN KEY (DelCoorID) REFERENCES EMPLOYEES(EmployeeID) ON DELETE CASCADE 
); 

-- TRAINER TABLE 

CREATE TABLE TRAINER ( 
    TrainerID       VARCHAR(4), 
    PRIMARY KEY(TrainerID), 
    FOREIGN KEY (TrainerID) REFERENCES EMPLOYEES(EmployeeID) ON DELETE CASCADE 
);

-- SUPPORT_AGENT 
CREATE TABLE SUPPORT_AGENT ( 
    SupportAgentID  VARCHAR(4),    
    TrainerID       VARCHAR(4), 
    PRIMARY KEY(SupportAgentID), 
    FOREIGN KEY (SupportAgentID) REFERENCES EMPLOYEES(EmployeeID) ON DELETE CASCADE,
    FOREIGN KEY (TrainerID) REFERENCES EMPLOYEES(EmployeeID) ON DELETE CASCADE 
);


-- III] Inserting Data

-- Populating the Users Table

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES(1, 'Alice', 'M.', 'Johnson', 'F', TO_DATE('1990-05-12', 'YYYY-MM-DD'), TO_DATE(SYSDATE - 60, 'YYYY-MM-DD'), 0, 1);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES(2, 'Bob', 'A.', 'Smith', 'M', TO_DATE('1985-08-20', 'YYYY-MM-DD'), TO_DATE(SYSDATE - 90, 'YYYY-MM-DD'), 0, 1);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES (3, 'Charlie', 'B.', 'Brown', 'M', TO_DATE('1995-11-02', 'YYYY-MM-DD'), TO_DATE(SYSDATE - 15, 'YYYY-MM-DD'), 0, 1);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES (4, 'Diana', NULL, 'Prince', 'F', TO_DATE('1992-01-10', 'YYYY-MM-DD'), TO_DATE(SYSDATE - 20, 'YYYY-MM-DD'), 1, 0);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES (5, 'Elena', 'C.', 'Gilbert', 'F', TO_DATE('1990-12-15', 'YYYY-MM-DD'), TO_DATE('2023-06-01', 'YYYY-MM-DD'), 1, 1);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES (6, 'Frank', NULL, 'Castle', 'M', TO_DATE('1988-07-25', 'YYYY-MM-DD'), TO_DATE('2024-01-10', 'YYYY-MM-DD'), 1, 0);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES (7, 'Grace', 'D.', 'Hopper', 'F', TO_DATE('1989-09-02', 'YYYY-MM-DD'), TO_DATE(SYSDATE - 45, 'YYYY-MM-DD'), 0, 1);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES (8, 'Henry', 'E.', 'Ford', 'M', TO_DATE('1994-04-19', 'YYYY-MM-DD'), TO_DATE(SYSDATE - 150, 'YYYY-MM-DD'), 0, 1);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES (9, 'Ivy', 'F.', 'Adams', 'F', TO_DATE('1996-03-21', 'YYYY-MM-DD'), TO_DATE('2024-02-05', 'YYYY-MM-DD'), 1, 0);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES (10, 'Jack', 'G.', 'Ryan', 'M', TO_DATE('1993-10-08', 'YYYY-MM-DD'), TO_DATE(SYSDATE - 30, 'YYYY-MM-DD'), 0, 1);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES (11, 'Karen', 'H.', 'Walker', 'F', TO_DATE('1990-08-16', 'YYYY-MM-DD'), TO_DATE('2023-12-10', 'YYYY-MM-DD'), 1, 0);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES (12, 'Leo', 'I.', 'Tolstoy', 'M', TO_DATE('1992-05-25', 'YYYY-MM-DD'), TO_DATE(SYSDATE - 10, 'YYYY-MM-DD'), 0, 1);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES (13, 'Mona', NULL, 'Lisa', 'F', TO_DATE('1995-12-30', 'YYYY-MM-DD'), TO_DATE('2024-03-01', 'YYYY-MM-DD'), 1, 0);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES (14, 'Nathan', 'J.', 'Drake', 'M', TO_DATE('1987-07-22', 'YYYY-MM-DD'), TO_DATE(SYSDATE - 5, 'YYYY-MM-DD'), 0, 1);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES (15, 'Olivia', 'K.', 'Pope', 'F', TO_DATE('1983-11-12', 'YYYY-MM-DD'), TO_DATE(SYSDATE - 75, 'YYYY-MM-DD'), 0, 1);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES(16, 'Paul', 'L.', 'Atreides', 'M', TO_DATE('1999-06-15', 'YYYY-MM-DD'), TO_DATE('2021-04-05', 'YYYY-MM-DD'), 1, 0);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES(17, 'Quinn', 'M.', 'Harper', 'F', TO_DATE('1985-12-20', 'YYYY-MM-DD'), TO_DATE('2022-02-12', 'YYYY-MM-DD'), 0, 1);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES(18, 'Rita', 'N.', 'Skeeter', 'F', TO_DATE('1991-11-01', 'YYYY-MM-DD'), TO_DATE('2023-07-21', 'YYYY-MM-DD'), 1, 1);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES(19, 'Steve', 'O.', 'Rogers', 'M', TO_DATE('1988-04-30', 'YYYY-MM-DD'), TO_DATE('2020-11-15', 'YYYY-MM-DD'), 0, 1);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES(20, 'Tina', NULL, 'Fey', 'F', TO_DATE('2000-03-18', 'YYYY-MM-DD'), TO_DATE('2024-02-01', 'YYYY-MM-DD'), 1, 0);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES(21, 'Uma', 'P.', 'Thurman', 'F', TO_DATE('1997-09-25', 'YYYY-MM-DD'), TO_DATE('2022-10-10', 'YYYY-MM-DD'), 1, 0);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES(22, 'Victor', 'Q.', 'Frankenstein', 'M', TO_DATE('1992-07-14', 'YYYY-MM-DD'), TO_DATE('2023-06-05', 'YYYY-MM-DD'), 0, 1);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES(23, 'Willow', 'R.', 'Smith', 'F', TO_DATE('2001-01-11', 'YYYY-MM-DD'), TO_DATE('2023-03-25', 'YYYY-MM-DD'), 1, 0);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES(24, 'Xander', 'S.', 'Harris', 'M', TO_DATE('1994-02-22', 'YYYY-MM-DD'), TO_DATE('2021-09-18', 'YYYY-MM-DD'), 0, 1);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES(25, 'Yara', 'T.', 'Greyjoy', 'F', TO_DATE('1998-08-08', 'YYYY-MM-DD'), TO_DATE('2020-12-30', 'YYYY-MM-DD'), 1, 0);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES(26, 'Lucas', 'T.', 'Williams', 'M', TO_DATE('1985-05-15', 'YYYY-MM-DD'), TO_DATE('2024-09-01', 'YYYY-MM-DD'), 0, 1);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES(27, 'Lily', 'M.', 'Smith', 'F', TO_DATE('1992-07-03', 'YYYY-MM-DD'), TO_DATE('2024-09-10', 'YYYY-MM-DD'), 0, 1);

INSERT INTO Users (UserID, First_Name, Middle_Name, Last_Name, Gender, DateOfBirth, SignupDate, Is_Customer, Is_Restaurantowner)
VALUES(28, 'Olivia', 'J.', 'Johnson', 'F', TO_DATE('1990-11-22', 'YYYY-MM-DD'), TO_DATE('2024-09-10', 'YYYY-MM-DD'), 0, 1);

-- Populating Address table

INSERT INTO ADDRESS (UserID, Street, Apartment, City, State, Country, Zipcode)
VALUES(1, '123 Elm Street', 'Apt 101', 'Austin', 'TX', 'USA', '73301');

INSERT INTO ADDRESS (UserID, Street, Apartment, City, State, Country, Zipcode)
VALUES(1, '456 Oak Lane', 'Apt 102', 'Dallas', 'TX', 'USA', '75201');

INSERT INTO ADDRESS (UserID, Street, Apartment, City, State, Country, Zipcode)
VALUES(2, '789 Maple Avenue', 'Apt 201', 'London', 'London', 'UK', 'SW1A 1AA');

INSERT INTO ADDRESS (UserID, Street, Apartment, City, State, Country, Zipcode)
VALUES(2, '101 King Street', 'Apt 202', 'Manchester', 'Manchester', 'UK', 'M1 1AE');

INSERT INTO ADDRESS (UserID, Street, Apartment, City, State, Country, Zipcode)
VALUES(3, '15 Champs-Élysées', 'Apt 301', 'Paris', 'Île-de-France', 'France', '75008');

INSERT INTO ADDRESS (UserID, Street, Apartment, City, State, Country, Zipcode)
VALUES(3, '27 Rue Cler', 'Apt 302', 'Lyon', 'Auvergne-Rhône-Alpes', 'France', '69001');

INSERT INTO ADDRESS (UserID, Street, Apartment, City, State, Country, Zipcode)
VALUES(4, '50 Collins Street', 'Apt 401', 'Melbourne', 'VIC', 'Australia', '3000');

INSERT INTO ADDRESS (UserID, Street, Apartment, City, State, Country, Zipcode)
VALUES(4, '12 Harbour Street', 'Apt 402', 'Sydney', 'NSW', 'Australia', '2000');

INSERT INTO ADDRESS (UserID, Street, Apartment, City, State, Country, Zipcode)
VALUES(5, '123 Biscayne Boulevard', 'Apt 501', 'Miami', 'FL', 'USA', '33132');

INSERT INTO ADDRESS (UserID, Street, Apartment, City, State, Country, Zipcode)
VALUES(5, '55 Loop Street', 'Apt 502', 'Cape Town', 'Western Cape', 'South Africa', '8001');

-- Populating Address table

INSERT INTO PHONE_NUMBER (UserID, Phone_Number) VALUES(1, '+1-512-555-1234');
INSERT INTO PHONE_NUMBER (UserID, Phone_Number) VALUES (1, '+1-512-555-5678');
INSERT INTO PHONE_NUMBER (UserID, Phone_Number) VALUES (2, '+44-20-7946-0958');
INSERT INTO PHONE_NUMBER (UserID, Phone_Number) VALUES (2, '+44-161-555-7890');
INSERT INTO PHONE_NUMBER (UserID, Phone_Number) VALUES (3, '+33-1-7020-3030');
INSERT INTO PHONE_NUMBER (UserID, Phone_Number) VALUES (3, '+33-4-7890-1122');
INSERT INTO PHONE_NUMBER (UserID, Phone_Number) VALUES (4, '+61-3-9010-1234');
INSERT INTO PHONE_NUMBER (UserID, Phone_Number) VALUES (4, '+61-2-8765-4321');
INSERT INTO PHONE_NUMBER (UserID, Phone_Number) VALUES (5, '+27-21-555-6789');
INSERT INTO PHONE_NUMBER (UserID, Phone_Number) VALUES (5, '+27-11-555-1234');

-- Populating the restaurant table

INSERT INTO RESTAURANT (RestaurantID, RestaurantName, OwnerID) VALUES (1, 'Alice Cafe', 1);
INSERT INTO RESTAURANT (RestaurantID, RestaurantName, OwnerID) VALUES (2, 'Bobs Bistro', 2);
INSERT INTO RESTAURANT (RestaurantID, RestaurantName, OwnerID) VALUES (3, 'Charlies Grill', 3);
INSERT INTO RESTAURANT (RestaurantID, RestaurantName, OwnerID) VALUES (4, 'Elena Eatery', 5);
INSERT INTO RESTAURANT (RestaurantID, RestaurantName, OwnerID) VALUES (5, 'Graces Gourmet', 7);
INSERT INTO RESTAURANT (RestaurantID, RestaurantName, OwnerID) VALUES (6, 'Henrys Diner', 8);
INSERT INTO RESTAURANT (RestaurantID, RestaurantName, OwnerID) VALUES (7, 'Jacks Joint', 10);
INSERT INTO RESTAURANT (RestaurantID, RestaurantName, OwnerID) VALUES(8, 'Lucas Grill', 26);
INSERT INTO RESTAURANT (RestaurantID, RestaurantName, OwnerID) VALUES(9, 'Lily''s Cafe', 27);
INSERT INTO RESTAURANT (RestaurantID, RestaurantName, OwnerID) VALUES(10, 'Lily''s Diner', 27);
INSERT INTO RESTAURANT (RestaurantID, RestaurantName, OwnerID) VALUES(11, 'Olivia''s Bakeshop', 28);
INSERT INTO RESTAURANT (RestaurantID, RestaurantName, OwnerID) VALUES(12, 'Olivia''s Bistro', 28);
INSERT INTO RESTAURANT (RestaurantID, RestaurantName, OwnerID) VALUES(13, 'Olivia''s Deli', 28); 

-- Populating Cuisine

INSERT INTO CUISINE (CuisineID, CuisineName)VALUES (1, 'ITALIAN');
INSERT INTO CUISINE (CuisineID, CuisineName)VALUES (2, 'FRENCH');
INSERT INTO CUISINE (CuisineID, CuisineName)VALUES (3, 'AMERICAN');
INSERT INTO CUISINE (CuisineID, CuisineName)VALUES (4, 'MEDITERRANEAN');
INSERT INTO CUISINE (CuisineID, CuisineName)VALUES (5, 'JAPANESE');
INSERT INTO CUISINE (CuisineID, CuisineName)VALUES (6, 'THAI');
INSERT INTO CUISINE (CuisineID, CuisineName)VALUES (7, 'KOREAN');
INSERT INTO CUISINE (CuisineID, CuisineName)VALUES (8, 'MEXICAN');

-- Populating Features

INSERT INTO FEATURES (RestaurantID, CuisineID) VALUES (1,1);
INSERT INTO FEATURES (RestaurantID, CuisineID) VALUES (1,2);
INSERT INTO FEATURES (RestaurantID, CuisineID) VALUES (2,3);
INSERT INTO FEATURES (RestaurantID, CuisineID) VALUES (2,4);
INSERT INTO FEATURES (RestaurantID, CuisineID) VALUES (3,3);
INSERT INTO FEATURES (RestaurantID, CuisineID) VALUES (4,1);
INSERT INTO FEATURES (RestaurantID, CuisineID) VALUES (5,5);
INSERT INTO FEATURES (RestaurantID, CuisineID) VALUES (5,6);
INSERT INTO FEATURES (RestaurantID, CuisineID) VALUES (5,7);
INSERT INTO FEATURES (RestaurantID, CuisineID) VALUES (6,8);
INSERT INTO FEATURES (RestaurantID, CuisineID) VALUES (7,3);

-- LOCATIONS TABLE

INSERT INTO LOCATIONS (LocationID, Street, City, State, Country, Zipcode, RestaurantID)
VALUES(1, '123 Queen Street', 'Melbourne', 'VIC', 'Australia', '3000', 1);
INSERT INTO LOCATIONS (LocationID, Street, City, State, Country, Zipcode, RestaurantID)
VALUES(2, '456 King Street', 'Sydney', 'NSW', 'Australia', '2000', 1);
INSERT INTO LOCATIONS (LocationID, Street, City, State, Country, Zipcode, RestaurantID)
VALUES(3, '789 Bridge Road', 'Perth', 'WA', 'Australia', '6000', 2);
INSERT INTO LOCATIONS (LocationID, Street, City, State, Country, Zipcode, RestaurantID)
VALUES(4, '12 Collins Avenue', 'Brisbane', 'QLD', 'Australia', '4000', 6);
INSERT INTO LOCATIONS (LocationID, Street, City, State, Country, Zipcode, RestaurantID)
VALUES(5, '50 Oxford Street', 'New York', 'NY', 'USA', '10001', 3);
INSERT INTO LOCATIONS (LocationID, Street, City, State, Country, Zipcode, RestaurantID)
VALUES(6, '200 Elm Avenue', 'Los Angeles', 'CA', 'USA', '90001', 3);
INSERT INTO LOCATIONS (LocationID, Street, City, State, Country, Zipcode, RestaurantID)
VALUES(7, '15 Champs-Élysées', 'Paris', 'Île-de-France', 'France', '75008', 4);
INSERT INTO LOCATIONS (LocationID, Street, City, State, Country, Zipcode, RestaurantID)
VALUES(8, '101 Piccadilly', 'London', 'London', 'UK', 'W1J 7JT', 4);
INSERT INTO LOCATIONS (LocationID, Street, City, State, Country, Zipcode, RestaurantID)
VALUES(9, '32 High Street', 'Mexico City', 'CDMX', 'Mexico', '01010', 5);
INSERT INTO LOCATIONS (LocationID, Street, City, State, Country, Zipcode, RestaurantID)
VALUES(10, '123 Revolution Avenue', 'Guadalajara', 'Jalisco', 'Mexico', '44100', 5);



-- Populating the Order table

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(11, SYSDATE - 2, 15.00, 'Delivered', 4, 1);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(12, SYSDATE - 4, 20.00, 'In Progress', 4, 2);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(13, SYSDATE - 5, 18.00, 'Pending', 4, 1);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(14, SYSDATE - 3, 25.00, 'Delivered', 6, 3);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(15, SYSDATE - 6, 35.00, 'In Progress', 6, 4);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(16, SYSDATE - 8, 30.00, 'Pending', 6, 5);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(17, SYSDATE - 10, 22.00, 'Delivered', 6, 3);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(18, SYSDATE - 12, 28.00, 'Pending', 6, 4);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(19, SYSDATE - 6, 40.00, 'Delivered', 9, 6);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(20, SYSDATE - 7, 35.00, 'In Progress', 9, 7);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(21, SYSDATE - 9, 30.00, 'Pending', 9, 6);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(22, SYSDATE - 3, 50.00, 'Delivered', 11, 6);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(23, SYSDATE - 5, 60.00, 'In Progress', 11, 7);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(24, SYSDATE - 14, 55.00, 'Pending', 13, 5);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(25, SYSDATE - 16, 70.00, 'Delivered', 13, 7);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(26, '2023-12-15', 45.00, 'Delivered', 3, 2);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(27, '2023-08-19', 25.00, 'Pending', 5, 3);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(28, '2023-10-10', 30.00, 'In Progress', 7, 1);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(29, '2022-11-11', 50.00, 'Delivered', 2, 4);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(30, '2022-06-20', 35.00, 'Pending', 6, 5);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(31, '2022-04-25', 60.00, 'Delivered', 8, 3);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(32, '2021-09-12', 70.00, 'In Progress', 4, 6);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(33, '2021-03-30', 55.00, 'Delivered', 5, 2);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(34, '2021-01-15', 20.00, 'Pending', 7, 4);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(35, '2020-07-08', 40.00, 'Delivered', 9, 7);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(36, '2020-05-20', 65.00, 'In Progress', 11, 6);

INSERT INTO Orders (OrderID, DateofOrder, TotalAmount, DeliveryStatus, UserID, RestaurantID)
VALUES(37, '2020-02-28', 75.00, 'Delivered', 12, 7);

-- Populating Menu_Items

INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(1, 'Espresso', 'A strong coffee brewed by forcing hot water under pressure.', 3.50, 1);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(2, 'Cappuccino', 'A coffee drink made with espresso and steamed milk foam.', 4.00, 1);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(3, 'Caesar Salad', 'A classic salad with romaine, croutons, and Caesar dressing.', 8.50, 2);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(4, 'Grilled Chicken', 'Tender chicken grilled to perfection.', 12.00, 2);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(5, 'Cheeseburger', 'A juicy burger topped with melted cheese.', 10.00, 3);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(6, 'BBQ Ribs', 'Slow-cooked ribs glazed with BBQ sauce.', 15.00, 3);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(7, 'Margherita Pizza', 'A simple pizza with tomato, mozzarella, and basil.', 9.00, 4);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(8, 'Pasta Primavera', 'Pasta with fresh vegetables in a light sauce.', 11.50, 4);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(9, 'Sushi Roll', 'Delicate rolls filled with fresh fish and rice.', 14.00, 5);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(10, 'Tempura', 'Lightly battered and fried seafood or vegetables.', 13.00, 5);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(11, 'Vegan Burger', 'A plant-based burger with all the fixings.', 11.00, 6);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(12, 'Fries', 'Crispy golden fries, perfect as a side or snack.', 5.00, 6);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(13, 'BBQ Wings', 'Chicken wings tossed in smoky BBQ sauce.', 7.50, 7);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(14, 'Pulled Pork Sandwich', 'Slow-cooked pork served in a soft bun.', 10.50, 7);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(15, 'Pad Thai', 'A Thai stir-fried noodle dish with shrimp, peanuts, and lime.', 12.00, 5);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(16, 'Tom Yum Soup', 'A tangy and spicy Thai soup with shrimp and mushrooms.', 8.50, 5);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(17, 'Kimchi Fried Rice', 'A Korean-style fried rice with kimchi and vegetables.', 10.00, 5);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(18, 'Bulgogi', 'Korean BBQ beef marinated in a sweet and savory sauce.', 14.00, 7);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(19, 'Croque Monsieur', 'A French ham and cheese sandwich, topped with béchamel sauce.', 13.00, 2);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(20, 'Ratatouille', 'A French vegetable stew made with zucchini, eggplant, and tomatoes.', 15.00, 4);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(21, 'Lasagna', 'Layers of pasta, meat, and cheese baked to perfection.', 12.00, 4);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(22, 'Tiramisu', 'A classic Italian dessert made with coffee-soaked ladyfingers and mascarpone.', 8.00, 1);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(23, 'Burrito Bowl', 'A rice bowl with seasoned meat, beans, and fresh toppings.', 10.00, 6);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(24, 'Taco Tuesday Special', 'A special taco offering with a variety of fillings and toppings.', 8.00, 6);
INSERT INTO Menu_Item (MenuItemID, Name, Description, Price, RestaurantID)
VALUES(25, 'Butter Chicken', 'A creamy, spiced chicken dish served with naan or rice.', 15.00, 3);


-- populating order_quantity
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(1, 11, 4);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(3, 12, 2);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(2, 13, 5);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(5, 14, 1);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(6, 14, 1);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(7, 15, 4);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(10, 16, 2);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(5, 17, 2);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(7, 18, 3);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(11, 19, 3);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(12, 19, 1);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(13, 20, 2);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(14, 20, 2);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(12, 21, 6);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(23, 22, 5);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(11, 23, 5);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(12, 23, 1);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(10, 24, 4);
INSERT INTO Order_Quantity (MenuItemID, OrderID, Quantity)VALUES(18, 25, 5);
/*INSERT INTO Order_Quantity (Menu_Item_ID, OrderID, Quantity)VALUES(3, 26, 1);
INSERT INTO Order_Quantity (Menu_Item_ID, OrderID, Quantity)VALUES(5, 27, 2);
INSERT INTO Order_Quantity (Menu_Item_ID, OrderID, Quantity)VALUES(6, 28, 1);
INSERT INTO Order_Quantity (Menu_Item_ID, OrderID, Quantity)VALUES(7, 29, 2);
INSERT INTO Order_Quantity (Menu_Item_ID, OrderID, Quantity)VALUES(8, 30, 1);
INSERT INTO Order_Quantity (Menu_Item_ID, OrderID, Quantity)VALUES(9, 32, 3);
INSERT INTO Order_Quantity (Menu_Item_ID, OrderID, Quantity)VALUES(10, 32, 1);
INSERT INTO Order_Quantity (Menu_Item_ID, OrderID, Quantity)VALUES(11, 33, 1);
INSERT INTO Order_Quantity (Menu_Item_ID, OrderID, Quantity)VALUES(12, 34, 2);
INSERT INTO Order_Quantity (Menu_Item_ID, OrderID, Quantity)VALUES(13, 35, 3);
INSERT INTO Order_Quantity (Menu_Item_ID, OrderID, Quantity)VALUES(14, 36, 2);
INSERT INTO Order_Quantity (Menu_Item_ID, OrderID, Quantity)VALUES(14, 37, 2);
*/

-- populating reviews table

INSERT INTO Review (ReviewID, UserID, MenuItemID, Rating, ReviewText, DateofReview)
VALUES(1, 4, 1, 5, 'Loved the espresso!', SYSDATE - 12);
INSERT INTO Review (ReviewID, UserID, MenuItemID, Rating, ReviewText, DateofReview)
VALUES(2, 4, 2, 4, 'Cappuccino was great!', SYSDATE - 30);
INSERT INTO Review (ReviewID, UserID, MenuItemID, Rating, ReviewText, DateofReview)
VALUES(3, 6, 3, 4, 'Caesar Salad was fresh!', SYSDATE - 60);
INSERT INTO Review (ReviewID, UserID, MenuItemID, Rating, ReviewText, DateofReview)
VALUES(4, 6, 4, 5, 'Grilled Chicken was amazing!', SYSDATE - 4);
INSERT INTO Review (ReviewID, UserID, MenuItemID, Rating, ReviewText, DateofReview)
VALUES(5, 9, 5, 5, 'Cheeseburger was perfect!', SYSDATE - 73);
INSERT INTO Review (ReviewID, UserID, MenuItemID, Rating, ReviewText, DateofReview)
VALUES(6, 9, 6, 4, 'BBQ Ribs were tasty!', SYSDATE - 120);
INSERT INTO Review (ReviewID, UserID, MenuItemID, Rating, ReviewText, DateofReview)
VALUES(7, 13, 7, 4, 'Pizza was delicious!', SYSDATE - 18);
INSERT INTO Review (ReviewID, UserID, MenuItemID, Rating, ReviewText, DateofReview)
VALUES(8, 13, 11, 5, 'Pasta Primavera was delightful!', SYSDATE - 189);
INSERT INTO Review (ReviewID, UserID, MenuItemID, Rating, ReviewText, DateofReview)
VALUES(9, 11, 9, 4, 'Sushi Roll was okay.', SYSDATE - 53);
INSERT INTO Review (ReviewID, UserID, MenuItemID, Rating, ReviewText, DateofReview)
VALUES(10, 11, 13, 3, 'Wings were average.', SYSDATE - 1);
INSERT INTO Review (ReviewID, UserID, MenuItemID, Rating, ReviewText, DateofReview)
VALUES(11, 4, 22, 5, 'Tiramisu was awesome.', SYSDATE - 7);

-- populating promotions

INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd) 
VALUES (1, 101, 'New Year Offer', DATE '2023-01-01', DATE '2023-01-10');
INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd) 
VALUES (1, 102, 'Spring Festival', DATE '2023-04-01', DATE '2023-04-10');
INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd) 
VALUES (1, 103, 'Summer Bonanza', DATE '2023-07-05', DATE '2023-07-15');
INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd) 
VALUES (1, 104, 'Winter Special', DATE '2023-10-15', DATE '2023-10-25');
INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd) 
VALUES (2, 105, 'Spring Feast', DATE '2023-03-25', DATE '2023-04-05');
INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd) 
VALUES (2, 106, 'Winter Sale', DATE '2023-12-01', DATE '2023-12-15');
INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd) 
VALUES (3, 107, 'Holiday Discount', DATE '2023-12-20', DATE '2023-12-31');
INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd) 
VALUES (3, 108, 'Summer Delight', DATE '2023-06-10', DATE '2023-06-20');
INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd) 
VALUES (3, 109, 'Winter Blast', DATE '2023-11-15', DATE '2023-11-25');
INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd) 
VALUES (3, 110, 'Fall Treat', DATE '2023-09-05', DATE '2023-09-15');
INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd) 
VALUES (4, 111, 'Valentine Special', DATE '2023-02-10', DATE '2023-02-20');
INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd) 
VALUES (4, 112, 'Back to School', DATE '2023-08-01', DATE '2023-08-10');
INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd) 
VALUES (4, 113, 'Thanksgiving Offer', DATE '2023-11-20', DATE '2023-11-30');
INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd) 
VALUES (4, 114, 'Holiday Cheer', DATE '2023-12-05', DATE '2023-12-15');
INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd)
VALUES (5, 115, 'New Year Discount', DATE '2023-01-05', DATE '2023-01-15');
INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd) 
VALUES (5, 116, 'Spring Celebration', DATE '2023-04-05', DATE '2023-04-15');
INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd) 
VALUES (5, 117, 'Summer Sizzle', DATE '2023-07-10', DATE '2023-07-20');
INSERT INTO Promotions (RestaurantID, PromoID, PromoDesc, PromoFrom, PromoEnd) 
VALUES (5, 118, 'Holiday Feast', DATE '2023-12-10', DATE '2023-12-20');

-- populating operation_hours

INSERT INTO OPERATIONAL_HOURS (RestaurantID, LocationID, DayoftheWeek, Openingtime, Closingtime)
VALUES (1, 1, 1, TO_DATE('08:00:00', 'HH24:MI:SS'), TO_DATE('20:00:00', 'HH24:MI:SS'));
INSERT INTO OPERATIONAL_HOURS (RestaurantID, LocationID, DayoftheWeek, Openingtime, Closingtime)
VALUES (1, 1, 2, TO_DATE('08:00:00', 'HH24:MI:SS'), TO_DATE('20:00:00', 'HH24:MI:SS'));
INSERT INTO OPERATIONAL_HOURS (RestaurantID, LocationID, DayoftheWeek, Openingtime, Closingtime)
VALUES (1, 1, 3, TO_DATE('08:00:00', 'HH24:MI:SS'), TO_DATE('20:00:00', 'HH24:MI:SS'));
INSERT INTO OPERATIONAL_HOURS (RestaurantID, LocationID, DayoftheWeek, Openingtime, Closingtime)
VALUES (1, 2, 4, TO_DATE('09:00:00', 'HH24:MI:SS'), TO_DATE('21:00:00', 'HH24:MI:SS'));
INSERT INTO OPERATIONAL_HOURS (RestaurantID, LocationID, DayoftheWeek, Openingtime, Closingtime)
VALUES (1, 2, 5, TO_DATE('09:00:00', 'HH24:MI:SS'), TO_DATE('21:00:00', 'HH24:MI:SS'));
INSERT INTO OPERATIONAL_HOURS (RestaurantID, LocationID, DayoftheWeek, Openingtime, Closingtime)
VALUES (1, 2, 6, TO_DATE('09:00:00', 'HH24:MI:SS'), TO_DATE('21:00:00', 'HH24:MI:SS'));
INSERT INTO OPERATIONAL_HOURS (RestaurantID, LocationID, DayoftheWeek, Openingtime, Closingtime)
VALUES (2, 3, 1, TO_DATE('07:30:00', 'HH24:MI:SS'), TO_DATE('19:30:00', 'HH24:MI:SS'));
INSERT INTO OPERATIONAL_HOURS (RestaurantID, LocationID, DayoftheWeek, Openingtime, Closingtime)
VALUES (2, 3, 2, TO_DATE('07:30:00', 'HH24:MI:SS'), TO_DATE('19:30:00', 'HH24:MI:SS'));
INSERT INTO OPERATIONAL_HOURS (RestaurantID, LocationID, DayoftheWeek, Openingtime, Closingtime)
VALUES (2, 3, 3, TO_DATE('07:30:00', 'HH24:MI:SS'), TO_DATE('19:30:00', 'HH24:MI:SS'));
INSERT INTO OPERATIONAL_HOURS (RestaurantID, LocationID, DayoftheWeek, Openingtime, Closingtime)
VALUES (3, 5, 4, TO_DATE('10:00:00', 'HH24:MI:SS'), TO_DATE('22:00:00', 'HH24:MI:SS'));
INSERT INTO OPERATIONAL_HOURS (RestaurantID, LocationID, DayoftheWeek, Openingtime, Closingtime)
VALUES (3, 5, 5, TO_DATE('10:00:00', 'HH24:MI:SS'), TO_DATE('22:00:00', 'HH24:MI:SS'));
INSERT INTO OPERATIONAL_HOURS (RestaurantID, LocationID, DayoftheWeek, Openingtime, Closingtime)
VALUES (3, 5, 6, TO_DATE('10:00:00', 'HH24:MI:SS'), TO_DATE('22:00:00', 'HH24:MI:SS'));
INSERT INTO OPERATIONAL_HOURS (RestaurantID, LocationID, DayoftheWeek, Openingtime, Closingtime)
VALUES (3, 6, 1, TO_DATE('11:00:00', 'HH24:MI:SS'), TO_DATE('23:00:00', 'HH24:MI:SS'));
INSERT INTO OPERATIONAL_HOURS (RestaurantID, LocationID, DayoftheWeek, Openingtime, Closingtime)
VALUES (3, 6, 2, TO_DATE('11:00:00', 'HH24:MI:SS'), TO_DATE('23:00:00', 'HH24:MI:SS'));
INSERT INTO OPERATIONAL_HOURS (RestaurantID, LocationID, DayoftheWeek, Openingtime, Closingtime)
VALUES (3, 6, 7, TO_DATE('11:00:00', 'HH24:MI:SS'), TO_DATE('23:00:00', 'HH24:MI:SS'));

SELECT RestaurantID, LocationID, DayoftheWeek,
       TO_CHAR(Openingtime, 'HH24:MI:SS') AS Openingtime,
       TO_CHAR(Closingtime, 'HH24:MI:SS') AS Closingtime
FROM OPERATIONAL_HOURS;



-- populating employee table

INSERT INTO Employees (EmployeeID, Emp_FName, Emp_MName, Emp_LName, Date_of_Birth, Start_Date, Department, EmpRole)
VALUES('E001', 'Alice', 'M.', 'Johnson', TO_DATE('1990-05-12', 'YYYY-MM-DD'), TO_DATE('2023-05-15', 'YYYY-MM-DD'), 'MANAGEMENT','PLATFORM MANAGER');
INSERT INTO Employees (EmployeeID, Emp_FName, Emp_MName, Emp_LName, Date_of_Birth, Start_Date, Department, EmpRole)
VALUES('E002', 'Nathan', 'J.', 'Drake', TO_DATE('1987-07-22', 'YYYY-MM-DD'), TO_DATE('2022-06-18', 'YYYY-MM-DD'), 'DELIVERY COORDINATION','DELIVERY COORDINATOR');
INSERT INTO Employees (EmployeeID, Emp_FName, Emp_MName, Emp_LName, Date_of_Birth, Start_Date, Department, EmpRole)
VALUES('E003', 'John', 'A.', 'Smith',TO_DATE('1990-05-15', 'YYYY-MM-DD'),TO_DATE('2022-01-01', 'YYYY-MM-DD'), 'DELIVERY','DELIVERY DRIVER');
INSERT INTO Employees (EmployeeID, Emp_FName, Emp_MName, Emp_LName, Date_of_Birth, Start_Date, Department, EmpRole)
VALUES('E004', 'Emily', 'B.', 'Johnson',  TO_DATE('1992-07-20', 'YYYY-MM-DD'), TO_DATE('2021-03-10', 'YYYY-MM-DD'), 'DELIVERY','DELIVERY DRIVER');
INSERT INTO Employees (EmployeeID, Emp_FName, Emp_MName, Emp_LName, Date_of_Birth, Start_Date, Department, EmpRole)
VALUES('E005', 'Michael', 'C.', 'Brown',TO_DATE('1995-11-12', 'YYYY-MM-DD'), TO_DATE('2023-06-15', 'YYYY-MM-DD'),'DELIVERY','DELIVERY DRIVER');
INSERT INTO Employees (EmployeeID, Emp_FName, Emp_MName, Emp_LName, Date_of_Birth, Start_Date, Department, EmpRole)
VALUES('E006', 'Sarah', 'D.', 'Davis',TO_DATE('1988-01-25', 'YYYY-MM-DD'), TO_DATE('2020-08-20', 'YYYY-MM-DD'), 'DELIVERY','DELIVERY DRIVER');
INSERT INTO Employees (EmployeeID, Emp_FName, Emp_MName, Emp_LName, Date_of_Birth, Start_Date, Department, EmpRole)
VALUES('E007', 'Plane', 'K.', 'Jane',TO_DATE('1993-04-13', 'YYYY-MM-DD'), TO_DATE('2021-09-17', 'YYYY-MM-DD'), 'DELIVERY COORDINATION','DELIVERY COORDINATOR');

-- Populating delivery table

INSERT INTO Delivery (DeliveryID, DelCoorID, DelDrivID, PickupTime, DropoffTime, OrderID, Is_Completed)
VALUES(1, 'E007', 'E003', TO_TIMESTAMP('2024-11-29 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-29 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 11, 1);
INSERT INTO Delivery (DeliveryID, DelCoorID, DelDrivID, PickupTime, DropoffTime, OrderID, Is_Completed)
VALUES(2, 'E007', 'E003', TO_TIMESTAMP('2024-11-27 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-27 02:15:00', 'YYYY-MM-DD HH24:MI:SS'), 12, 1);
INSERT INTO Delivery (DeliveryID, DelCoorID, DelDrivID, PickupTime, DropoffTime, OrderID, Is_Completed)
VALUES(3, 'E007', 'E003', TO_TIMESTAMP('2024-11-26 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-26 16:45:00', 'YYYY-MM-DD HH24:MI:SS'), 13, 1);
INSERT INTO Delivery (DeliveryID, DelCoorID, DelDrivID, PickupTime, DropoffTime, OrderID, Is_Completed)
VALUES(4, 'E007', 'E004', TO_TIMESTAMP('2024-11-28 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-28 19:55:00', 'YYYY-MM-DD HH24:MI:SS'), 14, 1);
INSERT INTO Delivery (DeliveryID, DelCoorID, DelDrivID, PickupTime, DropoffTime, OrderID, Is_Completed)
VALUES(5, 'E007', 'E004', TO_TIMESTAMP('2024-11-25 23:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-25 23:50:00', 'YYYY-MM-DD HH24:MI:SS'), 15, 1);
INSERT INTO Delivery (DeliveryID, DelCoorID, DelDrivID, PickupTime, DropoffTime, OrderID, Is_Completed)
VALUES(6, 'E007', 'E004', TO_TIMESTAMP('2024-11-23 21:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-23 21:30:00', 'YYYY-MM-DD HH24:MI:SS'), 16, 1);
INSERT INTO Delivery (DeliveryID, DelCoorID, DelDrivID, PickupTime, DropoffTime, OrderID, Is_Completed)
VALUES(7, 'E007', 'E005', TO_TIMESTAMP('2024-11-21 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-21 21:20:00', 'YYYY-MM-DD HH24:MI:SS'), 17, 1);
INSERT INTO Delivery (DeliveryID, DelCoorID, DelDrivID, PickupTime, DropoffTime, OrderID, Is_Completed)
VALUES(8, 'E007', 'E005', TO_TIMESTAMP('2024-11-19 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-19 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 18, 1);
INSERT INTO Delivery (DeliveryID, DelCoorID, DelDrivID, PickupTime, DropoffTime, OrderID, Is_Completed)
VALUES(9, 'E007', 'E005', TO_TIMESTAMP('2024-11-25 17:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-25 17:45:00', 'YYYY-MM-DD HH24:MI:SS'), 19, 1);
INSERT INTO Delivery (DeliveryID, DelCoorID, DelDrivID, PickupTime, DropoffTime, OrderID, Is_Completed)
VALUES(10, 'E007', 'E006', TO_TIMESTAMP('2024-11-24 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-24 12:30:00', 'YYYY-MM-DD HH24:MI:SS'), 20, 1);

INSERT INTO Delivery (DeliveryID, DelCoorID, DelDrivID, PickupTime, DropoffTime, OrderID, Is_Completed)
VALUES(11, 'E007', 'E003', TO_TIMESTAMP('2024-11-22 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-22 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 21, 1);
INSERT INTO Delivery (DeliveryID, DelCoorID, DelDrivID, PickupTime, DropoffTime, OrderID, Is_Completed)
VALUES(12, 'E007', 'E003', TO_TIMESTAMP('2024-11-28 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-28 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), 22, 1);
INSERT INTO Delivery (DeliveryID, DelCoorID, DelDrivID, PickupTime, DropoffTime, OrderID, Is_Completed)
VALUES(13, 'E007', 'E003', TO_TIMESTAMP('2024-11-26 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-26 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 23, 1);
INSERT INTO Delivery (DeliveryID, DelCoorID, DelDrivID, PickupTime, DropoffTime, OrderID, Is_Completed)
VALUES(14, 'E007', 'E003', TO_TIMESTAMP('2024-11-17 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-17 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), 24, 1);
INSERT INTO Delivery (DeliveryID, DelCoorID, DelDrivID, PickupTime, DropoffTime, OrderID, Is_Completed)
VALUES(15, 'E007', 'E003', TO_TIMESTAMP('2024-11-15 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-15 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), 25, 1);
INSERT INTO Delivery (DeliveryID, DelCoorID, DelDrivID, PickupTime, DropoffTime, OrderID, Is_Completed)
VALUES(16, 'E007', 'E003', TO_TIMESTAMP('2024-11-15 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-15 17:00:00', 'YYYY-MM-DD HH24:MI:SS'), 26, 1);
INSERT INTO Delivery (DeliveryID, DelCoorID, DelDrivID, PickupTime, DropoffTime, OrderID, Is_Completed)
VALUES(17, 'E007', 'E003', TO_TIMESTAMP('2024-11-19 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-19 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), 27, 1);

-- populating training table

INSERT INTO TRAINING (TrainingID, TrainingDesc, TrainingFromDate, TrainingToDate, EmployeeID) 
VALUES (9, 'Safety Training', DATE '2023-01-15', DATE '2023-01-16', 'E003');
INSERT INTO TRAINING (TrainingID, TrainingDesc, TrainingFromDate, TrainingToDate, EmployeeID) 
VALUES (10, 'Customer Service Training', DATE '2022-07-22', DATE '2022-07-28', 'E002');
INSERT INTO TRAINING (TrainingID, TrainingDesc, TrainingFromDate, TrainingToDate, EmployeeID) 
VALUES(11, 'Leadership Training', DATE '2023-08-01', DATE '2023-08-10', 'E001');
INSERT INTO TRAINING (TrainingID, TrainingDesc, TrainingFromDate, TrainingToDate, EmployeeID)  
VALUES (12, 'Delivery Training', DATE '2024-09-01', DATE '2024-09-02', 'E004');

-- Populating favorites table

INSERT INTO FAVORITE (MenuItemID, UserID) VALUES (1,4);
INSERT INTO FAVORITE (MenuItemID, UserID) VALUES (2,4);
INSERT INTO FAVORITE (MenuItemID, UserID) VALUES (3,6);
INSERT INTO FAVORITE (MenuItemID, UserID) VALUES (4,9);
INSERT INTO FAVORITE (MenuItemID, UserID) VALUES (5,9);
INSERT INTO FAVORITE (MenuItemID, UserID) VALUES (6,9);
INSERT INTO FAVORITE (MenuItemID, UserID) VALUES (7,9);
INSERT INTO FAVORITE (MenuItemID, UserID) VALUES (8,9);
INSERT INTO FAVORITE (MenuItemID, UserID) VALUES (9,9);
INSERT INTO FAVORITE (MenuItemID, UserID) VALUES (10,9);
INSERT INTO FAVORITE (MenuItemID, UserID) VALUES (11,9);
INSERT INTO FAVORITE (MenuItemID, UserID) VALUES (12,9);
INSERT INTO FAVORITE (MenuItemID, UserID) VALUES (13,9);
INSERT INTO FAVORITE (MenuItemID, UserID) VALUES (14,11);
INSERT INTO FAVORITE (MenuItemID, UserID) VALUES (15,13);

-- IV] Running Queries

-- Query 1 => List details of restaurant owners who have signed up within the past three months.

SELECT  UserID, First_Name, Last_Name, SignupDate
FROM    USERS
WHERE   Is_Restaurantowner = 1
AND     SignupDate >= ADD_MONTHS(SYSDATE, -3);

-- Query 2 => Find the names of customers who placed orders with only two restaurants in the past month.

SELECT  U.First_Name, U.Last_Name, U.UserID
FROM    USERS U JOIN ORDERS O ON U.UserID=O.UserID
WHERE   O.DateofOrder>=SYSDATE-30
GROUP BY U.First_Name, U.Last_Name, U.UserID
HAVING  COUNT(DISTINCT O.RestaurantID)=2;

-- Query 3 =>Calculate the average number of orders placed by the top five customers in the platform.

SELECT AVG(OrderCount) AS AverageOrders
FROM (
    SELECT UserID, COUNT(*) AS OrderCount
    FROM Orders
    GROUP BY UserID
    ORDER BY OrderCount DESC
) TopCustomers
WHERE ROWNUM <= 5;

-- Query 4 => List the name of each restaurant and its most popular menu item.

WITH RESTNAMES AS (
    SELECT 
        M.RestaurantID, 
        M.MenuItemID, 
        SUM(Q.Quantity) AS TotalQuantity
    FROM 
        MENU_ITEM M
    JOIN 
        ORDER_QUANTITY Q ON M.MenuItemID = Q.MenuItemID
    GROUP BY 
        M.RestaurantID, M.MenuItemID
),
RANKED_ITEMS AS (
    SELECT 
        RestaurantID, 
        MenuItemID,
        TotalQuantity,
        RANK() OVER (PARTITION BY RestaurantID ORDER BY TotalQuantity DESC) AS rank
    FROM 
        RESTNAMES
)
SELECT 
    R.RestaurantName, 
    M.Name AS MostPopularItem
FROM 
    RESTAURANT R
JOIN 
    RANKED_ITEMS RI ON R.RestaurantID = RI.RestaurantID
JOIN 
    MENU_ITEM M ON RI.MenuItemID = M.MenuItemID
WHERE 
    RI.rank = 1;
    
-- Query 5 => Identify menu items that haven’t been ordered in the last six months

WITH MI AS (
    SELECT  Q.MenuItemID
    FROM    ORDER_QUANTITY Q 
    JOIN    ORDERS O ON Q.OrderID = O.OrderID
    WHERE   O.DateOfOrder > ADD_MONTHS(SYSDATE, -6)
),
MU AS (
    SELECT M.MENUITEMID
    FROM   MENU_ITEM M
)
SELECT MENUITEMID
FROM   MU
MINUS
SELECT MENUITEMID
FROM   MI;

-- Query 6 => Find customers who have reviewed all the items from a specific restaurant

WITH REST_MENU_ITEMS AS(
    SELECT COUNT(M.MenuItemID) as COUNTITEMS
    FROM Menu_Item M
    WHERE M.RestaurantID=1
),
USER_REVW_ITEMS AS(
    SELECT U.First_Name, U.Last_Name,R.UserID, COUNT(DISTINCT R.MenuItemID) as REVIEWCOUNT
    FROM ((REVIEW R JOIN USERS U ON R.UserID=U.UserID) 
    JOIN MENU_ITEM I ON R.MenuItemID=I.MenuItemID) 
    JOIN RESTAURANT T ON I.RestaurantID=T.RestaurantID
    WHERE T.RestaurantID=1
    GROUP BY R.UserID, U.First_Name, U.Last_Name
)
SELECT URT.First_Name,URT.Last_Name
FROM USER_REVW_ITEMS URT, REST_MENU_ITEMS RMI
WHERE RMI.COUNTITEMS - URT.REVIEWCOUNT = 0;

-- Query 7 => Identify the restaurant with the most promotions’ amount in the past year

SELECT  R.RestaurantID as SrNo, R.RestaurantName as TOP_RESTAURANTS , COUNT(PROMOID) AS TOTALNOOFPROMOTIONS
FROM    RESTAURANT R JOIN PROMOTIONS P ON R.RestaurantID=P.RestaurantID
WHERE   EXTRACT(YEAR FROM PromoFrom)=2023
GROUP BY R.RestaurantID,R.RestaurantName
ORDER BY COUNT(PROMOID) DESC
FETCH FIRST 3 ROWS ONLY;

-- Query 8 => Find the year with the highest total order payment.

SELECT EXTRACT(YEAR FROM DateofOrder) AS OrderYear, SUM(TotalAmount) AS TotalOrderAmount
FROM Orders
WHERE DeliveryStatus='Delivered'
GROUP BY EXTRACT(YEAR FROM DateofOrder)
ORDER BY TotalOrderAmount DESC
FETCH FIRST 1 ROWS ONLY;

-- Query 9 =>	List the names of customers who ordered the most popular menu items

WITH RESTNAMES AS (
    SELECT 
        M.RestaurantID, 
        M.MenuItemID, 
        SUM(Q.Quantity) AS TotalQuantity
    FROM 
        MENU_ITEM M
    JOIN 
        ORDER_QUANTITY Q ON M.MenuItemID = Q.MenuItemID
    GROUP BY 
        M.RestaurantID, M.MenuItemID
),
RANKED_ITEMS AS (
    SELECT 
        RestaurantID, 
        MenuItemID,
        TotalQuantity,
        RANK() OVER (PARTITION BY RestaurantID ORDER BY TotalQuantity DESC) AS rank
    FROM 
        RESTNAMES
)
SELECT First_Name, Last_Name, RI.RestaurantID
FROM ((ORDER_QUANTITY Q JOIN RANKED_ITEMS RI ON Q.MenuItemID=RI.MenuItemID) 
                        JOIN ORDERS O ON Q.OrderID=O.OrderID)
                        JOIN USERS U ON O.UserID=U.UserID
WHERE RANK=1;

-- Query 10 => 10.	Find delivery drivers who have delivered at least 10 orders in the past month.

SELECT D.DeldrivID AS DriverID, E.Emp_FName AS FirstName, E.Emp_LName AS LastName, COUNT(D.OrderID) AS TotalDeliveries
FROM DELIVERY D JOIN ORDERS O ON d.OrderID = o.OrderID JOIN EMPLOYEES E ON D.DeldrivID = e.EmployeeID
WHERE D.Is_Completed = 1 AND O.DateofOrder >= ADD_MONTHS(SYSDATE, -1)
GROUP BY D.DeldrivID, e.Emp_FName, e.Emp_LName
HAVING COUNT(D.OrderID) >= 10
ORDER BY TotalDeliveries DESC;

-- Query 11 => List customers who have been active for more than two years.

SELECT  UserID, First_Name, Middle_Name, Last_Name, SignupDate
FROM    USERS
WHERE   Is_Customer = 1 
        AND (Signupdate >= ADD_MONTHS(SYSDATE, -24)
        OR UserID in 
        (SELECT O.UserID
        FROM    ORDERS O
        WHERE   DateofOrder>=ADD_MONTHS(SYSDATE,-24)));
        
-- Query 12 => Find the number of orders delivered by the top three delivery drivers.

SELECT E.EmployeeID AS DriverID, E.Emp_FName AS DriverFirstName, E.Emp_LName AS DriverLastName,COUNT(D.OrderID) AS DeliveredOrders
FROM (Delivery D JOIN ORDERS O ON D.OrderID=O.OrderID) JOIN Employees E ON D.DeldrivID = E.EmployeeID
WHERE D.Is_Completed = 1
GROUP BY D.DeldrivID, E.EmployeeID, E.Emp_FName, E.Emp_LName
ORDER BY DeliveredOrders DESC
FETCH FIRST 3 ROWS ONLY;

        
-- Query 13 => 13.	List the restaurant owner who manages the most restaurants.

SELECT 
    U.UserID AS OwnerID,
    U.First_Name AS OwnerFirstName,
    U.Last_Name AS OwnerLastName,
    COUNT(R.RestaurantID) AS NumberOfRestaurants
FROM USERS U
JOIN RESTAURANT R ON U.UserID = R.OwnerID
GROUP BY U.UserID, U.First_Name, U.Last_Name
ORDER BY NumberOfRestaurants DESC
FETCH FIRST 1 ROWS ONLY;

--Query 14 => Identify restaurants that have run promotions in every quarter of the past year.

SELECT R.RestaurantID, R.RestaurantName
FROM RESTAURANT R
JOIN PROMOTIONS P ON R.RestaurantID = P.RestaurantID
WHERE EXTRACT(YEAR FROM P.PromoFrom) = 2023
GROUP BY R.RestaurantID, R.RestaurantName
HAVING COUNT(DISTINCT TO_NUMBER(TO_CHAR(P.PromoFrom, 'Q'))) = 4;


-- Query 15 => List all employees who are also restaurant owners, and display their employee details along with the details of the restaurant they own.

SELECT E.Emp_Fname, E.Emp_Lname, E.Start_Date, E.Department, E.EmpRole, R.RestaurantName
FROM (EMPLOYEES E JOIN USERS U ON (E.Emp_Fname=U.First_Name
                                AND E.Emp_Lname=U.Last_Name
                                AND E.Date_of_Birth=U.DateofBirth))
                  JOIN RESTAURANT R ON U.UserID=R.OwnerID
WHERE Is_RestaurantOwner=1;

-- Query 16 => 16.	List the names and contact information of all employees who were hired before a 
-- specific date but have not received any new training since that date.

SELECT E.EmployeeID,E.Emp_FName,E.Emp_MName, E.Emp_LName, E.EmpRole, E.Department, E.Start_Date
FROM Employees E LEFT JOIN Training T ON E.EmployeeID = T.EmployeeID
WHERE E.Start_Date > DATE '2022-01-01'AND (T.TrainingToDate IS NULL OR t.TrainingToDate < DATE '2022-01-01');

-- V] VIEW CREATION

-- VIEW 1 => TopCustomers: View of customers who placed the most orders in the past month.

CREATE VIEW TOP_CUSTOMERS AS 
SELECT      U.UserID, U.First_Name, U.Last_Name, 
            COUNT(O.OrderID) AS TOTALORDERS_PASTMONTH
FROM        ORDERS O JOIN USERS U ON O.UserID = U.UserID
WHERE       O.DateofOrder >= ADD_MONTHS(SYSDATE,-1)
GROUP BY    U.UserID, U.First_Name, U.Last_Name
ORDER BY    TOTALORDERS_PASTMONTH DESC;

-- VIEW 2 => 2.	PopularRestaurants: View of the most ordered-from restaurants in the past year.

CREATE VIEW POPULAR_RESTAURANTS AS
SELECT R.RestaurantID, R.RestaurantName, COUNT(O.OrderID) AS TotalOrders
FROM ORDERS O JOIN RESTAURANT R ON O.RestaurantID = R.RestaurantID
WHERE o.DateofOrder >= ADD_MONTHS(SYSDATE,-12)
GROUP BY R.RestaurantID, R.RestaurantName
ORDER BY TotalOrders DESC;

-- VIEW 3 => 3.	HighlyRatedItems: View of menu items that have an average rating of at least 4.5.

CREATE VIEW HIGHLY_RATED_ITEMS AS
SELECT N.MenuItemID, N.Name, R.RestaurantID, R.RestaurantName
FROM MENU_ITEM N JOIN RESTAURANT R ON N.RestaurantID=R.RestaurantID
WHERE N.MenuItemID IN (
    SELECT R.MenuItemID
    FROM REVIEW R JOIN MENU_ITEM M ON R.MenuItemID=M.MenuItemID
    GROUP BY R.MenuItemID
    HAVING AVG(R.Rating)>=4.5
);

-- VIEW 4 => FrequentDrivers: View of delivery drivers who have delivered the most orders in the past month.

CREATE VIEW FrequentDrivers AS 
SELECT      E.EmployeeID AS DriverID, E.Emp_FName AS DriverFirstName, E.Emp_LName AS DriverLastName,COUNT(D.OrderID) AS DeliveredOrders
FROM        (Delivery D JOIN ORDERS O ON D.OrderID=O.OrderID) JOIN Employees E ON D.DeldrivID = E.EmployeeID
WHERE       D.Is_Completed = 1 AND TRUNC(D.PickupTime)>=ADD_MONTHS(SYSDATE,-1) AND TRUNC(D.DropoffTime)<=SYSDATE
GROUP BY    D.DeldrivID, E.EmployeeID, E.Emp_FName, E.Emp_LName
ORDER BY    DeliveredOrders DESC
FETCH FIRST 3 ROWS ONLY;

-- VIEW 5 =>PotentialOwners: View of customers who have added at least 10 menu items to their Favorites list but have not yet registered as Restaurant Owners.

CREATE VIEW POTENTIAL_OWNERS AS
SELECT U.UserID,U.First_Name, U.Last_Name,COUNT(F.MenuItemID)as NoofFavorites
FROM FAVORITE F JOIN USERS U ON F.UserID=U.UserID
WHERE Is_Restaurantowner = 0
GROUP BY U.UserID, U.First_Name, U.Last_Name
HAVING COUNT(F.MenuItemID)>=10;



