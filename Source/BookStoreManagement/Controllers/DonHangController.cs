using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data.Entity;

namespace DoAnLTW.Controllers
{
    public class DonHangController : Controller
    {
        BookDBEntities2 db = new BookDBEntities2();

        public ActionResult Index()
        {
            var hoaDons = db.HoaDons
                 .Include(h => h.NguoiDung)
                 .Include(h => h.TinhTrang1)
                 .Include(h => h.PhuongThucThanhToan)
                 .OrderByDescending(h => h.NgayLap)
                 .ToList();
            return View(hoaDons);
        }

        public ActionResult CapNhatTrangThai(int maHD)
        {
            var hd = db.HoaDons.Find(maHD);
            if (hd == null)
                return HttpNotFound();

            ViewBag.TTList = new SelectList(db.TinhTrangs.ToList(), "ID", "TinhTrangHoaDon", hd.TinhTrang);
            ViewBag.PTTTList = new SelectList(db.PhuongThucThanhToans.ToList(), "MaPTTT", "TenPTTT", hd.MaPTTT);
            return View(hd);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult CapNhatTrangThai(int maHD, int? tinhTrang)
        {
            var hd = db.HoaDons.Find(maHD);
            if (hd == null)
                return HttpNotFound();

            if (tinhTrang == null)
            {
                TempData["Error"] = "Vui lòng chọn một Trạng Thái hợp lệ để cập nhật.";
                return RedirectToAction("CapNhatTrangThai", new { maHD });
            }

            if (!db.TinhTrangs.Any(t => t.ID == tinhTrang))
            {
                TempData["Error"] = "Trạng thái không hợp lệ!";
                return RedirectToAction("CapNhatTrangThai", new { maHD });
            }

            hd.TinhTrang = tinhTrang;

            db.LichSuDonHangs.Add(new LichSuDonHang
            {
                MaHD = hd.MaHD,
                TinhTrang = tinhTrang,
                NgayCapNhat = DateTime.Now,
                GhiChu = "Cập nhật trạng thái bởi người bán"
            });

            db.SaveChanges();
            TempData["SuccessMessage"] = "Cập nhật trạng thái đơn hàng thành công!";
            return RedirectToAction("Index");
        }

        public ActionResult ThongKeDoanhThu(string loaiThongKe = "thang")
        {
            ViewBag.LoaiThongKe = loaiThongKe;
            var thongKe = new List<object[]>();

            if (loaiThongKe == "ngay")
            {

                var temp = db.HoaDons
                             .Where(h => h.NgayLap != null)
                             .GroupBy(h => DbFunctions.TruncateTime(h.NgayLap))
                             .Select(g => new
                             {
                                 Ngay = g.Key,
                                 TongTien = g.Sum(x => x.ThanhTien)
                             })
                             .ToList();

                thongKe = temp.Select(x => new object[] { x.Ngay, x.TongTien }).ToList();
            }
            else if (loaiThongKe == "thang")
            {
                var temp = db.HoaDons
                             .Where(h => h.NgayLap != null)
                             .GroupBy(h => new { h.NgayLap.Value.Year, h.NgayLap.Value.Month })
                             .Select(g => new
                             {
                                 Nam = g.Key.Year,
                                 Thang = g.Key.Month,
                                 TongTien = g.Sum(x => x.ThanhTien)
                             })
                             .ToList();

                thongKe = temp.Select(x => new object[] { x.Thang, x.Nam, x.TongTien }).ToList();
            }
            else if (loaiThongKe == "nam")
            {
                var temp = db.HoaDons
                             .Where(h => h.NgayLap != null)
                             .GroupBy(h => h.NgayLap.Value.Year)
                             .Select(g => new
                             {
                                 Nam = g.Key,
                                 TongTien = g.Sum(x => x.ThanhTien)
                             })
                             .ToList();

                thongKe = temp.Select(x => new object[] { x.Nam, x.TongTien }).ToList();
            }

            ViewBag.ThongKe = thongKe;
            return View();
        }
	}
}