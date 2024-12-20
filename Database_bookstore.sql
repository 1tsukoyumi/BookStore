﻿create database BookStore
Go

Use BookStore
Go


--bảng quản lý thông tin người dùng
Create table Users (
	UserID	int identity(1,1) primary key,
	Username nvarchar(50) not null unique,
	PasswordHash varbinary(100) not null,
	Role nvarchar(20) not null default 'User',
	CreatedDate datetime not null default getdate(),
	LastLogin datetime null,
	UserStatus bit default 1 --trạng thái
);
Go

--bảng tác giả
create table TacGia (
	MaTacGia int identity(1,1) primary key,
	TenTacGia nvarchar(200) not null,
	CreatedDate datetime not null default getdate(),
	IsActive bit default 1
);
go

--bảng danh mục
Create table Theloai (
	MaTheLoai int identity(1,1) primary key,
	TenTheLoai nvarchar(100) not null,
	CreatedDate datetime not null default getdate(),
	IsActive bit default 1
);
Go

--bảng quản lý sách
create table Sach (
	MaSach int identity(1,1) primary key,
	TenSach nvarchar(200) not null,
	MaTacGia int not null,
	MaTheLoai int not null,
	GiaBan int not null check(GiaBan >= 0),
	SoLuongTon int not null check(SoLuongTon >= 0) default 0,
	MoTa nvarchar(max) null,
	AnhBia nvarchar(200) not null, --URL ảnh bìa
	CreatedDate datetime not null default getdate(),
	IsActive bit null,
	constraint FK_Sach_TacGia foreign key (MaTacGia) references TacGia(MaTacGia),
	constraint FK_Sach_TheLoai foreign key (MaTheLoai) references TheLoai(MaTheLoai)
);
Go

--bảng đơn hàng
Create table HoaDon (
	MaHoaDon int identity(1,1) primary key,
	UserID int not null,
	OrderDate datetime not null default getdate(),
    ThanhTien int default 0,
	--Status nvarchar(50) not null check(status in ('Pending','Completed','Cancelled')),
	constraint FK_HoaDon_Users foreign key (UserID) references Users(UserID)
);
Go

--bảng chi tiết đơn hàng
Create table CTHoaDon (
	MaCTHoaDon int identity(1,1),
	MaHoaDon int not null,
	MaSach int not null,
	SoLuong int not null check(SoLuong >= 0),
	GiaBan int not null check(GiaBan >= 0)
	Constraint PR_CTHoaDon primary key (MaHoaDon, MaCTHoaDon),
	Constraint FK_CTHoaDon_HoaDon foreign key (MaHoaDon) references HoaDon(MaHoaDon),
	Constraint FK_CTHoaDon_Sach foreign key (MaSach) references Sach(MaSach)
);
Go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--thủ tục đăng nhập
create proc dbo.spUserLogin
	@Username nvarchar(50),
	@Password nvarchar(100)
as begin try
	if not exists (
		select * from Users
		Where Username = @Username
			and PWDCOMPARE(@Password, PasswordHash) = 1
			And Role = 'User'
			And UserStatus = 1
	)
	Begin
		raiserror (N'Tên đăng nhập hoặc mật khẩu không chính xác.', 16, 1);
		Return;
	end
--cập nhật thời gian đăng nhập cuối cùng
	Update Users
		set LastLogin = getdate()
		Where Username = @Username;
--trả về thông tin user
	select UserID, Username, Role, LastLogin, CreatedDate
		from Users
		Where Username = @Username;
	end try
	Begin catch
		declare @error nvarchar(1000) = error_message();
		Raiserror(@error, 16, 1);
	end catch
go

--thêm mô tả cho cột role trong Users
Exec sys.sp_addextendedproperty
	@name = N'MS_Description',
	@value = N'User: Người dùng, Admin: Người quản trị',
	@level0type = N'SCHEMA', @level0name = N'dbo', 
    @level1type = N'TABLE', @level1name = N'Users', 
    @level2type = N'COLUMN', @level2name = N'Role';
go

