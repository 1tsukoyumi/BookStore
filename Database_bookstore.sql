create database BookStore
Go

Use BookStore
Go

--bảng quản lý thông tin người dùng
Create table Users (
	UserID	int identity(1,1) primary key,
	Username nvarchar(50) not null unique,
	PasswordHash nvarchar(max) not null,
	Fullname nvarchar(100) not null,
	Email nvarchar(100) not null unique,
	Phone nvarchar(20) null,
	Address nvarchar(200) null,
	Role nvarchar(20) not null default 'User',
	CreatedDate datetime not null default getdate(),
	LastLogin datetime null,
	UserStatus bit null --trạng thái
);
Go

--bảng quản lý sách
create table Books (
	BookID int identity(1,1) primary key,
	Title nvarchar(200) not null,
	Author nvarchar(100) not null,
	Publisher nvarchar(100) not null,
	Category nvarchar(100) not null,
	Price int not null check(Price >= 0),
	SoldQuantity int not null check(SoldQuantity >= 0) default 0,
	Description nvarchar(max) null,
	CoverImage nvarchar(200) not null, --URL ảnh bìa
	CreatedDate datetime not null default getdate(),
	IsActive bit null
);
Go

--bảng đơn hàng
Create table Orders (
	OrderID int identity(1,1) primary key,
	UserID int not null,
	OrderDate datetime not null default getdate(),
	TotalAmount int not null check(TotalAmount >= 0),
	Status nvarchar(50) not null check(status in ('Pending','Conpleted','Cancelled')),
	constraint FK_Oders_Users foreign key (UserID) references Users(UserID)
);
Go

--bảng chi tiết đơn hàng
Create table OrderDetails (
	OrderDetailID int identity(1,1) primary key,
	OrderID int not null,
	BookID int not null,
	Quantity int not null check(Quantity >= 0),
	UnitPrice int not null check(UnitPrice >= 0)
	Constraint FK_OderDetails_Orders foreign key (OrderID) references Orders(OrderID),
	Constraint FK_OrderDetails_Books foreign key (BookID) references Books(BookID)
);
Go

--bảng giỏ hàng
Create table Cart (
	CartID int identity(1,1) primary key,
	UserID int not null,
	BookID int not null,
	Quantity int not null check(Quantity >= 0)
	Constraint FK_Cart_Users foreign key (UserID) references Users(UserID),
	Constraint FK_Cart_Books foreign key (BookID) references Books(BookID)
);
Go

--bảng thông tin thanh toán
Create table Payments (
	PaymentID int identity(1,1) primary key,
	OrderID int not null,
	PaymentDate datetime not null default getdate(),
	PaymentMethod nvarchar(50) not null,
	AmountPaid int not null check(AmountPaid >= 0),
	constraint FK_Payments_Orders foreign key (OrderID) references Orders(OrderID)
);
Go

--bảng danh mục
Create table Categories (
	CategoryID int identity(1,1) primary key,
	MainCategory NVARCHAR(100) null,
	CategoryName nvarchar(100) not null
);
Go

--bảng lịch sử hoạt động của admin
Create table AuditLogs (
	LogID int identity(1,1) primary key,
	AdminID int not null,
	Action nvarchar(200) not null,
	ActionDate datetime default getdate(),
	constraint FK_AditLogs_Users foreign key (AdminID) references Users(UserID)
);
Go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--cập nhật thêm cho danh mục lớn
UPDATE Categories
SET MainCategory = 
    CASE 
        WHEN CategoryName LIKE N'Văn học%' THEN N'Văn học'
        WHEN CategoryName LIKE N'Phi văn học%' THEN N'Phi văn học'
        WHEN CategoryName LIKE N'Chuyên môn%' THEN N'Chuyên môn'
        WHEN CategoryName LIKE N'Phát triển bản thân%' THEN N'Phát triển bản thân'
        WHEN CategoryName LIKE N'Học thuật%' THEN N'Học thuật'
        WHEN CategoryName LIKE N'Thiếu nhi%' THEN N'Thiếu nhi'
        WHEN CategoryName LIKE N'Đặc thù%' THEN N'Đặc thù'
        ELSE NULL
    END
go

