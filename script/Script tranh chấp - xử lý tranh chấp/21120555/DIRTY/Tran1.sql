USE QLPHONGKHAM
GO

EXEC sp_ThemDuLieuThuoc
GO
EXEC sp_ThemThongTinThuoc 'T002',N'Thuốc B',N'Viên',N'Chỉ định A',2000,'01/12/2023'


SELECT*FROM THUOC