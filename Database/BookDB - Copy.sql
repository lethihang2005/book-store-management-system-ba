CREATE DATABASE BookDB;
GO

USE BookDB;
GO

-- ========================================
-- TẠO CÁC BẢNG
-- ========================================

-- 1. NHÀ XUẤT BẢN, LOẠI SÁCH, SÁCH
CREATE TABLE NXB 
(
    MaNXB INT IDENTITY(1,1) PRIMARY KEY,
    TenNXB NVARCHAR(100) NOT NULL,
    DiaChi NVARCHAR(255),
    DienThoai NVARCHAR(20)
);

CREATE TABLE LoaiSach 
(
    MaLoai INT IDENTITY(1,1) PRIMARY KEY,
    TenLoai NVARCHAR(100) NOT NULL,
    GhiChu NVARCHAR(255),
    AnhDaiDien NVARCHAR(255)
);

CREATE TABLE Sach 
(
    MaSach INT IDENTITY(1,1) PRIMARY KEY,
    TenSach NVARCHAR(200) NOT NULL,
    TacGia NVARCHAR(100),
    NamXB INT,
    SoTrang INT,
    GiaBan DECIMAL(18,2),
    GiaGoc DECIMAL(18,2),
    SoLuongTon INT DEFAULT 0,
    NoiDung NVARCHAR(MAX),
    AnhBia NVARCHAR(255),
    LuotMua INT DEFAULT 0,
	DiemDanhGia DECIMAL(3,2) DEFAULT 0,
    SoLuotDanhGia INT DEFAULT 0,
    MaLoai INT FOREIGN KEY REFERENCES LoaiSach(MaLoai),
    MaNXB INT FOREIGN KEY REFERENCES NXB(MaNXB)
);

CREATE TABLE HinhAnh
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    MaSach INT FOREIGN KEY REFERENCES Sach(MaSach),
    HinhAnh NVARCHAR(255)
);

-- 2. TÀI KHOẢN NGƯỜI DÙNG (ADMIN & KHÁCH HÀNG)
CREATE TABLE VaiTro 
(
    IDVaiTro INT IDENTITY(1,1) PRIMARY KEY,
    TenVaiTro NVARCHAR(50) NOT NULL,  -- 'Admin' hoặc 'KhachHang'
    MoTa NVARCHAR(255)
);

CREATE TABLE NguoiDung 
(
    MaND INT IDENTITY(1,1) PRIMARY KEY,
    TenDangNhap NVARCHAR(50) UNIQUE NOT NULL,
    MatKhau NVARCHAR(255) NOT NULL,
    HoTen NVARCHAR(100),
    GioiTinh NVARCHAR(10),
    NamSinh INT,
    AnhDaiDien NVARCHAR(255),
    DienThoai NVARCHAR(20),
    Email NVARCHAR(100) UNIQUE,
    DiaChi NVARCHAR(255),
    IDVaiTro INT FOREIGN KEY REFERENCES VaiTro(IDVaiTro),
    NgayDangKy DATETIME DEFAULT GETDATE(),
    TrangThai BIT DEFAULT 1  -- 1: hoạt động, 0: khóa
);

-- 3. CHƯƠNG TRÌNH KHUYẾN MÃI
CREATE TABLE KhuyenMai 
(
    MaKM INT IDENTITY(1,1) PRIMARY KEY,
    TenKM NVARCHAR(100),
    MoTa NVARCHAR(255),
    LoaiKM NVARCHAR(20), -- 'PhanTram' hoặc 'TienMat'
    GiaTriGiam DECIMAL(18,2),
    DonToiThieu DECIMAL(18,2),
    NgayBatDau DATETIME,
    NgayKetThuc DATETIME,
	HinhAnh NVARCHAR(255) NOT NULL
);

CREATE TABLE Sach_KhuyenMai 
(
    MaSach INT FOREIGN KEY REFERENCES Sach(MaSach),
    MaKM INT FOREIGN KEY REFERENCES KhuyenMai(MaKM),
    NgaySuDung DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (MaSach, MaKM)
);

-- 4. ĐƠN HÀNG & THANH TOÁN
CREATE TABLE GioHang 
(
    MaKH INT FOREIGN KEY REFERENCES NguoiDung(MaND),
    MaSach INT FOREIGN KEY REFERENCES Sach(MaSach),
    SoLuong INT,
    PRIMARY KEY (MaKH, MaSach)
);

CREATE TABLE TinhTrang 
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    TinhTrangHoaDon NVARCHAR(50) -- 'Chờ xử lý', 'Đang giao', 'Hoàn tất', 'Đã hủy'
);

CREATE TABLE PhuongThucThanhToan 
(
    MaPTTT INT IDENTITY(1,1) PRIMARY KEY,
    TenPTTT NVARCHAR(100), -- COD, Chuyển khoản, Ví điện tử...
    MoTa NVARCHAR(255),
    TrangThai BIT DEFAULT 1
);

CREATE TABLE HoaDon 
(
    MaHD INT IDENTITY(1,1) PRIMARY KEY,
    MaKH INT FOREIGN KEY REFERENCES NguoiDung(MaND),
	MaKM INT FOREIGN KEY REFERENCES KhuyenMai(MaKM),
    NgayLap DATETIME DEFAULT GETDATE(),
    TongTien DECIMAL(18,2),
	GiamGia DECIMAL(18,2),
	PhiVanChuyen DECIMAL(18,2),
	ThanhTien DECIMAL(18,2),
    DiaChiGiaoHang NVARCHAR(255),
	GhiChu NVARCHAR(255),
    TinhTrang INT FOREIGN KEY REFERENCES TinhTrang(ID),
    MaPTTT INT FOREIGN KEY REFERENCES PhuongThucThanhToan(MaPTTT),
    DaThanhToan BIT DEFAULT 0
);

CREATE TABLE ChiTietHoaDon 
(
    MaHD INT FOREIGN KEY REFERENCES HoaDon(MaHD),
    MaSach INT FOREIGN KEY REFERENCES Sach(MaSach),
    SoLuong INT CHECK (SoLuong > 0),
    GiaBan DECIMAL(18,2),
    PRIMARY KEY (MaHD, MaSach)
);

CREATE TABLE LichSuDonHang 
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    MaHD INT FOREIGN KEY REFERENCES HoaDon(MaHD),
    TinhTrang INT FOREIGN KEY REFERENCES TinhTrang(ID),
    NgayCapNhat DATETIME DEFAULT GETDATE(),
    GhiChu NVARCHAR(255)
);

-- 5. TƯƠNG TÁC NGƯỜI DÙNG (ĐÁNH GIÁ, YÊU THÍCH)
CREATE TABLE DanhGia 
(
    MaDG INT IDENTITY(1,1) PRIMARY KEY,
    MaKH INT FOREIGN KEY REFERENCES NguoiDung(MaND),
    MaSach INT FOREIGN KEY REFERENCES Sach(MaSach),
    SoSao INT CHECK (SoSao BETWEEN 1 AND 5),
    BinhLuan NVARCHAR(MAX),
    NgayDanhGia DATETIME DEFAULT GETDATE(),
	TrangThai BIT DEFAULT 1 
);

CREATE TABLE YeuThich 
(
    MaKH INT FOREIGN KEY REFERENCES NguoiDung(MaND),
    MaSach INT FOREIGN KEY REFERENCES Sach(MaSach),
    NgayThem DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (MaKH, MaSach)
);

-- 6. GIAO DIỆN 
CREATE TABLE Slider 
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    HinhAnh NVARCHAR(255) NOT NULL
);

CREATE TABLE DichVu 
(
    MaDichVu INT IDENTITY(1,1) PRIMARY KEY,
    TenDichVu NVARCHAR(255) NOT NULL,
	MoTa NVARCHAR(255) NOT NULL,
	Icon NVARCHAR(255) NOT NULL
);

