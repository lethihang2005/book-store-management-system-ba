using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data.Entity;
using DoAnLTW.Models;

namespace DoAnLTW.Controllers
{
    public class CartController : Controller
    {
        BookDBEntities2 db = new BookDBEntities2();

        public ActionResult Index()
        {
            if (Session["User"] == null)
            {
                return RedirectToAction("Login", "User");
            }

            var user = (NguoiDung)Session["User"];

            var cart = db.GioHangs
                .Where(x => x.MaKH == user.MaND)
                .Include(x => x.Sach)
                .ToList();

            return View(cart);
        }

        public ActionResult AddToCart(int id)
        {
            if (Session["User"] == null)
            {
                return RedirectToAction("Login", "User");
            }

            var user = (NguoiDung)Session["User"];

            var cart = db.GioHangs.FirstOrDefault(x => x.MaKH == user.MaND && x.MaSach == id);

            if (cart != null)
            {
                cart.SoLuong += 1;
                TempData["SuccessMessage"] = "🛒 Đã tăng số lượng sản phẩm!";
            }
            else
            {
                db.GioHangs.Add(new GioHang
                {
                    MaKH = user.MaND,
                    MaSach = id,
                    SoLuong = 1
                });

                TempData["SuccessMessage"] = "🛒 Đã thêm sản phẩm vào giỏ hàng!";
            }

            db.SaveChanges();

            if (Request.UrlReferrer != null)
            {
                return Redirect(Request.UrlReferrer.ToString());
            }

            return RedirectToAction("Index", "Cart");
        }

        public ActionResult RemoveFromCart(int id)
        {
            if (Session["User"] == null)
            {
                return RedirectToAction("Login", "User");
            }
            var user = (NguoiDung)Session["User"];

            var cart = db.GioHangs.FirstOrDefault(x => x.MaKH == user.MaND && x.MaSach == id);

            if (cart != null)
            {
                db.GioHangs.Remove(cart);
                db.SaveChanges();
                TempData["Warning"] = "🗑️ Đã xóa sản phẩm khỏi giỏ hàng!";
            }

            if (Request.UrlReferrer != null)
            {
                return Redirect(Request.UrlReferrer.ToString());
            }

            return RedirectToAction("Index", "Cart");
        }

        public ActionResult UpdateSL(int id, int type = 1)
        {
            if (Session["User"] == null)
            {
                return RedirectToAction("Login", "User");
            }
            var user = (NguoiDung)Session["User"];

            var cart = db.GioHangs.FirstOrDefault(x => x.MaKH == user.MaND && x.MaSach == id);

            if (cart != null)
            {
                if (type == -1)
                {
                    if (cart.SoLuong > 1)
                    {
                        cart.SoLuong -= 1;
                        TempData["Warning"] = "➖ Đã giảm số lượng sản phẩm!";
                    }
                    else
                    {
                        db.GioHangs.Remove(cart);
                        TempData["Error"] = "🗑️ Đã xóa sản phẩm khỏi giỏ hàng!";
                    }
                }
                else
                {
                    cart.SoLuong += 1;
                    TempData["SuccessMessage"] = "➕ Đã tăng số lượng sản phẩm!";
                }

                db.SaveChanges();
            }
            return RedirectToAction("Index", "Cart");
        }

        public ActionResult _CartBadge()
        {
            if (Session["User"] == null)
            {
                return Content("0");
            }

            var user = (NguoiDung)Session["User"];

            int count = db.GioHangs.Count(x => x.MaKH == user.MaND);

            return Content(count.ToString());
        }
	}
}