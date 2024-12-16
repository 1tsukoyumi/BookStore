using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Data;
using System.Data.SqlClient;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Security.Claims;

namespace back_end.Controllers;

[ApiController]
[Route("[controller]")]
public class TopicController : ControllerBase
{
    private readonly IConfiguration _configuration;
    private readonly Token _jwt;

    public TopicController(IConfiguration configuration)
    {
        _configuration = configuration;
        _jwt = new Token();
    }

    [HttpGet(Name = "Lay_Sach")]
    public async Task<ActionResult> LaySach([FromQuery] int? MaSach)
    {
        try
        {
            string authHeader = "";
            string token = "";

            // Lấy token từ header Authorization
            authHeader = Request.Headers["Authorization"];
            if (string.IsNullOrEmpty(authHeader) || !authHeader.StartsWith("Bearer "))
            {
                return Unauthorized(new { message = "Missing or invalid Authorization header" });
            }

            token = authHeader["Bearer ".Length..].Trim();

            // Gọi hàm ValidateToken
            if (_jwt.ValidateToken(token, out ClaimsPrincipal? claims))
            {
                // Token hợp lệ và lấy thông tin userName trong payload
                var userName = claims?.FindFirst(c => c.Type == "Username")?.Value;

                string connectionString = _configuration.GetConnectionString("DefaultConnection");
                using SqlConnection connection = new(connectionString);
                if (connection.State == ConnectionState.Closed)
                {
                    await connection.OpenAsync();
                }

                using SqlCommand command = new();
                command.Connection = connection;
                command.CommandType = CommandType.StoredProcedure;

                // Nếu người dùng có truyền mã sách
                if (MaSach.HasValue)
                {
                    command.CommandText = "spLaySachByMaSach";
                    command.Parameters.AddWithValue("@MaSach", MaSach);
                }
                else
                {
                    command.CommandText = "spLaySach";
                }

                SqlDataAdapter da = new(command);
                DataTable dt = new();
                da.Fill(dt);

                // Server trả dữ liệu về cho client theo định dạng JSON
                return new ContentResult
                {
                    Content = JsonConvert.SerializeObject(new { data = dt }),
                    ContentType = "application/json",
                    StatusCode = 200
                };
            }
            else
            {
                // Token không hợp lệ
                return Unauthorized(new { message = "Token is invalid" });
            }
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message.ToString() });
        }
    }

    [HttpGet("{MaSach?}", Name = "Get_Sach_With_Another_Way")]
    public async Task<ActionResult> GetSachOther(int? MaSach)
    {
        try
        {
            string authHeader = "";
            string token = "";

            // Lấy token từ header Authorization
            authHeader = Request.Headers["Authorization"];
            if (string.IsNullOrEmpty(authHeader) || !authHeader.StartsWith("Bearer "))
            {
                return Unauthorized(new { message = "Missing or invalid Authorization header" });
            }

            token = authHeader["Bearer ".Length..].Trim();

            // Gọi hàm ValidateToken
            if (_jwt.ValidateToken(token, out ClaimsPrincipal? claims))
            {
                // Token hợp lệ và lấy thông tin userName trong payload
                var userName = claims?.FindFirst(c => c.Type == "Username")?.Value;

                string connectionString = _configuration.GetConnectionString("DefaultConnection");
                using SqlConnection connection = new(connectionString);
                if (connection.State == ConnectionState.Closed)
                {
                    await connection.OpenAsync();
                }

                using SqlCommand command = new();
                command.Connection = connection;
                command.CommandType = CommandType.StoredProcedure;

                // Nếu có truyền vào mã sách
                if (MaSach.HasValue)
                {
                    command.CommandText = "spLaySachByMaSach";
                    command.Parameters.AddWithValue("@MaSach", MaSach);
                }
                else
                {
                    command.CommandText = "spLaySach";
                }

                SqlDataAdapter da = new(command);
                DataTable dt = new();
                da.Fill(dt);

                // Server trả dữ liệu về cho client theo định dạng JSON
                return new ContentResult
                {
                    Content = JsonConvert.SerializeObject(new { data = dt }),
                    ContentType = "application/json",
                    StatusCode = 200
                };
            }
            else
            {
                // Token không hợp lệ
                return Unauthorized(new { message = "Token is invalid" });
            }
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message.ToString() });
        }
    }

    [HttpPost]
    public async Task<ActionResult> PostSach()
    {
        try
        {
            string authHeader = "";
            string token = "";

            // Lấy token từ header Authorization
            authHeader = Request.Headers["Authorization"];
            if (string.IsNullOrEmpty(authHeader) || !authHeader.StartsWith("Bearer "))
            {
                return Unauthorized(new { message = "Missing or invalid Authorization header" });
            }

            token = authHeader["Bearer ".Length..].Trim();

            // Gọi hàm ValidateToken
            if (_jwt.ValidateToken(token, out ClaimsPrincipal? claims))
            {
                // Token hợp lệ và lấy thông tin userName trong payload
                var userName = claims?.FindFirst(c => c.Type == "Username")?.Value;

                string connectionString = _configuration.GetConnectionString("DefaultConnection");
                using SqlConnection connection = new(connectionString);
                if (connection.State == ConnectionState.Closed)
                {
                    await connection.OpenAsync();
                }

                using SqlCommand command = new();
                command.Connection = connection;
                command.CommandType = CommandType.StoredProcedure;
                command.CommandText = "spCapNhatSach";

                // Lấy thông tin MaSach và TenSach trong Body
                using (var reader = new StreamReader(Request.Body))
                {
                    var requestBody = await reader.ReadToEndAsync();
                    var jsonObject = JObject.Parse(requestBody);

                    // Thêm các tham số cho thủ tục
                    command.Parameters.AddWithValue("@MaSach", jsonObject["TenSach"]?.Value<int>());
                    command.Parameters.AddWithValue("@TenSach", jsonObject["TenSach"]?.Value<string>());
                    command.Parameters.AddWithValue("Username", userName);
                }

                SqlDataAdapter da = new(command);
                DataTable dt = new();
                da.Fill(dt);

                // Server gửi thông báo về cho client
                // dt.Rows[0]["errMsg"] đây là dữ liệu mà trong câu thủ tục trả về               
                return new ContentResult
                {
                    Content = JsonConvert.SerializeObject(new { message = dt.Rows[0]["errMsg"] }),
                    ContentType = "application/json",
                    StatusCode = 200
                };
            }
            else
            {
                // Token không hợp lệ
                return Unauthorized(new { message = "Token is invalid" });
            }
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message.ToString() });
        }
    }
    [HttpPut("/update/{MaSach?}")]
    public async Task<ActionResult> UpdateSach(int? MaSach)
    {
        try
        {
            string authHeader = "";
            string token = "";

            // Lấy token từ header Authorization
            authHeader = Request.Headers["Authorization"];
            if (string.IsNullOrEmpty(authHeader) || !authHeader.StartsWith("Bearer "))
            {
                return Unauthorized(new { message = "Missing or invalid Authorization header" });
            }

            token = authHeader["Bearer ".Length..].Trim();

            // Gọi hàm ValidateToken
            if (_jwt.ValidateToken(token, out ClaimsPrincipal? claims))
            {
                // Token hợp lệ và lấy thông tin userName trong payload
                var userName = claims?.FindFirst(c => c.Type == "Username")?.Value;

                string connectionString = _configuration.GetConnectionString("DefaultConnection");
                using SqlConnection connection = new(connectionString);
                if (connection.State == ConnectionState.Closed)
                {
                    await connection.OpenAsync();
                }

                using SqlCommand command = new();
                command.Connection = connection;
                command.CommandType = CommandType.StoredProcedure;
                command.CommandText = "spCapNhatSach";

                // Lấy thông tin MaSach và TenSach trong Body
                using (var reader = new StreamReader(Request.Body))
                {
                    var requestBody = await reader.ReadToEndAsync();
                    var jsonObject = JObject.Parse(requestBody);

                    // Thêm các tham số cho thủ tục
                    command.Parameters.AddWithValue("@MaSach",MaSach);
                    command.Parameters.AddWithValue("@TenSach", jsonObject["TenSach"]?.Value<string>());
                    command.Parameters.AddWithValue("@Username", userName);
                }

                SqlDataAdapter da = new(command);
                DataTable dt = new();
                da.Fill(dt);

                // Server gửi thông báo về cho client
                // dt.Rows[0]["errMsg"] đây là dữ liệu mà trong câu thủ tục trả về               
                return new ContentResult
                {
                    Content = JsonConvert.SerializeObject(new { message = dt.Rows[0]["errMsg"] }),
                    ContentType = "application/json",
                    StatusCode = 200
                };
            }
            else
            {
                // Token không hợp lệ
                return Unauthorized(new { message = "Token is invalid" });
            }
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message.ToString() });
        }
    }


    [HttpDelete("delete")]
    public async Task<ActionResult> DeleteSach()
    {
        try
        {
            string authHeader = "";
            string token = "";

            // Lấy token từ header Authorization
            authHeader = Request.Headers["Authorization"];
            if (string.IsNullOrEmpty(authHeader) || !authHeader.StartsWith("Bearer "))
            {
                return Unauthorized(new { message = "Missing or invalid Authorization header" });
            }

            token = authHeader["Bearer ".Length..].Trim();

            // Gọi hàm ValidateToken
            if (_jwt.ValidateToken(token, out ClaimsPrincipal? claims))
            {
                // Token hợp lệ và lấy thông tin userName trong payload
                var userName = claims?.FindFirst(c => c.Type == "Username")?.Value;

                string connectionString = _configuration.GetConnectionString("DefaultConnection");
                using SqlConnection connection = new(connectionString);
                if (connection.State == ConnectionState.Closed)
                {
                    await connection.OpenAsync();
                }

                using SqlCommand command = new();
                command.Connection = connection;
                command.CommandType = CommandType.StoredProcedure;
                command.CommandText = "spAnSach";

                // Lấy thông tin MaSach và TenSach trong Body
                using (var reader = new StreamReader(Request.Body))
                {
                    var requestBody = await reader.ReadToEndAsync();
                    var jsonObject = JObject.Parse(requestBody);

                    // Thêm các tham số cho thủ tục
                    command.Parameters.AddWithValue("@MaSach", jsonObject["MaSach"]?.Value<int>());
                    command.Parameters.AddWithValue("@Username", userName);
                }

                SqlDataAdapter da = new(command);
                DataTable dt = new();
                da.Fill(dt);

                // Server gửi thông báo về cho client
                // dt.Rows[0]["errMsg"] đây là dữ liệu mà trong câu thủ tục trả về
                return new ContentResult
                {
                    Content = JsonConvert.SerializeObject(new { message = dt.Rows[0]["errMsg"] }),
                    ContentType = "application/json",
                    StatusCode = 200
                };
            }
            else
            {
                // Token không hợp lệ
                return Unauthorized(new { message = "Token is invalid" });
            }
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message.ToString() });
        }
    }
}