CREATE TABLE GioiThieu
(
	MaGT INT IDENTITY(1,1) PRIMARY KEY,
    TenGT NVARCHAR(255) NOT NULL,
	MoTa NVARCHAR(255) NOT NULL,
	Icon NVARCHAR(255) NOT NULL
);

GO

-- ========================================
-- DỮ LIỆU MẪU
-- ========================================

-- Nhà Xuất Bản
INSERT INTO NXB (TenNXB, DiaChi, DienThoai)
VALUES
	(N'Nhà Xuất Bản Trẻ', N'TP. Hồ Chí Minh', '02838227490'),
	(N'Nhà Xuất Bản Giáo Dục', N'Hà Nội', '02438515320'),
	(N'NXB Tổng Hợp TP.HCM', N'TP. Hồ Chí Minh', '02838225340'),
	(N'NXB Trẻ', N'161B Lý Chính Thắng, Quận 3, TP.HCM', '02838438660'),
	(N'NXB Kim Đồng', N'55 Quang Trung, Hà Nội', '02439432608'),
	(N'NXB Giáo Dục', N'81 Trần Hưng Đạo, Hà Nội', '02439439769'),
	(N'NXB Khoa học và Kỹ thuật', N'Hà Nội', '02438258276'),
	(N'NXB Bách khoa Hà Nội', N'Hà Nội', '02438682136'),
	(N'NXB Lao Động', N'TP. Hồ Chí Minh', '02839304386');
GO

-- Loại Sách 
INSERT INTO LoaiSach (TenLoai, GhiChu, AnhDaiDien)
VALUES
    (N'Tiểu thuyết', N'Sách văn học, tiểu thuyết Việt Nam và nước ngoài', 'tieuthuyet.jpg'),
    (N'Kỹ năng sống', N'Sách phát triển bản thân, kỹ năng mềm', 'kynangsong.jpg'),
    (N'Tin học', N'Sách công nghệ thông tin, lập trình', 'tinhoc.jpg'),
    (N'Giáo trình', N'Sách học tập, tài liệu giảng dạy', 'giaotrinh.jpg'),
    (N'Kinh doanh - Làm giàu', N'Sách phát triển tư duy kinh doanh và tài chính cá nhân', 'kinhdoanh.jpg'),
    (N'Truyện tranh', N'Sách giải trí, truyện tranh Nhật Bản và quốc tế', 'truyentranh.jpg'),
	(N'Khoa học', N'Sách khám phá khoa học, vũ trụ, sinh học, vật lý', 'khoahoc.jpg'),
    (N'Thiếu nhi', N'Sách dành cho trẻ em, truyện cổ tích, sách học tập vui', 'thieunhi.jpg'),
    (N'Nấu ăn', N'Sách hướng dẫn công thức nấu ăn Việt và quốc tế', 'nauan.jpg'),
    (N'Văn học nước ngoài', N'Tác phẩm nổi tiếng của các tác giả quốc tế', 'vanhocnuocngoai.jpg'),
    (N'Tiểu sử - Hồi ký', N'Câu chuyện cuộc đời của những nhân vật nổi tiếng', 'tieusu.jpg'),
    (N'Du lịch', N'Sách hướng dẫn, khám phá các điểm đến trên thế giới', 'dulich.jpg');
GO