--thêm mô tả cho cột userstatus
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'1 - Kích hoạt, 0 - Tạm khóa', 
    @level0type = N'SCHEMA', @level0name = N'dbo', 
    @level1type = N'TABLE', @level1name = N'Users', 
    @level2type = N'COLUMN', @level2name = N'UserStatus';
go

--thủ tục thêm sách mới
Create proc dbo.spCreateSach
	@TenSach nvarchar(200),
	@MaTacGia int,
	@MaTheLoai int,
	@GiaBan int,
	@SoLuongTon int,
	@AnhBia nvarchar(200) 
as begin try
	if exists (
		select * from Sach
		Where TenSach = @TenSach
	)
	BEGIN
        SELECT N'Sách này đã tồn tại trong hệ thống.' AS errMsg;
        RETURN;
    END
	INSERT INTO Sach (TenSach, MaTacGia, MaTheLoai, GiaBan, SoLuongTon, AnhBia, CreatedDate, IsActive)
    VALUES (@TenSach, @MaTacGia, @MaTheLoai, @GiaBan, @SoLuongTon, @AnhBia, GETDATE(), 1);
	SELECT N'Sách đã được thêm thành công.' AS errMsg;
end try
Begin catch
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--thủ tục cập nhật sách
Create proc dbo.spUpdateSach
	@MaSach int,
	@TenSach nvarchar(200),
	@MaTacGia int,
	@MaTheLoai int,
	@GiaBan int,
	@SoLuongTon int,
	@AnhBia nvarchar(200) 
as begin try
	if not exists (
		select * from Sach where MaSach = @MaSach and IsActive = 1
	)
	Begin
		raiserror (N'Sách không tồn tại hoặc đã bị xóa.', 16, 1);
		SELECT N'Sách không tồn tại hoặc đã bị xóa.' AS errMsg;
        RETURN;
	end
	Update Sach
	Set TenSach = @TenSach,
		MaTacGia = @MaTacGia,
		MaTheLoai = @MaTheLoai,
		GiaBan = @GiaBan,
		SoLuongTon = @SoLuongTon,
		AnhBia = @AnhBia
	where MaSach = @MaSach;
	Print 'Sách đã được cập nhật thành công.';
	SELECT N'Sách đã được cập nhật thành công.' AS errMsg;
end try
Begin catch
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--thủ tục xoá mềm sách (ẩn không mất)
Create proc dbo.spAnSach
	@MaSach int
as begin try
	if not exists (
		select * from Sach where MaSach = @MaSach and IsActive = 1
	)
	Begin
		raiserror (N'Sách không tồn tại hoặc đã bị xóa.', 16, 1);
		SELECT N'Sách không tồn tại hoặc đã bị xóa..' AS errMsg;
		Return;
	end
	Update Sach
	Set IsActive = 0
	Where MaSach = @MaSach;
	Print 'Sách đã được xoá thành công.';
	SELECT N'Sách đã được xoá thành công.' AS errMsg;
end try
Begin catch
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--thủ tục khôi phục lại những cuốn sách bị ẩn đi
CREATE PROC dbo.spHienSach
    @MaSach INT
AS BEGIN TRY
    IF NOT EXISTS (
        SELECT * 
        FROM Sach 
        WHERE MaSach = @MaSach AND IsActive = 0
    )
    BEGIN
        RAISERROR (N'Sách không tồn tại hoặc chưa bị xóa.', 16, 1);
		SELECT N'Sách không tồn tại hoặc chưa bị xóa.' AS errMsg;
        RETURN;
    END
    UPDATE Sach
    SET IsActive = 1
    WHERE MaSach = @MaSach;

    PRINT 'Sách đã được khôi phục thành công.';
	SELECT N'Sách đã được khôi phục thành công.' AS errMsg;
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--thủ tục lấy sách bằng mã
CREATE proc dbo.spGetSachByID
@MaSach int
AS
	select s.MaSach,
            s.TenSach ,
            t.TenTacGia ,
			s.MaTacGia,
			s.MaTheLoai,
            tl.TenTheLoai ,
            s.GiaBan ,
            s.SoLuongTon ,
            s.MoTa ,
            s.AnhBia ,
            s.CreatedDate,
			s.IsActive
	FROM Sach s
        INNER JOIN TacGia t ON s.MaTacGia = t.MaTacGia
        INNER JOIN TheLoai tl ON s.MaTheLoai = tl.MaTheLoai
	Where s.IsActive = 1 and s.MaSach = @MaSach;
