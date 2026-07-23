using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data.Entity;

namespace DoAnLTW.Controllers
{
    public class FavouriteController : Controller
    {
        BookDBEntities2 db = new BookDBEntities2();

        public ActionResult Index()
        {
            if (Session["User"] == null)
            {
                return RedirectToAction("Login", "User");
            }

            var user = (NguoiDung)Session["User"];

            var favourite = db.YeuThiches
                .Where(x => x.MaKH == user.MaND)
                .Include(x => x.Sach)
                .ToList();

            return View(favourite);
        }

        public ActionResult AddToFavourite(int id)
        {
            if (Session["User"] == null)
            {
                return RedirectToAction("Login", "User");
            }

            var user = (NguoiDung)Session["User"];

            var favourite = db.YeuThiches.FirstOrDefault(x => x.MaKH == user.MaND && x.MaSach == id);

            if (favourite != null)
            {
                db.YeuThiches.Remove(favourite);
                TempData["Warning"] = "❌ Đã xóa khỏi danh sách yêu thích!";
            }
            else
            {
                db.YeuThiches.Add(new YeuThich
                {
                    MaKH = user.MaND,
                    MaSach = id,
                    NgayThem = DateTime.Now
                });

                TempData["SuccessMessage"] = "❤️ Đã thêm vào danh sách yêu thích!";
            }

            db.SaveChanges();

            if (Request.UrlReferrer != null)
            {
                return Redirect(Request.UrlReferrer.ToString());
            }

            return RedirectToAction("Index", "Product");
        }

        public ActionResult RemoveFromFavourite(int id)
        {
            if (Session["User"] == null)
            {
                return RedirectToAction("Login", "User");
            }
            var user = (NguoiDung)Session["User"];

            var favourite = db.YeuThiches.FirstOrDefault(x => x.MaKH == user.MaND && x.MaSach == id);

            if (favourite != null)
            {
                db.YeuThiches.Remove(favourite);
                db.SaveChanges();
                TempData["Warning"] = "❌ Đã xóa khỏi danh sách yêu thích!";
            }

            if (Request.UrlReferrer != null)
            {
                return Redirect(Request.UrlReferrer.ToString());
            }

            return RedirectToAction("Index", "Favourite");
        }

        public ActionResult _FavouriteBadge()
        {
            if (Session["User"] == null)
            {
                return Content("0"); 
            }

            var user = (NguoiDung)Session["User"];

            int count = db.YeuThiches.Count(x => x.MaKH == user.MaND);

            return Content(count.ToString());
        }
	}
}