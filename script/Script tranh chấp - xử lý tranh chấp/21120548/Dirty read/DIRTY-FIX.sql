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