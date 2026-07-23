using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data.Entity;
using System.IO;
using System.Text;
using System.Globalization;

namespace DoAnLTW.Controllers
{
    public class SanPhamController : Controller
    {
        BookDBEntities2 db = new BookDBEntities2();

        public ActionResult Index()
        {
            var model = db.Saches
                .Include(s => s.LoaiSach)
                .Include(s => s.NXB)
                .ToList();
            return View(model);
        }

        [HttpGet]
        public ActionResult ThemSanPham()
        {
            ViewBag.LoaiList = new SelectList(db.LoaiSaches, "MaLoai", "TenLoai");
            ViewBag.NXBList = new SelectList(db.NXBs, "MaNXB", "TenNXB");
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ThemSanPham(Sach sp, HttpPostedFileBase AnhBia)
        {
            if (AnhBia != null)
            {
                string fileName = Path.GetFileName(AnhBia.FileName);
                string path = Path.Combine(Server.MapPath("~/Content/Images/"), fileName);
                AnhBia.SaveAs(path);
                sp.AnhBia = fileName;
            }
            sp.LuotMua = 0;
            sp.DiemDanhGia = sp.SoLuotDanhGia = 0;

            if (ModelState.IsValid)
            {
                db.Saches.Add(sp);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            ViewBag.LoaiList = new SelectList(db.LoaiSaches, "MaLoai", "TenLoai", sp.MaLoai);
            ViewBag.NXBList = new SelectList(db.NXBs, "MaNXB", "TenNXB", sp.MaNXB);
            return View(sp);
        }

        public ActionResult SuaSanPham(int id)
        {
            var sp = db.Saches.Find(id);
            if (sp == null) return HttpNotFound();

            ViewBag.LoaiList = new SelectList(db.LoaiSaches, "MaLoai", "TenLoai", sp.MaLoai);
            ViewBag.NXBList = new SelectList(db.NXBs, "MaNXB", "TenNXB", sp.MaNXB);
            return View(sp);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult SuaSanPham(Sach sp, HttpPostedFileBase AnhBia)
        {
            if (AnhBia != null && AnhBia.ContentLength > 0)
            {
                string fileName = Path.GetFileName(AnhBia.FileName);
                string path = Path.Combine(Server.MapPath("~/Content/Images/"), fileName);
                AnhBia.SaveAs(path);
                sp.AnhBia = fileName;
            }
            db.Entry(sp).State = EntityState.Modified;
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        public ActionResult XoaSanPham(int id)
        {
            var sp = db.Saches.Find(id);
            if (sp == null) return HttpNotFound();
            db.Saches.Remove(sp);
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        [HttpPost]
        public ActionResult LuuThayDoiSanPham(FormCollection form)
        {
            var danhSach = db.Saches.Include(s => s.Sach_KhuyenMai).ToList();

            foreach (var sp in danhSach)
            {

                string xoaKey = "Xoa_" + sp.MaSach;
                if (!string.IsNullOrEmpty(form[xoaKey]) && form[xoaKey] == "1")
                {

                    var kmCu = sp.Sach_KhuyenMai.ToList();
                    foreach (var km in kmCu)
                        db.Sach_KhuyenMai.Remove(km);

                    db.Saches.Remove(sp);
                    continue;
                }


                string soLuongKey = "SoLuongTon_" + sp.MaSach;
                if (!string.IsNullOrEmpty(form[soLuongKey]))
                    sp.SoLuongTon = int.Parse(form[soLuongKey]);


                string trangThaiKey = "TrangThai_" + sp.MaSach;
                if (!string.IsNullOrEmpty(form[trangThaiKey]))
                {
                    int trangThai = int.Parse(form[trangThaiKey]);
                    sp.SoLuongTon = trangThai == 1 ? (sbyte?)Math.Max(sp.SoLuongTon ?? 0, 1) : (sbyte?)0;

                }


                string kmKey = "KhuyenMai_" + sp.MaSach;
                var kmCu2 = sp.Sach_KhuyenMai.Where(k => k.MaKM == 1).ToList();
                foreach (var km in kmCu2)
                    db.Sach_KhuyenMai.Remove(km);

                if (!string.IsNullOrEmpty(form[kmKey]) && form[kmKey] == "1")
                {
                    db.Sach_KhuyenMai.Add(new DoAnLTW.Sach_KhuyenMai
                    {
                        MaSach = sp.MaSach,
                        MaKM = 1,
                        NgaySuDung = DateTime.Now
                    });
                }

                db.Entry(sp).State = EntityState.Modified;
            }

            db.SaveChanges();
            TempData["SuccessMessage"] = "Đã lưu tất cả thay đổi!";
            return RedirectToAction("Index");
        }

        public ActionResult Timkiemtheoten(string keyword)
        {
            if (string.IsNullOrWhiteSpace(keyword))
            {

                return View("Index", db.Saches.ToList());
            }

            var tukhoaBoDau = RemoveDiacritics(keyword.Trim().ToLower());
            List<Sach> lst = db.Saches.ToList();
            lst = lst.Where(x => !string.IsNullOrEmpty(x.TenSach) && RemoveDiacritics(x.TenSach.Trim().ToLower()).Contains(tukhoaBoDau)).ToList();
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
	}
}