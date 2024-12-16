using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Data;
using System.Data.SqlClient;
using Newtonsoft.Json.Linq;

namespace back_end.Controllers;

[ApiController]
[Route("[controller]")]
public class UserController : ControllerBase
{
    private readonly IConfiguration _configuration;
    public UserController(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    [AllowAnonymous]
    [HttpPost(Name = "LOGIN")]
    [Route("login")]
    public async Task<IActionResult> UserCheckAuthentication()
    {
        try
        {
            if (Request.ContentLength == null || Request.ContentLength == 0)
            {
                return BadRequest(new { message = "Please input Username and Password!" });
            }

            string connectionString = _configuration.GetConnectionString("DefaultConnection");
            using SqlConnection connection = new(connectionString);
            if (connection.State == ConnectionState.Closed)
            {
                await connection.OpenAsync();
            }

            using SqlCommand command = new();
            command.Connection = connection;
            command.CommandType = CommandType.StoredProcedure;
            command.CommandText = "spUserLogin";

            using (var reader = new StreamReader(Request.Body))
            {
                var requestBody = await reader.ReadToEndAsync();

                // Parse the JSON content to a JObject
                var jsonObject = JObject.Parse(requestBody);
                if (jsonObject["Username"] == null)
                    return BadRequest(new { message = "Please input Username!" });

                command.Parameters.AddWithValue("@Username", jsonObject["Username"]?.Value<string>());
                command.Parameters.AddWithValue("@Password", jsonObject["Password"]?.Value<string>());
            }

            SqlDataAdapter da = new(command);
            DataTable dt = new();
            da.Fill(dt);

            var jwt = new Token();

            var tokenString = jwt.GenerateJwtToken(
              username: dt.Rows[0]["Username"].ToString()
            );

            return Ok(new { Token = tokenString });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message.ToString() });
        }
    }
}