-- Sách
INSERT INTO Sach (TenSach, TacGia, NamXB, SoTrang, GiaBan, GiaGoc, SoLuongTon, NoiDung, AnhBia, LuotMua, DiemDanhGia, SoLuotDanhGia, MaLoai, MaNXB)
VALUES
	-- Tiểu thuyết (MaLoai = 1)
	(N'Nhà giả kim', N'Paulo Coelho', 2020, 240, 89000, 120000, 50,
	 N'"Nhà giả kim" là một trong những tác phẩm truyền cảm hứng nổi tiếng nhất của nhà văn Paulo Coelho. Câu chuyện kể về hành trình của chàng chăn cừu trẻ Santiago rời bỏ quê hương Tây Ban Nha để lên đường tìm kiếm kho báu trong kim tự tháp Ai Cập. Trên đường đi, cậu gặp nhiều người và học được những bài học quý giá về niềm tin, số phận và sức mạnh của ước mơ. Tác phẩm không chỉ là một câu chuyện phiêu lưu kỳ diệu mà còn là triết lý sống sâu sắc, khơi dậy khát vọng theo đuổi mục tiêu và tin tưởng vào chính bản thân mình.', 
	 'nhagiakim.jpg', 350, 4.85, 95, 1, 1),
	
	(N'Truyện Kiều', N'Nguyễn Du', 2018, 350, 75000, 95000, 30,
	 N'"Truyện Kiều" của đại thi hào Nguyễn Du là kiệt tác văn học cổ điển Việt Nam, được xem là đỉnh cao của nghệ thuật thơ ca dân tộc. Tác phẩm kể về cuộc đời của Thúy Kiều – một người con gái tài sắc vẹn toàn nhưng phải chịu nhiều đau khổ trong xã hội phong kiến bất công. Bằng ngòi bút nhân đạo và tinh tế, Nguyễn Du đã khắc họa sâu sắc thân phận con người, nỗi đau của tình yêu, chữ hiếu và nhân nghĩa. Tác phẩm là sự kết hợp tuyệt vời giữa nghệ thuật ngôn từ, triết lý nhân sinh và tinh thần nhân đạo sâu sắc.', 
	 'truyenkieu.jpg', 120, 4.60, 40, 1, 1),
	
	(N'Lịch sử Việt Nam', N'Trần Trọng Kim', 2018, 600, 130000, 160000, 40,
	 N'"Lịch sử Việt Nam" của Trần Trọng Kim là công trình nghiên cứu có giá trị lớn, ghi lại toàn bộ quá trình hình thành, phát triển và đấu tranh của dân tộc Việt Nam từ thời dựng nước đến thời cận đại. Tác phẩm được trình bày khoa học, mạch lạc và dễ hiểu, giúp người đọc hình dung được dòng chảy lịch sử của đất nước qua từng triều đại. Không chỉ là tài liệu học tập hữu ích, cuốn sách còn nuôi dưỡng lòng yêu nước, tự hào dân tộc và ý thức bảo tồn giá trị truyền thống Việt Nam trong mỗi người.', 
	 'lichsuVN.jpg', 80, 4.45, 25, 1, 3),

	-- Kỹ năng sống (MaLoai = 2)
	(N'Đắc nhân tâm', N'Dale Carnegie', 2019, 320, 99000, 130000, 80,
	 N'"Đắc nhân tâm" là cuốn sách kinh điển của Dale Carnegie, giúp người đọc hiểu rõ hơn về nghệ thuật ứng xử và cách xây dựng mối quan hệ tốt đẹp với người khác. Thông qua những câu chuyện thực tế, tác giả chỉ ra rằng thành công không chỉ đến từ tài năng mà còn từ khả năng thấu hiểu và tôn trọng người khác. Cuốn sách mang đến những nguyên tắc vàng để sống hạnh phúc, giao tiếp hiệu quả và đạt được lòng tin của mọi người. Đây là tác phẩm không thể thiếu với bất kỳ ai muốn phát triển bản thân và hoàn thiện kỹ năng xã hội.', 
	 'dacnhantam.jpg', 450, 4.70, 110, 2, 3),
	
	(N'7 Thói quen hiệu quả', N'Stephen R. Covey', 2021, 410, 115000, 150000, 60,
	 N'"7 Thói quen hiệu quả" của Stephen R. Covey trình bày khuôn khổ toàn diện để đạt được hiệu suất cao dựa trên "nguyên tắc và giá trị cốt lõi". Sách hướng dẫn người đọc chuyển đổi từ sự phụ thuộc sang độc lập và cuối cùng là sự phụ thuộc lẫn nhau thông qua bảy thói quen. Bảy thói quen này bao gồm việc đạt được "chiến thắng cá nhân" (Chủ động, Bắt đầu bằng đích đến, Ưu tiên việc quan trọng) và "chiến thắng công cộng" (Tư duy cùng thắng, Thấu hiểu rồi được thấu hiểu, Hợp lực sáng tạo). Cuốn sách là một cẩm nang thiết thực giúp bạn thay đổi tư duy, nâng cao năng suất, và xây dựng mối quan hệ bền vững.', 
	 '7thoiquen.jpg', 380, 4.80, 105, 2, 3),
	
	(N'Bí mật của Phan Thiên Ân', N'Andy Andrews', 2022, 280, 105000, 130000, 45,
	 N'"Bí mật của Phan Thiên Ân" là câu chuyện truyền cảm hứng về hành trình tìm lại giá trị cuộc sống của một doanh nhân trẻ đang dần đánh mất niềm tin và ý nghĩa trong công việc. Thông qua những bài học triết lý sâu sắc được truyền lại từ người thầy, Phan Thiên Ân đã nhận ra sức mạnh của lòng biết ơn, tình yêu thương và sự kiên trì. Cuốn sách khuyến khích người đọc tin tưởng vào bản thân, sống có mục tiêu và lan tỏa năng lượng tích cực đến mọi người xung quanh. Đây là tác phẩm đầy nhân văn, chạm đến trái tim của hàng triệu độc giả.', 
	 'phanthienan.jpg', 190, 4.65, 55, 2, 1),

	-- Tin học (MaLoai = 3)
	(N'Lập trình C cơ bản', N'Nguyễn Tấn Trực', 2022, 360, 95000, 120000, 70,
	 N'"Lập trình C cơ bản" là giáo trình hướng dẫn người mới bắt đầu làm quen với ngôn ngữ lập trình C – nền tảng của nhiều ngôn ngữ lập trình hiện đại. Cuốn sách được biên soạn rõ ràng, dễ hiểu, đi từ các khái niệm cơ bản như biến, hàm, mảng đến những nội dung nâng cao như con trỏ, cấu trúc và xử lý tệp. Mỗi chương đều có ví dụ minh họa thực tế và bài tập thực hành giúp người học rèn luyện kỹ năng. Đây là tài liệu không thể thiếu cho sinh viên CNTT và những ai muốn bắt đầu hành trình lập trình của mình.', 
	 'laptrinhc.jpg', 150, 4.55, 60, 3, 2),
	
	(N'Python cho người mới bắt đầu', N'Eric Matthes', 2023, 500, 135000, 170000, 65,
	 N'"Python cho người mới bắt đầu" của Eric Matthes là cuốn sách hướng dẫn lập trình thực hành, giúp người đọc làm quen với Python thông qua các dự án cụ thể. Sách giới thiệu những kiến thức cơ bản về cú pháp, kiểu dữ liệu, vòng lặp và hàm, sau đó hướng dẫn xây dựng các ứng dụng như trò chơi, web, hay xử lý dữ liệu. Với phong cách trình bày dễ hiểu và trực quan, đây là tài liệu tuyệt vời cho sinh viên, lập trình viên mới và bất kỳ ai muốn khám phá thế giới lập trình bằng Python.', 
	 'pythoncoban.jpg', 210, 4.75, 75, 3, 2),
	
	(N'Cấu trúc dữ liệu và giải thuật', N'Lê Minh Hoàng', 2021, 380, 115000, 140000, 50,
	 N'"Cấu trúc dữ liệu và giải thuật" là tài liệu học tập quan trọng dành cho sinh viên ngành Công nghệ thông tin và những người theo đuổi lập trình chuyên nghiệp. Cuốn sách cung cấp cái nhìn toàn diện về các cấu trúc dữ liệu như danh sách, ngăn xếp, hàng đợi, cây, đồ thị cùng với những thuật toán tìm kiếm và sắp xếp hiệu quả. Mỗi khái niệm được trình bày kèm ví dụ minh họa và phân tích độ phức tạp chi tiết, giúp người đọc hiểu sâu bản chất vấn đề. Đây là nền tảng vững chắc để phát triển tư duy lập trình và giải quyết bài toán tối ưu.', 
	 'giaithuat.jpg', 110, 4.50, 45, 3, 2),

	-- Giáo trình (MaLoai = 4)
	(N'Toán cao cấp', N'Nguyễn Đình Trí', 2020, 500, 98000, 125000, 100,
	 N'"Toán cao cấp" là giáo trình nền tảng được biên soạn dành cho sinh viên đại học, cao đẳng các khối kỹ thuật và kinh tế. Cuốn sách cung cấp kiến thức toàn diện về giới hạn, đạo hàm, tích phân, chuỗi số, ma trận và phương trình vi phân. Với cách trình bày rõ ràng, dễ hiểu và hệ thống bài tập phong phú, sách giúp người học rèn luyện tư duy logic và khả năng phân tích. Ngoài ra, phần ứng dụng toán học trong thực tế được bổ sung nhằm giúp sinh viên thấy được mối liên hệ giữa lý thuyết và thực hành, từ đó củng cố kiến thức và nâng cao hiệu quả học tập.', 
	 'toancaocap.jpg', 250, 4.35, 80, 4, 2),
	
	(N'Lý thuyết xác suất và thống kê', N'Phạm Văn Tiến', 2021, 420, 105000, 135000, 90,
	 N'"Lý thuyết xác suất và thống kê" là giáo trình quan trọng dành cho sinh viên ngành kinh tế, kỹ thuật và khoa học máy tính. Cuốn sách giúp người đọc hiểu rõ các khái niệm về biến ngẫu nhiên, phân phối xác suất, kỳ vọng, phương sai, kiểm định giả thuyết và hồi quy. Ngoài lý thuyết cơ bản, sách còn cung cấp nhiều ví dụ minh họa thực tế, giúp người học áp dụng phương pháp thống kê vào xử lý dữ liệu và phân tích kết quả nghiên cứu. Đây là tài liệu không thể thiếu cho những ai muốn làm việc với dữ liệu và phát triển kỹ năng phân tích định lượng.', 
	 'xacsuatthongke.jpg', 200, 4.40, 70, 4, 2),
	
	(N'Truyền nhiệt học', N'Nguyễn Văn Hòa', 2019, 460, 112000, 140000, 70,
	 N'"Truyền nhiệt học" là giáo trình chuyên sâu dành cho sinh viên kỹ thuật, đặc biệt là ngành cơ khí, nhiệt – lạnh và năng lượng. Cuốn sách trình bày các hiện tượng truyền dẫn nhiệt, đối lưu và bức xạ, cùng với các phương pháp tính toán thực tế trong thiết kế hệ thống trao đổi nhiệt. Tác giả minh họa sinh động bằng hình ảnh, đồ thị và ví dụ kỹ thuật giúp người học dễ dàng nắm bắt kiến thức. Đây là tài liệu tham khảo hữu ích cho sinh viên, kỹ sư và những ai làm việc trong lĩnh vực kỹ thuật nhiệt và công nghệ năng lượng.', 
	 'truyennhiet.jpg', 130, 4.25, 45, 4, 2),

	-- Kinh doanh - Làm giàu (MaLoai = 5)
	(N'Cha giàu cha nghèo', N'Robert Kiyosaki', 2021, 380, 120000, 150000, 75,
	 N'"Cha giàu cha nghèo" là một trong những cuốn sách tài chính cá nhân nổi tiếng nhất mọi thời đại. Robert Kiyosaki kể lại câu chuyện giữa hai người cha – một người giàu, một người nghèo – để giúp độc giả nhận ra sự khác biệt trong tư duy về tiền bạc, đầu tư và tự do tài chính. Tác phẩm giúp người đọc hiểu cách làm cho tiền bạc làm việc cho mình thay vì làm việc vì tiền. Với ngôn từ giản dị, dễ hiểu, cuốn sách đã truyền cảm hứng cho hàng triệu người trên thế giới bắt đầu hành trình làm chủ tài chính cá nhân và đạt được sự độc lập kinh tế.', 
	 'chagiauchangheo.jpg', 550, 4.88, 150, 5, 3),
	
	(N'Tư duy nhanh và chậm', N'Daniel Kahneman', 2022, 520, 145000, 180000, 40,
	 N'Trong "Tư duy nhanh và chậm", Daniel Kahneman – nhà kinh tế học đạt giải Nobel – phân tích cách hai hệ thống tư duy của con người hoạt động: hệ thống nhanh (trực giác) và hệ thống chậm (lý trí). Ông chỉ ra rằng, phần lớn các quyết định trong cuộc sống và công việc đều chịu ảnh hưởng bởi những thiên kiến nhận thức vô thức. Thông qua hàng loạt ví dụ thực tế, tác giả giúp người đọc nhận ra cách cải thiện khả năng ra quyết định, tư duy phản biện và tránh sai lầm trong phân tích. Đây là cuốn sách quan trọng cho những ai muốn hiểu sâu hơn về tâm lý học hành vi và tư duy con người.', 
	 'tuduynhanhcham.jpg', 290, 4.70, 85, 5, 3),
	
	(N'Người giàu có nhất thành Babylon', N'George S. Clason', 2020, 320, 99000, 130000, 55,
	 N'"Người giàu có nhất thành Babylon" là tác phẩm kinh điển về tài chính cá nhân, được viết bằng những câu chuyện ngụ ngôn sâu sắc từ thành phố Babylon cổ đại. Cuốn sách dạy người đọc những nguyên tắc cơ bản nhưng vô cùng hiệu quả để quản lý tiền bạc: tiết kiệm, đầu tư, chi tiêu hợp lý và không ngừng học hỏi. Với ngôn ngữ giản dị, dễ hiểu, tác giả truyền tải triết lý rằng bất kỳ ai cũng có thể trở nên giàu có nếu biết kỷ luật và kiên trì. Đây là cuốn sách gối đầu giường cho những người mong muốn tự do tài chính và thành công bền vững.', 
	 'babylon.jpg', 310, 4.68, 90, 5, 3),

	-- Truyện tranh (MaLoai = 6)
	(N'Doraemon - Chú mèo máy đến từ tương lai', N'Fujiko F. Fujio', 2022, 200, 25000, 30000, 150,
	 N'"Doraemon" kể về chú mèo máy đến từ thế kỷ 22 được gửi về quá khứ để giúp cậu bé hậu đậu Nobita thay đổi cuộc sống. Với chiếc túi thần kỳ chứa đầy bảo bối, Doraemon cùng Nobita, Shizuka, Jaian và Suneo đã trải qua vô số cuộc phiêu lưu kỳ thú. Bộ truyện không chỉ mang đến tiếng cười mà còn ẩn chứa những bài học về tình bạn, lòng dũng cảm, tinh thần sáng tạo và ước mơ. Đây là tác phẩm kinh điển của tuổi thơ, được yêu thích trên toàn thế giới.', 
	 'doraemon.jpg', 600, 4.90, 180, 6, 5),
	
	(N'Thám tử lừng danh Conan', N'Gosho Aoyama', 2023, 190, 30000, 35000, 140,
	 N'"Thám tử lừng danh Conan" là bộ truyện trinh thám nổi tiếng của Nhật Bản, xoay quanh cậu học sinh trung học Shinichi Kudo bị thu nhỏ thành Conan sau khi uống phải thuốc độc. Từ đó, cậu tiếp tục phá giải các vụ án bí ẩn bằng trí thông minh phi thường. Bộ truyện hấp dẫn với những tình tiết gay cấn, logic chặt chẽ cùng yếu tố tình cảm nhẹ nhàng. Đây là tác phẩm không thể bỏ qua cho những ai yêu thích thể loại trinh thám và suy luận.', 
	 'conan.jpg', 580, 4.75, 170, 6, 5),
	
	(N'One Piece - Vua hải tặc', N'Eiichiro Oda', 2023, 210, 35000, 40000, 160,
	 N'"One Piece" kể về hành trình của cậu bé Luffy – người mang trong mình ước mơ trở thành Vua Hải Tặc. Cùng với đồng đội Mũ Rơm, Luffy vượt qua nhiều thử thách, khám phá những vùng biển bí ẩn và đối đầu với các thế lực hùng mạnh. Bộ truyện không chỉ mang đến những trận chiến mãn nhãn mà còn truyền tải thông điệp sâu sắc về tình bạn, ước mơ và khát vọng tự do. "One Piece" đã trở thành biểu tượng của manga Nhật Bản với lượng người hâm mộ khổng lồ trên toàn cầu.', 
	 'onepiece.jpg', 720, 4.92, 210, 6, 5),

	 -- Khoa học (MaLoai = 7)
	(N'Vũ trụ trong vỏ hạt dẻ', N'Stephen Hawking', 2020, 250, 145000, 180000, 40,
	 N'"Vũ trụ trong vỏ hạt dẻ" là tác phẩm nổi tiếng của nhà vật lý thiên tài Stephen Hawking, tiếp nối thành công của "Lược sử thời gian". Cuốn sách trình bày những khái niệm phức tạp về vật lý lượng tử, thuyết tương đối, và bản chất của vũ trụ bằng ngôn ngữ dễ hiểu, sinh động, kết hợp hình ảnh minh họa tuyệt đẹp. Tác phẩm giúp người đọc nhận ra vẻ đẹp kỳ diệu của khoa học và khơi dậy trí tò mò về vũ trụ bao la. Đây là cuốn sách không thể thiếu cho những ai yêu thích khám phá bí ẩn của không gian và thời gian.', 
	 'vutruvohatde.jpg', 90, 4.60, 30, 7, 3),
	
	(N'Lược sử thời gian', N'Stephen Hawking', 2019, 300, 150000, 190000, 35,
	 N'Tác phẩm khoa học phổ thông kinh điển đã làm thay đổi cách công chúng nhìn nhận về vật lý lý thuyết và vũ trụ học hiện đại. Stephen Hawking đã tóm tắt lịch sử và cấu trúc của vũ trụ, từ Vụ Nổ Lớn (Big Bang) đến các lỗ đen, mà không cần sử dụng bất kỳ công thức toán học phức tạp nào. Cuốn sách khám phá các khái niệm như "không gian, thời gian, hố đen, và lực hấp dẫn", đặt ra những câu hỏi sâu sắc về nguồn gốc, bản chất và số phận cuối cùng của vũ trụ. Đây là một hành trình triết lý và khoa học tuyệt vời, thách thức hiểu biết thông thường của con người về thế giới.', 
	 'luocsuthoigian.jpg', 75, 4.55, 25, 7, 3),

	-- Thiếu nhi (MaLoai = 8)
	(N'Không gia đình', N'Hector Malot', 2022, 420, 85000, 110000, 50,
	 N'Tác phẩm kinh điển của văn học thiếu nhi Pháp kể về cậu bé Rémi mồ côi, sống cuộc đời lang thang cùng gánh xiếc của cụ Vitalis. Dù phải trải qua nhiều gian khổ, Rémi vẫn giữ được tấm lòng nhân hậu, nghị lực và khát vọng tìm về gia đình. “Không gia đình” là câu chuyện cảm động, ca ngợi tình người, lòng dũng cảm và niềm tin vào cuộc sống. Cuốn sách là người bạn đồng hành tuyệt vời cho mọi thế hệ thiếu nhi.', 
	 'khonggiadinh.jpg', 220, 4.75, 65, 8, 5),
	
	(N'Hoàng tử bé', N'Antoine de Saint-Exupéry', 2023, 150, 78000, 95000, 80,
	 N'"Hoàng tử bé" là câu chuyện nhẹ nhàng, đầy chất thơ kể về hành trình của một cậu bé từ hành tinh nhỏ bé đến Trái Đất. Bằng những cuộc gặp gỡ và đối thoại giản dị, tác giả gửi gắm những thông điệp sâu sắc về tình yêu, sự cô đơn và ý nghĩa của cuộc sống. Cuốn sách không chỉ dành cho trẻ em mà còn khiến người lớn suy ngẫm về cách nhìn cuộc đời với trái tim trong sáng. Đây là tác phẩm vượt thời gian, được dịch ra hơn 300 ngôn ngữ trên thế giới.', 
	 'hoangtube.jpg', 300, 4.95, 85, 8, 1),

	-- Nấu ăn (MaLoai = 9)
	(N'Nấu ăn Gia đình', N'Triệu Thị Chơi', 2021, 300, 99000, 120000, 60,
	 N'Cuốn sách tập hợp hơn 100 công thức món ăn truyền thống của Việt Nam, từ những món dân dã như canh chua, cá kho tộ đến các món đặc sản vùng miền. Mỗi công thức đều được hướng dẫn chi tiết, dễ hiểu, kèm mẹo chọn nguyên liệu và trình bày đẹp mắt. Tác giả – nghệ nhân ẩm thực Cẩm Vân – chia sẻ bí quyết nấu ăn sao cho “ngon miệng và ấm lòng”. Đây là tài liệu hữu ích cho những ai muốn giữ gìn và phát huy tinh hoa ẩm thực Việt.', 
	 'nauangiadinh.jpg', 180, 4.50, 50, 9, 3),
	
	(N'Ăn xanh để khỏe', N'Nguyễn Thị Thu Hương', 2020, 500, 160000, 200000, 30,
	 N'"Ăn xanh để khỏe" hướng dẫn người đọc cách lựa chọn và chế biến thực phẩm có nguồn gốc tự nhiên, giúp thanh lọc cơ thể, tăng sức đề kháng và duy trì vóc dáng. Sách còn giới thiệu các thực đơn ăn chay khoa học, giàu dinh dưỡng nhưng vẫn hấp dẫn. Đây là cuốn cẩm nang hữu ích cho lối sống lành mạnh và bền vững trong thời đại hiện nay.', 
	 'anxanhdekhoe.jpg', 85, 4.30, 20, 9, 3),

	-- Văn học nước ngoài (MaLoai = 10)
	(N'Giết con chim nhại', N'Harper Lee', 2021, 360, 115000, 145000, 55,
	 N'Tác phẩm đoạt giải Pulitzer, được kể qua con mắt của cô bé Scout Finch, khám phá các vấn đề nhạy cảm như "phân biệt chủng tộc, định kiến và công lý" tại miền Nam nước Mỹ trong những năm 1930. Câu chuyện tập trung vào nỗ lực dũng cảm của luật sư Atticus Finch khi ông bảo vệ một người đàn ông da đen bị buộc tội oan. Cuốn sách không chỉ là một bài ca "về lòng nhân ái, sự đồng cảm và bản lĩnh đạo đức" khi đối diện với bất công, mà còn là một tác phẩm quan trọng giúp người đọc nhìn nhận lại các giá trị nhân văn cốt lõi, mãi là một tác phẩm truyền cảm hứng trong văn học thế giới.', 
	 'gietconchimnhai.jpg', 150, 4.70, 40, 10, 1),
	
	(N'Chiến tranh và hòa bình', N'Lev Tolstoy', 2020, 900, 185000, 220000, 25,
	 N'Bộ tiểu thuyết sử thi vĩ đại, được coi là một trong những thành tựu lớn nhất của văn học thế giới. Tác phẩm đan xen câu chuyện lịch sử về "cuộc xâm lược của Napoleon vào Nga" (1805–1812) với cuộc đời của năm gia đình quý tộc, đặc biệt là Pierre Bezukhov và Hoàng tử Andrei Bolkonsky. Tolstoy đã miêu tả chi tiết, sống động về "chiến tranh tàn khốc và cuộc sống hòa bình" với những triết lý sâu sắc về tình yêu, cái chết, ý nghĩa cuộc đời và vai trò của cá nhân trong lịch sử. Đây là một bức tranh toàn cảnh về xã hội Nga thế kỷ 19, một tác phẩm đồ sộ và giàu tính nhân văn.', 
	 'chientranhhoabinh.jpg', 40, 4.65, 15, 10, 1),
	
	(N'Tiếng gọi nơi hoang dã', N'Jack London', 2021, 280, 89000, 110000, 60,
	 N'Câu chuyện phiêu lưu kinh điển về "Buck", một chú chó nhà bị bắt cóc và đưa đến vùng Yukon lạnh giá của Alaska để kéo xe trượt tuyết trong cơn sốt vàng. Buck buộc phải thích nghi với môi trường khắc nghiệt, phải chiến đấu để sinh tồn và học cách quay trở về với "bản năng hoang dã" nguyên thủy. Tác phẩm là một khám phá sâu sắc về "cuộc chiến sinh tồn", sự xung đột giữa văn minh và tự nhiên, và sự trỗi dậy của những bản năng mạnh mẽ nhất trong mọi sinh vật. Sách tôn vinh sức mạnh tiềm ẩn và lòng trung thành mãnh liệt của loài vật.', 
	 'tienggoihoangda.jpg', 110, 4.55, 35, 10, 3),

	-- Tiểu sử - Hồi ký (MaLoai = 11)
	(N'Elon Musk: Tesla, SpaceX và cuộc chinh phục vũ trụ', N'Ashlee Vance', 2022, 450, 135000, 170000, 40,
	 N'Cuốn tiểu sử toàn diện về "Elon Musk", một trong những doanh nhân có tầm ảnh hưởng lớn nhất thế giới, người đứng sau các công ty mang tính cách mạng như PayPal, Tesla, SpaceX và SolarCity. Sách kể lại cuộc đời Musk từ thời thơ ấu đầy khó khăn ở Nam Phi đến những thách thức kịch tính trong việc xây dựng các công ty công nghệ tiên phong. Đây là một câu chuyện hấp dẫn về "sự đổi mới không ngừng, tham vọng chinh phục không gian" và nỗ lực phi thường để thay đổi tương lai nhân loại, khắc họa rõ nét tính cách phức tạp, sự kiên trì và tầm nhìn phi thường của Musk.', 
	 'elonmusk.jpg', 160, 4.80, 50, 11, 3),
	
	(N'Becoming - Chất Michelle', N'Michelle Obama', 2021, 500, 145000, 180000, 35,
	 N'Hồi ký chân thực và sâu sắc của "Michelle Obama", cựu Đệ nhất phu nhân Hoa Kỳ. Bà chia sẻ về cuộc đời mình qua ba phần chính: "Trưởng thành" (gốc gác tại South Side, Chicago), "Chúng ta" (mối quan hệ với Barack Obama và hành trình làm mẹ), và "Hơn thế nữa" (những năm tháng tại Nhà Trắng). Cuốn sách là một cái nhìn thẳng thắn vào những thách thức về chủng tộc, giới tính, chính trị, và là một lời kêu gọi mạnh mẽ về "tầm quan trọng của tiếng nói và hành động" trong việc kiến tạo tương lai, truyền cảm hứng về việc tìm kiếm bản sắc và mục đích sống.',
	 'becoming.jpg', 140, 4.75, 45, 11, 3),
	
	(N'Steve Jobs', N'Walter Isaacson', 2020, 600, 155000, 190000, 50,
	 N'Tiểu sử chính thức và chi tiết về "Steve Jobs", nhà đồng sáng lập Apple, dựa trên hơn 40 cuộc phỏng vấn với Jobs và hàng trăm cuộc phỏng vấn với gia đình, bạn bè, đối thủ và đồng nghiệp. Tác giả Walter Isaacson đã nắm bắt được "tính cách phức tạp, sự hoàn hảo ám ảnh và niềm đam mê đổi mới" đã giúp Jobs thay đổi hoàn toàn sáu ngành công nghiệp: máy tính cá nhân, phim hoạt hình, âm nhạc, điện thoại, máy tính bảng và xuất bản kỹ thuật số. Cuốn sách là cái nhìn chân thật về thiên tài, tầm nhìn và những mâu thuẫn bên trong con người huyền thoại này.', 
	 'stevejobs.jpg', 200, 4.85, 60, 11, 3),

	-- Du lịch (MaLoai = 12)
	(N'Bụi đường tuổi trẻ', N'Trần Hạo Nam', 2018, 380, 98000, 120000, 60,
	 N'"Bụi đường tuổi trẻ" là hành trình rong ruổi khắp đất nước của một chàng trai trẻ đam mê khám phá. Qua từng trang viết, tác giả chia sẻ trải nghiệm thực tế, những câu chuyện giản dị nhưng đầy cảm xúc về con người và văn hóa Việt Nam. Cuốn sách khơi dậy tinh thần tự do, khát khao chinh phục và niềm yêu quê hương đất nước. Đây là cuốn sách truyền cảm hứng tuyệt vời cho những tâm hồn thích xê dịch.', 
	 'buiduongtuoitre.jpg', 100, 4.40, 30, 12, 1),
	
	(N'Ăn, Cầu nguyện, Yêu', N'Elizabeth Gilbert', 2023, 420, 150000, 180000, 45,
	 N'Cuốn hồi ký du lịch nổi tiếng kể về hành trình của Elizabeth đến Ý, Ấn Độ và Indonesia để tìm lại cân bằng sau đổ vỡ. Mỗi nơi là một chặng đường khám phá bản thân – từ niềm vui ẩm thực, sự tĩnh tâm trong thiền định, đến tình yêu mới. Với văn phong gần gũi và sâu sắc, “Ăn, Cầu nguyện, Yêu” trở thành hiện tượng toàn cầu, truyền cảm hứng sống tích cực cho hàng triệu độc giả.', 
	 'an_caunguyen_yeu.jpg', 130, 4.70, 40, 12, 3);
