--Thêm dữ liệu để test transaction
go
create or alter proc sp_ThemDuLieu
as
begin
begin try
	insert into KHACHHANG values ('0123456789',N'Nguyễn Văn A', '2002-04-01',N'KTX Khu B'),('0123456790',N'Trần Thị B','2001-02-03',N'Thủ Đức');
	insert into BENHAN values ('0123456789','BA01',null),('0123456790','BA02',null);
	insert into THUOC values ('THUOC01','Paracetamol',N'Viên',N'Dùng trong trường hợp bị sốt',100,'2024-03-04');
end try
begin catch
	print N'Dữ liệu đã tồn tại'
end catch
end

--Procedure cho tran 1
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
		waitfor delay '00:00:05'

		set @slton = @slton - @sl
		update THUOC
		set SoLuongTonKho = @slton
		where MaThuoc = @mathuoc
		insert into CHITIETDONTHUOC values (@mathuoc,@sdt,@maba,@sl)
	end try
	begin catch
		PRINT N'LỖI HỆ THỐNG'		ROLLBACK TRAN		RETURN 1	
	END CATCH
COMMIT TRAN
return 0


--Procedure cho tran 2
go
create or alter proc sp_ThemChiTietDonThuoc2
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
		if (@slton < @sl)

		set @slton = @slton - @sl
		update THUOC
		set SoLuongTonKho = @slton
		where MaThuoc = @mathuoc
		insert into CHITIETDONTHUOC values (@mathuoc,@sdt,@maba,@sl)
	end try
	begin catch
		PRINT N'LỖI HỆ THỐNG'		ROLLBACK TRAN		RETURN 1	
	END CATCH
COMMIT TRAN
return 0