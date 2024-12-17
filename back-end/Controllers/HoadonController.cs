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
public class HoadonController : ControllerBase
{
    private readonly IConfiguration _configuration;
    private readonly Token _jwt;

    public HoadonController(IConfiguration configuration)
    {
        _configuration = configuration;
        _jwt = new Token();
    }

    // API: Lấy danh sách hóa đơn
    [HttpGet]
    public async Task<ActionResult> GetAllHoaDon()
    {
        try
        {
            string connectionString = _configuration.GetConnectionString("DefaultConnection");
            using SqlConnection connection = new(connectionString);
            await connection.OpenAsync();

            using SqlCommand command = new();
            command.Connection = connection;
            command.CommandType = CommandType.StoredProcedure;
            command.CommandText = "spGetAllHoaDon";

            SqlDataAdapter da = new(command);
            DataTable dt = new();
            da.Fill(dt);

            return new ContentResult
            {
                Content = JsonConvert.SerializeObject(new { data = dt }),
                ContentType = "application/json",
                StatusCode = 200
            };
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    // API: Lấy chi tiết hóa đơn theo ID
    [HttpGet("{MaHoaDon}")]
    public async Task<ActionResult> GetHoaDonDetails(int MaHoaDon)
    {
        try
        {
            string connectionString = _configuration.GetConnectionString("DefaultConnection");
            using SqlConnection connection = new(connectionString);
            await connection.OpenAsync();

            using SqlCommand command = new();
            command.Connection = connection;
            command.CommandType = CommandType.StoredProcedure;
            command.CommandText = "spGetCTHoaDon";
            command.Parameters.AddWithValue("@MaHoaDon", MaHoaDon);

            SqlDataAdapter da = new(command);
            DataTable dt = new();
            da.Fill(dt);

            return new ContentResult
            {
                Content = JsonConvert.SerializeObject(new { data = dt }),
                ContentType = "application/json",
                StatusCode = 200
            };
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    // API: Tạo hóa đơn mới
    [HttpPost]
    public async Task<ActionResult> CreateHoaDon()
    {
        try
        {
            string connectionString = _configuration.GetConnectionString("DefaultConnection");
            using SqlConnection connection = new(connectionString);
            await connection.OpenAsync();

            using SqlCommand command = new();
            command.Connection = connection;
            command.CommandType = CommandType.StoredProcedure;
            command.CommandText = "spCreateHoaDon";

            using var reader = new StreamReader(Request.Body);
            var requestBody = await reader.ReadToEndAsync();
            var jsonObject = JObject.Parse(requestBody);

            command.Parameters.AddWithValue("@UserID", jsonObject["UserID"]?.Value<int>());
            command.Parameters.AddWithValue("@OrderDetails", jsonObject["OrderDetails"]?.ToString());

            SqlDataAdapter da = new(command);
            DataTable dt = new();
            da.Fill(dt);

            return new ContentResult
            {
                Content = JsonConvert.SerializeObject(new { message = dt.Rows[0]["Message"], MaHoaDon = dt.Rows[0]["MaHoaDon"] }),
                ContentType = "application/json",
                StatusCode = 200
            };
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    // API: Cập nhật trạng thái hóa đơn
    [HttpPut("{MaHoaDon}/status")]
    public async Task<ActionResult> UpdateHoaDonStatus(int MaHoaDon, [FromBody] JObject body)
    {
        try
        {
            string connectionString = _configuration.GetConnectionString("DefaultConnection");
            using SqlConnection connection = new(connectionString);
            await connection.OpenAsync();

            using SqlCommand command = new();
            command.Connection = connection;
            command.CommandType = CommandType.StoredProcedure;
            command.CommandText = "spUpdateHoaDonStatus";

            command.Parameters.AddWithValue("@MaHoaDon", MaHoaDon);
            command.Parameters.AddWithValue("@Status", body["Status"]?.ToString());

            SqlDataAdapter da = new(command);
            DataTable dt = new();
            da.Fill(dt);

            return new ContentResult
            {
                Content = JsonConvert.SerializeObject(new { message = dt.Rows[0]["Message"] }),
                ContentType = "application/json",
                StatusCode = 200
            };
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    // API: Xóa chi tiết hóa đơn
    [HttpDelete("{MaHoaDon}/ct/{MaCTHoaDon}")]
    public async Task<ActionResult> DeleteCTHoaDon(int MaHoaDon, int MaCTHoaDon)
    {
        try
        {
            string connectionString = _configuration.GetConnectionString("DefaultConnection");
            using SqlConnection connection = new(connectionString);
            await connection.OpenAsync();

            using SqlCommand command = new();
            command.Connection = connection;
            command.CommandType = CommandType.StoredProcedure;
            command.CommandText = "spDeleteCTHoaDon";

            command.Parameters.AddWithValue("@MaHoaDon", MaHoaDon);
            command.Parameters.AddWithValue("@MaCTHoaDon", MaCTHoaDon);

            SqlDataAdapter da = new(command);
            DataTable dt = new();
            da.Fill(dt);

            return new ContentResult
            {
                Content = JsonConvert.SerializeObject(new { message = dt.Rows[0]["Message"] }),
                ContentType = "application/json",
                StatusCode = 200
            };
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