--thêm thể loại sách
INSERT INTO Categories (CategoryName)
VALUES 
	(N'Văn học - Tiểu thuyết lãng mạn'),
	(N'Văn học - Khoa học viễn tưởng'),
	(N'Văn học - Huyền bí'),
	(N'Văn học - Phiêu lưu'),
	(N'Văn học - Kinh dị'),
	(N'Văn học - Fantasy'),
	(N'Văn học - Lịch sử hư cấu'),
	(N'Văn học - Hài hước'),
	(N'Phi văn học - Tiểu sử và hồi ký'),
	(N'Phi văn học - Khoa học'),
	(N'Phi văn học - Lịch sử'),
	(N'Phi văn học - Tâm lý học'),
	(N'Phi văn học - Kinh tế học và kinh doanh'),
	(N'Phi văn học - Chính trị'),
	(N'Phi văn học - Sách hướng dẫn và tài liệu học tập'),
	(N'Chuyên môn - Y học'),
	(N'Chuyên môn - Công nghệ thông tin'),
	(N'Chuyên môn - Luật'),
	(N'Chuyên môn - Nghệ thuật & thiết kế'),
	(N'Chuyên môn - Kiến trúc'),
	(N'Phát triển bản thân - Quản lý thời gian'),
	(N'Phát triển bản thân - Kỹ năng sống'),
	(N'Phát triển bản thân - Lãnh đạo'),
	(N'Phát triển bản thân - Tài chính cá nhân'),
	(N'Phát triển bản thân - Tâm linh và triết học'),
	(N'Học thuật - Toán học'),
	(N'Học thuật - Vật lý'),
	(N'Học thuật - Văn học cổ điển'),
	(N'Học thuật - Xã hội học'),
	(N'Học thuật - Nhân học'),
	(N'Thiếu nhi - Truyện tranh'),
	(N'Thiếu nhi - Truyện cổ tích'),
	(N'Thiếu nhi - Sách tương tác'),
	(N'Đặc thù - Sách nấu ăn'),
	(N'Đặc thù - Sách du lịch'),
	(N'Đặc thù - Sách tôn giáo'),
	(N'Đặc thù - Sách thơ'),
	(N'Đặc thù - Sách nghệ thuật'),
	(N'Đặc thù - Sách ảnh');
Go

--trigger kiểm tra role = admin để ghi vào AditLogs
Create trigger trg_EnsureAdminRole
On AuditLogs
For insert
As Begin
	if exists (
		select 1
		From inserted i
		Join Users u on i.AdminID = u.UserID
		Where u.Role <> 'Admin'
	)
	Begin
		raiserror(N'Chỉ Admin có quyền log', 16, 1);
		Rollback;
	end
end;
Go

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
            FullName = i.FullName,
            Email = i.Email,
            Phone = i.Phone,
            Address = i.Address,
            Role = i.Role,
            CreatedDate = i.CreatedDate
		from Users u join inserted i on u.UserID = i.UserID
	end
end;
Go

--thủ tục đăng nhập cho user
create proc dbo.spUserLogin
	@Username nvarchar(50),
	@Password nvarchar(100)
as begin try
	if not exists (
		select 1 from Users
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
	select UserID, FullName, Email, Phone, Address, CreatedDate
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
		select 1 from Users
		Where Username = @Username
		--dùng bảo mật hashbytes để mã hoá password
			and PasswordHash = HASHBYTES('SHA2_256', @Password)
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
	select UserID, Username, FullName, Email, Phone, Address, Role, LastLogin, CreatedDate
		from Users
		Where Username = @Username;
	end try
	Begin catch
--xử lý lỗi
		declare @error nvarchar(1000) = error_message();
		Raiserror(@error, 16, 1);
	end catch
go

--thủ tục đăng ký User
Create proc dbo.spRegisterUser
	@Username nvarchar(50),
	@Password nvarchar(100),
	@Fullname nvarchar(100),
	@Email nvarchar(100)
as begin try
	if exists (
		select 1 from Users where Username = @Username
	)
	Begin
		raiserror (N'Tên đăng nhập đã tồn tại. Vui lòng chọn tên đăng nhập khác.', 16, 1);
		Return;
	end
	If exists (
		select 1 from Users where Email = @Email
	)
	Begin
		raiserror (N'Mail đã tồn tại. Vui lòng chọn Mail khác.', 16, 1);
		Return;
	end
	insert into Users (Username, PasswordHash, FullName, Email, Role, UserStatus, CreatedDate)
	values (
		@Username,
		HASHBYTES('HSA2_256', @Password),
		@Fullname,
		@Email,
		'User',
		1,
		GETDATE()
	);
	Print 'Tài khoản đã được đăng ký thành công.';
end try
Begin catch
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--cập nhật thông tin cho User
Create proc dbo.spUpdateUser
	@UserID INT,
    @FullName NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20),
    @Address NVARCHAR(200)
as begin try
	if not exists (
		select 1 from Users where UserID = @UserID
	)
	Begin
		raiserror (N'Tài khoản không tồn tại.', 16, 1);
		Return;
	end
	If exists (
		select 1 from Users 
		Where Email = @Email and UserID <> @UserID
	)
	Begin
		Raiserror (N'Email đã được sử dụng bởi người dùng khác.', 16, 1);
		Return;
	end
	Update Users
	Set Fullname = @FullName,
		Email = @Email,
		Phone = @Phone,
		Address = @Address
	where UserID = @UserID;
	Print 'Thông tin cá nhân đã được cập nhật thành công.';
	End try
	Begin catch
		DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--thủ tục thêm sách mới
