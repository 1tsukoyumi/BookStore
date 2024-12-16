create database BookStore
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
	UserStatus bit null --trạng thái
);
Go

--bảng tác giả
create table TacGia (
	MaTacGia int identity(1,1) primary key,
	TenTacGia nvarchar(200) not null
);
go

--bảng danh mục
Create table Theloai (
	Matheloai int identity(1,1) primary key,
	Tentheloai nvarchar(100) not null
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

--trigger ngăn không cho user tự thay đổi role
Create trigger trg_RoleChange
On Users
instead of update
As begin
	if exists (
		select 1
		From inserted i
		Join deleted d on i.UserID = d.UserID
		Where i.Role = 'Admin' and d.Role <> 'Admin'
			and SYSTEM_USER not in (
				select Username from Users where Role = 'Admin'
			)
	)
	Begin
		raiserror(N'Chỉ Admin có quyền chỉnh sửa', 16, 1);
		Rollback;
	end
	else begin
		update Users
		Set Username = i.Username,
            PasswordHash = i.PasswordHash,
            Role = i.Role,
            CreatedDate = i.CreatedDate
		from Users u join inserted i on u.UserID = i.UserID
	end
end;
Go

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

--thủ tục đăng nhập cho admin
Create proc dbo.spAdminLogin
	@Username nvarchar(50),
	@Password nvarchar(100)
as begin try
	if not exists (
		select * from Users
		Where Username = @Username
			and PWDCOMPARE(@Password, PasswordHash) = 1
			And Role = 'Admin'
			And UserStatus = 1
	)
	Begin
		raiserror (N'Tài khoản hoặc mật khẩu không chính xác, hoặc tài khoản không phải Admin.', 16, 1);
		Return;
	end
--cập nhật thời gian đăng nhập cuối cùng
	Update Users
		set LastLogin = getdate()
		Where Username = @Username;
--trả về thông tin admin
	select UserID, Username, Role, LastLogin, CreatedDate
		from Users
		Where Username = @Username;
	end try
	Begin catch
--xử lý lỗi
		declare @error nvarchar(1000) = error_message();
		Raiserror(@error, 16, 1);
	end catch
go

--thủ tục thêm sách mới
Create proc dbo.spThemSach
	@TenSach nvarchar(200),
	@MaTacGia int,
	@MaTheLoai int,
	@GiaBan int,
	@SoLuongTon int,
	@MoTa nvarchar(max),
	@AnhBia nvarchar(200) 
as begin try
	if exists (
		select * from Sach
		Where TenSach = @TenSach
	)
	BEGIN
        RAISERROR (N'Sách này đã tồn tại trong hệ thống.', 16, 1);
        RETURN;
    END
	INSERT INTO Sach VALUES (@TenSach, @MaTacGia, @MaTheLoai, @GiaBan, @SoLuongTon, @MoTa, @AnhBia, GETDATE(), 1);
	PRINT 'Sách đã được thêm thành công.';
end try
Begin catch
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--thủ tục cập nhật sách
Create proc dbo.spCapNhatSach
	@MaSach int,
	@TenSach nvarchar(200),
	@MaTacGia int,
	@MaTheLoai int,
	@GiaBan int,
	@SoLuongTon int,
	@MoTa nvarchar(max),
	@AnhBia nvarchar(200) 
as begin try
	if not exists (
		select * from Sach where MaSach = @MaSach and IsActive = 1
	)
	Begin
		raiserror (N'Sách không tồn tại hoặc đã bị xóa.', 16, 1);
        RETURN;
	end
	Update Sach
	Set GiaBan = @GiaBan
	where MaSach = @MaSach;
	Print 'Giá sách đã được cập nhật thành công.';
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
		Return;
	end
	Update Sach
	Set IsActive = 0
	Where MaSach = @MaSach;
	Print 'Sách đã được xoá thành công.';
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
        RETURN;
    END
    UPDATE Sach
    SET IsActive = 1
    WHERE MaSach = @MaSach;

    PRINT 'Sách đã được khôi phục thành công.';
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--thủ tục xuất danh sách thể loại
Create proc dbo.spLaySachTheoTheLoai
as begin try
	select
		TenTheLoai
	from Theloai
	For json path, include_null_values; --trả về dưới định dang json
end try
begin catch
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--thủ tục lấy sách bằng mã
CREATE proc dbo.spLaySachByMaSach
@MaSach int
AS
	SELECT * FROM Sach 
	WHERE MaSach = @MaSach and IsActive = 1
go

--thủ tục hiện sách ra màn hình
Create proc dbo.spLaySach
As begin try
	select MaSach,
		TenSach as [Tên sách],
		MaTacGia,
		MaTheLoai,
		FORMAT(GiaBan, 'N0') as [Giá bán],
		SoLuongTon,
		MoTa,
		AnhBia as [Ảnh bìa]
	From Sach
	Where IsActive = 1
end try
Begin catch
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

insert into Users (Username, PasswordHash, UserStatus) 
	values ('user', PWDENCRYPT('user'), 1)
go