go

--thủ tục hiện sách ra màn hình
Create proc dbo.spGetAllSach
As begin try
	select s.MaSach,
            s.TenSach ,
			s.MaTacGia,
			s.MaTheLoai,
            t.TenTacGia ,
            tl.TenTheLoai ,
            s.GiaBan ,
            s.SoLuongTon ,
            s.MoTa ,
            s.AnhBia ,
            s.CreatedDate,
			s.IsActive
	FROM Sach s
        INNER JOIN TacGia t ON s.MaTacGia = t.MaTacGia
        INNER JOIN TheLoai tl ON s.MaTheLoai = tl.MaTheLoai
	Where s.IsActive = 1;
end try
Begin catch
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

insert into Users (Username, PasswordHash, UserStatus) 
	values ('user', PWDENCRYPT('user'), 1)
go

insert into Users (Username, PasswordHash, Role, UserStatus) 
	values ('admin', PWDENCRYPT('admin'), 'Admin', 1)
go

CREATE PROC dbo.spGetAllTacGia
AS BEGIN TRY
    SELECT MaTacGia, TenTacGia, CreatedDate, IsActive
    FROM TacGia
    WHERE IsActive = 1;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

CREATE PROC dbo.spGetTacGiaByID
    @MaTacGia INT
AS BEGIN TRY
    SELECT MaTacGia, TenTacGia, CreatedDate, IsActive
    FROM TacGia
    WHERE MaTacGia = @MaTacGia AND IsActive = 1;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

CREATE PROC dbo.spCreateTacGia
    @TenTacGia NVARCHAR(200)
AS BEGIN TRY
    -- Kiểm tra nếu tác giả đã tồn tại
    IF EXISTS (SELECT 1 FROM TacGia WHERE TenTacGia = @TenTacGia AND IsActive = 1)
    BEGIN
        SELECT N'Tác giả đã tồn tại.' AS errMsg;
        RETURN;
    END

    -- Thêm mới tác giả
    INSERT INTO TacGia (TenTacGia, CreatedDate, IsActive)
    VALUES (@TenTacGia, GETDATE(), 1);

    SELECT N'Tác giả đã được thêm thành công.' AS errMsg;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

CREATE PROC dbo.spUpdateTacGia
    @MaTacGia INT,
    @TenTacGia NVARCHAR(200)
AS BEGIN TRY
    -- Kiểm tra nếu tác giả tồn tại
    IF NOT EXISTS (SELECT 1 FROM TacGia WHERE MaTacGia = @MaTacGia AND IsActive = 1)
    BEGIN
        SELECT N'Tác giả không tồn tại hoặc đã bị xóa.' AS errMsg;
        RETURN;
    END

    -- Cập nhật thông tin tác giả
    UPDATE TacGia
    SET TenTacGia = @TenTacGia
    WHERE MaTacGia = @MaTacGia;

    SELECT N'Tác giả đã được cập nhật thành công.' AS errMsg;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

CREATE PROC dbo.spAnTacGia
    @MaTacGia INT
AS BEGIN TRY
    -- Kiểm tra nếu tác giả tồn tại
    IF NOT EXISTS (SELECT 1 FROM TacGia WHERE MaTacGia = @MaTacGia AND IsActive = 1)
    BEGIN
        SELECT N'Tác giả không tồn tại hoặc đã bị xóa.' AS errMsg;
        RETURN;
    END

    -- Xóa mềm tác giả
    UPDATE TacGia
    SET IsActive = 0
    WHERE MaTacGia = @MaTacGia;

    SELECT N'Tác giả đã được ẩn thành công.' AS errMsg;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

CREATE PROC dbo.spGetAllTheLoai
AS BEGIN TRY
    SELECT MaTheLoai, TenTheLoai, CreatedDate, IsActive
    FROM TheLoai
    WHERE IsActive = 1;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

CREATE PROC dbo.spGetTheLoaiByID
    @MaTheLoai INT
