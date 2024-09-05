USE MASTER
GO 
DROP DATABASE QLPHONGKHAM
GO
CREATE DATABASE QLPHONGKHAM;
GO


USE QLPHONGKHAM
GO

CREATE TABLE KHACHHANG(
	Sdt VARCHAR(11),
	HoTen NVARCHAR(50),
	NgaySinh DATE,
	DiaChi NVARCHAR(200),
	

	CONSTRAINT PK_KHACHHANG PRIMARY KEY(Sdt)
)

CREATE TABLE KHACHHANGCOTAIKHOAN(
	TenDangNhap VARCHAR(11),
	MatKhau VARCHAR(20),

	CONSTRAINT PK_KHACHHANGCOTAIKHOAN PRIMARY KEY (TenDangNhap),

	CONSTRAINT FK_KHACHHANGCOTAIKHOAN_KHACHHANG FOREIGN KEY (TenDangNhap) REFERENCES KHACHHANG(Sdt)
)

CREATE TABLE NHASI(
	MaNhaSi VARCHAR(10),
	HoTen NVARCHAR(50),
	NgaySinh DATE,
	DiaChi NVARCHAR(200),
	Sdt VARCHAR(11),
	MatKhau VARCHAR(20),

	CONSTRAINT PK_NHASI PRIMARY KEY(MaNhaSi)
)

CREATE TABLE LICHTRUC(
	Ngay DATE,
	ThuTuCa INT,
	GioBatDau TIME,
	GioKetThuc TIME,

	CONSTRAINT PK_LICHTRUC PRIMARY KEY(Ngay,ThuTuCa)
)

CREATE TABLE LICHCANHAN(
	MaNhaSi VARCHAR(10),
	Ngay DATE,
	ThuTuCa INT,
	TrangThai NVARCHAR(20),

	CONSTRAINT PK_LICHCANHAN PRIMARY KEY(MaNhaSi,Ngay,ThuTuCa),

	CONSTRAINT FK_LICHCANHAN_NHASI FOREIGN KEY (MaNhaSi) REFERENCES NHASI(MaNhaSi),
	CONSTRAINT FK_LICHCANHAN_LICHTRUC FOREIGN KEY (Ngay,ThuTuCa) REFERENCES LICHTRUC(Ngay,ThuTuCa)

)

CREATE TABLE PHIEUHEN(
	MaPhieu VARCHAR(10),
	NhaSiKham VARCHAR(10),
	Ngay DATE,
	ThuTuCa INT,
	SdtKhachHang VARCHAR(11),

	CONSTRAINT PK_PHIEUHEN PRIMARY KEY(MaPhieu),

	CONSTRAINT FK_PHIEUHEN_KHACHHANG FOREIGN KEY (SdtKhachHang) REFERENCES KHACHHANG(Sdt),
	--CONSTRAINT FK_PHIEUHEN_NHASI FOREIGN KEY (NhaSiKham) REFERENCES NHASI(MaNhaSi),
	--CONSTRAINT FK_PHIEUHEN_LICHTRUC FOREIGN KEY (Ngay,ThuTuCa) REFERENCES LICHTRUC(Ngay,ThuTuCa),
	CONSTRAINT FK_PHIEUHEN_LICHCANHAN FOREIGN KEY (NhaSiKham,Ngay,ThuTuCa) REFERENCES LICHCANHAN(MaNhaSi,Ngay,ThuTuCa)

)

CREATE TABLE BENHAN(
	SdtKhachHang VARCHAR(11),
	MaBenhAn varchar(10),
	MaPhieuHen varchar(10),
	

	CONSTRAINT PK_BENHAN PRIMARY KEY(SdtKhachHang, MaBenhAn),

	CONSTRAINT FK_BENHAN_KHACHHANG FOREIGN KEY (SdtKhachHang) REFERENCES KHACHHANG(Sdt),
	CONSTRAINT FK_BENHAN_PHIEUHEN FOREIGN KEY (MaPhieuHen) REFERENCES PHIEUHEN(MaPhieu)
)

CREATE TABLE THUOC(
	MaThuoc VARCHAR(10),
	TenThuoc NVARCHAR(50),
	DonViTinh VARCHAR(20),
	ChiDinh NVARCHAR(200),
	SoLuongTonKho INT check(SoLuongTonKho >= 0), 
	NgayHetHan DATE,

	CONSTRAINT PK_THUOC PRIMARY KEY(MaThuoc)
)

CREATE TABLE CHITIETDONTHUOC(
	MaThuoc VARCHAR(10),
	SdtKhachHang VARCHAR(11),
	MaBenhAn varchar(10),
	SoLuong INT check (SoLuong > 0),

	CONSTRAINT PK_CHITIETDONTHUOC PRIMARY KEY(MaThuoc,SdtKhachHang,MaBenhAn),

	CONSTRAINT FK_CHITIETDONTHUOC_THUOC FOREIGN KEY (MaThuoc) REFERENCES THUOC(MaThuoc),
	--CONSTRAINT FK_CHITIETDONTHUOC_KHACHHANG FOREIGN KEY (SdtKhachHang) REFERENCES KHACHHANG(Sdt),
	CONSTRAINT FK_CHITIETDONTHUOC_BENHAN FOREIGN KEY (SdtKhachHang,MaBenhAn) REFERENCES BENHAN(SdtKhachHang,MaBenhAn)
)

CREATE TABLE DICHVU(
	MaDichVu VARCHAR(10),
	TenDichVu NVARCHAR(50),
	PhiDichVu FLOAT,

	CONSTRAINT PK_DICHVU PRIMARY KEY(MaDichVu)
)

CREATE TABLE CHITIETDICHVU(
	MaDichVu VARCHAR(10),
	SdtKhachHang VARCHAR(11),
	MaBenhAn varchar(10),

	CONSTRAINT PK_CHITIETDICHVU PRIMARY KEY(MaDichVu,SdtKhachHang,MaBenhAn),

	CONSTRAINT FK_CHITIETDICHVU_DICHVU FOREIGN KEY (MaDichVu) REFERENCES DICHVU(MaDichVu),
	--CONSTRAINT FK_CHITIETDICHVU_KHACHHANG FOREIGN KEY (SdtKhachHang) REFERENCES KHACHHANG(Sdt),
	CONSTRAINT FK_CHITIETDICHVU_BENHAN FOREIGN KEY (SdtKhachHang,MaBenhAn) REFERENCES BENHAN(SdtKhachHang,MaBenhAn)


)

CREATE TABLE HOADON(
	MaHoaDon VARCHAR(10),
	MaBenhAn varchar(10),
	SdtKhachHang VARCHAR(11),
	TongTien FLOAT,

	CONSTRAINT PK_HOADON PRIMARY KEY(MaHoaDon),

	--CONSTRAINT FK_HOADON_KHACHHANG FOREIGN KEY (SdtKhachHang) REFERENCES KHACHHANG(Sdt),
	CONSTRAINT FK_HOADON_BENHAN FOREIGN KEY (SdtKhachHang,MaBenhAn) REFERENCES BENHAN(SdtKhachHang,MaBenhAn)

)

CREATE TABLE NHANVIEN(
	MaNhanVien VARCHAR(10),
	HoTen NVARCHAR(50),
	NgaySinh DATE,
	DiaChi NVARCHAR(200),
	Sdt VARCHAR(11),
	MatKhau VARCHAR(20),

	CONSTRAINT PK_NHANVIEN PRIMARY KEY(MaNhanVien)
)


