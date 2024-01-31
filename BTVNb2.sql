-- Create Database

CREATE DATABASE BTVNb2;
USE BTVNb2;
CREATE TABLE sv(
    sv_id INT IDENTITY(1,1) NOT NULL ,
    sv_name NVARCHAR(25) NOT NULL,
    sv_birth DATETIME NULL,
    PRIMARY KEY (sv_id)
);
CREATE TABLE gv (
    gv_id INT IDENTITY(1,1) NOT NULL ,
    gv_name NVARCHAR(25) NOT NULL,
    pos NVARCHAR(50) NULL,
    PRIMARY KEY (gv_id)
);
CREATE TABLE kh(
    sv_id INT NOT NULL,
    gv_id INT NOT NULL,
    kh_name NVARCHAR(25) NOT NULL,
    result INT NOT NULL,
    PRIMARY KEY (sv_id, gv_id),
    FOREIGN KEY (sv_id) REFERENCES sv(sv_id),
    FOREIGN KEY (gv_id) REFERENCES gv(gv_id)
);

-- Insert data
Insert into sv(sv_name, sv_birth) values (N'Nguyễn Văn A', '2002-11-24'),
(N'Nguyễn Văn B', '2001-11-24');
INSERT INTO gv(gv_name,pos) values (N'Ban Hà Bằng', 'Giảng viên'),
(N'Nguyễn Văn E', 'Trưởng Khoa'),
(N'Nguyễn Văn F', 'Phó Khoa');
INSERT INTO kh(sv_id, gv_id, kh_name, result) values (7,1,N'OS', 10),
(7,2,N'Lý', 9),
(7,3,N'Hóa', 8),
(8,1,N'Toán', 7),
(8,2,N'Toán', 6),
(8,3,N'Toán', 5),
(9,1,N'Toán', 4),
(9,2,N'Toán', 3),
(9,3,N'Toán', 2);
Insert into sv(sv_name) values (N'Nguyễn Văn C');