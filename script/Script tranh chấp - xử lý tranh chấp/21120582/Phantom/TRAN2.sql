--------Thêm phiếu hẹn------------
select* from LICHCANHAN
declare @rt int
exec @rt = sp_ThemLichHen 'PH005', 'NS002', '11-25-2023', 1, '0123456781'
if @rt = 1
	print N'Thêm lịch hẹn thất bại'
else 
	print N'Thêm lịch hẹn thành công'
select * from PHIEUHEN


