USE MASTER;
GO 
DROP DATABASE QLPHONGKHAM;
GO
CREATE DATABASE QLPHONGKHAM;
GO


USE QLPHONGKHAM;
GO

CREATE TABLE KHACHHANG(
	Sdt VARCHAR(11),
	HoTen NVARCHAR(50),
	NgaySinh DATE,
	DiaChi NVARCHAR(200),
	

	CONSTRAINT PK_KHACHHANG PRIMARY KEY(Sdt),
)

CREATE TABLE KHACHHANGCOTAIKHOAN(
	TenDangNhap VARCHAR(11),
	MatKhau VARCHAR(20),

	CONSTRAINT PK_KHACHHANGCOTAIKHOAN PRIMARY KEY (TenDangNhap),

	CONSTRAINT FK_KHACHHANGCOTAIKHOAN_KHACHHANG FOREIGN KEY (TenDangNhap) REFERENCES KHACHHANG(Sdt)
)

CREATE TABLE NHASI(
	MaNhaSi VARCHAR(10),
	HoTen NVARCHAR(50),
	NgaySinh DATE,
	DiaChi NVARCHAR(200),
	Sdt VARCHAR(11),
	MatKhau VARCHAR(20),

	CONSTRAINT PK_NHASI PRIMARY KEY(MaNhaSi),
)

CREATE TABLE LICHTRUC(
	Ngay DATE,
	ThuTuCa INT,
	GioBatDau TIME,
	GioKetThuc TIME,

	CONSTRAINT PK_LICHTRUC PRIMARY KEY(Ngay,ThuTuCa),
)

CREATE TABLE LICHCANHAN(
	MaNhaSi VARCHAR(10),
	Ngay DATE,
	ThuTuCa INT,
	TrangThai NVARCHAR(20),

	CONSTRAINT PK_LICHCANHAN PRIMARY KEY(MaNhaSi,Ngay,ThuTuCa),

	CONSTRAINT FK_LICHCANHAN_NHASI FOREIGN KEY (MaNhaSi) REFERENCES NHASI(MaNhaSi),
	CONSTRAINT FK_LICHCANHAN_LICHTRUC FOREIGN KEY (Ngay,ThuTuCa) REFERENCES LICHTRUC(Ngay,ThuTuCa),

)

CREATE TABLE PHIEUHEN(
	MaPhieu VARCHAR(10),
	NhaSiKham VARCHAR(10),
	Ngay DATE,
	ThuTuCa INT,
	SdtKhachHang VARCHAR(11),

	CONSTRAINT PK_PHIEUHEN PRIMARY KEY(MaPhieu),

	CONSTRAINT FK_PHIEUHEN_KHACHHANG FOREIGN KEY (SdtKhachHang) REFERENCES KHACHHANG(Sdt),
	--CONSTRAINT FK_PHIEUHEN_NHASI FOREIGN KEY (NhaSiKham) REFERENCES NHASI(MaNhaSi),
	--CONSTRAINT FK_PHIEUHEN_LICHTRUC FOREIGN KEY (Ngay,ThuTuCa) REFERENCES LICHTRUC(Ngay,ThuTuCa),
	CONSTRAINT FK_PHIEUHEN_LICHCANHAN FOREIGN KEY (NhaSiKham,Ngay,ThuTuCa) REFERENCES LICHCANHAN(MaNhaSi,Ngay,ThuTuCa),

)

CREATE TABLE BENHAN(
	SdtKhachHang VARCHAR(11),
	MaBenhAn varchar(10),
	MaPhieuHen varchar(10),
	

	CONSTRAINT PK_BENHAN PRIMARY KEY(SdtKhachHang, MaBenhAn),

	CONSTRAINT FK_BENHAN_KHACHHANG FOREIGN KEY (SdtKhachHang) REFERENCES KHACHHANG(Sdt),
	CONSTRAINT FK_BENHAN_PHIEUHEN FOREIGN KEY (MaPhieuHen) REFERENCES PHIEUHEN(MaPhieu),
)

CREATE TABLE THUOC(
	MaThuoc VARCHAR(10),
	TenThuoc NVARCHAR(50),
	DonViTinh VARCHAR(20),
	ChiDinh NVARCHAR(200),
	SoLuongTonKho INT check(SoLuongTonKho >= 0), 
	NgayHetHan DATE,

	CONSTRAINT PK_THUOC PRIMARY KEY(MaThuoc),
)

