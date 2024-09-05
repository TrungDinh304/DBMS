go
--Thêm dữ liệu để thực hiện test
exec sp_ThemDuLieu

go
exec sp_ThemChiTietDonThuoc 'THUOC02','0123456789','BA01',5

select * from THUOC