AS BEGIN TRY
    SELECT MaTheLoai, TenTheLoai, CreatedDate, IsActive
    FROM TheLoai
    WHERE MaTheLoai = @MaTheLoai AND IsActive = 1;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

CREATE PROC dbo.spCreateTheLoai
    @TenTheLoai NVARCHAR(100)
AS BEGIN TRY
    -- Kiểm tra nếu thể loại đã tồn tại
    IF EXISTS (SELECT 1 FROM TheLoai WHERE TenTheLoai = @TenTheLoai AND IsActive = 1)
    BEGIN
        SELECT N'Thể loại đã tồn tại.' AS errMsg;
        RETURN;
    END

    -- Thêm mới thể loại
    INSERT INTO TheLoai (TenTheLoai, CreatedDate, IsActive)
    VALUES (@TenTheLoai, GETDATE(), 1);

    SELECT N'Thể loại đã được thêm thành công.' AS errMsg;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

CREATE PROC dbo.spUpdateTheLoai
    @MaTheLoai INT,
    @TenTheLoai NVARCHAR(100)
AS BEGIN TRY
    -- Kiểm tra nếu thể loại tồn tại
    IF NOT EXISTS (SELECT 1 FROM TheLoai WHERE MaTheLoai = @MaTheLoai AND IsActive = 1)
    BEGIN
        SELECT N'Thể loại không tồn tại hoặc đã bị xóa.' AS errMsg;
        RETURN;
    END

    -- Cập nhật thông tin thể loại
    UPDATE TheLoai
    SET TenTheLoai = @TenTheLoai
    WHERE MaTheLoai = @MaTheLoai;

    SELECT N'Thể loại đã được cập nhật thành công.' AS errMsg;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

CREATE PROC dbo.spAnTheLoai
    @MaTheLoai INT
AS BEGIN TRY
    -- Kiểm tra nếu thể loại tồn tại
    IF NOT EXISTS (SELECT 1 FROM TheLoai WHERE MaTheLoai = @MaTheLoai AND IsActive = 1)
    BEGIN
        SELECT N'Thể loại không tồn tại hoặc đã bị xóa.' AS errMsg;
        RETURN;
    END

    -- Xóa mềm thể loại
    UPDATE TheLoai
    SET IsActive = 0
    WHERE MaTheLoai = @MaTheLoai;

    SELECT N'Thể loại đã được ẩn thành công.' AS errMsg;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--Tạo hóa đơn mới
CREATE PROC dbo.spCreateHoaDon
    @UserID INT,
    @OrderDetails NVARCHAR(MAX) -- JSON chứa danh sách sách
