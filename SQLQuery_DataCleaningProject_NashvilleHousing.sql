-- data cleaning project

select *
from PortfolioProjects..NashvilleHousing

-- Standardize Data Format

select SaleDate, CONVERT(Date, SaleDate) as FixedSaleDate
from PortfolioProjects..NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
add FixedSaleDate Date;

update dbo.NashvilleHousing
set FixedSaleDate = CONVERT(Date, SaleDate)

select FixedSaleDate
from PortfolioProjects..NashvilleHousing

-- populate propety address data

select *
from PortfolioProjects..NashvilleHousing
where PropertyAddress is null

select *
from PortfolioProjects..NashvilleHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) PropertyAddressFilled
from PortfolioProjects..NashvilleHousing a
join PortfolioProjects..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects..NashvilleHousing a
join PortfolioProjects..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

select PropertyAddress
from PortfolioProjects..NashvilleHousing
where PropertyAddress is null  --nothing shows that means there is no null values anymore

-- Breaking out Address into individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProjects..NashvilleHousing

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address1
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address2
from PortfolioProjects..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCitys Nvarchar(255);

update NashvilleHousing
set PropertySplitCitys = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select *
from PortfolioProjects..NashvilleHousing


select OwnerAddress
from PortfolioProjects..NashvilleHousing

select 
PARSENAME(replace(OwnerAddress,',','.'),3) as Address 
, PARSENAME(replace(OwnerAddress,',','.'), 2) as City
, PARSENAME(replace(OwnerAddress,',','.'), 1)as  State
from PortfolioProjects..NashvilleHousing

alter table NashvilleHousing
add Address Nvarchar(255);

update NashvilleHousing
set Address = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add City Nvarchar(255);

update NashvilleHousing
set City = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add State Nvarchar(255);

update NashvilleHousing
set State = PARSENAME(replace(OwnerAddress,',','.'),1)

select *
from PortfolioProjects..NashvilleHousing

-- change Y and N to Yes and No in "Solid as Vacant" field 

select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProjects..NashvilleHousing
group by SoldAsVacant
order by 2




select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
     end
from PortfolioProjects..NashvilleHousing


update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end

select *
from PortfolioProjects..NashvilleHousing

-- Removing Duplicates

with RowNumCTE as(
select *,
ROW_NUMBER() over (
	partition by ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	order by UniqueID
	) row_num
from PortfolioProjects..NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

with RowNumCTE as(
select *,
ROW_NUMBER() over (
	partition by ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	order by UniqueID
	) row_num
from PortfolioProjects..NashvilleHousing
--order by ParcelID
)
delete
from RowNumCTE
where row_num > 1

-- Delete Unused Columns

select *
from PortfolioProjects..NashvilleHousing

alter table PortfolioProjects..NashvilleHousing
DROP COLUMN TaxDistrict, PropertyAddress, OwnerAddress