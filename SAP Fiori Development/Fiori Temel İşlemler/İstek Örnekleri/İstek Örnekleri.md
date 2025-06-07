Bu sayfada oluşturduğunuz fiori servislerine nasıl istek atarsanız onun örnekleri paylaşılmıştır.

	• Verilen örneklerde entityset ve değişken adları sizin örneklerinizde farklı olabilir.
	• İstekler görseller ile desteklenmiştir buradaki yapılar size %100 uygun olmayabilir.
	• İstek atarken tarih alanı nullable seçilmelidir (segw->entity->properties).
	• Guid alan boş yollanamaz eğer alan boş ise 0`lı 8-4-4-4-12 formatta yollanmalıdır.

	1. Read Request
	
	İstek fiori makinesinden atılıyor ise;
	         /VekaletEkleSet(UsName='UTOSUN',RepName='UTOSUN')
	
	İstek fiori webten atılıyor ise;
	
	
![image](https://github.com/user-attachments/assets/1de9a7c2-9024-43ee-8d12-c9bc6e25b9c8)

![image](https://github.com/user-attachments/assets/c4396090-0aea-4769-9dc5-52d5918f00b5)

	________________________________________________________________________________
	
	1. Query Request
	
	İstek fiori makinesinden atılıyor ise;
	
	EntitySetName?$filter=IvCarrid eq 'AA'
	
İstek fiori webten atılıyor ise;

![image](https://github.com/user-attachments/assets/d1c93b56-9a3a-4bd7-9cd2-51867bee8039)

![image](https://github.com/user-attachments/assets/cb401e73-3349-4ca3-9cc1-df20bb2d8c8d)

![image](https://github.com/user-attachments/assets/49078f5e-b9d7-435d-90e9-c71aad6738d8)