/* Tong tien hoa don = Phi dich vu trong benh an */
go
create or alter trigger trgHoaDon
on HOADON
for insert,update
as
begin
	UPDATE HOADON
	set TongTien = (
		select Phi from inserted i, BENHAN ba, (select SdtKhachHang,MaBenhAn,sum(PhiDichVu) as Phi from CHITIETDICHVU ctdv, DICHVU dv
					where ctdv.MaDichVu= dv.MaDichVu
					group by SdtKhachHang,MaBenhAn) dv_ct  
		where i.MaBenhAn = ba.MaBenhAn and i.SdtKhachHang = ba.SdtKhachHang
		and ba.MaBenhAn = dv_ct.MaBenhAn and dv_ct.SdtKhachHang = ba.SdtKhachHang
	)
end

/*	Ngày khám của bệnh án phải có trong lịch cá nhân có trạng thái bận 
và bác sĩ phụ trách phải khớp với lịch cá nhân đó	
*/


/*	Trong lịch trực giờ bắt đầu phải sau giờ kết thúc */
go
create or alter trigger trgGioBD_GioKT
on LICHTRUC
for insert,update
as
begin
	if exists (
		select * from inserted i where i.GioBatDau >= i.GioKetThuc
	)
	begin
		raiserror(N'Giờ bắt đầu phải trước giờ kết thúc',16,1);
		rollback
	end
end

/* Bác sĩ và nhân viên phải trên 18 tuổi */
go
create or alter trigger trgTuoiBacSi
on NHASI
for insert,update
as
begin
	if exists (
		select * from inserted i where datediff(year,i.NgaySinh,GETDATE()) < 18
	)
	begin
		raiserror(N'Bác sĩ phải đủ 18 tuổi trở lên',15,1)
		rollback
	end
end

go
create or alter trigger trgTuoiNhanVien
on NHANVIEN
for insert,update
as
begin
	if exists (
		select * from inserted i where datediff(year,i.NgaySinh,GETDATE()) < 18
	)
	begin
		raiserror(N'Nhân viên phải đủ 18 tuổi trở lên',15,1)
		rollback
	end
end

/* Số điện thoại phải có 10 chữ số */
go
create or alter trigger trgSoDienThoai
on KHACHHANG
for insert,update
as
begin
	if exists (
		select * from inserted i where len(i.Sdt) <> 10
	)
	begin
		raiserror(N'Số điện thoại phải có 10 chữ số',15,1)
		rollback
	end
end

/*	1 lịch cá nhân chỉ được hẹn với một lịch hẹn	 */
/* Khi lịch cá nhân được hẹn thì trạng thái chuyển sang bận */
/* Khách hàng không được hẹn lịch cá nhân đang trong trạng thái bận */
go
create or alter trigger trgThemPhieuHen
on PHIEUHEN
after INSERT
as
begin
	if not exists (
		select * from LICHCANHAN lcn, inserted i 
		where lcn.MaNhaSi=i.NhaSiKham and lcn.Ngay = i.Ngay and lcn.ThuTuCa = i.ThuTuCa and lcn.TrangThai =N'Bận'
	)
	begin
		UPDATE LICHCANHAN
		set TrangThai = N'Bận'
		from LICHCANHAN lcn, inserted i
		where lcn.MaNhaSi=i.NhaSiKham and lcn.Ngay = i.Ngay and lcn.ThuTuCa = i.ThuTuCa
	end
end

go
create or alter trigger trgXoaPhieuHen
on PHIEUHEN
for delete
as
begin
	UPDATE LICHCANHAN
	SET TrangThai = N'Rảnh'
	from LICHCANHAN lcn, deleted d
	where lcn.MaNhaSi = d.NhaSiKham and lcn.Ngay = d.Ngay and lcn.ThuTuCa = d.ThuTuCa
end

go
create or alter trigger trgSuaPhieuHen
on PHIEUHEN
after UPDATE
as
begin
	UPDATE LICHCANHAN
	set TrangThai = N'Bận'
	from LICHCANHAN lcn, inserted i
	where lcn.MaNhaSi=i.NhaSiKham and lcn.Ngay = i.Ngay and lcn.ThuTuCa = i.ThuTuCa
	UPDATE LICHCANHAN
	SET TrangThai = N'Rảnh'
	from LICHCANHAN lcn, deleted d
	where lcn.MaNhaSi = d.NhaSiKham and lcn.Ngay = d.Ngay and lcn.ThuTuCa = d.ThuTuCa
end

-- *****************************************  PHÂN QUYỀN NHA SĨ  ********************************************

GO
EXEC sp_addrole 'NhaSi'

-- Quản lí tài khoản nha sĩ
GO
GRANT SELECT,UPDATE ON NHASI TO NhaSi

-- Quản lí lịch hẹn của nha sĩ
-- Nha sĩ có thể xem lịch hẹn, có thể thêm xóa sửa các lịch hẹn cá nhân.
GO
GRANT SELECT,INSERT,UPDATE,DELETE ON LICHCANHAN to NhaSi

GO
GRANT SELECT ON LICHTRUC TO NhaSi

-- Quản lí hồ sơ bệnh nhân
GO
GRANT SELECT,INSERT,UPDATE,DELETE ON BENHAN TO NhaSi

GO
GRANT SELECT,INSERT,DELETE,UPDATE ON CHITIETDONTHUOC TO NhaSi

GO
GRANT SELECT,INSERT,DELETE,UPDATE ON CHITIETDICHVU TO NhaSi

GO
GRANT SELECT ON THUOC TO NhaSi

GO
GRANT SELECT ON DICHVU TO NhaSi

GO
GRANT SELECT ON KHACHHANG TO NhaSi

GO
GRANT SELECT ON PHIEUHEN TO NhaSi

--EXEC sp_addlogin 'user','1000','QLPhongKham'
--EXEC sp_grantdbaccess 'user', 'user'
--EXEC sp_addrolemember 'NhaSi', 'user'

--EXEC sp_droprolemember 'NhaSi', 'user'
--EXEC sp_droprole 'NhaSi'
--EXEC sp_revokedbaccess 'user'
--EXEC sp_droplogin 'user'

--*****************************************************   PHÂN QUYỀN KHÁCH HÀNG   *********************************************************--
go
Exec sp_addrole 'KhachHang'

go
Grant select, update on KHACHHANG to KhachHang

go
Grant select, update on KHACHHANGCOTAIKHOAN to KhachHang

go
grant select on BENHAN to KhachHang

go
grant insert on PHIEUHEN to KhachHang


--Exec sp_addlogin 'tam','1000','QLPhongKham'
--Exec sp_grantdbaccess 'tam', 'tam'
--EXEC sp_addrolemember 'KhachHang', 'tam';

--EXEC sp_droprolemember 'KhachHang', 'tam';
--EXEC sp_droprole 'KhachHang';
--Exec sp_revokedbaccess 'tam'
--exec sp_droplogin 'tam'

--*****************************************************   PHÂN QUYỀN NHÂN VIÊN   *********************************************************--
go

Exec sp_addrole 'NhanVien'
go

-- tiếp nhận khách hàng
Grant select, update, insert on KHACHHANG to NhanVien
go

Grant select, update, insert on KHACHHANGCOTAIKHOAN to NhanVien
go
-- thêm xóa sửa lịch hẹn
Grant select, update, insert, delete on PHIEUHEN to NhanVien
GO
grant select on LICHCANHAN to NhanVien
go

-- LẬP HÓA ĐƠN
GRANT SELECT, INSERT ON HOADON TO NhanVien
go
grant select on CHITIETDONTHUOC to NhanVien
go
grant select on CHITIETDICHVU to NhanVien
go


--EXEC sp_addlogin 'user','1000','QLPhongKham'
--EXEC sp_grantdbaccess 'user', 'user'
--EXEC sp_addrolemember 'NhanVien', 'user'

