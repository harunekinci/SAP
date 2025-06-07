Merhabalar bu dokümantasyonda fiori kurulumu için gerekli adım ve uygulamalar belirtilmiştir.

JDK Kurulması
İlk olarak oracle resmi sitesi üzerinden Jdk indirmemiz ve kurmamız gerekiyor.

Url : https://www.oracle.com/tr/java/technologies/javase/javase8-archive-downloads.html

Buradan işletim sisteminize uygun seçenekleri seçerek indirme işlemi yapmanız gerekiyor fakat öncesinde oracle üzerinde ücretsiz bir hesap oluşturmalısınız.

Orion Kurulması
Fiori projelerimizi geliştirebileceğimiz ayağa kaldırabileceğimiz uygulama olan orion`u kurmamız gerekiyor bunun için resmi sitesine gitmemiz gerekiyor.

![Adsız](https://github.com/user-attachments/assets/fa2a50ca-0409-4ba6-a4f9-42dc5922f716)

Url : SAP Development Tools (ondemand.com)

Bu sayfadan kırmızı alandaki link üzerinden indirilmelidir. Sonrasında zip içerisinde eclipse dosyasını c dizinine taşımamız gerekiyor.

C dizinindeki işlemler
1-) Dizinde sapwebide adlı bir klasör oluşturun.
2-) Oluşturduğunuz klasöre indirdiğiniz zipteki dosyaları taşıyın.

![image](https://github.com/user-attachments/assets/769b2a08-de75-407f-bb0e-eb8995160356)

![image](https://github.com/user-attachments/assets/dc6974ae-741a-4e22-ae31-84839b3cf7d0)

Burdan exe`yi ayağa kaldırıyoruz. Sonrasında herhangi bir tarayıcıya localhost:8080 yazıyoruz.
burdan hesap oluşturup giriş yapıyoruz.

 Sonrasında c dizinine gidiyoruz ve sapwebide -> eclipse -> config_master -> service.destination yolunu takip edip orda EMLAK.TXT oluşturun.
 Sonrasında size atılan config metnini buraya yazın.


  Config Metni:
			Description=EMLAK
			Type=HTTP
			Authentication=NoAuthentication
			Name=EMLAK
			ProxyType=OnPremise
			URL=http\://eksapfioridev.emlakkonut.com.tr\:8030
			WebIDEUsage=odata_abap,dev_abap,ui5_execute_abap
			WebIDESystem=EFD
			WebIDEEnabled=true

 Üstteki kodu txt dosyasına atıp kaydediyoruz sonrasında dosyanın txt uzantısını siliyoruz.

 Artık fiori sap bağlantısının config ayarları hazır.

![image](https://github.com/user-attachments/assets/2c781e02-5a4a-417c-8e4f-198a64f425d6)
