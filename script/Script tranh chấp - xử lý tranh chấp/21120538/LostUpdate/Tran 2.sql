--Sau khi sửa lỗi lost update của 2 proc và chạy 2 transaction, transaction 2 sẽ báo lỗi deadlock.
--Ta sẽ chạy lại transaction 2 sau thông báo lỗi deadlock. Từ đó giải quyết được lỗi lost update

exec sp_ThemChiTietDonThuoc2 'THUOC01','0123456790','BA02',10

select * from THUOC