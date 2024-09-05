USE QLPHONGKHAM
GO

-- DIRTY READ
CREATE PROC sp_SuaThuoc
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

CREATE PROC sp_XemThuoc
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

-- CHẠY PROCEDURE VỚI DEMO LỖI DIRTY

CREATE OR ALTER PROC sp_AddData
AS
	INSERT INTO THUOC VALUES
	('T-002520','Paracetamol',N'Viên',N'Dùng khi bị cảm',2000,'01/02/2023'),
	('T-002534','Tylenol',N'Viên',N'Dùng 1 viên mỗi 6 tiếng và không quá 3 viên trong 24 giờ',1570,'01/03/2023'),
	('T-002522',N'Thuốc A',N'Lọ',N'Chỉ định A',2000,'01/03/2023')

GO

EXEC sp_AddData