--thêm chi tiết đơn thuốc (sau khi chi tiết đơn thuốc được thêm vào thì số lượng thuốc bị thay đổi)
select * from BENHAN
declare @rt int
exec @rt = sp_Insert_CTDT 'T001','0123456789','BA15',20
print @rt
if @rt =1 
	print N'Thêm chi tiết đơn thuốc thất bại'
else 
	print N'THêm chi tiết đơn thuốc thành công'
select * from CHITIETDONTHUOC where MaBenhAn = 'BA003' and SdtKhachHang = '0123456781'


go


select * from thuoc

select * from CHITIETDONTHUOC

