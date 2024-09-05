﻿USE QLPHONGKHAM

GO
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

--PROC này để hỗ trợ thêm dữ liệu vào bảng để thực hiện 2 proc trên
GO
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

