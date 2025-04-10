--Cleaning Data in SQL Queries
SELECT * 
FROM portfolioProject..NashvilleHousing

SELECT SaleDateConverted, CONVERT(date, saledate)
FROM portfolioProject..NashvilleHousing

UPDATE NashvilleHousing 
SET SaleDate = CONVERT(date, saledate)

ALTER TABLE  NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, saledate)	


-- Populate Property Address data

SELECT *
FROM portfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.ParcelID,b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
FROM portfolioProject..NashvilleHousing a
JOIN portfolioProject..NashvilleHousing b
on a.ParcelID =b.ParcelID
and a.[UniqueID ] <>  b.[UniqueID ]
where a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
FROM portfolioProject..NashvilleHousing a
JOIN portfolioProject..NashvilleHousing b
on a.ParcelID =b.ParcelID
and a.[UniqueID ] <>  b.[UniqueID ]
where a.PropertyAddress is null 

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM portfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,lEN(propertyaddress)) as Address
FROM portfolioProject..NashvilleHousing



ALTER TABLE  NashvilleHousing
ADD PropertySplitAddress NVARCHAR(225);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE  NashvilleHousing
ADD PropertySplitCity NVARCHAR(225);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,lEN(propertyaddress))

SELECT * 
FROM portfolioProject..NashvilleHousing


SELECT OwnerAddress
FROM portfolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM portfolioProject..NashvilleHousing

ALTER TABLE  NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(225);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE  NashvilleHousing
ADD OwnerSplitcity NVARCHAR(225);
UPDATE NashvilleHousing
SET OwnerSplitcity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE  NashvilleHousing
ADD OwnerSplitState NVARCHAR(225);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * 
FROM portfolioProject..NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
       WHEN SoldAsVacant= 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM portfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
       WHEN SoldAsVacant= 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


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

FROM portfolioProject..NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

-- Delete Unused Columns
ALTER TABLE portfolioProject..NashvilleHousing
DROP COLUMN taxDistrict,PropertyAddress, OwnerAddress

ALTER TABLE portfolioProject..NashvilleHousing
DROP COLUMN SaleDate

SELECT * 
FROM portfolioProject..NashvilleHousing