using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Text;
using System.Security.Cryptography;
using System.IO;

namespace DoAnLTW.Controllers
{
    public class UserController : Controller
    {
        BookDBEntities db = new BookDBEntities();

        public ActionResult Login(string returnUrl)
        {
            if (!string.IsNullOrEmpty(returnUrl))
            {
                if (Url.IsLocalUrl(returnUrl) &&
                    !returnUrl.ToLower().Contains("/user/login") &&
                    !returnUrl.ToLower().Contains("/user/register"))
                {
                    Session["ReturnUrl"] = returnUrl;
                }
            }
            else
            {
                var referrer = Request.UrlReferrer;
                if (referrer != null)
                {
                    string referrerPath = referrer.PathAndQuery.ToLower();
                    bool isLocal = referrer.Host.Equals(Request.Url.Host, StringComparison.OrdinalIgnoreCase);

                    if (isLocal &&
                        !referrerPath.Contains("/user/login") &&
                        !referrerPath.Contains("/user/register"))
                    {
                        Session["ReturnUrl"] = referrer.PathAndQuery; 
                    }
                }
            }

            return View();
        }

        [HttpPost]
        public ActionResult LoginSubmit(FormCollection collect)
        {
            var email = collect["Email"];
            var password = collect["Password"];

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                TempData["Warning"] = "Vui lòng nhập đầy đủ thông tin!";
                return View("Login");
            }

            string hashedPassword = HashPassword(password);

            NguoiDung u = db.NguoiDungs.FirstOrDefault(x => x.Email == email && x.MatKhau == hashedPassword);
            
            if (u != null)
            {
                Session["User"] = u;
                TempData["SuccessMessage"] = "✅ Đăng nhập thành công!";

                string returnUrl = Session["ReturnUrl"] as string;
                Session["ReturnUrl"] = null;

                if (!string.IsNullOrEmpty(returnUrl))
                {
                    return Redirect(returnUrl);
                }
                return RedirectToAction("Index", "Home");
            }
            TempData["Error"] = "❌ Thông tin đăng nhập không hợp lệ!";
            return View("Login");
        }

        public ActionResult Register()
        {
            return View();
        }

        [HttpPost]
        public ActionResult RegisterSubmit(NguoiDung kh)
        {
            var check = db.NguoiDungs.FirstOrDefault(x => x.TenDangNhap == kh.TenDangNhap || x.Email == kh.Email);
            if (check != null)
            {
                TempData["Error"] = "❌ Tên người dùng hoặc Email đã tồn tại!";
                return View("Register");
            }

            if (string.IsNullOrEmpty(kh.AnhDaiDien))
            {
                kh.AnhDaiDien = "no-avatar.png";
            }

            kh.MatKhau = HashPassword(kh.MatKhau);

            kh.NgayDangKy = DateTime.Now;
            kh.TrangThai = true;

            db.NguoiDungs.Add(kh);
            db.SaveChanges();

            TempData["SuccessMessage"] = "✅ Đăng ký tài khoản thành công! Mời bạn đăng nhập.";
            Session["User"] = kh;

            return RedirectToAction("Login", "User");
        }