GO
	
-- Hình ảnh cho các sách
INSERT INTO HinhAnh (MaSach, HinhAnh)
VALUES
	-- Tiểu thuyết
	(1, 'nhagiakim_1.jpg'),
	(1, 'nhagiakim_2.jpg'),
	(2, 'truyenkieu_1.jpg'),
	(2, 'truyenkieu_2.jpg'),
	(3, 'lichsuVN_1.jpg'),
	(3, 'lichsuVN_2.jpg'),

	-- Kỹ năng sống
	(4, 'dacnhantam_1.jpg'),
	(4, 'dacnhantam_2.jpg'),
	(5, '7thoiquen_1.jpg'),
	(5, '7thoiquen_2.jpg'),
	(6, 'phanthienan_1.jpg'),
	(6, 'phanthienan_2.jpg'),

	-- Tin học
	(7, 'laptrinhc_1.jpg'),
	(7, 'laptrinhc_2.jpg'),
	(8, 'pythoncoban_1.jpg'),
	(8, 'pythoncoban_2.jpg'),
	(9, 'giaithuat_1.jpg'),
	(9, 'giaithuat_2.jpg'),

	-- Giáo trình
	(10, 'toancaocap_1.jpg'),
	(10, 'toancaocap_2.jpg'),
	(11, 'xacsuatthongke_1.jpg'),
	(11, 'xacsuatthongke_2.jpg'),
	(12, 'truyennhiet_1.jpg'),
	(12, 'truyennhiet_2.jpg'),

	-- Kinh doanh - Làm giàu
	(13, 'chagiauchangheo_1.jpg'),
	(13, 'chagiauchangheo_2.jpg'),
	(14, 'tuduynhanhcham_1.jpg'),
	(14, 'tuduynhanhcham_2.jpg'),
	(15, 'babylon_1.jpg'),
	(15, 'babylon_2.jpg'),

	-- Truyện tranh
	(16, 'doraemon_1.jpg'),
	(16, 'doraemon_2.jpg'),
	(17, 'conan_1.jpg'),
	(17, 'conan_2.jpg'),
	(18, 'onepiece_1.jpg'),
	(18, 'onepiece_2.jpg'),

	-- Khoa học
	(19, 'vutruvohatde_1.jpg'),
	(19, 'vutruvohatde_2.jpg'),
    (20, 'luocsuthoigian_1.jpg'),
    (20, 'luocsuthoigian_2.jpg'),

	-- Thiếu nhi
    (21, 'khonggiadinh_1.jpg'),
    (21, 'khonggiadinh_2.jpg'),
    (22, 'hoangtube_1.jpg'),
    (22, 'hoangtube_2.jpg'),

	-- Nấu ăn
    (23, 'nauangiadinh_1.jpg'),
    (23, 'nauangiadinh_2.jpg'),
    (24, 'anxanhdekhoe_1.jpg'),
    (24, 'anxanhdekhoe_2.jpg'),

	-- Văn học nước ngoài
    (25, 'gietconchimnhai_1.jpg'),
    (25, 'gietconchimnhai_2.jpg'),
    (26, 'chientranhhoabinh_1.jpg'),
    (26, 'chientranhhoabinh_2.jpg'),
    (27, 'tienggoihoangda_1.jpg'),
    (27, 'tienggoihoangda_2.jpg'),

	-- Tiểu sử - Hồi ký
    (28, 'elonmusk_1.jpg'),
    (28, 'elonmusk_2.jpg'),
    (29, 'becoming_1.jpg'),
    (29, 'becoming_2.jpg'),
    (30, 'stevejobs_1.jpg'),
    (30, 'stevejobs_2.jpg'),

	-- Du lịch
    (31, 'buiduongtuoitre_1.jpg'),
    (31, 'buiduongtuoitre_2.jpg'),
    (32, 'an_caunguyen_yeu_1.jpg'),
    (32, 'an_caunguyen_yeu_2.jpg');

