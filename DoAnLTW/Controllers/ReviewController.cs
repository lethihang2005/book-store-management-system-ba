using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data.Entity;

namespace DoAnLTW.Controllers
{
    public class ReviewController : Controller
    {
        BookDBEntities db = new BookDBEntities();

        public ActionResult Index()
        {
            var reviews = db.DanhGias
                .Include(n => n.NguoiDung)
                .Include(n => n.Sach)
                .ToList();
            return PartialView(reviews);
        }

        public ActionResult AddReview(int maSach)
        {
            var sach = db.Saches.Find(maSach);
            ViewBag.MaSach = maSach;
            ViewBag.TenSach = sach != null ? sach.TenSach : "Sách không tồn tại";
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult AddReviewOnSubmit(DanhGia dg)
        {
            if (ModelState.IsValid)
            {
                var user = Session["User"] as NguoiDung;
                dg.MaKH = user.MaND;
                dg.NgayDanhGia = DateTime.Now;
                dg.TrangThai = true;

                db.DanhGias.Add(dg);
                db.SaveChanges();

                TempData["SuccessMessage"] = "🎉 Cảm ơn bạn! Đánh giá của bạn đã được gửi thành công!";

                return RedirectToAction("Detail", "Product", new { id = dg.MaSach });
            }

            var sach = db.Saches.Find(dg.MaSach);
            ViewBag.MaSach = dg.MaSach;
            ViewBag.TenSach = sach != null ? sach.TenSach : "Sách không tồn tại";
            return View("AddReview", dg);
        }
    }
}