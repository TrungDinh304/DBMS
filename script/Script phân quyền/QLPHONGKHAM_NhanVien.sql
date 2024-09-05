use QLPHONGKHAM
go

Exec sp_addrole 'NhanVien'
go

-- tiếp nhận khách hàng
Grant select, update, insert on KHACHHANG to NhanVien
go

Grant select, update, insert on KHACHHANGCOTAIKHOAN to NhanVien
go
-- thêm xóa sửa lịch hẹn
Grant select, update, insert, delete on PHIEUHEN to NhanVien
GO
grant select on LICHCANHAN to NhanVien
go

-- LẬP HÓA ĐƠN
GRANT SELECT, INSERT ON HOADON TO NhanVien
go
grant select on CHITIETDONTHUOC to NhanVien
go
grant select on CHITIETDICHVU to NhanVien
go

exec sp_addlogin 'NhanVien1','0908','QLPHONGKHAM'
EXEC sp_grantdbaccess 'NhanVien1', 'NhanVien1'
EXEC sp_addrolemember 'NhanVien', 'NhanVien1'

EXEC sp_addlogin 'user','1000','QLPhongKham'
EXEC sp_grantdbaccess 'user', 'user'
EXEC sp_addrolemember 'NhanVien', 'user'

exec sp_addlogin 'NhanVien2','0908'
EXEC sp_grantdbaccess 'NhanVien2', 'NhanVien2'
EXEC sp_addrolemember 'NhanVien', 'NhanVien2'

--EXEC sp_droprolemember 'NhanVien', 'user'
--EXEC sp_droprole 'NhanVien'
--EXEC sp_revokedbaccess 'user'
--EXEC sp_droplogin 'user'
select * from NhanVien
insert into NhanVien 
values('user',N'Người dùng','2001-10-12',N'ktx khu b, Linh Trung, Thủ Đức, TPHCM','0898827912','1000')