CREATE TABLE CHITIETDONTHUOC(
	MaThuoc VARCHAR(10),
	SdtKhachHang VARCHAR(11),
	MaBenhAn varchar(10),
	SoLuong INT check (SoLuong > 0),

	CONSTRAINT PK_CHITIETDONTHUOC PRIMARY KEY(MaThuoc,SdtKhachHang,MaBenhAn),

	CONSTRAINT FK_CHITIETDONTHUOC_THUOC FOREIGN KEY (MaThuoc) REFERENCES THUOC(MaThuoc),
	--CONSTRAINT FK_CHITIETDONTHUOC_KHACHHANG FOREIGN KEY (SdtKhachHang) REFERENCES KHACHHANG(Sdt),
	CONSTRAINT FK_CHITIETDONTHUOC_BENHAN FOREIGN KEY (SdtKhachHang,MaBenhAn) REFERENCES BENHAN(SdtKhachHang,MaBenhAn),
)

CREATE TABLE DICHVU(
	MaDichVu VARCHAR(10),
	TenDichVu NVARCHAR(50),
	PhiDichVu FLOAT,

	CONSTRAINT PK_DICHVU PRIMARY KEY(MaDichVu),
)

CREATE TABLE CHITIETDICHVU(
	MaDichVu VARCHAR(10),
	SdtKhachHang VARCHAR(11),
	MaBenhAn varchar(10),

	CONSTRAINT PK_CHITIETDICHVU PRIMARY KEY(MaDichVu,SdtKhachHang,MaBenhAn),

	CONSTRAINT FK_CHITIETDICHVU_DICHVU FOREIGN KEY (MaDichVu) REFERENCES DICHVU(MaDichVu),
	--CONSTRAINT FK_CHITIETDICHVU_KHACHHANG FOREIGN KEY (SdtKhachHang) REFERENCES KHACHHANG(Sdt),
	CONSTRAINT FK_CHITIETDICHVU_BENHAN FOREIGN KEY (SdtKhachHang,MaBenhAn) REFERENCES BENHAN(SdtKhachHang,MaBenhAn),


)

CREATE TABLE HOADON(
	MaHoaDon VARCHAR(10),
	MaBenhAn varchar(10),
	SdtKhachHang VARCHAR(11),
	TongTien FLOAT,

	CONSTRAINT PK_HOADON PRIMARY KEY(MaHoaDon),

	--CONSTRAINT FK_HOADON_KHACHHANG FOREIGN KEY (SdtKhachHang) REFERENCES KHACHHANG(Sdt),
	CONSTRAINT FK_HOADON_BENHAN FOREIGN KEY (SdtKhachHang,MaBenhAn) REFERENCES BENHAN(SdtKhachHang,MaBenhAn),

)

CREATE TABLE NHANVIEN(
	MaNhanVien VARCHAR(10),
	HoTen NVARCHAR(50),
	NgaySinh DATE,
	DiaChi NVARCHAR(200),
	Sdt VARCHAR(11),
	MatKhau VARCHAR(20),

	CONSTRAINT PK_NHANVIEN PRIMARY KEY(MaNhanVien),
)


/* Tong tien hoa don = Phi dich vu trong benh an */
go
create or alter trigger trgHoaDon
on HOADON
for insert,update
as
begin
	UPDATE HOADON
	set TongTien = (
		select Phi from inserted i, BENHAN ba, (select SdtKhachHang,MaBenhAn,sum(PhiDichVu) as Phi from CHITIETDICHVU ctdv, DICHVU dv
					where ctdv.MaDichVu= dv.MaDichVu
					group by SdtKhachHang,MaBenhAn) dv_ct  
		where i.MaBenhAn = ba.MaBenhAn and i.SdtKhachHang = ba.SdtKhachHang
		and ba.MaBenhAn = dv_ct.MaBenhAn and dv_ct.SdtKhachHang = ba.SdtKhachHang
	)
end

/*	Ngày khám của bệnh án phải có trong lịch cá nhân có trạng thái bận 
và bác sĩ phụ trách phải khớp với lịch cá nhân đó	
*/


