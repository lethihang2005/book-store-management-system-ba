using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data.Entity;
using System.Text;
using System.Globalization;

namespace DoAnLTW.Controllers
{
    public class ProductController : Controller
    {
        BookDBEntities db = new BookDBEntities();

        public ActionResult Index(string sort)
        {
            ViewBag.CurrentSort = sort;
            List<Sach> lst = db.Saches.ToList();

            // Sắp xếp
            switch (sort)
            {
                case "price_asc":
                    lst = lst.OrderBy(x => x.GiaBan).ToList();
                    break;
                case "price_desc":
                    lst = lst.OrderByDescending(x => x.GiaBan).ToList();
                    break;
                case "rating_asc":
                    lst = lst.OrderBy(x => x.DiemDanhGia).ToList();
                    break;
                case "rating_desc":
                    lst = lst.OrderByDescending(x => x.DiemDanhGia).ToList(); 
                    break;
                default:
                    lst = lst.OrderBy(x => x.MaSach).ToList(); 
                    break;
            }
            return View(lst);
        }

        public ActionResult _Categories()
        {
            return PartialView(db.LoaiSaches.ToList());
        }

        public ActionResult _Publishers()
        {
            return PartialView(db.NXBs.ToList());
        }

        public ActionResult _Prices()
        {
            return PartialView();
        }

        public ActionResult _Sorts()
        {
            return PartialView();
        }

        public ActionResult _Products()
        {
            return PartialView(db.Saches.ToList());
        }

        public ActionResult _Offcanvas()
        {
            return PartialView();
        }

        public ActionResult Detail(int id)
        {
            Sach sach = db.Saches
                .Include(s => s.LoaiSach)
                .Include(s => s.NXB)
                .Include(s => s.DanhGias.Select(d => d.NguoiDung))
                .Where(x => x.MaSach == id).FirstOrDefault();

            if (sach == null)
            {
                return HttpNotFound();
            }

            var user = Session["User"] as NguoiDung;

            bool hasPurchased = false;
            bool hasReviewed = false;
            bool isFavourite = false;
            bool isInCart = false;
            if (user != null)
            {
                hasPurchased = db.ChiTietHoaDons.Any(ct => ct.MaSach == id && ct.HoaDon.MaKH == user.MaND); // && ct.HoaDon.TinhTrang == 7
                hasReviewed = db.DanhGias.Any(dg => dg.MaSach == id && dg.MaKH == user.MaND);
                isFavourite = db.YeuThiches.Any(yt => yt.MaKH == user.MaND && yt.MaSach == id);
                isInCart = db.GioHangs.Any(gh => gh.MaKH == user.MaND && gh.MaSach == id);
            }
            ViewBag.HasPurchased = hasPurchased;
            ViewBag.HasReviewed = hasReviewed;
            ViewBag.IsFavourite = isFavourite;
            ViewBag.IsInCart = isInCart;

            List<Sach> SPLienQuan = db.Saches.Where(x => x.MaLoai == sach.MaLoai).ToList();
            ViewBag.SanPhamLienQuan = SPLienQuan;
            return View(sach);
        }

        public ActionResult TimKiemTheoTenSach(string key)
        {
            ViewBag.Key = key;
            var tukhoaBoDau = RemoveDiacritics(key.Trim().ToLower());
            List<Sach> lst = db.Saches.ToList();
            lst = lst.Where(x => !string.IsNullOrEmpty(x.TenSach) && RemoveDiacritics(x.TenSach.Trim().ToLower()).Contains(tukhoaBoDau)).ToList();
            return View("Index", lst);
        }

        public ActionResult TimKiemTheoTheLoai(int id)
        {
            List<Sach> lst = db.Saches.Where(x => x.MaLoai == id).ToList();
            return View("Index", lst);
        }

        public static string RemoveDiacritics(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
                return text;

            string normalizedString = text.Normalize(NormalizationForm.FormD);
            StringBuilder stringBuilder = new StringBuilder();

            foreach (char c in normalizedString)
            {
                UnicodeCategory unicodeCategory = CharUnicodeInfo.GetUnicodeCategory(c);
                if (unicodeCategory != UnicodeCategory.NonSpacingMark)
                {
                    stringBuilder.Append(c);
                }
            }

            string result = stringBuilder.ToString().Normalize(NormalizationForm.FormC);
            result = result.Replace('Đ', 'D').Replace('đ', 'd');

            return result;
        }

        public ActionResult TimKiem(int[] type, int[] author, string price, string sort)
        {
            ViewBag.CurrentSort = sort;

            List<Sach> lst = db.Saches.ToList();

            // Lọc theo thể loại
            if (type != null && type.Length > 0)
            {
                lst = lst.Where(x => x.MaLoai.HasValue && type.Contains(x.MaLoai.Value)).ToList();
            }

            // Lọc theo nhà xuất bản
            if (author != null && author.Length > 0)
            {
                lst = lst.Where(x => x.MaNXB.HasValue && author.Contains(x.MaNXB.Value)).ToList();
            }

            // Lọc theo giá
            if (!String.IsNullOrEmpty(price))
            {
                switch (price)
                {
                    case "1":
                        lst = lst.Where(x => x.GiaBan <= 50000).ToList();
                        break;
                    case "2":
                        lst = lst.Where(x => x.GiaBan > 50000 && x.GiaBan <= 100000).ToList();
                        break;
                    case "3":
                        lst = lst.Where(x => x.GiaBan > 100000 && x.GiaBan <= 150000).ToList();
                        break;
                    case "4":
                        lst = lst.Where(x => x.GiaBan > 150000).ToList();
                        break;
                    default: break;
                }
            }

            // Sắp xếp
            switch (sort)
            {
                case "price_asc":
                    lst = lst.OrderBy(x => x.GiaBan).ToList();
                    break;
                case "price_desc":
                    lst = lst.OrderByDescending(x => x.GiaBan).ToList();
                    break;
                case "rating_asc":
                    lst = lst.OrderBy(x => x.DiemDanhGia).ToList();
                    break;
                case "rating_desc":
                    lst = lst.OrderByDescending(x => x.DiemDanhGia).ToList();
                    break;
                default:
                    lst = lst.OrderBy(x => x.MaSach).ToList();
                    break;
            }

            return View("Index", lst);
        }

        public ActionResult _TimKiem()
        {
            return PartialView();
        }
    }
}