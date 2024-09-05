--update số lượng thuốc
select * from THUOC

declare @rt int
exec @rt = Update_SoLuongThuoc 'T001', 200
if @rt = 1
	print N'Cập nhật thất bại'
else 
	print N'Cập nhật thành công'

select MaThuoc, SoLuongTonKho, DonViTinh from THUOC