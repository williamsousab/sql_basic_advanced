-- (Query 1) Gênero dos leads
-- Colunas: gênero, leads(#)


select
	case
		when gen.gender = 'female' then 'Mulheres'
		when gen.gender = 'male' then 'Homens'
	end as "gênero",
	count(*) "leads(#)"

from sales.customers cus
left join temp_tables.ibge_genders gen
on UPPER(cus.first_name) = UPPER(gen.first_name)
group by gender


-- (Query 2) Status profissional dos leads
-- Colunas: status profissional, leads (%)

select
	case
		when professional_status = 'freelancer' then 'Freelancer'
		when professional_status = 'retired' then 'Aposentado(a)'
		when professional_status = 'clt' then 'CLT'
		when professional_status = 'self_employed' then 'Autônomo(a)'		
		when professional_status = 'other' then 'Outro'
		when professional_status = 'businessman' then 'Empresário(a)'
		when professional_status = 'civil_servant' then 'Funcionário(a) Público(a)'
		when professional_status = 'student' then 'Estudante'
	end as "status profissional",
	(count(*)::float)/(select count(*) from sales.customers) as "leads (%)"
from sales.customers
group by "status profissional"
order by "leads (%)"


-- (Query 3) Faixa etária dos leads
-- Colunas: faixa etária, leads (%)


select
	case
		when DATE_PART('year', AGE(birth_date)) between 0 and 20 then '0-20'
		when DATE_PART('year', AGE(birth_date)) between 20 and 40 then '20-40'
		when DATE_PART('year', AGE(birth_date)) between 40 and 60 then '40-60'
		when DATE_PART('year', AGE(birth_date)) between 60 and 80 then '60-80'
		else '80+' end "faixa etária",
		count(*)::float/(select count(*) from sales.customers) as "leads (%)"

from sales.customers
group by "faixa etária"
order by "faixa etária" desc


-- (Query 4) Faixa salarial dos leads
-- Colunas: faixa salarial, leads (%), ordem


select
	case
		when income between 0 and 5000 then '0-5000'
		when income between 5000 and 10000 then '5000-10000'
		when income between 10000 and 15000 then '10000-15000'
		when income between 15000 and 20000 then '15000-20000'
		else '20000+' end "faixa salárial",
		count(*)::float/(select count(*) from sales.customers) as "leads (%)",

	case
		when income between 0 and 5000 then 1
		when income between 5000 and 10000 then 2
		when income between 10000 and 15000 then 3
		when income between 15000 and 20000 then 4
		else 5 end "ordem"
		
from sales.customers
group by "faixa salárial", "ordem"
order by "ordem" desc


-- (Query 5) Classificação dos veículos visitados
-- Colunas: classificação do veículo, veículos visitados (#)
-- Regra de negócio: Veículos novos tem até 2 anos e seminovos acima de 2 anos


with
	classificacao_veiculos as (
	
		select
			fun.visit_page_date,
			pro.model_year,
			extract('year' from visit_page_date) - pro.model_year::int as idade_veiculo,
			case
				when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 'Novo'
				else 'Seminovo'
				end as "classificação do veículo"
		
		from sales.funnel as fun
		left join sales.products as pro
			on fun.product_id = pro.product_id	
	)

select
	"classificação do veículo",
	count(*) as "veículos visitados (#)"
from classificacao_veiculos
group by "classificação do veículo"
order by "classificação do veículo"



-- (Query 6) Idade dos veículos visitados
-- Colunas: Idade do veículo, veículos visitados (%), ordem

with
	faixa_de_idade_dos_veiculos as (
	
		select
			fun.visit_page_date,
			pro.model_year,
			extract('year' from visit_page_date) - pro.model_year::int as idade_veiculo,
			case
				when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 'até 2 anos'
				when (extract('year' from visit_page_date) - pro.model_year::int)<=4 then 'de 2 à 4 anos'
				when (extract('year' from visit_page_date) - pro.model_year::int)<=6 then 'de 4 à 6 anos'
				when (extract('year' from visit_page_date) - pro.model_year::int)<=8 then 'de 6 à 8 anos'
				when (extract('year' from visit_page_date) - pro.model_year::int)<=10 then 'de 8 à 10 anos'
				else 'acima de 10 anos'
				end as "idade do veículo",
			case
				when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 1
				when (extract('year' from visit_page_date) - pro.model_year::int)<=4 then 2
				when (extract('year' from visit_page_date) - pro.model_year::int)<=6 then 3
				when (extract('year' from visit_page_date) - pro.model_year::int)<=8 then 4
				when (extract('year' from visit_page_date) - pro.model_year::int)<=10 then 5
				else 6
				end as "ordem"

		from sales.funnel as fun
		left join sales.products as pro
			on fun.product_id = pro.product_id	
	)

select
	"idade do veículo",
	count(*)::float/(select count(*) from sales.funnel) as "veículos visitados (%)",
	ordem
from faixa_de_idade_dos_veiculos
group by "idade do veículo", ordem
order by ordem

-- (Query 7) Veículos mais visitados por marca
-- Colunas: brand, model, visitas (#)

select
	pro.brand,
	pro.model,
	count(*) as "visitas (#)"
	
from sales.funnel as fun
left join sales.products as pro
	on fun.product_id = pro.product_id
group by pro.brand, pro.model
order by pro.brand, pro.model, "visitas (#)"