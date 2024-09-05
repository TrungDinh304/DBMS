USE QLPHONGKHAM
GO

-- SỬA LỖI PHANTOM READ:
-- CÁCH 1: SỬ DỤNG MỨC SERIALIZABLE, DẪN TỚI PHÁ BỎ GIAO TÁC ĐỒNG THỜI.
-- CÁCH 2: SỬ DỤNG KHÓA TRÊN CÂU LỆNH
CREATE PROC sp_KeDonThuoc
	@MaThuoc VARCHAR(10),
	@sdt VARCHAR(11),
	@MaBA VARCHAR(10),
	@SoLuong INT
AS
	BEGIN TRAN
	SET TRAN ISOLATION LEVEL READ SERIALIZABLE

	BEGIN TRY
	select * from THUOC 

	if (not exists (select * from THUOC where MaThuoc=@MaThuoc))
	begin
		print N'Thuốc này không tồn tại'
		rollback tran
		return 1
	end

	if exists(select * 
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
	--DELAY
	WAITFOR DELAY '0:0:05'
	if @soluong > (select soluongtonkho from THUOC where MaThuoc = @MaThuoc)
	begin
		print N'Không còn đủ thuốc ' + @Mathuoc + N' để thực hiện kê đơn.'
		rollback tran
		return 1
	end
	

	update THUOC
	set SoLuongTonKho = SoLuongTonKho - @soluong
	where MaThuoc = @MaThuoc
	insert into CHITIETDONTHUOC 
	values (@MaThuoc, @sdt, @MaBA, @soluong)

	END TRY
	BEGIN CATCH
		PRINT N'Lỗi hệ thống'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
	COMMIT TRAN
GO

CREATE PROC sp_ThemThuoc
	@MaThuoc VARCHAR(10),
	@TenThuoc NVARCHAR(50),
	@DonViTinh VARCHAR(20),
	@ChiDinh NVARCHAR(200),
	@SoLuongTon INT,
	@NgayHetHan DATE
AS
	BEGIN TRAN
	SET TRAN ISOLATION LEVEL READ COMMITED

	BEGIN TRY
	IF(EXISTS(SELECT * FROM THUOC WHERE MaThuoc = @MaThuoc))
	BEGIN
	ROLLBACK TRAN
	RETURN 1
	END

	INSERT INTO THUOC VALUES 
	(@MaThuoc, @TenThuoc, @DonViTinh, @ChiDinh, @SoLuongTon, @NgayHetHan)

	IF DATEDIFF(DD,@NgayHetHan,GETDATE()) > 0   
	BEGIN 
	PRINT N'Ngày hết hạn phải sau ngày hiện tại' 
	END

	END TRY
	BEGIN CATCH
		PRINT N'Lỗi hệ thống'
		ROLLBACK TRAN
		RETURN 1
	END CATCH

	COMMIT TRAN
GO

CREATE OR ALTER PROC sp_AddData
AS
	INSERT INTO THUOC VALUES
	('T-002520','Paracetamol',N'Viên',N'Dùng khi bị cảm',2000,'01/02/2023'),
	('T-002534','Tylenol',N'Viên',N'Dùng 1 viên mỗi 6 tiếng và không quá 3 viên trong 24 giờ',1570,'01/03/2023'),
	('T-002522',N'Thuốc A',N'Lọ',N'Chỉ định A',2000,'01/03/2023')

	INSERT INTO KHACHHANG VALUES
	('0123654987',N'Nguyễn Thị B','2003-11-06',N'Đà Nẵng'),
	('0123456789',N'Phạm Ngọc Hân','2004-10-06',N'TPHCM')

	INSERT INTO BENHAN VALUES('0123456789','0000000001','1000')

	INSERT INTO LICHTRUC VALUES ('2023-11-21',1,'08:00:00', '09:00:00')
	INSERT INTO NHASI VALUES ('1000',N'Nguyễn Văn A','2003-12-12',N'Long An','0987654321','1000')
	INSERT INTO LICHCANHAN VALUES ('1000','2023-11-21',1,N'Rảnh')
	INSERT INTO LICHTRUC VALUES ('2023-11-20',1,'08:00:00', '09:00:00')
	INSERT INTO LICHCANHAN VALUES ('1000','2023-11-20',1,N'Bận')
	INSERT INTO PHIEUHEN VALUES ('1000','1000','2023-11-20',1,'0123456789')
GO
