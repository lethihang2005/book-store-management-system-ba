using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace DoAnLTW.Controllers
{
    public class VoucherController : Controller
    {
        BookDBEntities2 db = new BookDBEntities2();

        public ActionResult Index()
        {
            return View(db.KhuyenMais.ToList());
        }
	}
}