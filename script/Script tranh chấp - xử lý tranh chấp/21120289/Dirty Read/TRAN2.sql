DECLARE @R1 INT

EXEC @R1 = sp_XemThuoc 'T-002520','Paracetamol',N'Viên',N'Dùng khi bị cảm',2000,'21/09/2023'

IF @R1 = 1
	PRINT N'FAILED'
ELSE
	PRINT N'SUCCESS'
GO