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
    public class HomeController : Controller
    {
        BookDBEntities db = new BookDBEntities();

        public ActionResult Index()
        {
            return View();
        }

        public ActionResult _Sliders()
        {
            return PartialView(db.Sliders.ToList());
        }

        public ActionResult _Services()
        {
            return PartialView(db.DichVus.ToList());
        }

        public ActionResult _Categories()
        {
            return PartialView(db.LoaiSaches.ToList());
        }

        public ActionResult _Vouchers()
        {
            return PartialView(db.KhuyenMais.ToList());
        }

        public ActionResult _BestSellers()
        {
            var bestSeller = db.Saches
                             .OrderByDescending(s => s.LuotMua)
                             .Take(7)
                             .ToList();
            return PartialView(bestSeller);
        }

        public ActionResult _OtherBooks()
        {
            var other = db.Saches
                             .OrderBy(s => Guid.NewGuid())
                             .Take(7)
                             .ToList();
            return PartialView(other);
        }

        public ActionResult _Reviews()
        {
            var reviews = db.DanhGias
                .Include(n => n.NguoiDung)
                .Include(n => n.Sach)
                .ToList();
            return PartialView(reviews);
        }
    }
}