AS
BEGIN TRY
    BEGIN TRANSACTION;

    -- Thêm hóa đơn mới
    INSERT INTO HoaDon (UserID, OrderDate, ThanhTien)
    VALUES (@UserID, GETDATE(), 0);

    -- Lấy mã hóa đơn vừa được tạo
    DECLARE @MaHoaDon INT = SCOPE_IDENTITY();

    -- Bảng tạm để lưu chi tiết hóa đơn từ JSON
    DECLARE @Details TABLE (
        MaSach INT,
        SoLuong INT
    );

    -- Parse JSON vào bảng tạm (lấy MaSach và SoLuong từ đầu vào)
    INSERT INTO @Details (MaSach, SoLuong)
    SELECT 
        JSON_VALUE(d.value, '$.MaSach') AS MaSach,
        JSON_VALUE(d.value, '$.SoLuong') AS SoLuong
    FROM OPENJSON(@OrderDetails) AS d;

    -- Kiểm tra số lượng tồn của từng sách
    IF EXISTS (
        SELECT 1
        FROM @Details d
        INNER JOIN Sach s ON d.MaSach = s.MaSach
        WHERE d.SoLuong > s.SoLuongTon
    )
    BEGIN
        RAISERROR (N'Số lượng tồn không đủ cho một hoặc nhiều sách.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Trừ số lượng tồn trong bảng Sach và thêm chi tiết hóa đơn
    INSERT INTO CTHoaDon (MaHoaDon, MaSach, SoLuong, GiaBan)
    SELECT 
        @MaHoaDon, 
        d.MaSach, 
        d.SoLuong, 
        s.GiaBan -- Lấy giá bán từ bảng Sach
    FROM @Details d
    INNER JOIN Sach s ON d.MaSach = s.MaSach;

    -- Cập nhật số lượng tồn trong bảng Sach
    UPDATE s
    SET s.SoLuongTon = s.SoLuongTon - d.SoLuong
    FROM Sach s
    INNER JOIN @Details d ON s.MaSach = d.MaSach;

    -- Tính tổng tiền của hóa đơn
    DECLARE @ThanhTien INT;
    SELECT @ThanhTien = SUM(SoLuong * GiaBan)
    FROM CTHoaDon
    WHERE MaHoaDon = @MaHoaDon;

    -- Cập nhật tổng tiền vào bảng HoaDon
    UPDATE HoaDon
    SET ThanhTien = @ThanhTien
    WHERE MaHoaDon = @MaHoaDon;

    COMMIT TRANSACTION;

    SELECT @MaHoaDon AS MaHoaDon, N'Hóa đơn đã được tạo thành công.' AS Message;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--Lấy danh sách hóa đơn
CREATE PROC dbo.spGetAllHoaDon
AS
BEGIN TRY
    SELECT 
        h.MaHoaDon,
        h.UserID,
        u.Username,
        h.OrderDate,
        h.ThanhTien
    FROM HoaDon h
    INNER JOIN Users u ON h.UserID = u.UserID
    ORDER BY h.OrderDate DESC;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--Lấy chi tiết hóa đơn
CREATE PROC dbo.spGetCTHoaDon
    @MaHoaDon INT
AS
BEGIN TRY
    -- Danh sách chi tiết hóa đơn
    SELECT 
        c.MaCTHoaDon,
        c.MaSach,
        s.TenSach,
        c.SoLuong,
        c.GiaBan,
        (c.SoLuong * c.GiaBan) AS ThanhTien
    FROM CTHoaDon c
    INNER JOIN Sach s ON c.MaSach = s.MaSach
    WHERE c.MaHoaDon = @MaHoaDon;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

CREATE TRIGGER trg_CheckSoLuongTon
ON CTHoaDon
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra số lượng tồn trước khi trừ
    IF EXISTS (
        SELECT 1 
        FROM INSERTED i
        INNER JOIN Sach s ON i.MaSach = s.MaSach
        WHERE i.SoLuong > s.SoLuongTon
    )
    BEGIN
        RAISERROR (N'Số lượng tồn không đủ để thêm chi tiết hóa đơn.', 16, 1);
        ROLLBACK TRANSACTION; -- Hủy bỏ giao dịch
        RETURN;
    END;

    -- Trừ số lượng tồn trong bảng Sach
    UPDATE s
    SET s.SoLuongTon = s.SoLuongTon - i.SoLuong
    FROM Sach s
    INNER JOIN INSERTED i ON s.MaSach = i.MaSach;

    PRINT N'Số lượng tồn đã được cập nhật thành công.';
END;
GO

CREATE TRIGGER trg_CalculateThanhTien
ON CTHoaDon
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Tạo một bảng tạm lưu các MaHoaDon bị ảnh hưởng
    DECLARE @AffectedHoaDon TABLE (MaHoaDon INT);

    -- Thêm MaHoaDon từ bảng INSERTED
    IF EXISTS (SELECT 1 FROM INSERTED)
    BEGIN
        INSERT INTO @AffectedHoaDon (MaHoaDon)
        SELECT DISTINCT MaHoaDon FROM INSERTED;
    END

    -- Thêm MaHoaDon từ bảng DELETED
    IF EXISTS (SELECT 1 FROM DELETED)
    BEGIN
        INSERT INTO @AffectedHoaDon (MaHoaDon)
        SELECT DISTINCT MaHoaDon FROM DELETED;
    END

    -- Cập nhật lại ThanhTien trong bảng HoaDon
    UPDATE h
    SET h.ThanhTien = ISNULL(c.TotalAmount, 0)
    FROM HoaDon h
    INNER JOIN (
        SELECT MaHoaDon, SUM(SoLuong * GiaBan) AS TotalAmount
        FROM CTHoaDon
        WHERE MaHoaDon IN (SELECT MaHoaDon FROM @AffectedHoaDon)
        GROUP BY MaHoaDon
    ) c ON h.MaHoaDon = c.MaHoaDon;

    -- Đặt ThanhTien = 0 cho các hóa đơn không còn chi tiết nào
    UPDATE h
    SET h.ThanhTien = 0
    FROM HoaDon h
    WHERE NOT EXISTS (
        SELECT 1 
        FROM CTHoaDon c 
        WHERE c.MaHoaDon = h.MaHoaDon
    );
END;
GO


--thêm tác giả
INSERT INTO TacGia (TenTacGia)
VALUES 
    (N'William Shakespeare'),
    (N'Jane Austen'),
    (N'Leo Tolstoy'),
    (N'Charles Dickens'),
    (N'Fyodor Dostoevsky'),
    (N'George Orwell'),
    (N'Mark Twain'),
    (N'J.R.R. Tolkien'),
    (N'Agatha Christie'),
    (N'J.K. Rowling'),
    (N'Ernest Hemingway'),
    (N'Gabriel García Márquez'),
    (N'Victor Hugo'),
    (N'Homer'),
    (N'Edgar Allan Poe'),
    (N'Dan Brown'),
    (N'Oscar Wilde'),
    (N'Arthur Conan Doyle'),
    (N'Haruki Murakami'),
    (N'Franz Kafka'),
    (N'Herman Melville'),
    (N'John Steinbeck'),
    (N'Emily Dickinson'),
    (N'Alexandre Dumas'),
    (N'Toni Morrison'),
    (N'Harper Lee'),
    (N'Khaled Hosseini'),
    (N'Stephen King'),
    (N'Virginia Woolf'),
    (N'Mary Shelley'),
    (N'George R.R. Martin'),
    (N'Paulo Coelho'),
    (N'Marcel Proust'),
    (N'Margaret Atwood'),
    (N'Miguel de Cervantes'),
    (N'J.D. Salinger'),
    (N'C.S. Lewis'),
    (N'Ursula K. Le Guin'),
    (N'Roald Dahl'),
    (N'Stendhal'),
    (N'Jules Verne'),
    (N'Joseph Conrad'),
    (N'Albert Camus'),
    (N'Tolstoy Dostoevsky'),
    (N'Umberto Eco'),
    (N'Ralph Waldo Emerson'),
    (N'Maya Angelou'),
    (N'Ray Bradbury'),
    (N'Thomas Hardy'),
    (N'Salman Rushdie'),
    (N'J.M. Barrie'),
    (N'Neil Gaiman'),
    (N'Michel Houellebecq'),
    (N'Jack London'),
    (N'Kurt Vonnegut'),
    (N'Aldous Huxley'),
    (N'Patrick Rothfuss'),
    (N'Philip Pullman'),
    (N'Louisa May Alcott'),
    (N'Gustave Flaubert'),
    (N'Sophocles'),
    (N'Plato'),
    (N'Aristotle'),
    (N'Rumi'),
    (N'Thich Nhat Hanh'),
    (N'Anne Rice'),
    (N'Sheryl Sandberg'),
    (N'Lisa See'),
    (N'Veronica Roth'),
    (N'Suzanne Collins'),
    (N'Nicholas Sparks'),
    (N'James Joyce'),
    (N'Zadie Smith'),
    (N'Milan Kundera'),
    (N'Anne Frank'),
    (N'Thomas Mann'),
    (N'George Eliot'),
    (N'Tom Clancy'),
    (N'Markus Zusak'),
    (N'Kazuo Ishiguro'),
    (N'Yann Martel'),
    (N'Veronica Rossi'),
    (N'Rick Riordan'),
    (N'Colleen Hoover'),
    (N'Rainbow Rowell'),
    (N'E.L. James'),
    (N'Tara Westover'),
    (N'John Green'),
    (N'Laura Hillenbrand'),
    (N'Gillian Flynn'),
    (N'Mitch Albom'),
    (N'Lisa Genova'),
    (N'Elizabeth Gilbert'),
    (N'Kiera Cass'),
    (N'Shakespeare Hafez'),
    (N'Daphne du Maurier'),
    (N'Samuel Beckett'),
    (N'Vernon Lee'),
    (N'Chimamanda Ngozi Adichie'),
    (N'Toni Cade Bambara'),
    (N'Sylvia Plath'),
    (N'Taiye Selasi');
go

--thêm thể loại
INSERT INTO TheLoai (TenTheLoai)
VALUES 
    (N'Văn học - Tiểu thuyết'),
    (N'Văn học - Truyện ngắn'),
    (N'Văn học - Khoa học viễn tưởng'),
    (N'Văn học - Lãng mạn'),
    (N'Văn học - Kinh dị'),
    (N'Văn học - Trinh thám'),
    (N'Văn học - Hài hước'),
    (N'Văn học - Lịch sử'),
    (N'Văn học - Phiêu lưu'),
    (N'Văn học - Hiện thực'),

    (N'Thiếu nhi - Truyện tranh'),
    (N'Thiếu nhi - Truyện cổ tích'),
    (N'Thiếu nhi - Truyện ngắn giáo dục'),
    (N'Thiếu nhi - Sách tương tác'),

    (N'Lịch sử - Tiểu thuyết lịch sử'),
    (N'Lịch sử - Tư liệu và nghiên cứu'),

    (N'Khoa học - Viễn tưởng'),
    (N'Khoa học - Vũ trụ và vật lý'),
    (N'Khoa học - Sinh học'),
    (N'Khoa học - Công nghệ thông tin'),
    (N'Khoa học - Môi trường'),

    (N'Kinh tế - Kinh doanh'),
    (N'Kinh tế - Tài chính'),
    (N'Kinh tế - Quản lý'),
    (N'Kinh tế - Marketing và Bán hàng'),

    (N'Phát triển bản thân - Kỹ năng sống'),
    (N'Phát triển bản thân - Quản lý thời gian'),
    (N'Phát triển bản thân - Tư duy tích cực'),
    (N'Phát triển bản thân - Lãnh đạo'),

    (N'Tâm lý - Tình cảm'),
    (N'Tâm lý - Trị liệu'),
    (N'Tâm lý - Phát triển bản thân'),

    (N'Tôn giáo - Tâm linh'),
    (N'Tôn giáo - Triết học'),
    (N'Tôn giáo - Phật giáo'),
    (N'Tôn giáo - Thiên chúa giáo'),

    (N'Nấu ăn - Sách công thức'),
    (N'Nấu ăn - Ẩm thực vùng miền'),

    (N'Du lịch - Hướng dẫn du lịch'),
    (N'Du lịch - Văn hóa và con người'),

    (N'Nghệ thuật - Mỹ thuật'),
    (N'Nghệ thuật - Nhiếp ảnh'),
    (N'Nghệ thuật - Thiết kế và thời trang'),

    (N'Trinh thám - Tội phạm'),
    (N'Trinh thám - Hành động'),

    (N'Y học - Sách sức khỏe'),
    (N'Y học - Dinh dưỡng'),

    (N'Học thuật - Toán học'),
    (N'Học thuật - Vật lý'),
    (N'Học thuật - Sinh học'),
    (N'Học thuật - Khoa học xã hội'),

    (N'Giáo dục - Tham khảo'),
    (N'Giáo dục - Học ngoại ngữ'),
    (N'Giáo dục - Sách luyện thi'),

    (N'Kỹ thuật - Công trình xây dựng'),
    (N'Kỹ thuật - Cơ khí'),
    (N'Kỹ thuật - Điện tử và viễn thông'),

    (N'Thể thao - Sách tập luyện'),
    (N'Thể thao - Kỹ thuật chơi thể thao'),

    (N'Sách kỹ năng nghề nghiệp'),
    (N'Sách hướng dẫn học tập và nghiên cứu'),

    (N'Truyện tranh - Manga'),
    (N'Truyện tranh - Manhwa'),
    (N'Truyện tranh - Webtoon'),

    (N'Sách thiếu nhi - Kể chuyện'),
    (N'Sách thiếu nhi - Phát triển kỹ năng'),

    (N'Sách điện tử'),
    (N'Sách nói (Audio Book)');
go

INSERT INTO Sach (TenSach, MaTacGia, MaTheLoai, GiaBan, SoLuongTon, MoTa, AnhBia, IsActive)
VALUES
(N'Harry Potter và Hòn Đá Phù Thủy', 1, 1, 150000, 50, N'Phần đầu tiên trong bộ truyện Harry Potter nổi tiếng.', 'https://example.com/harry1.jpg', 1),
(N'Harry Potter và Phòng Chứa Bí Mật', 1, 1, 160000, 45, N'Phần hai của bộ truyện Harry Potter.', 'https://example.com/harry2.jpg', 1),
(N'Harry Potter và Tên Tù Nhân Ngục Azkaban', 1, 1, 170000, 40, N'Phần ba của bộ truyện Harry Potter.', 'https://example.com/harry3.jpg', 1),
(N'Chạng Vạng', 2, 2, 120000, 60, N'Tiểu thuyết lãng mạn giả tưởng về ma cà rồng.', 'https://example.com/twilight.jpg', 1),
(N'Đại Gia Gatsby', 3, 3, 100000, 30, N'Tiểu thuyết kinh điển của nhà văn F. Scott Fitzgerald.', 'https://example.com/gatsby.jpg', 1),
(N'Cuộc Phiêu Lưu Của Sherlock Holmes', 4, 4, 130000, 35, N'Tuyển tập truyện trinh thám nổi tiếng của Conan Doyle.', 'https://example.com/sherlock.jpg', 1),
(N'Đồi Gió Hú', 5, 2, 110000, 25, N'Tiểu thuyết lãng mạn nổi tiếng của Emily Brontë.', 'https://example.com/wuthering.jpg', 1),
(N'Tội Ác Và Hình Phạt', 6, 5, 180000, 20, N'Tác phẩm văn học kinh điển của Fyodor Dostoevsky.', 'https://example.com/crime.jpg', 1),
(N'Nhà Giả Kim', 7, 6, 90000, 70, N'Tiểu thuyết triết lý đầy cảm hứng của Paulo Coelho.', 'https://example.com/alchemist.jpg', 1),
(N'Bí Kíp Luyện Rồng', 8, 7, 95000, 80, N'Truyện thiếu nhi phiêu lưu hấp dẫn.', 'https://example.com/dragon.jpg', 1),
(N'Hoàng Tử Bé', 9, 6, 85000, 90, N'Tác phẩm nổi tiếng mang thông điệp sâu sắc.', 'https://example.com/littleprince.jpg', 1),
(N'1984', 10, 8, 140000, 55, N'Tiểu thuyết phản địa đàng của George Orwell.', 'https://example.com/1984.jpg', 1),
(N'Truyện Kiều', 11, 9, 70000, 65, N'Tác phẩm thơ nổi tiếng của Nguyễn Du.', 'https://example.com/kieu.jpg', 1),
(N'Dế Mèn Phiêu Lưu Ký', 12, 7, 80000, 85, N'Truyện thiếu nhi kinh điển của Tô Hoài.', 'https://example.com/demen.jpg', 1),
(N'Bố Già', 13, 3, 200000, 20, N'Tiểu thuyết về thế giới mafia của Mario Puzo.', 'https://example.com/godfather.jpg', 1),
(N'Người Đua Diều', 14, 4, 125000, 45, N'Tác phẩm cảm động về tình bạn và tình yêu.', 'https://example.com/kiterunner.jpg', 1),
(N'Đắc Nhân Tâm', 15, 10, 105000, 100, N'Cuốn sách về nghệ thuật giao tiếp và thành công.', 'https://example.com/dacnhantam.jpg', 1),
(N'Thiên Thần Và Ác Quỷ', 16, 4, 155000, 60, N'Tiểu thuyết trinh thám nổi tiếng của Dan Brown.', 'https://example.com/angels.jpg', 1),
(N'Mật Mã Da Vinci', 16, 4, 165000, 50, N'Tiểu thuyết bí ẩn nổi tiếng của Dan Brown.', 'https://example.com/davinci.jpg', 1),
(N'Bảy Thói Quen Của Người Thành Đạt', 17, 10, 115000, 75, N'Cuốn sách phát triển bản thân nổi tiếng.', 'https://example.com/7habits.jpg', 1);
