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

/*9. Показать тематики книг и сумму страниц всех книг по каждой из них.*/
select t."name", b.pages  from bookshop.themes t 
join bookshop.books b on b.themeid = t.id group by t."name" 






