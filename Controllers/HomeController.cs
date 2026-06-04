using System.Diagnostics;
using ApexAUTO_web.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace ApexAUTO_web.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        // 1. Veritabaný baðlantý adresimiz (Connection String)
        private string connectionString = @"Server=DESKTOP-8VUMRLO;Database=ApexAUTO;Trusted_Connection=True;TrustServerCertificate=True;";

        public IActionResult Index()
        {
            // Veritabanýndan çekeceðimiz araçlarý bu listenin içine dolduracaðýz
            List<Dictionary<string, string>> araclarListesi = new List<Dictionary<string, string>>();

            // 2. SQL Server ile baðlantý kuruyoruz
            using (SqlConnection baglanti = new SqlConnection(connectionString))
            {
                // Dün yazdýðýmýz View yapýsýný çaðýrýyoruz
                string sorgu = "SELECT Car_Brand, Car_Model, Car_Plate, Segment_Name, Daily_Fee, Car_State FROM vw_CarPricing";

                using (SqlCommand komut = new SqlCommand(sorgu, baglanti))
                {
                    baglanti.Open(); // Baðlantýyý aç

                    using (SqlDataReader okuyucu = komut.ExecuteReader())
                    {
                        // Veritabanýndaki tüm satýrlarý tek tek oku
                        while (okuyucu.Read())
                        {
                            var arac = new Dictionary<string, string>
                    {
                        { "Marka", okuyucu["Car_Brand"].ToString() },
                        { "Model", okuyucu["Car_Model"].ToString() },
                        { "Plaka", okuyucu["Car_Plate"].ToString() },
                        { "Segment", okuyucu["Segment_Name"].ToString() },
                        { "Fiyat", okuyucu["Daily_Fee"].ToString() },
                        { "Durum", okuyucu["Car_State"].ToString() }
                    };
                            araclarListesi.Add(arac);
                        }
                    }
                }
            }

            // 3. Veritabanýndan aldýðýmýz bu listeyi HTML sayfasýna (View'a) gönderiyoruz
            return View(araclarListesi);
        }
        [HttpPost]
        public IActionResult KiralamaEkle(int musteriID, int aracID, int subeID, int sigortaID, DateTime baslangic, DateTime bitis)
        {
            using (SqlConnection baglanti = new SqlConnection(connectionString))
            {
                // SQL Server'da yazdýðýmýz Stored Procedure adýný veriyoruz
                using (SqlCommand komut = new SqlCommand("sp_AddRental", baglanti))
                {
                    // Bu komutun bir düz metin deðil, Prosedür olduðunu C#'a bildiriyoruz
                    komut.CommandType = System.Data.CommandType.StoredProcedure;

                    // Formdan gelen verileri SQL parametrelerine eþliyoruz
                    komut.Parameters.AddWithValue("@CustomerID", musteriID);
                    komut.Parameters.AddWithValue("@CarID", aracID);
                    komut.Parameters.AddWithValue("@BranchID", subeID);
                    komut.Parameters.AddWithValue("@InsuranceID", sigortaID);
                    komut.Parameters.AddWithValue("@StartDate", baslangic);
                    komut.Parameters.AddWithValue("@FinishDate", bitis);

                    baglanti.Open();
                    komut.ExecuteNonQuery(); // SQL'deki prosedürü tetikler ve kaydeder
                }
            }

            // Ýþlem bittikten sonra sayfayý yenilemek için Index'e geri gönderiyoruz
            return RedirectToAction("Index");
        }


        public IActionResult Cars()
        {
            List<Dictionary<string, string>> araclarListesi = new List<Dictionary<string, string>>();

            using (SqlConnection baglanti = new SqlConnection(connectionString))
            {
                string sorgu = "SELECT Car_Brand, Car_Model, Car_Plate, Segment_Name, Daily_Fee, Car_State FROM vw_CarPricing";

                using (SqlCommand komut = new SqlCommand(sorgu, baglanti))
                {
                    baglanti.Open();
                    using (SqlDataReader okuyucu = komut.ExecuteReader())
                    {
                        while (okuyucu.Read())
                        {
                            var arac = new Dictionary<string, string>
                    {
                        { "Marka", okuyucu["Car_Brand"].ToString() },
                        { "Model", okuyucu["Car_Model"].ToString() },
                        { "Plaka", okuyucu["Car_Plate"].ToString() },
                        { "Segment", okuyucu["Segment_Name"].ToString() },
                        { "Fiyat", okuyucu["Daily_Fee"].ToString() },
                        { "Durum", okuyucu["Car_State"].ToString() }
                    };
                            araclarListesi.Add(arac);
                        }
                    }
                }
            }
            return View(araclarListesi);
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        // Booking Sayfasýný ve Kiralamalarý Getiren Fonksiyon
        public IActionResult Booking(string aramaMetni)
        {
            List<Dictionary<string, string>> kiralamalar = new List<Dictionary<string, string>>();

            using (SqlConnection baglanti = new SqlConnection(connectionString))
            {
                // Eðer arama kutusuna TC girildiyse Index tetiklensin diye WHERE Customers.TC_No filtrelemesi ekliyoruz
                string sorgu = "SELECT * FROM vw_RentalDetails";

                // Burasý TC Kimlik Ýndeksini (IX_Customers_TCNo) sunumda hocaya kanýtlayacaðýnýz yerdir!
                if (!string.IsNullOrEmpty(aramaMetni))
                {
                    sorgu = @"SELECT r.Rent_ID, c.Name + ' ' + c.Surname AS CustomerName, c.Phone_No, 
                             cr.Car_Brand + ' ' + cr.Car_Model AS CarInfo, cr.Car_Plate, 
                             b.Branch_Name, r.Rent_Start_Date, r.Rent_Finish_Date 
                      FROM Rental r
                      JOIN Customers c ON r.Customer_ID = c.Customer_ID
                      JOIN Cars cr ON r.CAR_ID = cr.Car_ID
                      JOIN Branches b ON r.Branch_ID = b.Branch_ID
                      WHERE c.TC_No = @tc";
                }

                using (SqlCommand komut = new SqlCommand(sorgu, baglanti))
                {
                    if (!string.IsNullOrEmpty(aramaMetni))
                    {
                        komut.Parameters.AddWithValue("@tc", aramaMetni);
                    }

                    baglanti.Open();
                    using (SqlDataReader okuyucu = komut.ExecuteReader())
                    {
                        while (okuyucu.Read())
                        {
                            var kiralama = new Dictionary<string, string>
                    {
                        { "RentID", okuyucu["Rent_ID"].ToString() },
                        { "Musteri", okuyucu["CustomerName"].ToString() },
                        { "Telefon", okuyucu["Phone_No"].ToString() },
                        { "Arac", okuyucu["CarInfo"].ToString() },
                        { "Plaka", okuyucu["Car_Plate"].ToString() },
                        { "Sube", okuyucu["Branch_Name"].ToString() },
                        { "Baslangic", Convert.ToDateTime(okuyucu["Rent_Start_Date"]).ToString("dd/MM/yyyy") },
                        { "Bitis", Convert.ToDateTime(okuyucu["Rent_Finish_Date"]).ToString("dd/MM/yyyy") }
                    };
                            kiralamalar.Add(kiralama);
                        }
                    }
                }
            }
            return View(kiralamalar);
        }

        // Araç Teslim Alýndýðýnda (Kayýt Silindiðinde) Tetiklenecek Fonksiyon
        [HttpPost]
        public IActionResult KiralamaSil(int rentID)
        {
            using (SqlConnection baglanti = new SqlConnection(connectionString))
            {
                string sorgu = "DELETE FROM Rental WHERE Rent_ID = @id";
                using (SqlCommand komut = new SqlCommand(sorgu, baglanti))
                {
                    komut.Parameters.AddWithValue("@id", rentID);
                    baglanti.Open();
                    komut.ExecuteNonQuery(); // DELETE iþlemiyle birlikte SQL'deki trg_MarkCarAsAvailable otomatik tetiklenir!
                }
            }
            return RedirectToAction("Booking");
        }

    }
}
