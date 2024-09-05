use QLPHONGKHAM
go 



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
	waitfor delay '0:0:05'
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




