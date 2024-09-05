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
CREATE OR ALTER PROC sp_XemLichHen
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
	END TRY
		
	BEGIN CATCH
		RAISERROR(N'LỖI HỆ THỐNG HOẶC ĐÃ TỒN TẠI DỮ LIỆU CẦN THÊM, KHÔNG CẦN THÊM LẠI',16,1)
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0

