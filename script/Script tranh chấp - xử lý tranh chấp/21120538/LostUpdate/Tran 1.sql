go
--Thêm dữ liệu để thực hiện test
exec sp_ThemDuLieu
--Sau khi test lỗi lost update, dữ liệu của CHITIETDONTHUOC vẫn được thêm vào.
--Nếu sửa lại lỗi lost update, để chạy được 2 transaction thì cần phải thay đổi dữ liệu đưa vào
--để tránh bị trùng CHITIETDONTHUOC hoặc xóa các dòng vừa thêm vào CHITIETDONTHUOC trong test ban đầu
go

exec sp_ThemChiTietDonThuoc1 'THUOC01','0123456789','BA01',20

select * from THUOC