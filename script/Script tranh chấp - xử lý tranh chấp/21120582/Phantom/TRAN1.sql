------------ThêmLịch cá nhân-----------------
select* from LICHCANHAN

declare @rt int
exec @rt = sp_Insert_LichCaNhan 'NS003', '2023-11-27', 1
if @rt = 1
	print N'Thêm Lịch cá nhân thất bại'
else
	print N'Thêm Lịch cá nhân thành công'
select * from LICHCANHAN