--EXEC sp_droprolemember 'NhanVien', 'user'
--EXEC sp_droprole 'NhanVien'
--EXEC sp_revokedbaccess 'user'
--EXEC sp_droplogin 'user'

--*****************************************************   PHÂN QUYỀN QUẢN TRỊ VIÊN   *********************************************************--
go
exec sp_addrole 'QuanTriVien'

go
grant alter any user to QuanTriVien
grant alter on role::NhaSi to QuanTriVien
grant alter on role::NhanVien to QuanTriVien

go
grant insert, update, delete, select ON THUOC to QuanTriVien
grant insert, update, delete, select on NHANVIEN to QuanTriVien
grant insert, update, delete, select on NHASI to QuanTriVien

go
use master
go
sp_addLogin 'loginQTV', '1'
grant alter any login to loginQTV

go
use QLPHONGKHAM
create User userQTV for Login loginQTV with Default_Schema = QLPHONGKHAM

go
exec sp_addrolemember 'QuanTriVien','userQTV'

--exec sp_addlogin 'loginNhasi','1'

--go
--use QLPHONGKHAM
--create User userNhaSi for Login loginNhaSi with Default_Schema = QLPHONGKHAM
--exec sp_addrolemember 'NhaSi','userNha'

--alter login loginNhaSi disable


--********************** [ THÊM CÁC LOGIN ĐỂ TEST] *********************
--[KHÁCH HÀNG]
Exec sp_addlogin 'customer1','1000','QLPHONGKHAM'
Exec sp_grantdbaccess 'customer1', 'customer1'
EXEC sp_addrolemember 'KhachHang', 'customer1';

--[NHA SĨ]
Exec sp_addlogin '1000','1','QLPHONGKHAM'
Exec sp_grantdbaccess '1000', '1000'
EXEC sp_addrolemember 'NhaSi', '1000';

--[NHÂN VIÊN]
Exec sp_addlogin 'staff1','1000','QLPHONGKHAM'
Exec sp_grantdbaccess 'staff1', 'staff1'
EXEC sp_addrolemember 'NhanVien', 'staff1';

--[QUẢN TRỊ VIÊN]
Exec sp_addlogin 'QTV1','1','QLPHONGKHAM'
Exec sp_grantdbaccess 'QTV1', 'QTV1'
EXEC sp_addrolemember 'QuanTriVien', 'QTV1';

Exec sp_addlogin 'QTV2','1','QLPHONGKHAM'
Exec sp_grantdbaccess 'QTV2', 'QTV2'
EXEC sp_addrolemember 'QuanTriVien', 'QTV2';

--*************************** [ CHẠY PROC ] **************************
-- Tâm
GO
CREATE OR ALTER PROC sp_ThemLichHen
	@MaPhieu VARCHAR(10),
	@NhaSiKham VARCHAR(10),
	@Ngay DATE,
	@ThuTuCa INT,
	@SdtKhachHang VARCHAR(11)
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
	BEGIN TRY
		DECLARE @TempLichCaNhan TABLE (
			MaNhaSi VARCHAR(10),
			Ngay DATE,
			ThuTuCa INT,
			TrangThai NVARCHAR(20)
		);
		INSERT INTO @TempLichCaNhan
		SELECT* FROM LICHCANHAN WHERE MaNhaSi=@NhaSiKham AND Ngay=@Ngay AND THUTUCA=@ThuTuCa
		INSERT INTO PHIEUHEN VALUES (@MaPhieu,@NhaSiKham,@Ngay,@ThuTuCa,@SdtKhachHang)
		WAITFOR DELAY '00:00:05'
		IF EXISTS (SELECT * FROM @TempLichCaNhan WHERE TrangThai = N'Bận')
		BEGIN
			--RAISERROR(N'LỊCH CỦA NHA SĨ NÀY ĐÃ BẬN, VUI LÒNG CHỌN LỊCH KHÁC',16,1)
			PRINT(N'LỊCH CỦA NHA SĨ NÀY ĐÃ BẬN, VUI LÒNG CHỌN LỊCH KHÁC')
			ROLLBACK TRAN
			RETURN 1
		END
	END TRY
		
	BEGIN CATCH
		RAISERROR(N'LỖI HỆ THỐNG',16,1)
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0

GO
GRANT EXEC ON dbo.sp_ThemLichHen TO NhanVien

GO
CREATE OR ALTER PROC sp_XemLichHen
	@MaNhaSi VARCHAR(10),
	@Ngay DATE
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
	BEGIN TRY
		IF (NOT EXISTS (SELECT*FROM NHASI WHERE MaNhaSi=@MaNhaSi))
		BEGIN
			PRINT(N'NHA SĨ KHÔNG TỒN TẠI')
			ROLLBACK TRAN
			RETURN 1
		END

		IF (NOT EXISTS (SELECT*FROM PHIEUHEN WHERE NhaSiKham=@MaNhaSi AND Ngay=@Ngay))
		BEGIN
			PRINT(N'NHA SĨ KHÔNG CÓ LỊCH HẸN TRONG NGÀY' + cast(@Ngay as VARCHAR))
			ROLLBACK TRAN
			RETURN 1
		END
		SELECT * FROM PHIEUHEN WHERE NhaSiKham=@MaNhaSi AND Ngay=@Ngay 
	END TRY
		
	BEGIN CATCH
		RAISERROR(N'LỖI HỆ THỐNG',16,1)
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0

GO
GRANT EXEC ON dbo.sp_XemLichHen TO NhaSi

--PROC này để hỗ trợ thêm dữ liệu vào bảng để thực hiện 2 proc trên
GO
CREATE OR ALTER PROC sp_ThemDuLieu
AS
BEGIN TRAN
	BEGIN TRY
		INSERT INTO LICHTRUC VALUES ('2023-11-21',1,'08:00:00', '09:00:00')
		INSERT INTO NHASI VALUES ('1000',N'Nguyễn Văn A','2003-12-12',N'Long An','0987654321','1000')
		INSERT INTO LICHCANHAN VALUES ('1000','2023-11-21',1,N'Rảnh')

		INSERT INTO KHACHHANG VALUES ('0123654987',N'Nguyễn Thị B','2003-11-06',N'Đà Nẵng')
		INSERT INTO KHACHHANG VALUES ('0123456789',N'Phạm Ngọc Hân','2004-10-06',N'TPHCM')
		INSERT INTO LICHTRUC VALUES ('2023-11-20',1,'08:00:00', '09:00:00')
		INSERT INTO LICHCANHAN VALUES ('1000','2023-11-20',1,N'Bận')
		INSERT INTO PHIEUHEN VALUES ('1000','1000','2023-11-20',1,'0123456789')

		INSERT INTO BENHAN VALUES ('0123654987','BA14',NULL)
		INSERT INTO BENHAN VALUES ('0123456789','BA15',NULL)
	END TRY
		
	BEGIN CATCH
		RAISERROR(N'LỖI HỆ THỐNG HOẶC ĐÃ TỒN TẠI DỮ LIỆU CẦN THÊM, KHÔNG CẦN THÊM LẠI',16,1)
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0

go
exec sp_ThemDuLieu

GO
CREATE OR ALTER PROC sp_ThemLichHen_Fix
	@MaPhieu VARCHAR(10),
	@NhaSiKham VARCHAR(10),
	@Ngay DATE,
	@ThuTuCa INT,
	@SdtKhachHang VARCHAR(11)

AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
	BEGIN TRY
		DECLARE @TempLichCaNhan TABLE (
			MaNhaSi VARCHAR(10),
			Ngay DATE,
			ThuTuCa INT,
			TrangThai NVARCHAR(20)
		);
		INSERT INTO @TempLichCaNhan
		SELECT* FROM LICHCANHAN WHERE MaNhaSi=@NhaSiKham AND Ngay=@Ngay AND THUTUCA=@ThuTuCa
		INSERT INTO PHIEUHEN VALUES (@MaPhieu,@NhaSiKham,@Ngay,@ThuTuCa,@SdtKhachHang)
		WAITFOR DELAY '00:00:05'		
		IF EXISTS (SELECT * FROM @TempLichCaNhan WHERE TrangThai = N'Bận')
		BEGIN
			--RAISERROR(N'LỊCH CỦA NHA SĨ NÀY ĐÃ BẬN, VUI LÒNG CHỌN LỊCH KHÁC',16,1)
			PRINT(N'LỊCH CỦA NHA SĨ NÀY ĐÃ BẬN, VUI LÒNG CHỌN LỊCH KHÁC')
			ROLLBACK TRAN
			RETURN 1
		END
	END TRY

	BEGIN CATCH
		RAISERROR(N'LỖI HỆ THỐNG',16,1)
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0

GO
GRANT EXEC ON dbo.sp_ThemLichHen_Fix TO NhanVien

GO
CREATE OR ALTER PROC sp_XemLichHen_Fix
	@MaNhaSi VARCHAR(10),
	@Ngay DATE
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
	BEGIN TRY
		IF (NOT EXISTS (SELECT*FROM NHASI WHERE MaNhaSi=@MaNhaSi))
		BEGIN
			PRINT(N'NHA SĨ KHÔNG TỒN TẠI')
			ROLLBACK TRAN
			RETURN 1
		END

		IF (NOT EXISTS (SELECT*FROM PHIEUHEN WHERE NhaSiKham=@MaNhaSi AND Ngay=@Ngay))
		BEGIN
			PRINT(N'NHA SĨ KHÔNG CÓ LỊCH HẸN TRONG NGÀY' + cast(@Ngay as VARCHAR))
			ROLLBACK TRAN
			RETURN 1
		END
		SELECT * FROM PHIEUHEN WHERE NhaSiKham=@MaNhaSi AND Ngay=@Ngay 
	END TRY
		
	BEGIN CATCH
		RAISERROR(N'LỖI HỆ THỐNG',16,1)
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0

GO
GRANT EXEC ON dbo.sp_XemLichHen_Fix TO NhaSi
GO
-- Trung
create or alter proc sp_Insert_CTDT
@MaThuoc varchar(10),
@sdt varchar(11),
@MaBA varchar(10),
@soluong int
as
begin tran 
	begin try 
	if exists(	select * 
				from CHITIETDONTHUOC 
				where MaThuoc = @MaThuoc and MaBenhAn = @MaBA and SdtKhachHang = @sdt)
	begin 
		print N'Chi tiết đơn thuốc đã tồn tại - Thuốc đã được kê trong bệnh án ' + @MaBA + N' của khách hàng có số điện thoại ' + @sdt
		rollback tran
		return 1
	end
	if not exists (select * from KHACHHANG where Sdt = @sdt)
	begin 
		print N'Không tồn tại khách hàng có số điện thoại: ' + @sdt
		rollback tran
		return 1
	end
	if not exists (select * from BENHAN where MaBenhAn = @MaBA and SdtKhachHang = @sdt)
	begin 
		print N'Bệnh án không tồn tại.'
		rollback tran
		return 1
	end
	if @soluong > (select soluongtonkho from THUOC where MaThuoc = @MaThuoc)
	begin
		print N'Không còn đủ thuốc ' + @Mathuoc + N' để thực hiện kê đơn.'
		rollback tran
		return 1
	end
	----
	----------------------thêm chi tiết đơn thuốc-----------------------------------------
	declare @soluongthuoc int = (select SoLuongTonKho from THUOC where MaThuoc = @MaThuoc)
	set @soluongthuoc = @soluongthuoc - @soluong
	--------------------------------------------------------------------------------------
	waitfor delay '00:00:05'
	--------------------------------------------------------------------------------------
	update THUOC
	set SoLuongTonKho = @soluongthuoc
	where MaThuoc = @MaThuoc

	insert into CHITIETDONTHUOC 
	values (@MaThuoc, @sdt, @MaBA, @soluong)

	end try
	begin catch
	print N'Lỗi hệ thống'
	rollback tran
	return 1
	end catch

commit tran
return 0
go

create or alter proc Update_SoLuongThuoc
@MaThuoc varchar(10),
@soluongcapnhat int
as
begin tran 
	begin try
	if not exists (select * from THUOC where MaThuoc = @MaThuoc)
	begin 
		print cast(N'Không tồn tại thuốc có mã: ' + @MaThuoc as nvarchar(10))
		rollback tran
		return 1
	end
	if @soluongcapnhat = 0
	begin 
		print N'Số lượng cập nhật phải khác 0'
		rollback tran
		return 1
	end
	if (select SoLuongTonKho from THUOC where MaThuoc = @MaThuoc)-@soluongcapnhat < 0
	begin 
		print N'Số lượng tồn kho sau khi cập nhật số lượng không được âm'
		rollback tran 
		return 1
	end
	----------------------thực hiện cập nhật----------------
	declare @soluongthuoc int = (select SoLuongTonKho from THUOC where MaThuoc = @MaThuoc)
	set @soluongthuoc = @soluongthuoc + @soluongcapnhat

	Update THUOC
	set SoLuongTonKho = @soluongthuoc
	where MaThuoc = @MaThuoc
	--------------------------------------------------------
	end try
	begin catch
		print N'Lỗi hệ thống'
		Rollback tran
		return 1
	end catch
commit tran
return 0
go

create or alter proc sp_Insert_LichHen
@Ma varchar(10),
@Nhasi varchar(10),
@Ngay date,
@Ca int,
@sdt varchar(11)
as
begin tran
	begin try
	if exists (select * from PHIEUHEN where MaPhieu = @Ma)
	begin
		print N'Đã tồn tại phiếu hẹn có mã: ' + @Ma 
		rollback tran
		return 1
	end
	
	if not exists (	select * 
					from LICHCANHAN 
					where Ngay = @Ngay and ThuTuCa = @Ca and MaNhaSi = @Nhasi and TrangThai <> N'Bận')
	begin 
		Print N'Lịch hẹn không hợp lệ với lịch cá nhân của nha sĩ'
		rollback tran
		return 1
	end
	if exists (select * from PHIEUHEN where Ngay = @Ngay and ThuTuCa = @Ca and NhaSiKham = @Nhasi)
		begin
			print N'Buổi làm việc này đã được một khách hàng khác đăng kí hẹn.'
			rollback tran 
			return 1
		end
	if not exists (select * from KHACHHANG where Sdt = @sdt)
	begin 
		print N'Không tồn tại khách hàng có số điện thoại ' + @sdt
		rollback tran 
		return 1
	end
	-- Test 
	waitfor delay '00:00:05'
	---------------------tiến hành đặt lịch hẹn------------------------------
	insert into PHIEUHEN
	values ( @Ma, @Nhasi, @Ngay, @Ca, @sdt)

	update LICHCANHAN 
	set TrangThai = N'Bận'
	where Ngay = @Ngay and ThuTuCa = @Ca and MaNhaSi = @Nhasi
	-------------------------------------------------------------------------

	end try
	begin catch
		print N'Lỗi hệ thống'
		rollback tran
		return 1
	end catch
commit tran
return 0
go

