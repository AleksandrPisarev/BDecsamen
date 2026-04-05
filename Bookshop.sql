create schema Bookshop;

create table Bookshop.Countries (
	Id integer generated always as identity primary key,
	Name varchar(50) not null UNIQUE
);

create table Bookshop.Authors (
	Id integer generated always as identity primary key,
	Name varchar(255) not null,
	Surname varchar(255) not null,
	CountryId integer not null,
	foreign key (CountryId) references Bookshop.Countries(Id)
);

create table Bookshop.Themes (
	Id integer generated always as identity primary key,
	Name varchar(100) not null UNIQUE
);

create table Bookshop.Books (
	Id integer generated always as identity primary key,
	Name varchar(255) not null,
	Pages integer not null CHECK (Pages > 0),
	Price decimal(19,2) CHECK (Price > 0) not null,
	PublishDate date CHECK (PublishDate <= CURRENT_DATE) not null,
	AuthorId integer not null,
	ThemeId integer not null,
	foreign key (AuthorId) references Bookshop.Authors(Id),
	foreign key (ThemeId) references Bookshop.Themes(Id)
);

create table Bookshop.Shops (
	Id integer generated always as identity primary key,
	Name varchar(255) not null,
	CountryId integer not null,
	foreign key (CountryId) references Bookshop.Countries(Id)
);

create table Bookshop.Sales (
	Id integer generated always as identity primary key,
	Price decimal(19,2) CHECK (Price > 0) not null,
	Quantity integer not null CHECK (Quantity > 0),
	SaleDate  date CHECK (SaleDate <= CURRENT_DATE) DEFAULT CURRENT_DATE not null,
	BookId integer not null,
	ShopId integer not null,
	foreign key (BookId) references Bookshop.Books(Id),
	foreign key (ShopId) references Bookshop.Shops(Id)
);

/*1. Показать все книги, количество страниц в которых больше
500, но меньше 650.*/
select * from bookshop.books b  where b.pages > 500 and b.pages < 650;

/*2. Показать все книги, в которых первая буква названия либо
«А», либо «З».*/
select * from bookshop.books b where left (b."name", 1) = "А" or left (b."name", 1) = "З";

/*3. Показать все книги жанра «Детектив», количество проданных книг более 30 экземпляров.*/
select * from bookshop.books b 
join bookshop.themes t on b.themeid = t.id 
join bookshop.sales s on s.bookid = b.id
where t."name" = "Детектив" and s.quantity > 30;

/*4. Показать все книги, в названии которых есть слово «Microsoft но нет слова "Windows"*/
select * from bookshop.books b where b."name" ilike '%Microsoft%' and not b."name" ilike '%Windows%';

/*5. Показать все книги (название, тематика, полное имя автора в одной ячейке), цена одной страницы которых меньше 65 копеек.*/
select concat_ws(' | ', b."name", t."name", a."name", a.surname) as book_info from bookshop.books b 
join bookshop.themes t on b.themeid = t.id
join bookshop.authors a on b.authorid = a.id
join bookshop.sales s on s.bookid = b.id
where (s.price / b.pages) < 0,65;

/*6. Показать все книги, название которых состоит из 4 слов.*/
select * from bookshop.books b where array_length(regexp_split_to_array(trim(b."name"), '\s+'), 1) = 4;

/*7. Показать информацию о продажах в следующем виде:
▷ Название книги, но, чтобы оно не содержало букву «А».
▷ Тематика, но, чтобы не «Программирование».
▷ Автор, но, чтобы не «Герберт Шилдт».
▷ Цена, но, чтобы в диапазоне от 10 до 20 гривен.
▷ Количество продаж, но не менее 8 книг.
▷ Название магазина, который продал книгу, но он не должен быть в Украине или России.*/
select b."name" as "название книги", t."name" as "тематика", concat_ws(' | ', a."name", a.surname) as "автор", s.price, s.quantity, sh."name" as "магазин" from bookshop.sales s 
join bookshop.books b on s.bookid = b.id 
join bookshop.themes t on b.themeid = t.id 
join bookshop.authors a on b.authorid = a.id
join bookshop.shops sh on s.shopid = sh.id
join bookshop.countries c on sh.countryid = c.id 
where b."name" not ilike '%A%' and t."name" != 'Програмирование' and a."name" != 'Герберт' and a.surname != 'Шилдт' and s.price between 10 and 20 and s.quantity >= 8 and c."name" not in ('украина', 'Россия')

/*8. Показать следующую информацию в два столбца (числа в правом столбце приведены в качестве примера):
▷ Количество авторов: 14
▷ Количество книг: 47
▷ Средняя цена продажи: 85.43 грн.
▷ Среднее количество страниц: 650.6.*/
select 'количество авторов' as 'показатель', count(id)::text as 'значение' from bookshop.authors a
union all 
select 'количество книг', count(id)::text as from bookshop.books b 
union all 
select 'средняя цена продажи', round(SUM(s.price * s.quantity ) / SUM(s.quantity ), 2)::text || ' грн. ' from bookshop.sales s
union all 
select 'среднее количество страниц', round(AVG(b.pages), 1)::text from bookshop.books b

/*9. Показать тематики книг и сумму страниц всех книг по каждой из них.*/
select t."name", SUM(b.pages) from bookshop.themes t 
join bookshop.books b on b.themeid = t.id
group by t."name" 

/*10. Показать количество всех книг и сумму страниц этих книг по каждому из авторов.*/
select concat_ws(' | ', a."name", a.surname) as "автор", count(b.id), SUM(b.pages) from bookshop.authors a 
join bookshop.books b on b.authorid = a.id
group by a.id, a."name", a.surname

/*11. Показать книгу тематики «Программирование» с наибольшим количеством страниц.*/
select * from bookshop.books b 
join bookshop.themes t on b.themeid = t.id 
where t."name" = 'Програмирование'
order by b.pages desc limit 1

/*12. Показать среднее количество страниц по каждой тематике, которое не превышает 400.*/
select t."name", round(AVG(b.pages), 1) from bookshop.themes t 
join bookshop.books b on b.themeid = t.id 
group by t.id, t."name" 
having AVG(b.pages) <=  400

/*13. Показать сумму страниц по каждой тематике, учитывая
только книги с количеством страниц более 400, и чтобы
тематики были «Программирование», «Администрирование» и «Дизайн».*/
select t."name", SUM(b.pages) from bookshop.themes t
join bookshop.books b on b.themeid = t.id
where b.pages > 400 and t."name" in ('Програмирование', 'Администрирование', 'Дизайн')
group by t.id, t."name"

/*14. Показать информацию о работе магазинов: что, где, кем, когда и в каком количестве было продано.*/
select b."name" as "книга", c."name" as "страна", sh."name" as "магазин", s.saledate as "дата", s.quantity as "количество" from bookshop.shops sh 
join bookshop.countries c on sh.countryid = c.id 
join bookshop.sales s on s.shopid = sh.id 
join bookshop.books b on s.bookid = b.id 
order by s.saledate desc 

/*15. Показать самый прибыльный магазин.*/
select sh."name", SUM(s.price * s.quantity) as "прибыль" from bookshop.shops sh 
join bookshop.sales s on s.shopid = sh.id  
group by sh.id, sh."name"
order by "прибыль" desc limit 1


