--Thêm dữ liệu để test--
go
create or alter proc sp_ThemDuLieu
as
begin
begin try
	insert into KHACHHANG values ('0123456789',N'Nguyễn Văn A', '2002-04-01',N'KTX Khu B');
	insert into BENHAN values ('0123456789','BA01',null);
	insert into THUOC values ('THUOC01','Paracetamol',N'Viên',N'Dùng trong trường hợp bị sốt',100,'2024-03-04');
	insert into THUOC values ('THUOC02','Pilocarpine','Viên',N'Dùng trong trường hợp bị khô miệng',5,'2024-03-01');
end try
begin catch
	print N'Dữ liệu đã tồn tại'
end catch
end
go

--proc cho trans 1 (Nha sĩ)
create or alter proc sp_ThemChiTietDonThuoc
	@mathuoc nvarchar(50),
	@sdt	nvarchar(50),
	@maba	nvarchar(50),
	@sl		int
as
set transaction isolation level read committed
begin tran
	begin try
		if not exists (select * from THUOC where THUOC.MaThuoc = @mathuoc)
		begin
			PRINT CAST(@mathuoc AS VARCHAR(50)) + N' Không Tồn Tại'
			rollback tran
			return 1
		end
		if not exists (select * from KHACHHANG where KHACHHANG.Sdt = @sdt)
		begin
			PRINT N'Khách Hàng Không Tồn Tại'
			rollback tran
			return 1
		end
		if not exists (select * from BENHAN where BENHAN.MaBenhAn = @maba)
		begin
			PRINT N'Bệnh Án Không Tồn Tại'
			rollback tran
			return 1
		end
		declare @slton int
		set @slton = (select SoLuongTonKho from THUOC where THUOC.MaThuoc = @mathuoc)

		set @slton = @slton - @sl
		update THUOC
		set SoLuongTonKho = @slton
		where MaThuoc = @mathuoc
		insert into CHITIETDONTHUOC values (@mathuoc,@sdt,@maba,@sl)

		waitfor delay '00:00:05'
		declare @curDate DATETIME = getDate();
		declare @expDate DATETIME = (select NgayHetHan from THUOC where MaThuoc = @mathuoc)
		if (@curDate > @expDate)
		begin
			PRINT N'Thuốc đã hết hạn'
			rollback tran
			return 1
		end
	end try
	begin catch
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1	
	END CATCH
COMMIT TRAN
return 0;

--proc cho trans2 (Khách hàng)
go
create or alter proc sp_XemThongTinBenhAn_DonThuoc
	@sdt nvarchar(50),
	@maba nvarchar(50)
as
begin tran
	begin try
	if not exists (
		select * from BENHAN
		where MaBenhAn = @maba and SdtKhachHang = @sdt
	)
	begin
		PRINT N'Bệnhh án không Tồn Tại'
		rollback tran
		return 1
	end
	select * from BENHAN BA, CHITIETDONTHUOC
	where BA.MaBenhAn = @maba and BA.SdtKhachHang = @sdt and CHITIETDONTHUOC.MaBenhAn = BA.MaBenhAn
	end try
	begin catch
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1	
	END CATCH
COMMIT TRAN
return 0