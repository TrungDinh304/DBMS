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