GO

-- Vai trò
INSERT INTO VaiTro (TenVaiTro, MoTa)
VALUES 
    (N'Admin', N'Quản trị hệ thống, quản lý sản phẩm, đơn hàng và người dùng'),
    (N'KhachHang', N'Người mua hàng trực tuyến, có thể đặt hàng và đánh giá sản phẩm');
GO

-- Người dùng
INSERT INTO NguoiDung (TenDangNhap, MatKhau, HoTen, GioiTinh, NamSinh, AnhDaiDien, DienThoai, Email, DiaChi, IDVaiTro)
VALUES
    (N'admin', N'245lIgHhuwUAb8MC3G16Db3wuNUTfCjahlUQZZQkm5k=', N'Book Heaven', N'Nam', 1990, 'admin.png', '0909000001', 'admin@bookheaven.vn', N'TP. Hồ Chí Minh', 1),
    (N'vanan', N'245lIgHhuwUAb8MC3G16Db3wuNUTfCjahlUQZZQkm5k=', N'Nguyễn Văn An', N'Nam', 1998, 'user1.png', '0909123456', 'vanab@gmail.com', N'Hà Nội', 2),
    (N'thibinh', N'245lIgHhuwUAb8MC3G16Db3wuNUTfCjahlUQZZQkm5k=', N'Trần Thị Bình', N'Nữ', 2000, 'user2.png', '0912345678', 'thibinh@gmail.com', N'Đà Nẵng', 2),
    (N'minhcuong', N'245lIgHhuwUAb8MC3G16Db3wuNUTfCjahlUQZZQkm5k=', N'Lê Minh Cường', N'Nam', 1995, 'user3.png', '0934567890', 'minhcuong@gmail.com', N'Hải Phòng', 2),
    (N'thidung', N'245lIgHhuwUAb8MC3G16Db3wuNUTfCjahlUQZZQkm5k=', N'Đỗ Thị Dung', N'Nữ', 2002, 'user4.png', '0945678901', 'thidung@gmail.com', N'Cần Thơ', 2),
    (N'vanhung', N'245lIgHhuwUAb8MC3G16Db3wuNUTfCjahlUQZZQkm5k=', N'Phạm Văn Hùng', N'Nam', 1999, 'user5.png', '0978123456', 'vanhung@gmail.com', N'TP. Hồ Chí Minh', 2),
	(N'thanhloan', N'245lIgHhuwUAb8MC3G16Db3wuNUTfCjahlUQZZQkm5k=', N'Nguyễn Thanh Loan', N'Nữ', 1993, 'user6.png', '0987654321', 'thanhloan@gmail.com', N'Huế', 2),
	(N'quanghieu', N'245lIgHhuwUAb8MC3G16Db3wuNUTfCjahlUQZZQkm5k=', N'Trần Quang Hiếu', N'Nam', 2001, 'user7.png', '0963214587', 'quanghieu@gmail.com', N'Nha Trang', 2),
	(N'ngocmai', N'245lIgHhuwUAb8MC3G16Db3wuNUTfCjahlUQZZQkm5k=', N'Phạm Ngọc Mai', N'Nữ', 1997, 'user8.png', '0901239876', 'ngocmai@gmail.com', N'Vũng Tàu', 2),
	(N'vandat', N'245lIgHhuwUAb8MC3G16Db3wuNUTfCjahlUQZZQkm5k=', N'Hoàng Văn Đạt', N'Nam', 1996, 'user9.png', '0918765432', 'vandat@gmail.com', N'Đà Lạt', 2);
