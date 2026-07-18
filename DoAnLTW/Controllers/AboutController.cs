using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace DoAnLTW.Controllers
{
    public class AboutController : Controller
    {
        BookDBEntities db = new BookDBEntities();

        public ActionResult Index()
        {
            return View(db.GioiThieux.ToList());
        }
	}
}