/*
Cleaning Data in SQL Queries
*/

--------------------------------------------------------------------------------------------------------------------------

SELECT *
FROM PortfolioProject2..NashvilleHousing

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject2..NashvilleHousing

ALTER TABLE PortfolioProject2..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject2..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM PortfolioProject2..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

--Join tables on parcelID since a matching parcelID means a matching address
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2..NashvilleHousing a
JOIN PortfolioProject2..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
	--If parcel ID is the same but uniqueID (row) is different, we want to populate the null parcelID with the neighboring value
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2..NashvilleHousing a
JOIN PortfolioProject2..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

--Worked!
SELECT *
FROM PortfolioProject2..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject2..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM PortfolioProject2..NashvilleHousing

--Add tables and update columns

ALTER TABLE PortfolioProject2..NashvilleHousing
ADD StreetAddress Nvarchar(255);

UPDATE PortfolioProject2..NashvilleHousing
SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject2..NashvilleHousing
ADD City Nvarchar(255);

UPDATE PortfolioProject2..NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Check
SELECT *
FROM PortfolioProject2..NashvilleHousing


--Owner Address using parsename
Select OwnerAddress
FROM PortfolioProject2..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject2..NashvilleHousing

ALTER TABLE PortfolioProject2..NashvilleHousing
ADD OwnerStreetAddress Nvarchar(255);
ALTER TABLE PortfolioProject2..NashvilleHousing
ADD OwnerCity Nvarchar(255);
ALTER TABLE PortfolioProject2..NashvilleHousing
ADD OwnerState Nvarchar(255);

UPDATE PortfolioProject2..NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
UPDATE PortfolioProject2..NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
UPDATE PortfolioProject2..NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Check
SELECT *
FROM PortfolioProject2..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject2..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--Case statement to change 'Y' to 'Yes' and 'N' to 'No'
SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject2..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM PortfolioProject2..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM PortfolioProject2..NashvilleHousing

ALTER TABLE PortfolioProject2..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