Create proc dbo.spAddBook
	@Title NVARCHAR(200),
    @Author NVARCHAR(100),
    @Publisher NVARCHAR(100),
    @Category NVARCHAR(100),
    @Price int,
    @Description NVARCHAR(MAX),
    @CoverImage NVARCHAR(200) -- Đường dẫn hình ảnh
as begin try
	if exists (
		select 1 from Books
		Where Title = @Title
	)
	BEGIN
        RAISERROR (N'Sách này đã tồn tại trong hệ thống.', 16, 1);
        RETURN;
    END
	INSERT INTO Books (Title, Author, Publisher, Category, Price, Description, CoverImage, CreatedDate, IsActive)
    VALUES (@Title, @Author, @Publisher, @Category, @Price, @Description, @CoverImage, GETDATE(), 1);
	PRINT 'Sách đã được thêm thành công.';
end try
Begin catch
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--thủ tục cập nhật giá của sách
Create proc dbo.spUpdatePriceBook
	@BookID int,
	@Price int
as begin try
	if not exists (
		select 1 from Books where BookID = @BookID and IsActive = 1
	)
	Begin
		raiserror (N'Sách không tồn tại hoặc đã bị xóa.', 16, 1);
        RETURN;
	end
	Update Books
	Set Price = @Price
	where BookID = @BookID;
	Print 'Giá sách đã được cập nhật thành công.';
end try
Begin catch
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--thủ tục cập nhật số lượng bán sách
Create proc dbo.spUpdateSoldQuantity
	@BookID int
as begin try
	if not exists (
		select 1 from Books
		Where BookID = @BookID and IsActive = 1
	)
	begin 
		raiserror (N'Sách không tồn tại hoặc đã bị ẩn.', 16, 1);
		Return;
	end
	Update Books
	Set SoldQuantity = SoldQuantity + 1
	Where BookID = @BookID;
	Print 'Đã cập nhật số lượng đã bán thành công.';
end try
Begin catch
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--thủ tục xoá mềm sách (ẩn không mất)
Create proc dbo.spSoftDeleteBook
	@BookID int
as begin try
	if not exists (
		select 1 from Books where BookID = @BookID and IsActive = 1
	)
	Begin
		raiserror (N'Sách không tồn tại hoặc đã bị xóa.', 16, 1);
		Return;
	end
	Update Books
	Set IsActive = 0
	Where BookID = @BookID;
	Print 'Sách đã được xoá thành công.';
end try
Begin catch
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--thủ tục khôi phục lại những cuốn sách bị ẩn đi
CREATE PROC dbo.spRestoreBook
    @BookID INT
AS BEGIN TRY
    IF NOT EXISTS (
        SELECT 1 
        FROM Books 
        WHERE BookID = @BookID AND IsActive = 0
    )
    BEGIN
        RAISERROR (N'Sách không tồn tại hoặc chưa bị xóa.', 16, 1);
        RETURN;
    END
    UPDATE Books
    SET IsActive = 1
    WHERE BookID = @BookID;

    PRINT 'Sách đã được khôi phục thành công.';
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--thủ tục xuất danh sách thể loại theo danh mục lớn
Create proc dbo.spGetCategoriesByMainCategory
as begin try
	select
		MainCategory as [Danh mục lớn],
		STRING_AGG(CategoryName, ', ') within group (order by CategoryName) as [Thể loại]
	from Categories
	Group by MainCategory order by MainCategory
	For json path, include_null_values; --trả về dưới định dang json
end try
begin catch
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--thủ tục hiện sách ra màn hình
Create proc dbo.spGetBooks
As begin try
	select BookID,
		title as [Tên sách],
		CoverImage as [Ảnh bìa],
		FORMAT(Price, 'N0') as [Giá bán],
		SoldQuantity AS [Đã bán]
	From Books
	Where IsActive = 1
	Order by SoldQuantity;
end try
Begin catch
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO

--thủ tục xuất thông tin chi tiết của một cuốn sách
Create proc dbo.spGetBookDetails
	@BookID int
as begin try
	select BookID,
		Title AS [Tên sách],
        Author AS [Tác giả],
        Publisher AS [Nhà xuất bản],
        Category AS [Thể loại],
		FORMAT(Price, 'N0') AS [Giá bán],
		Description AS [Mô tả]
	from Books
	where BookID = @BookID and IsActive = 1;
	If @@ROWCOUNT = 0
	Begin
		raiserror (N'Không tìm thấy sách hoặc sách không còn hoạt động.', 16, 1);
		Return;
	end
end try
Begin catch
	DECLARE @ErrorMessage NVARCHAR(1000) = ERROR_MESSAGE();
    RAISERROR (@ErrorMessage, 16, 1);
END CATCH;
GO