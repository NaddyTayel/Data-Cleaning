/*
	cleaning data with sql queries

*/

select *
from [NashvilleHousing ]
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize data formate

select SaleDateConverted
from [NashvilleHousing ]


update [NashvilleHousing ]
set SaleDate = CONVERT(date, SaleDate)

alter table [NashvilleHousing ]
add SaleDateConverted date;

update [NashvilleHousing ]
set SaleDateConverted = CONVERT(date, SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------------------------------

--populate property address date

select *
from [NashvilleHousing ]
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [NashvilleHousing ] a
join [NashvilleHousing ] b
	on a.ParcelID = b.ParcelID
	and a.PropertyAddress = b.PropertyAddress
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
from [NashvilleHousing ] a
join [NashvilleHousing ] b
	on a.ParcelID = b.ParcelID
	and a.PropertyAddress = b.PropertyAddress
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from [NashvilleHousing ]

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as adress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , len(PropertyAddress)) as address
from [NashvilleHousing ]

alter table [NashvilleHousing ]
add PropertySpilAddress varchar(255);

update [NashvilleHousing ]
set PropertySpilAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


alter table [NashvilleHousing ]
add PropertySpilCity varchar(255);

update [NashvilleHousing ]
set PropertySpilCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , len(PropertyAddress))


select *
from [NashvilleHousing ]

select OwnerAddress
from [NashvilleHousing ]
where OwnerAddress is not null

select 
PARSENAME(replace(OwnerAddress, ',','.'),3),
PARSENAME(replace(OwnerAddress, ',','.'),2),
PARSENAME(replace(OwnerAddress, ',','.'),1)
from [NashvilleHousing ]
where OwnerAddress is not null


alter table [NashvilleHousing ]
add OwnerSpilAddress varchar(255);

update [NashvilleHousing ]
set OwnerSpilAddress = PARSENAME(replace(OwnerAddress, ',','.'),3)


alter table [NashvilleHousing ]
add OwnerSpilCity varchar(255);

update [NashvilleHousing ]
set OwnerSpilCity = PARSENAME(replace(OwnerAddress, ',','.'),2)

alter table [NashvilleHousing ]
add StateSpilCity varchar(255);

update [NashvilleHousing ]
set StateSpilCity = PARSENAME(replace(OwnerAddress, ',','.'),1)


select *
from [NashvilleHousing ]


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant),count(SoldAsVacant)
from [NashvilleHousing ]
group by SoldAsVacant
order by 2 

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
end
from [NashvilleHousing ]

update [NashvilleHousing ]
set SoldAsVacant = 
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [NashvilleHousing ]
--order by ParcelID
)

select *
from RowNumCTE
where row_num >1
--Order by PropertyAddress


select *
from [NashvilleHousing ]



-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
select *
from [NashvilleHousing ]

alter table [NashvilleHousing ]
drop column TaxDistrict, OwnerAddress, PropertyAddress, SaleData






-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
