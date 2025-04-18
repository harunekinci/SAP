Bir servisin çalışmadığı veya bir kullanıcının hata aldığı durumlarda servise ait error logları incelemek ve request body`i incelemek gerekir.

Error Log işlem koduna fiori sistemlerinden ulaşabiliriz.

Canlı Sistemden bu işlem koduna yetkiniz olmadığı takdirde xebaycol kullanıcısını kullanabilirsiniz.

	1. Sisteme Giriş Yapın
	2. /n/IWFND/ERROR_LOG  işlem kodunu açın.
Tarih, Saat, Servis adından hata olan satırı bulunuz.

![image](https://github.com/user-attachments/assets/300354af-21f7-4793-9af3-30b7a9edeb77)

Error text incelenmelidir, not implemented hatası çoğu zaman token almak için kullanılan servislerden kaynaklıdır.

Aşağıda kırmızı ile işaretlenen alanlardan request(iletilen) - response(gelen) metni görebilirsiniz.

	• Property bazlı hatalarda cache temizleme denenebilir.
	• Bazı hatalar abap program hatalarıdır.
	• Offset hataları gönderilen alan ile alakalıdır ( boş olabilir, uzunluk yetmeyebilir)