GO 

-- Khuyến mãi
INSERT INTO KhuyenMai (TenKM, MoTa, LoaiKM, GiaTriGiam, DonToiThieu, NgayBatDau, NgayKetThuc, HinhAnh)
VALUES
    (N'Giảm 10% đầu tháng', N'Áp dụng cho tất cả các đơn hàng trên 100.000đ', N'PhanTram', 10, 100000, '2025-10-01', '2025-12-15', 'khuyenmai1.png'),
    (N'Giảm 30.000đ cho đơn từ 200.000đ', N'Giảm trực tiếp vào hóa đơn', N'TienMat', 30000, 200000, '2025-10-20', '2025-12-10', 'khuyenmai2.png'),
    (N'Flash Sale cuối tuần giảm 15%', N'Áp dụng riêng cho các sách có thể loại là truyện tranh', N'PhanTram', 15, 0, '2025-10-25', '2025-12-31', 'khuyenmai3.png');
GO

-- Liên kết khuyến mãi với sách
INSERT INTO Sach_KhuyenMai (MaSach, MaKM)
VALUES
    (1, 1), (2, 1), (4, 1), (5, 1), (13, 1), (14, 1), (15, 1),
	(4, 2), (5, 2), (13, 2), (14, 2), (15, 2), (28, 2), (29, 2), (30, 2),
	(16, 3), (17, 3), (18, 3),
	(27, 3);