create or alter proc sp_Insert_LichCaNhan
@MaNhaSi varchar(10),
@Ngay date,
@Ca int
as
begin tran
	SET TRAN ISOLATION LEVEL REPEATABLE READ
	begin try
	------------------------điều kiện vi phạm---------------------------
	if exists (	select *
				from LICHCANHAN 
				where MaNhaSi = @MaNhaSi and Ngay = @Ngay and ThuTuCa = @ca)
	begin
		print N'Lịch cá nhân đã tồn tại.'
		rollback tran
		return 1
	end
	if not exists ( select *
				from NHASI
				where MaNhaSi = @MaNhaSi)
	begin 
		print N'Không tồn tại nha sĩ có mã: ' + @manhasi
		rollback tran 
		return 1
	end
	if not exists ( select *
				from LICHTRUC
				where Ngay = @Ngay and ThuTuCa = @Ca)
	begin 
		print N'Lịch trực không tồn tại'
		rollback tran
		return 1
	end

	-----------------------------------------------------------------
	------------tiến hành thêm lịch cá nhân------------------
	insert into LICHCANHAN
	values( @MaNhaSi, @Ngay, @Ca, N'Rảnh')
	---------------------------------------------------------
	end try
	begin catch
	print N'Lỗi hệ thống.'
	rollback tran 
	return 1
	end catch

commit tran 
return 0
go

-------------Xử lí tranh chấp:--------------------
create or alter proc sp_Insert_CTDT_fix
@MaThuoc varchar(10),
@sdt varchar(11),
@MaBA varchar(10),
@soluong int
as
begin tran 
	begin try 
	if exists(	select * 
				from CHITIETDONTHUOC 
				where MaThuoc = @MaThuoc and MaBenhAn = @MaBA and SdtKhachHang = @sdt)
	begin 
		print N'Chi tiết đơn thuốc đã tồn tại - Thuốc đã được kê trong bệnh án ' + @MaBA + N' của khách hàng có số điện thoại ' + @sdt
		rollback tran
		return 1
	end
	if not exists (select * from KHACHHANG where Sdt = @sdt)
	begin 
		print N'Không tồn tại khách hàng có số điện thoại: ' + @sdt
		rollback tran
		return 1
	end
	if not exists (select * from BENHAN where MaBenhAn = @MaBA and SdtKhachHang = @sdt)
	begin 
		print N'Bệnh án không tồn tại.'
		rollback tran
		return 1
	end
	if @soluong > (select soluongtonkho from THUOC where MaThuoc = @MaThuoc)
	begin
		print N'Không còn đủ thuốc ' + @Mathuoc + N' để thực hiện kê đơn.'
		rollback tran
		return 1
	end
	----
	----------------------thêm chi tiết đơn thuốc-----------------------------------------
	declare @soluongthuoc int = (	select SoLuongTonKho 
									from THUOC with (ROWLOCK, UPDLOCK)
									where MaThuoc = @MaThuoc)
	set @soluongthuoc = @soluongthuoc - @soluong
	--------------------------------------------------------------------------------------
	waitfor delay '00:00:05'
	--------------------------------------------------------------------------------------
	update THUOC
	set SoLuongTonKho = @soluongthuoc
	where MaThuoc = @MaThuoc

	insert into CHITIETDONTHUOC 
	values (@MaThuoc, @sdt, @MaBA, @soluong)

	end try
	begin catch
	print N'Lỗi hệ thống'
	rollback tran
	return 1
	end catch

commit tran
return 0
go

create or alter proc Update_SoLuongThuoc_fix
@MaThuoc varchar(10),
@soluongcapnhat int
as
begin tran 
	begin try
	if not exists (select * from THUOC where MaThuoc = @MaThuoc)
	begin 
		print cast(N'Không tồn tại thuốc có mã: ' + @MaThuoc as nvarchar(10))
		rollback tran
		return 1
	end
	if @soluongcapnhat = 0
	begin 
		print N'Số lượng cập nhật phải khác 0'
		rollback tran
		return 1
	end
	if (select SoLuongTonKho from THUOC where MaThuoc = @MaThuoc)-@soluongcapnhat < 0
	begin 
		print N'Số lượng tồn kho sau khi cập nhật số lượng không được âm'
		rollback tran 
		return 1
	end
	----------------------thực hiện cập nhật----------------
	declare @soluongthuoc int
	set @soluongthuoc = (	select SoLuongTonKho 
							from THUOC with (ROWLOCK, UPDLOCK) 
							where MaThuoc = @MaThuoc)
	set @soluongthuoc = @soluongthuoc + @soluongcapnhat

	Update THUOC
	set SoLuongTonKho = @soluongthuoc
	where MaThuoc = @MaThuoc
	--------------------------------------------------------
	end try
	begin catch
		print N'Lỗi hệ thống'
		Rollback tran
		return 1
	end catch
commit tran
return 0
go


create or alter proc sp_Insert_LichHen_fix
@Ma varchar(10),
@Nhasi varchar(10),
@Ngay date,
@Ca int,
@sdt varchar(11)
as
begin tran
	SET TRAN ISOLATION LEVEL SERIALIZABLE
	begin try
	if exists (select * from PHIEUHEN where MaPhieu = @Ma)
	begin
		print N'Đã tồn tại phiếu hẹn có mã: ' + @Ma 
		rollback tran
		return 1
	end
	
	if not exists (	select * 
					from LICHCANHAN 
					where Ngay = @Ngay and ThuTuCa = @Ca and MaNhaSi = @Nhasi and TrangThai <> N'Bận')
	begin 
		Print N'Lịch hẹn không hợp lệ với lịch cá nhân của nha sĩ'
		rollback tran
		return 1
	end
	if exists (select * from PHIEUHEN where Ngay = @Ngay and ThuTuCa = @Ca and NhaSiKham = @Nhasi)
		begin
			print N'Buổi làm việc này đã được một khách hàng khác đăng kí hẹn.'
			rollback tran 
			return 1
		end
	if not exists (select * from KHACHHANG where Sdt = @sdt)
	begin 
		print N'Không tồn tại khách hàng có số điện thoại ' + @sdt
		rollback tran 
		return 1
	end
	-- Test 
	waitfor delay '00:00:05'
	---------------------tiến hành đặt lịch hẹn------------------------------
	insert into PHIEUHEN
	values ( @Ma, @Nhasi, @Ngay, @Ca, @sdt)

	--Update có bao gồm đọc và ghi.
	update LICHCANHAN 
	set TrangThai = N'Bận'
	where Ngay = @Ngay and ThuTuCa = @Ca and MaNhaSi = @Nhasi
	-------------------------------------------------------------------------

	end try
	begin catch
		print N'Lỗi hệ thống'
		rollback tran
		return 1
	end catch
commit tran
return 0
go

create or alter proc sp_Insert_LichCaNhan_fix
@MaNhaSi varchar(10),
@Ngay date,
@Ca int
as
begin tran
	begin try
	------------------------điều kiện vi phạm---------------------------
	if exists (	select *
				from LICHCANHAN 
				where MaNhaSi = @MaNhaSi and Ngay = @Ngay and ThuTuCa = @ca)
	begin
		print N'Lịch cá nhân đã tồn tại.'
		rollback tran
		return 1
	end
	if not exists ( select *
				from NHASI
				where MaNhaSi = @MaNhaSi)
	begin 
		print N'Không tồn tại nha sĩ có mã: ' + @manhasi
		rollback tran 
		return 1
	end
	if not exists ( select *
				from LICHTRUC
				where Ngay = @Ngay and ThuTuCa = @Ca)
	begin 
		print N'Lịch trực không tồn tại'
		rollback tran
		return 1
	end
	-----------------------------------------------------------------
	------------tiến hành thêm lịch cá nhân------------------
	insert into LICHCANHAN
	values( @MaNhaSi, @Ngay, @Ca, N'Rảnh')
	---------------------------------------------------------
	end try
	begin catch
	print N'Lỗi hệ thống.'
	rollback tran 
	return 1
	end catch