/*	Trong lịch trực giờ bắt đầu phải sau giờ kết thúc */
go
create or alter trigger trgGioBD_GioKT
on LICHTRUC
for insert,update
as
begin
	if exists (
		select * from inserted i where i.GioBatDau >= i.GioKetThuc
	)
	begin
		raiserror(N'Giờ bắt đầu phải trước giờ kết thúc',16,1);
		rollback
	end
end

/* Bác sĩ và nhân viên phải trên 18 tuổi */
go
create or alter trigger trgTuoiBacSi
on NHASI
for insert,update
as
begin
	if exists (
		select * from inserted i where datediff(year,i.NgaySinh,GETDATE()) < 18
	)
	begin
		raiserror(N'Bác sĩ phải đủ 18 tuổi trở lên',15,1)
		rollback
	end
end

go
create or alter trigger trgTuoiNhanVien
on NHANVIEN
for insert,update
as
begin
	if exists (
		select * from inserted i where datediff(year,i.NgaySinh,GETDATE()) < 18
	)
	begin
		raiserror(N'Nhân viên phải đủ 18 tuổi trở lên',15,1)
		rollback
	end
end

/* Số điện thoại phải có 10 chữ số */
go
create or alter trigger trgSoDienThoai
on KHACHHANG
for insert,update
as
begin
	if exists (
		select * from inserted i where len(i.Sdt) <> 10
	)
	begin
		raiserror(N'Số điện thoại phải có 10 chữ số',15,1)
		rollback
	end
end

/*	1 lịch cá nhân chỉ được hẹn với một lịch hẹn	 */
/* Khi lịch cá nhân được hẹn thì trạng thái chuyển sang bận */
/* Khách hàng không được hẹn lịch cá nhân đang trong trạng thái bận */
go
create or alter trigger trgThemPhieuHen
on PHIEUHEN
after INSERT
as
begin
	if not exists (
		select * from LICHCANHAN lcn, inserted i 
		where lcn.MaNhaSi=i.NhaSiKham and lcn.Ngay = i.Ngay and lcn.ThuTuCa = i.ThuTuCa and lcn.TrangThai =N'Bận'
	)
	begin
		UPDATE LICHCANHAN
		set TrangThai = N'Bận'
		from LICHCANHAN lcn, inserted i
		where lcn.MaNhaSi=i.NhaSiKham and lcn.Ngay = i.Ngay and lcn.ThuTuCa = i.ThuTuCa
	end
end

go
create or alter trigger trgXoaPhieuHen
on PHIEUHEN
for delete
as
begin
	UPDATE LICHCANHAN
	SET TrangThai = N'Rảnh'
	from LICHCANHAN lcn, deleted d
	where lcn.MaNhaSi = d.NhaSiKham and lcn.Ngay = d.Ngay and lcn.ThuTuCa = d.ThuTuCa
end

go
create or alter trigger trgSuaPhieuHen
on PHIEUHEN
after UPDATE
as
begin
	UPDATE LICHCANHAN
	set TrangThai = N'Bận'
	from LICHCANHAN lcn, inserted i
	where lcn.MaNhaSi=i.NhaSiKham and lcn.Ngay = i.Ngay and lcn.ThuTuCa = i.ThuTuCa
	UPDATE LICHCANHAN
	SET TrangThai = N'Rảnh'
	from LICHCANHAN lcn, deleted d
	where lcn.MaNhaSi = d.NhaSiKham and lcn.Ngay = d.Ngay and lcn.ThuTuCa = d.ThuTuCa
end


--*****************************************************   PHÂN QUYỀN   *********************************************************--
go
Exec sp_addrole 'KhachHang'

go
Grant select, update on KHACHHANG to KhachHang

go
Grant select, update on KHACHHANGCOTAIKHOAN to KhachHang

go
grant select on BENHAN to KhachHang

go
grant select on CHITIETDONTHUOC to KhachHang

go
grant select on CHITIETDICHVU to KhachHang

go
grant insert on PHIEUHEN to KhachHang


--Exec sp_addlogin 'tam','1000','QLPhongKham'
--Exec sp_grantdbaccess 'tam', 'tam'
--EXEC sp_addrolemember 'KhachHang', 'tam';

--EXEC sp_droprolemember 'KhachHang', 'tam';
--EXEC sp_droprole 'KhachHang';
--Exec sp_revokedbaccess 'tam'
--exec sp_droplogin 'tam'