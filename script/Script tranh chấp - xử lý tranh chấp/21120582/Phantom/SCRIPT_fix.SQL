use QLPHONGKHAM
go


create or alter proc sp_Insert_LichHen
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
	waitfor delay '0:0:20'
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

create or alter proc sp_Insert_LichCaNhan
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




