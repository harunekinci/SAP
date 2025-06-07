Deep Entity Nedir ?

	• Deep Entity, ihtiyacı fonksiyon modül`de import ve export`un birden fazla olmasında read ve query`nin bu durum için uygun olmamasından ihtiyaç olarak doğan bağlama yapısıdır.
	
Örnek bir deep entity bağlama yazısı aşağıda paylaşılmıştır.
	
	https://medium.com/@tosun.umutt/sap-abap-deep-entity-i%CC%87le-servis-ba%C4%9Flama-ve-test-etme-89996c386b42 
	
	
Deep Entity projesi oluştururken önemli kurallardan bazıları aşağıdadır.

	1. Tüm İsimler Not Alınarak İlerlenmelidir.
	2. Projeyi başlanmadan önce hangi alanların tablo ve obje tipinde olacağı belirlenmelidir.
	3. İsimlendirmeler çok uzun olmamalıdır, problemler yaratabilir.
	4. MPC`de yapılan değişikler sonrası  DPC`ye geçmeden generate edilmelidir.
	5. DPC tarafında fonksiyon modüle verilen parametreler coresponding yapısı ile verilmelidir.
	Aksi durumda type conflit hatası alabilirsiniz.
	
	