        public static string HashPassword(string password)
        {
            string salt = "heaven";
            // 1. Kết hợp Mật khẩu và Salt
            string saltedPassword = password + salt;

            // 2. Băm bằng SHA256
            using (SHA256 sha256 = SHA256.Create())
            {
                // Băm chuỗi kết hợp (saltedPassword)
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(saltedPassword));

                // 3. Trả về chuỗi Hash Base64 (dễ dàng lưu trữ và so sánh)
                return Convert.ToBase64String(bytes);
            }
        }

        // Đăng xuất
        public ActionResult Logout()
        {
            Session["User"] = null;
            Session["Cart"] = null;
            TempData["SuccessMessage"] = "✅ Bạn đã đăng xuất thành công!";
            if (Request.UrlReferrer != null)
            {
                return Redirect(Request.UrlReferrer.ToString());
            }
            return RedirectToAction("Index", "Home");
        }

        // Trang thông tin cá nhân
        public ActionResult Profile()
        {
            NguoiDung u = (NguoiDung)Session["User"];

            if (u == null)
            {
                return RedirectToAction("Login", "User");
            }

            NguoiDung nguoiDung = db.NguoiDungs.FirstOrDefault(x => x.MaND == u.MaND);

            if (nguoiDung == null)
            {
                Session["User"] = null;
                return RedirectToAction("Login", "User");
            }
            ViewBag.VaiTroList = new SelectList(db.VaiTroes, "IDVaiTro", "TenVaiTro", nguoiDung.IDVaiTro);

            return View(nguoiDung);
        }

        // Cập nhật thông tin cá nhân
        [HttpPost]
        public ActionResult UpdateProfile(NguoiDung model, HttpPostedFileBase avatarFile, string adminPassword)
        {
            NguoiDung u = (NguoiDung)Session["User"];

            if (u == null)
            {
                return RedirectToAction("Login", "User");
            }

            ViewBag.VaiTroList = new SelectList(db.VaiTroes, "IDVaiTro", "TenVaiTro", model.IDVaiTro);

            var nguoiDung = db.NguoiDungs.FirstOrDefault(x => x.MaND == u.MaND);

            if (nguoiDung != null)
            {
                if (model.IDVaiTro == 1 && nguoiDung.IDVaiTro != 1)
                {
                    const string ADMIN_MASTER_PASSWORD_TEXT = "bookheaven";
                    string ADMIN_MASTER_HASH = HashPassword(ADMIN_MASTER_PASSWORD_TEXT);

                    string hashedAdminPassword = HashPassword(adminPassword);

                    if (hashedAdminPassword != ADMIN_MASTER_HASH)
                    {
                        ViewBag.Error = "Bạn cần nhập đúng Mật khẩu Admin để cấp quyền truy cập.";
                        ViewBag.AdminError = true;
                        return View("Profile", model); 
                    }
                }
                // Cập nhật thông tin
                nguoiDung.HoTen = model.HoTen;
                nguoiDung.GioiTinh = model.GioiTinh;
                nguoiDung.NamSinh = model.NamSinh;
                nguoiDung.DienThoai = model.DienThoai;
                nguoiDung.DiaChi = model.DiaChi;
                nguoiDung.IDVaiTro = model.IDVaiTro;

                if (avatarFile != null && avatarFile.ContentLength > 0)
                {
                    try
                    {
                        // Tạo tên file unique
                        string fileName = Path.GetFileNameWithoutExtension(avatarFile.FileName);
                        string extension = Path.GetExtension(avatarFile.FileName);
                        fileName = fileName + "_" + DateTime.Now.ToString("yyyyMMddHHmmss") + extension;

                        // Đường dẫn lưu file
                        string path = Path.Combine(Server.MapPath("~/Content/Images/"), fileName);

                        // Lưu file
                        avatarFile.SaveAs(path);

                        // Cập nhật vào database
                        nguoiDung.AnhDaiDien = fileName;
                    }
                    catch (Exception ex)
                    {
                        ViewBag.Error = "Lỗi khi upload ảnh: " + ex.Message;
                        return View("Profile", model);
                    }
                }

                db.SaveChanges();
                Session["User"] = nguoiDung;
                TempData["SuccessMessage"] = "✅ Cập nhật thông tin thành công!";
            }

            return View("Profile", nguoiDung);
        }

        // Đổi mật khẩu
        [HttpPost]
        public ActionResult ChangePassword(string oldPassword, string newPassword, string confirmPassword)
        {
            NguoiDung u = (NguoiDung)Session["User"];
            if (u == null)
            {
                return RedirectToAction("Login", "User");
            }

            var nguoiDung = db.NguoiDungs.FirstOrDefault(x => x.MaND == u.MaND);
            string hashedOldPassword = HashPassword(oldPassword);
            if (nguoiDung.MatKhau != hashedOldPassword)
            {
                TempData["Error"] = "❌ Mật khẩu cũ không đúng! Đổi thất bại!";
                return RedirectToAction("Profile");
            }

            if (newPassword != confirmPassword)
            {
                TempData["Error"] = "❌ Mật khẩu mới và xác nhận không khớp!";
                return RedirectToAction("Profile");
            }

            if (string.IsNullOrEmpty(newPassword) || newPassword.Length < 6)
            {
                TempData["Error"] = "❌ Mật khẩu mới phải có ít nhất 6 ký tự!";
                return RedirectToAction("Profile");
            }

            nguoiDung.MatKhau = HashPassword(newPassword);
            db.SaveChanges();

            TempData["SuccessMessage"] = "✅ Đổi mật khẩu thành công!";
            return RedirectToAction("Profile");
        }
	}
}