GO

-- Danh sách giỏ hàng
INSERT INTO GioHang (MaKH, MaSach, SoLuong)
VALUES
    (2, 17, 1), (2, 21, 2), (2, 6, 1),
    (3, 2, 1), (3, 9, 2), (3, 27, 1), (3, 15, 1),
    (4, 1, 1), (4, 10, 2), (4, 22, 1),
    (5, 3, 1), (5, 6, 1), (5, 9, 2), (5, 7, 1),
    (6, 5, 1), (6, 8, 1), (6, 12, 1), (6, 14, 2),
    (7, 2, 1), (7, 4, 2), (7, 30, 1),
    (8, 1, 1), (8, 10, 1),
    (9, 4, 2), (9, 18, 1),
    (10, 5, 1), (10, 6, 2);
GO

-- Tình trạng đơn hàng
INSERT INTO TinhTrang (TinhTrangHoaDon)
VALUES 
    (N'Chờ xử lý'),
    (N'Đang giao'),
    (N'Hoàn tất'),
    (N'Đã hủy'),
	(N'Đã đóng gói'),
	(N'Đã giao cho đối tác vận chuyển'),
	(N'Đã nhận hàng');
GO

-- Phương thức thanh toán
INSERT INTO PhuongThucThanhToan (TenPTTT, MoTa)
VALUES
    (N'Thanh toán khi nhận hàng (COD)', N'Khách hàng trả tiền mặt khi nhận hàng'),
	(N'Chuyển khoản ngân hàng', N'Thanh toán qua tài khoản ngân hàng'),
	(N'Ví điện tử MoMo', N'Thanh toán trực tuyến qua ví MoMo'),
	(N'ZaloPay', N'Thanh toán nhanh qua ZaloPay'),
	(N'Thẻ Tín dụng/Ghi nợ', N'Thanh toán qua cổng thanh toán VNPAY'),
	(N'Ví điện tử ShopeePay', N'Thanh toán trực tuyến qua ShopeePay');
GO

-- Hóa đơn
INSERT INTO HoaDon (MaKH, MaKM, TongTien, GiamGia, PhiVanChuyen, ThanhTien, DiaChiGiaoHang, GhiChu, TinhTrang, MaPTTT, DaThanhToan)
VALUES
    (2, 1, 283000, 28300, 20000, 274700, N'Hà Nội', N'Giao buổi sáng', 1, 1, 0),
	(3, 2, 350000, 30000, 25000, 345000, N'Đà Nẵng', N'Giao buổi chiều', 7, 2, 1),
	(4, NULL, 120000, 0, 20000, 140000, N'Hải Phòng', N'Giao nhanh', 3, 3, 1),
	(5, 3, 95000, 14250, 15000, 95750, N'Cần Thơ', N'Giao giờ hành chính', 5, 1, 0),
	(6, 1, 345000, 34500, 30000, 340500, N'TP. Hồ Chí Minh', N'Gói quà tặng kèm', 6, 4, 1),
	(7, 2, 410000, 30000, 25000, 405000, N'Huế', N'Giao cuối tuần', 2, 5, 1),
	(8, NULL, 177000, 0, 20000, 197000, N'Nha Trang', N'Đơn hàng gấp', 4, 6, 0);
GO 

-- Chi tiết hóa đơn
INSERT INTO ChiTietHoaDon (MaHD, MaSach, SoLuong, GiaBan)
VALUES
    (1, 1, 1, 89000),
	(1, 4, 1, 99000),
	(1, 7, 1, 95000),
	
	(2, 5, 2, 115000),
	(2, 13, 1, 120000),
	
	(3, 16, 3, 25000),
	(3, 6, 1, 45000),
	
	(4, 17, 2, 30000),
	(4, 18, 1, 35000),
	
	(5, 14, 1, 145000),
	(5, 6, 1, 105000),
	(5, 7, 1, 95000),
	
	(6, 30, 1, 155000),
	(6, 22, 2, 78000),
	(6, 23, 1, 99000),
	
	(7, 2, 1, 75000),
	(7, 12, 1, 102000);
GO

