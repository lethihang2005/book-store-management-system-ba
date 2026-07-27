using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace DoAnLTW.Controllers
{
    public class AboutController : Controller
    {
        private readonly BookDBEntities2 db = new BookDBEntities2();

        public ActionResult Index()
        {
            // About page has no entity called GioiThieus in the context.
            // Return the view without a model (or change to a real DbSet if needed).
            return View();
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db?.Dispose();
            }

            base.Dispose(disposing);
        }
    }
}