commit tran 
return 0
go


GRANT EXEC ON dbo.sp_Insert_LichCaNhan to NhaSi
GRANT EXEC ON dbo.sp_Insert_LichCaNhan_fix to NhaSi

GRANT EXEC ON dbo.sp_Insert_LichHen to NhanVien
GRANT EXEC ON dbo.sp_Insert_LichHen_fix to NhanVien

GRANT EXEC ON dbo.Update_SoLuongThuoc to QuanTriVien
GRANT EXEC ON dbo.Update_SoLuongThuoc_fix to QuanTriVien

GRANT EXEC ON dbo.sp_Insert_CTDT to NhaSi
GRANT EXEC ON dbo.sp_Insert_CTDT_fix to NhaSi



select * from LICHTRUC
-- Sol
go
use QLPHONGKHAM

	--Dirty read
GO
CREATE OR ALTER PROC sp_GhiHoSoBenhNhan
	@SdtKhachHang VARCHAR(11),
	@MaBenhAn VARCHAR(10),
	@MaThuoc VARCHAR(10),
	@Soluong INT
AS 
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
	BEGIN TRY
		--Kiểm tra thông tin @SdtKhachHang, @MaBenhAn có tồn tại không
		IF NOT EXISTS (SELECT * FROM BENHAN WHERE SdtKhachHang=@SdtKhachHang AND MaBenhAn = @MaBenhAn)
		BEGIN
            PRINT(N'Hồ sơ bệnh án không tồn tại')
            ROLLBACK TRAN
            RETURN 1
		END
		--Kiểm tra thông tin @MaThuoc có tồn tại không
		IF NOT EXISTS (SELECT * FROM THUOC WHERE MaThuoc = @MaThuoc)
		BEGIN
			PRINT(N'Thuốc không tồn tại trong kho')
			ROLLBACK TRAN
			RETURN 1
		END
		--Kiểm tra thông tin @SdtKhachHang, @MaBenhAn, @MaThuoc có tồn tại trong bảng CHITIETDONTHUOC không
		IF NOT EXISTS (SELECT * FROM CHITIETDONTHUOC WHERE SdtKhachHang = @SdtKhachHang AND
															MaBenhAn = @MaBenhAn AND
															MaThuoc=@MaThuoc)
		BEGIN
            PRINT(N'Chi tiết đơn thuốc này không tồn tại')
            ROLLBACK TRAN
            RETURN 1
		END
		--Chỉnh sửa thông tin về số lượng thuốc cảu @MaThuoc trong chi tiết đơn thuốc của bệnh án có khóa là @SdtKhachHang và @MaBenhAn
		UPDATE CHITIETDONTHUOC
		SET Soluong = @SoLuong
		WHERE SdtKhachHang = @SdtKhachHang
		AND MaBenhAn = @MaBenhAn
		AND MaThuoc = @MaThuoc

		WAITFOR DELAY '00:00:20'

		--Kiểm tra số lượng thuốc có hợp lệ không
		IF @Soluong > (SELECT SoLuongTonKho FROM THUOC WHERE MaThuoc = @MaThuoc)
		BEGIN
			PRINT(N'Số lượng thuốc trong kho không đủ')
			ROLLBACK TRAN
			RETURN 1
		END
	END TRY 
	
	BEGIN CATCH
		RAISERROR(N'LỖI HỆ THỐNG', 16, 1)
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0

GO
CREATE OR ALTER PROC sp_TraCuuHoSoBenhNhan
	@SdtKhachHang VARCHAR(11),
	@MaBenhAn VARCHAR(10)
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
	BEGIN TRY
		--Kiểm tra thông tin @SdtKhachHang, @MaBenhAn có tồn tại không
		IF NOT EXISTS (SELECT * FROM BENHAN WHERE SdtKhachHang = @SdtKhachHang
											AND MaBenhAn = @MaBenhAn)
		BEGIN
			PRINT(N'Hồ sơ bệnh án không tồn tại')
			ROLLBACK TRAN
			RETURN 1
		END
		--Xuất ra hồ sơ bệnh nhân gồm: số điện thoại, họ tên, thời gian khám (ngày, giờ), dịch vụ và đơn thuốc
		SELECT BA.SdtKhachHang, KH.HoTen, PH.Ngay, LT.GioBatDau, DV.TenDichVu, T.TenThuoc, CTDT.SoLuong
		FROM KHACHHANG KH, BENHAN BA, PHIEUHEN PH, LICHTRUC LT, CHITIETDICHVU CTDV, DICHVU DV, CHITIETDONTHUOC CTDT, THUOC T
		WHERE BA.SdtKhachHang = KH.Sdt 
		AND PH.SdtKhachHang = BA.SdtKhachHang 
		AND LT.Ngay = PH.Ngay 
		AND LT.ThuTuCa = PH.ThuTuCa 
		AND CTDV.SdtKhachHang = BA.SdtKhachHang  
		AND CTDV.MaBenhAn = BA.MaBenhAn 
		AND CTDV.MaDichVu = DV.MaDichVu 
		AND CTDT.SdtKhachHang = BA.SdtKhachHang 
		AND CTDT.MaBenhAn = BA.MaBenhAn 
		AND CTDT.MaThuoc = T.MaThuoc
	END TRY 

	BEGIN CATCH
		RAISERROR(N'LỖI HỆ THỐNG', 16, 1)
		ROLLBACK TRAN
		RETURN 1
	END CATCH 
COMMIT TRAN
RETURN 0

	--Dirty read fix
GO
CREATE OR ALTER PROC sp_GhiHoSoBenhNhan_Fix
	@SdtKhachHang VARCHAR(11),
	@MaBenhAn VARCHAR(10),
	@MaThuoc VARCHAR(10),
	@Soluong INT
AS 
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
	BEGIN TRY
		--Kiểm tra thông tin @SdtKhachHang, @MaBenhAn có tồn tại không
		IF NOT EXISTS (SELECT * FROM BENHAN WHERE SdtKhachHang=@SdtKhachHang AND MaBenhAn = @MaBenhAn)
		BEGIN
            PRINT(N'Hồ sơ bệnh án không tồn tại')
            ROLLBACK TRAN
            RETURN 1
		END
		--Kiểm tra thông tin @MaThuoc có tồn tại không
		IF NOT EXISTS (SELECT * FROM THUOC WHERE MaThuoc = @MaThuoc)
		BEGIN
			PRINT(N'Thuốc không tồn tại trong kho')
			ROLLBACK TRAN
			RETURN 1
		END
		--Kiểm tra thông tin @SdtKhachHang, @MaBenhAn, @MaThuoc có tồn tại trong bảng CHITIETDONTHUOC không
		IF NOT EXISTS (SELECT * FROM CHITIETDONTHUOC WHERE SdtKhachHang = @SdtKhachHang AND
															MaBenhAn = @MaBenhAn AND
															MaThuoc=@MaThuoc)
		BEGIN
            PRINT(N'Chi tiết đơn thuốc này không tồn tại')
            ROLLBACK TRAN
            RETURN 1
		END
		--Chỉnh sửa thông tin về số lượng thuốc cảu @MaThuoc trong chi tiết đơn thuốc của bệnh án có khóa là @SdtKhachHang và @MaBenhAn
		UPDATE CHITIETDONTHUOC
		SET Soluong = @SoLuong
		WHERE SdtKhachHang = @SdtKhachHang
		AND MaBenhAn = @MaBenhAn
		AND MaThuoc = @MaThuoc

		WAITFOR DELAY '00:00:20'

		--Kiểm tra số lượng thuốc có hợp lệ không
		IF @Soluong > (SELECT SoLuongTonKho FROM THUOC WHERE MaThuoc = @MaThuoc)
		BEGIN
			PRINT(N'Số lượng thuốc trong kho không đủ')
			ROLLBACK TRAN
			RETURN 1
		END
	END TRY 
	
	BEGIN CATCH
		RAISERROR(N'LỖI HỆ THỐNG', 16, 1)
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0