-- Lịch sử đơn hàng
INSERT INTO LichSuDonHang (MaHD, TinhTrang, GhiChu)
VALUES
    (1, 1, N'Khách hàng vừa đặt hàng (COD)'),
	(1, 5, N'Đã đóng gói và chờ lấy hàng'),
	(2, 1, N'Khách hàng vừa đặt hàng (Đã thanh toán)'),
	(2, 5, N'Đã đóng gói'),
    (2, 6, N'Đã giao cho đối tác vận chuyển'),
	(2, 7, N'Khách hàng đã nhận hàng và hoàn tất'),
	(3, 1, N'Đơn hàng đã được xác nhận và thanh toán'),
	(3, 3, N'Đã hoàn tất'),
	(4, 1, N'Đang chờ xác nhận thanh toán (COD)'),
	(4, 5, N'Đã đóng gói xong'),
	(5, 1, N'Đơn hàng mới'),
	(5, 5, N'Đã đóng gói'),
    (5, 6, N'Đã giao cho Vận chuyển'),
    (6, 1, N'Đơn hàng đã thanh toán'),
    (6, 2, N'Đang giao đến Huế'),
    (7, 1, N'Khách hàng yêu cầu hủy đơn do gấp'),
	(7, 4, N'Đơn hàng đã bị hủy');
GO

-- Đánh giá sách
INSERT INTO DanhGia (MaKH, MaSach, SoSao, BinhLuan)
VALUES
    (2, 1, 5, N'Tác phẩm rất hay, truyền cảm hứng mạnh mẽ về hành trình tìm kiếm ý nghĩa cuộc đời.'),
	(3, 4, 4, N'"Đắc nhân tâm" là cuốn sách kỹ năng sống vô cùng bổ ích, mọi người nên đọc.'),
	(4, 13, 5, N'Rất hay và dễ hiểu, giúp tôi thay đổi tư duy tài chính một cách hiệu quả.'),
	(5, 17, 3, N'Truyện Conan hay nhưng hơi dài, cần tập trung cao độ khi theo dõi các vụ án.'),
	(6, 10, 5, N'Giáo trình Toán Cao cấp được viết rất chi tiết, dễ hiểu cho sinh viên kỹ thuật.'),
	(7, 28, 5, N'Tiểu sử Elon Musk truyền động lực rất lớn, một người có tầm nhìn xuất sắc.'),
	(8, 21, 4, N'Sách "Không gia đình" rất cảm động, phù hợp cho cả thiếu nhi và người lớn.'),
	(9, 26, 4, N'Chiến tranh và hòa bình là tác phẩm vĩ đại, phản ánh sâu sắc xã hội Nga.'),
	(10, 27, 5, N'Câu chuyện sinh tồn của Buck thật mạnh mẽ, cuốn hút người đọc từ đầu đến cuối.'),
	(2, 5, 5, N'7 Thói quen hiệu quả là cẩm nang phát triển bản thân không thể thiếu của tôi.'),
	(3, 18, 5, N'One Piece mãi là số 1 trong lòng tôi, tuyệt vời về tình bạn và khát vọng.');
GO 

-- Danh sách yêu thích
INSERT INTO YeuThich (MaKH, MaSach)
VALUES
    (2, 13), (2, 28), (2, 25),
	(3, 1), (3, 5), (3, 25), (3, 18),
	(4, 14), (4, 8), (4, 30),
	(5, 15), (5, 19), (5, 20), (5, 16),
	(6, 29), (6, 30), (6, 4), (6, 1),
	(7, 11), (7, 22), (7, 26),
    (8, 7), (8, 9),
    (9, 12), (9, 24),
    (10, 31), (10, 32);
GO

-- Giao diện (Slider)
INSERT INTO Slider (HinhAnh)
VALUES
	('slider1.png'),
	('slider2.png'),
	('slider3.png'),
	('slider4.png'),
	('slider5.png'),
	('slider6.png'),
	('slider7.png'),
	('slider8.png'),
	('slider9.png'),
	('slider10.png'),
	('slider11.png');
GO 

-- Dịch vụ
INSERT INTO DichVu (TenDichVu, MoTa, Icon)
VALUES
	(N'Vận chuyển', N'Bảo đảm chất lượng khi vận chuyển.', 'fas fa-car-side fa-3x'),
	(N'Bảo mật', N'Thông tin tài khoản đảm bảo tuyệt đối.', 'fas fa-user-shield fa-3x'),
	(N'Hoàn trả', N'Đổi trả trong 30 ngày nếu có hư hại.', 'fas fa-exchange-alt fa-3x'),
	(N'Hỗ trợ 24/7', N'Giải đáp mọi thắc mắc nhanh chóng.', 'fa fa-phone-alt fa-3x');
GO

-- Giới thiệu
INSERT INTO GioiThieu(TenGT, MoTa, Icon)
VALUES
	(N'Ưu Tiên Khách Hàng', N'Luôn lắng nghe và thấu hiểu nhu cầu khách hàng, đặt sự hài lòng của khách hàng lên hàng đầu trong mọi hoạt động.', 'fas fa-hand-holding-heart fa-3x text-danger mb-3'),
	(N'Nội Dung Sách Đa Dạng', N'Kho tàng sách phong phú, từ văn học, kinh tế đến khoa học, luôn được cập nhật liên tục để đáp ứng mọi nhu cầu và sở thích đọc.', 'fas fa-book-open fa-3x text-success mb-3'),
	(N'Chất Lượng Sách Đảm Bảo', N'Các ấn phẩm được chọn lọc kỹ càng, đảm bảo chất lượng in ấn, nguồn gốc rõ ràng, không bán sách giả.', 'fas fa-check-double fa-3x text-warning mb-3'),
	(N'Cập Nhật Xu Hướng Mới', N'Chúng tôi luôn theo dõi thị trường để mang đến các tác phẩm mới lạ, độc quyền và các đầu sách đang thịnh hành.', 'fas fa-lightbulb fa-3x text-info mb-3'),
	(N'Dịch Vụ Tận Tâm', N'Đội ngũ hỗ trợ chuyên nghiệp, nhiệt tình, luôn sẵn sàng tư vấn và giải đáp mọi thắc mắc về sách và đơn hàng.', 'fas fa-users fa-3x text-primary mb-3'),
	(N'Giao Hàng Nhanh Chóng', N'Đóng gói cẩn thận, đảm bảo sách nguyên vẹn khi đến tay khách hàng cùng tốc độ giao hàng tối ưu nhất.', 'fas fa-truck-fast fa-3x text-success mb-3');
GO

-- ========================================
-- HIỂN THỊ CÁC BẢNG
-- ========================================
SELECT * FROM NXB
SELECT * FROM LoaiSach
SELECT * FROM Sach
SELECT * FROM HinhAnh

SELECT * FROM VaiTro
SELECT * FROM NguoiDung

SELECT * FROM KhuyenMai
SELECT * FROM Sach_KhuyenMai

SELECT * FROM GioHang
SELECT * FROM TinhTrang
SELECT * FROM PhuongThucThanhToan
SELECT * FROM HoaDon
SELECT * FROM ChiTietHoaDon
SELECT * FROM LichSuDonHang

SELECT * FROM DanhGia 
SELECT * FROM YeuThich

SELECT * FROM Slider
SELECT * FROM DichVu
SELECT * FROM GioiThieu

drop table NXB
drop table LoaiSach
drop table Sach
drop table HinhAnh
drop table VaiTro
drop table NguoiDung
drop table KhuyenMai
drop table Sach_KhuyenMai
drop table PhuongThucThanhToan
drop table TinhTrang
drop table HoaDon
drop table ChiTietHoaDon 
drop table LichSuDonHang
drop table DanhGia
drop table YeuThich
drop table GioHang
drop table Slider
drop table DichVu
drop table GioiThieu

