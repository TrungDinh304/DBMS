﻿DECLARE @R1 INT

EXEC @R1 = sp_KeDonThuoc 'T-002520','0123456789','0000000001',N'Dùng khi bị cảm',2000

IF @R1 = 1
	PRINT N'FAILED'
ELSE
	PRINT N'SUCCESS'
GO