GO
CREATE OR ALTER PROC sp_TraCuuHoSoBenhNhan_Fix
	@SdtKhachHang VARCHAR(11),
	@MaBenhAn VARCHAR(10)
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
	BEGIN TRY
		--Kiểm tra thông tin @SdtKhachHang, @MaBenhAn có tồn tại không
		IF NOT EXISTS (SELECT * FROM BENHAN WHERE SdtKhachHang = @SdtKhachHang
											AND MaBenhAn = @MaBenhAn)
		BEGIN
			PRINT(N'Hồ sơ bệnh án không tồn tại')
			ROLLBACK TRAN
			RETURN 1
		END
		--Xuất ra hồ sơ bệnh nhân gồm: số điện thoại, họ tên, thời gian khám (ngày, giờ), dịch vụ và đơn thuốc
		SELECT BA.SdtKhachHang, KH.HoTen, PH.Ngay, LT.GioBatDau, DV.TenDichVu, T.TenThuoc, CTDT.SoLuong
		FROM KHACHHANG KH, BENHAN BA, PHIEUHEN PH, LICHTRUC LT, CHITIETDICHVU CTDV, DICHVU DV, CHITIETDONTHUOC CTDT, THUOC T
		WHERE BA.SdtKhachHang = KH.Sdt 
		AND PH.SdtKhachHang = BA.SdtKhachHang 
		AND LT.Ngay = PH.Ngay 
		AND LT.ThuTuCa = PH.ThuTuCa 
		AND CTDV.SdtKhachHang = BA.SdtKhachHang  
		AND CTDV.MaBenhAn = BA.MaBenhAn 
		AND CTDV.MaDichVu = DV.MaDichVu 
		AND CTDT.SdtKhachHang = BA.SdtKhachHang 
		AND CTDT.MaBenhAn = BA.MaBenhAn 
		AND CTDT.MaThuoc = T.MaThuoc
	END TRY 

	BEGIN CATCH
		RAISERROR(N'LỖI HỆ THỐNG', 16, 1)
		ROLLBACK TRAN
		RETURN 1
	END CATCH 
COMMIT TRAN
RETURN 0

	--Thêm dữ liệu demo
GO
CREATE OR ALTER PROC sp_ThemDuLieu_Dirty_Sol
AS
BEGIN TRAN
	BEGIN TRY
		INSERT INTO KHACHHANG VALUES ('0383571234', N'Lâm Chí Phèo', '2003-02-03', N'Trà Vinh')
		INSERT INTO LICHTRUC VALUES ('2024-01-20', 1, '08:00:00', '09:00:00')
		INSERT INTO DICHVU VALUES ('DV-0905', N'Trồng răng', 5350000)
		INSERT INTO THUOC VALUES ('T-3002', N'Thuốc B', N'Viên', null, 3703, '2024-12-31')
		INSERT INTO NHASI VALUES ('2002', N'Kim Bình An', '1999-5-7', N'TP Hồ Chí Minh', '0383573442', '2002')
		INSERT INTO LICHCANHAN VALUES ('2002', '2024-01-20', 1, N'Trạng thái 1')
		INSERT INTO PHIEUHEN VALUES ('3003', '2002', '2024-01-20', 1, '0383571234')
		INSERT INTO BENHAN VALUES ('0383571234', 'BA32', '3003')
		INSERT INTO CHITIETDICHVU VALUES ('DV-0905', '0383571234', 'BA32')
		INSERT INTO CHITIETDONTHUOC VALUES ('T-3002', '0383571234', 'BA32', 10)
	END TRY

	BEGIN CATCH
		RAISERROR(N'LỖI HỆ THỐNG', 16, 1)
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0

-- Quang

go
use QLPHONGKHAM

--proc để update thuốc
go
create or alter proc sp_UpdateSoLuongThuoc
	@mathuoc nvarchar(50),
	@soluong int
as
update THUOC
set SoLuongTonKho = @soluong
where MaThuoc = @mathuoc

-- LostUpdate
go
create or alter proc sp_ThemChiTietDonThuoc1
	@mathuoc nvarchar(50),
	@sdt	nvarchar(50),
	@maba	nvarchar(50),
	@sl		int
as
set transaction isolation level read committed
begin tran
	begin try
		declare @slton int
		set @slton = (select SoLuongTonKho from THUOC where THUOC.MaThuoc = @mathuoc)
		waitfor delay '00:00:05'

		set @slton = @slton - @sl
		exec sp_UpdateSoLuongThuoc @mathuoc,@slton
		insert into CHITIETDONTHUOC values (@mathuoc,@sdt,@maba,@sl)
	end try
	begin catch
		PRINT ERROR_MESSAGE()
		ROLLBACK TRAN
		RETURN 1	
	END CATCH
COMMIT TRAN
return 0

--Lost Update Fix
go
create or alter proc sp_ThemChiTietDonThuoc1_Fix
	@mathuoc nvarchar(50),
	@sdt	nvarchar(50),
	@maba	nvarchar(50),
	@sl		int
as
begin tran
	begin try
		declare @slton int
		set @slton = (select SoLuongTonKho from THUOC WITH (ROWLOCK, UPDLOCK) where THUOC.MaThuoc = @mathuoc)
		if (@slton < @sl)
		begin
			PRINT N'Số lượng thuốc tồn kho không còn đủ'
			rollback tran
			return 1
		end
		waitfor delay '00:00:05'

		set @slton = @slton - @sl
		exec sp_UpdateSoLuongThuoc @mathuoc,@slton
		insert into CHITIETDONTHUOC values (@mathuoc,@sdt,@maba,@sl)
	end try
	begin catch
		PRINT ERROR_MESSAGE()
		ROLLBACK TRAN
		RETURN 1	
	END CATCH
COMMIT TRAN
return 0

go
grant exec on dbo.sp_ThemChiTietDonThuoc1 to NhaSi
grant exec on dbo.sp_ThemChiTietDonThuoc1_Fix to NhaSi

-- Nam
go
-- DIRTY READ
CREATE OR ALTER PROC sp_SuaThuoc
	@MaThuoc VARCHAR(10),
	@TenThuoc NVARCHAR(50),
	@DonViTinh VARCHAR(20),
	@ChiDinh NVARCHAR(200),
	@SoLuongTon INT,
	@NgayHetHan DATE
AS
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRAN


	BEGIN TRY
	IF NOT EXISTS (SELECT * FROM THUOC WHERE MaThuoc = @MaThuoc)
	BEGIN
		PRINT N'Mã thuốc không tồn tại'
		ROLLBACK TRAN
		RETURN 1
	END

	UPDATE THUOC
	SET TenThuoc = @TenThuoc, DonViTinh = @DonViTinh, ChiDinh = @ChiDinh, NgayHetHan = @NgayHetHan, SoLuongTonKho = @SoLuongTon
	WHERE MaThuoc = @MaThuoc

	-- DELAY
	WAITFOR DELAY '0:0:05'

	IF(DATEDIFF(DD,GETDATE(),@NgayHetHan)<=0)
	BEGIN
	PRINT N'Ngày hết hạn phải sau ngày hiện tại'
	ROLLBACK TRAN
	RETURN 1
	END
	END TRY

	BEGIN CATCH
		PRINT N'Lỗi hệ thống'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
	COMMIT
GO

GRANT EXEC ON dbo.sp_SuaThuoc TO QuanTriVien
GO

