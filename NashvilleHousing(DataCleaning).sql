/*

	Data Cleaning using SQL

*/
Select *
From PortfolioProjects.dbo.NashevillHousing

-- Standardize Date Format

Select Up_SaleDate
From PortfolioProjects.dbo.NashevillHousing

Alter Table NashevillHousing
Add Up_SaleDate Date;

Update NashevillHousing
Set Up_SaleDate = CONVERT(Date,SaleDate)



-- Populate Property Address data

Select t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress, ISNULL(t1.PropertyAddress, t2.PropertyAddress)
From PortfolioProjects.dbo.NashevillHousing t1
Join PortfolioProjects.dbo.NashevillHousing t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.[UniqueID ] <> t2.[UniqueID ]
where t1.PropertyAddress is NULL


Update t1
SET PropertyAddress = ISNULL(t1.PropertyAddress, t2.PropertyAddress)
From PortfolioProjects.dbo.NashevillHousing t1
Join PortfolioProjects.dbo.NashevillHousing t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.[UniqueID ] <> t2.[UniqueID ]
where t1.PropertyAddress is NULL

Select PropertyAddress
FROM PortfolioProjects.dbo.NashevillHousing


-- Breaking Address into Individual Columns(Address, City, States)

Select PropertyAddress
From PortfolioProjects.dbo.NashevillHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address, -- -1 is to remove the , from the output
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProjects.dbo.NashevillHousing


Alter Table NashevillHousing
Add new_PropertyAddress Nvarchar(255);

Update NashevillHousing
Set new_PropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashevillHousing
Add PropertyCity Nvarchar(255);

Update NashevillHousing
Set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select PropertyCity
From PortfolioProjects.dbo.NashevillHousing



Select OwnerAddress
From PortfolioProjects.dbo.NashevillHousing



-- Another Method Insted of using SubStrings
Select 
PARSENAME(Replace(OwnerAddress,',','.'), 3), -- ParseName only works with ".". So replace , with . 
 PARSENAME(Replace(OwnerAddress,',','.'), 2),
  PARSENAME(Replace(OwnerAddress,',','.'), 1)
From PortfolioProjects.dbo.NashevillHousing


Alter Table NashevillHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashevillHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)


Alter Table NashevillHousing
Add OwnerSplitCity Nvarchar(255);

Update NashevillHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)


Alter Table NashevillHousing
Add OwnerSplitState Nvarchar(255);

Update NashevillHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From PortfolioProjects.dbo.NashevillHousing



-- Change Y and N to Yes and NO


Select Distinct(SoldAsVacant)
From PortfolioProjects.dbo.NashevillHousing

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProjects.dbo.NashevillHousing


Update NashevillHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End




-- Remove Duplicates

With RowNumCTE as(
Select *,
	ROW_NUMBER() Over(
	Partition BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					)row_num
From PortfolioProjects.dbo.NashevillHousing
)
Delete
From RowNumCTE
Where row_num >1
--Order by PropertyAddress



-- Delete Unused Columns

Select *
From PortfolioProjects.dbo.NashevillHousing

Alter Table PortfolioProjects.dbo.NashevillHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProjects.dbo.NashevillHousing
Drop Column SaleDate


