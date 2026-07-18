using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Threading.Tasks;
using System.Web;
using System.IO;

namespace DoAnLTW.Controllers
{
    [RoutePrefix("api/LoaiSach")]

    public class BangLoaiApiController : ApiController
    {
        BookDBEntities db = new BookDBEntities();

        public class ApiResponse
        {
            public bool success { get; set; }
            public string message { get; set; }
            public object data { get; set; }
        }

        [HttpGet]
        [Route("")]
        public IHttpActionResult GetLoaiSaches()
        {
            try
            {
                var list = db.LoaiSaches.Select(l => new
                {
                    l.MaLoai,
                    l.TenLoai,
                    l.GhiChu,
                    l.AnhDaiDien
                }).ToList();

                return Ok(list);
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }


        [HttpGet]
        [Route("{id:int}")]
        public IHttpActionResult GetLoaiSach(int id)
        {
            try
            {
                var loai = db.LoaiSaches.Find(id);
                if (loai == null) return NotFound();

                return Ok(new
                {
                    loai.MaLoai,
                    loai.TenLoai,
                    loai.GhiChu,
                    loai.AnhDaiDien
                });
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }


        [HttpPost]
        [Route("")]
        public IHttpActionResult ThemLoai([FromBody] LoaiSach loai)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            try
            {
                db.LoaiSaches.Add(loai);
                db.SaveChanges();

                return Ok(new ApiResponse
                {
                    success = true,
                    message = "Thêm loại sách thành công!",
                    data = new { maLoai = loai.MaLoai }
                });
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }


        [HttpPut]
        [Route("{id:int}")]
        public IHttpActionResult SuaLoai(int id, [FromBody] LoaiSach loai)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var loaiCu = db.LoaiSaches.Find(id);
                if (loaiCu == null) return NotFound();

                loaiCu.TenLoai = loai.TenLoai;
                loaiCu.GhiChu = loai.GhiChu;
                loaiCu.AnhDaiDien = loai.AnhDaiDien;

                db.SaveChanges();

                return Ok(new ApiResponse
                {
                    success = true,
                    message = "Cập nhật thành công!",
                    data = null
                });
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }


        [HttpDelete]
        [Route("{id:int}")]
        public IHttpActionResult XoaLoai(int id)
        {
            try
            {
                var loai = db.LoaiSaches.Find(id);
                if (loai == null) return NotFound();

                // Kiểm tra có sách đang dùng không
                var countSach = db.Saches.Count(x => x.MaLoai == id);
                if (countSach > 0)
                {
                    return Content(HttpStatusCode.BadRequest, new ApiResponse
                    {
                        success = false,
                        message = "Không thể xóa! Có " + countSach + " sách đang thuộc loại này.",
                        data = null
                    });
                }

                db.LoaiSaches.Remove(loai);
                db.SaveChanges();

                return Ok(new ApiResponse
                {
                    success = true,
                    message = "Xóa thành công!",
                    data = null
                });
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }


        [HttpPost]
        [Route("UploadImage")]
        public async Task<IHttpActionResult> UploadImage()
        {
            try
            {
                // Kiểm tra có file không
                if (!Request.Content.IsMimeMultipartContent())
                {
                    return BadRequest("Không phải multipart/form-data");
                }

                var provider = new MultipartMemoryStreamProvider();
                await Request.Content.ReadAsMultipartAsync(provider);

                // Lấy file đầu tiên
                var file = provider.Contents.FirstOrDefault();
                if (file == null)
                {
                    return BadRequest("Không có file nào được tải lên");
                }

                // Đọc file
                var fileBytes = await file.ReadAsByteArrayAsync();
                var fileName = file.Headers.ContentDisposition.FileName.Trim('"');

                // Validate file extension
                var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif", ".bmp" };
                var extension = Path.GetExtension(fileName).ToLower();

                if (!allowedExtensions.Contains(extension))
                {
                    return Content(HttpStatusCode.BadRequest, new ApiResponse
                    {
                        success = false,
                        message = "Chỉ chấp nhận file ảnh: jpg, jpeg, png, gif, bmp",
                        data = null
                    });
                }

                // Kiểm tra kích thước (max 5MB)
                if (fileBytes.Length > 5 * 1024 * 1024)
                {
                    return Content(HttpStatusCode.BadRequest, new ApiResponse
                    {
                        success = false,
                        message = "File không được vượt quá 5MB",
                        data = null
                    });
                }

                // Tạo tên file mới (tránh trùng)
                var newFileName = Guid.NewGuid().ToString() + extension;

                // Đường dẫn lưu file
                var uploadPath = HttpContext.Current.Server.MapPath("~/Content/Images/");

                // Tạo thư mục nếu chưa có
                if (!Directory.Exists(uploadPath))
                {
                    Directory.CreateDirectory(uploadPath);
                }

                var filePath = Path.Combine(uploadPath, newFileName);

                // Lưu file
                File.WriteAllBytes(filePath, fileBytes);

                return Ok(new ApiResponse
                {
                    success = true,
                    message = "Upload ảnh thành công!",
                    data = new
                    {
                        fileName = newFileName,
                        fileUrl = "/Content/Images/" + newFileName
                    }
                });
            }
            catch (Exception ex)
            {
                return InternalServerError(new Exception("Lỗi upload: " + ex.Message));
            }
        }

        [HttpDelete]
        [Route("DeleteImage/{fileName}")]
        public IHttpActionResult DeleteImage(string fileName)
        {
            try
            {
                if (string.IsNullOrEmpty(fileName))
                {
                    return BadRequest("Tên file không hợp lệ");
                }

                var deleted = DeleteImageFile(fileName);

                if (deleted)
                {
                    return Ok(new ApiResponse
                    {
                        success = true,
                        message = "Xóa ảnh thành công!",
                        data = null
                    });
                }

                return NotFound();
            }
            catch (Exception ex)
            {
                return InternalServerError(new Exception("Lỗi xóa ảnh: " + ex.Message));
            }
        }

        // ==================== Helper Methods ====================

        private bool DeleteImageFile(string fileName)
        {
            try
            {
                var filePath = HttpContext.Current.Server.MapPath("~/Content/Images/" + fileName);

                if (File.Exists(filePath))
                {
                    File.Delete(filePath);
                    return true;
                }

                return false;
            }
            catch
            {
                return false;
            }
        }
    }
}