CREATE OR ALTER PROC sp_XemThuoc
	@MaThuoc VARCHAR(10)
AS
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
	BEGIN TRY
	IF NOT EXISTS (SELECT * FROM THUOC WHERE MaThuoc = @MaThuoc)
	BEGIN
		PRINT N'Mã thuốc không tồn tại'
             ROLLBACK TRAN
             RETURN 1
	END
	SELECT * FROM THUOC
	WHERE MaThuoc = @MaThuoc
	END TRY
	BEGIN CATCH
		PRINT N'Lỗi hệ thống'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
GO

GRANT EXEC ON dbo.sp_XemThuoc TO QuanTriVien
GO

-- CHẠY PROCEDURE VỚI DEMO LỖI DIRTY

CREATE OR ALTER PROC sp_AddData
AS
	INSERT INTO THUOC VALUES
	('T-002520','Paracetamol',N'Viên',N'Dùng khi bị cảm',2000,'01/02/2023'),
	('T-002534','Tylenol',N'Viên',N'Dùng 1 viên mỗi 6 tiếng và không quá 3 viên trong 24 giờ',1570,'01/03/2023'),
	('T-002522',N'Thuốc A',N'Lọ',N'Chỉ định A',2000,'01/03/2023')
GO

-- DIRTY READ FIX (SỬA GIAO TÁC NẠN NHÂN VỚI MỨC CÔ LẬP READ COMMITED)
CREATE OR ALTER PROC sp_SuaThuoc_Fix
	@MaThuoc VARCHAR(10),
	@TenThuoc NVARCHAR(50),
	@DonViTinh VARCHAR(20),
	@ChiDinh NVARCHAR(200),
	@SoLuongTon INT,
	@NgayHetHan DATE
AS
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRAN


	BEGIN TRY
	IF NOT EXISTS (SELECT * FROM THUOC WHERE MaThuoc = @MaThuoc)
	BEGIN
		PRINT N'Mã thuốc không tồn tại'
		ROLLBACK TRAN
		RETURN 1
	END

	UPDATE THUOC
	SET TenThuoc = @TenThuoc, DonViTinh = @DonViTinh, ChiDinh = @ChiDinh, NgayHetHan = @NgayHetHan, SoLuongTonKho = @SoLuongTon
	WHERE MaThuoc = @MaThuoc

	-- DELAY
	WAITFOR DELAY '0:0:05'

	IF(DATEDIFF(DD,GETDATE(),@NgayHetHan)<=0)
	BEGIN
	PRINT N'Ngày hết hạn phải sau ngày hiện tại'
	ROLLBACK TRAN
	RETURN 1
	END
	END TRY

	BEGIN CATCH
		PRINT N'Lỗi hệ thống'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
	COMMIT TRAN
GO

GRANT EXEC ON dbo.sp_SuaThuoc_Fix TO QuanTriVien
GO

CREATE OR ALTER PROC sp_XemThuoc_Fix
	@MaThuoc VARCHAR(10)
AS
SET TRAN ISOLATION LEVEL READ COMMITTED
BEGIN TRAN

	BEGIN TRY
	IF NOT EXISTS (SELECT * FROM THUOC WHERE MaThuoc = @MaThuoc)
	BEGIN
		PRINT N'Mã thuốc không tồn tại'
        ROLLBACK TRAN
        RETURN 1
	END
	SELECT * FROM THUOC
	WHERE MaThuoc = @MaThuoc
	END TRY
	BEGIN CATCH
		PRINT N'Lỗi hệ thống'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
GO

GRANT EXEC ON dbo.sp_SuaThuoc_Fix TO QuanTriVien
GO
-- Thắng

CREATE OR ALTER PROC sp_ThemThongTinThuoc 
	@MaThuoc VARCHAR(10),
	@TenThuoc NVARCHAR(50),
	@DonViTinh VARCHAR(20),
	@ChiDinh NVARCHAR(200),
	@SoLuongTon INT,
	@NgayHetHan DATE
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
	BEGIN TRY
		INSERT INTO THUOC VALUES (@MaThuoc, @TenThuoc, @DonViTinh, @ChiDinh, @SoLuongTon, @NgayHetHan)
		WAITFOR DELAY '00:00:10' 
		IF DATEDIFF(DD,@NgayHetHan,GETDATE()) > 0   
		BEGIN 
			PRINT N'Ngày hết hạn phải sau ngày hiện tại' 
			ROLLBACK TRAN 
			RETURN 1
		END
	END TRY
		
	BEGIN CATCH
		RAISERROR(N'LỖI HỆ THỐNG',16,1)
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0

GO
GRANT EXEC ON dbo.sp_ThemThongTinThuoc TO QuanTriVien
GO
CREATE OR ALTER PROC sp_XemThongTinThuoc
	@MaThuoc VARCHAR(10)
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM THUOC WHERE MaThuoc = @MaThuoc) 
		BEGIN 
		PRINT (N'Mã thuốc không tồn tại') 
			ROLLBACK TRAN 
			RETURN 1 
		END
		SELECT * FROM THUOC 
		WHERE MaThuoc = @MaThuoc

	END TRY
		
	BEGIN CATCH
		RAISERROR(N'LỖI HỆ THỐNG',16,1)
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO
GRANT EXEC ON dbo.sp_XemThongTinThuoc TO QuanTriVien
GO
--PROC này để hỗ trợ thêm dữ liệu 
CREATE OR ALTER PROC sp_ThemDuLieuThuoc
AS
BEGIN TRAN
	BEGIN TRY
		INSERT INTO THUOC VALUES
			('T001','Paracetamol',N'Viên',N'Dùng khi bị cảm',2000,'01/02/2024')
	END TRY
		
	BEGIN CATCH
		RAISERROR(N'LỖI HỆ THỐNG HOẶC ĐÃ TỒN TẠI DỮ LIỆU CẦN THÊM, KHÔNG CẦN THÊM LẠI',16,1)
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO
EXEC sp_ThemDuLieuThuoc
GO

CREATE OR ALTER PROC sp_ThemThongTinThuoc_Fix 
	@MaThuoc VARCHAR(10),
	@TenThuoc NVARCHAR(50),
	@DonViTinh VARCHAR(20),
	@ChiDinh NVARCHAR(200),
	@SoLuongTon INT,
	@NgayHetHan DATE
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
	BEGIN TRY
		INSERT INTO THUOC VALUES (@MaThuoc, @TenThuoc, @DonViTinh, @ChiDinh, @SoLuongTon, @NgayHetHan)
		WAITFOR DELAY '00:00:10' 
		IF DATEDIFF(DD,@NgayHetHan,GETDATE()) > 0   
		BEGIN 
			PRINT N'Ngày hết hạn phải sau ngày hiện tại' 
			ROLLBACK TRAN 
			RETURN 1
		END
	END TRY
		
	BEGIN CATCH
		RAISERROR(N'LỖI HỆ THỐNG',16,1)
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO
GRANT EXEC ON dbo.sp_ThemThongTinThuoc_Fix TO QuanTriVien
GO
CREATE OR ALTER PROC sp_XemThongTinThuoc_Fix
	@MaThuoc VARCHAR(10)
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM THUOC WHERE MaThuoc = @MaThuoc) 
		BEGIN 
		PRINT (N'Mã thuốc không tồn tại') 
			ROLLBACK TRAN 
			RETURN 1 
		END
		SELECT * FROM THUOC 
		WHERE MaThuoc = @MaThuoc

	END TRY
		
	BEGIN CATCH
		RAISERROR(N'LỖI HỆ THỐNG',16,1)
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO
GRANT EXEC ON dbo.sp_XemThongTinThuoc_Fix TO QuanTriVien
GO