using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using DoAnLTW.Models;

namespace DoAnLTW.Controllers
{
    public class PaymentController : Controller
    {
        BookDBEntities2 db = new BookDBEntities2();

        public decimal TinhGiamGia(int maKhuyenMai, List<DoAnLTW.GioHang> cart)
        {
            var km = db.KhuyenMais.FirstOrDefault(k => k.MaKM == maKhuyenMai && k.NgayBatDau <= DateTime.Now && k.NgayKetThuc >= DateTime.Now);

            if (km == null)
            {
                return 0;
            }

            decimal tongDonHang = cart.Sum(i => (decimal)(i.Sach.GiaBan.Value * i.SoLuong));
            if (km.DonToiThieu.HasValue && tongDonHang < km.DonToiThieu.Value)
            {
                return 0;
            }

            var maSachApDung = db.Sach_KhuyenMai
                .Where(sk => sk.MaKM == km.MaKM)
                .Select(sk => sk.MaSach)
                .ToList();

            decimal tongGiam = 0;

            if (km.LoaiKM != null && km.LoaiKM.ToLower() == "phantram")
            {
                foreach (var item in cart)
                {
                    if (maSachApDung.Contains((int)item.Sach.MaSach))
                    {
                        decimal giaTriGiam = km.GiaTriGiam.HasValue ? km.GiaTriGiam.Value : 0;
                        tongGiam += (decimal)(item.Sach.GiaBan.Value * item.SoLuong) * giaTriGiam / 100m;
                    }
                }
            }
            else if (km.LoaiKM != null && km.LoaiKM.ToLower() == "tienmat")
            {
                bool coSanPhamApDung = false;
                foreach (var item in cart)
                {
                    if (maSachApDung.Contains((int)item.Sach.MaSach))
                    {
                        coSanPhamApDung = true;
                        break;
                    }
                }

                if (coSanPhamApDung)
                {
                    tongGiam = km.GiaTriGiam.HasValue ? km.GiaTriGiam.Value : 0;
                }
            }

            return tongGiam;
        }

        public ActionResult XNThanhToan()
        {
            NguoiDung u = (NguoiDung)Session["User"];
            List<DoAnLTW.GioHang> cart = db.GioHangs.Where(g => g.MaKH == u.MaND).ToList();

            if (cart == null || cart.Count == 0)
                return RedirectToAction("Index", "Cart");

            var dsKM = db.KhuyenMais.Where(k => k.NgayBatDau <= DateTime.Now && k.NgayKetThuc >= DateTime.Now).Select(k => new { k.MaKM, k.TenKM }).ToList();
            ViewBag.KhuyenMaiList = new SelectList(dsKM, "MaKM", "TenKM");

            ViewBag.HoTen = u.HoTen;
            ViewBag.DiaChi = u.DiaChi;
            ViewBag.DienThoai = u.DienThoai;

            return View(cart);
        }

        [HttpPost]
        public ActionResult Payment(int? MaKhuyenMai, string HoTen, string DiaChiGiaoHang, string GhiChu, int MaPTTT)
        {
            NguoiDung u = (NguoiDung)Session["User"];
            List<DoAnLTW.GioHang> cart = db.GioHangs.Where(g => g.MaKH == u.MaND).ToList();

            if (cart == null || cart.Count == 0)
                return RedirectToAction("Index", "Cart");

            decimal giamGia = 0;
            int? maKMTimDuoc = null;

            if (MaKhuyenMai.HasValue)
            {
                maKMTimDuoc = MaKhuyenMai.Value;
                giamGia = TinhGiamGia(MaKhuyenMai.Value, cart);
            }

            decimal phiVanChuyen = 30000;
            decimal tongThanhToanHang = cart.Sum(i => (decimal)(i.Sach.GiaBan.Value * i.SoLuong));
            decimal tongTienSauGiam = tongThanhToanHang - giamGia;
            if (tongTienSauGiam < 0) tongTienSauGiam = 0;
            decimal tongThanhToanCuoi = tongTienSauGiam + phiVanChuyen;

            HoaDon hd = new HoaDon()
            {
                MaKH = u.MaND,
                MaKM = maKMTimDuoc,
                NgayLap = DateTime.Now,
                TongTien = tongTienSauGiam,
                GiamGia = giamGia,
                PhiVanChuyen = phiVanChuyen,
                ThanhTien = tongThanhToanCuoi,
                DiaChiGiaoHang = DiaChiGiaoHang,
                GhiChu = GhiChu,
                TinhTrang = 1,
                MaPTTT = MaPTTT,
                DaThanhToan = false,
            };

            db.HoaDons.Add(hd);
            db.SaveChanges();

            foreach (var i in cart)
            {
                ChiTietHoaDon ct = new ChiTietHoaDon()
                {
                    MaHD = hd.MaHD,
                    MaSach = i.Sach.MaSach,
                    SoLuong = i.SoLuong,
                    GiaBan = i.Sach.GiaBan.Value,
                };
                db.ChiTietHoaDons.Add(ct);
            }

            db.SaveChanges();

            db.GioHangs.RemoveRange(cart);
            db.SaveChanges();
            Session["Cart"] = null;

            ViewBag.GiamGia = giamGia;
            ViewBag.PhiVanChuyen = phiVanChuyen;
            ViewBag.TongThanhToanCuoi = tongThanhToanCuoi;

            return View(hd);
        }
    }
}